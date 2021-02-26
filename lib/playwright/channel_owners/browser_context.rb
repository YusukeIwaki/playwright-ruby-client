module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_browser_context.py
  define_channel_owner :BrowserContext do
    include Utils::Errors::SafeCloseError
    attr_accessor :browser
    attr_writer :owner_page, :options

    private def after_initialize
      @pages = Set.new
      @bindings = {}
      @timeout_settings = TimeoutSettings.new

      @channel.on('bindingCall', ->(params) { on_binding(ChannelOwners::BindingCall.from(params['binding'])) })
      @channel.once('close', ->(_) { on_close })
      @channel.on('page', ->(params) { on_page(ChannelOwners::Page.from(params['page']) )})
      @channel.on('route', ->(params) {
        on_route(ChannelOwners::Route.from(params['route']), ChannelOwners::Request.from(params['request']))
      })
    end

    private def on_page(page)
      page.send(:update_browser_context, self)
      @pages << page
      emit(Events::BrowserContext::Page, page)
    end

    private def on_route(route, request)
      # @routes.each ...
      route.continue_
    end

    private def on_binding(binding_call)
      func = @binding[binding_call.name]
      if func
        binding_call.call(func)
      end
    end

    def set_default_navigation_timeout(timeout)
      @timeout_settings.default_navigation_timeout = timeout
      @channel.send_message_to_server('setDefaultNavigationTimeoutNoReply', timeout: timeout)
    end

    def set_default_timeout(timeout)
      @timeout_settings.default_timeout = timeout
      @channel.send_message_to_server('setDefaultTimeoutNoReply', timeout: timeout)
    end

    def pages
      @pages.to_a
    end

    # @returns [Playwright::Page]
    def new_page
      raise 'Please use browser.new_context' if @owner_page
      resp = @channel.send_message_to_server('newPage')
      ChannelOwners::Page.from(resp)
    end

    def cookies(urls: nil)
      target_urls =
        if urls.nil?
          []
        elsif urls.is_a?(Enumerable)
          urls
        else
          [urls]
        end
      @channel.send_message_to_server('cookies', urls: urls)
    end

    def add_cookies(cookies)
      @channel.send_message_to_server('addCookies', cookies: cookies)
    end

    def clear_cookies
      @channel.send_message_to_server('clearCookies')
    end

    def grant_permissions(permissions, origin: nil)
      params = {
        permissions: permissions,
        origin: origin,
      }.compact
      @channel.send_message_to_server('grantPermissions', params)
    end

    def clear_permissions
      @channel.send_message_to_server('clearPermissions')
    end

    def set_geolocation(geolocation)
      @channel.send_message_to_server('setGeolocation', geolocation: geolocation)
    end

    def set_extra_http_headers(headers)
      @channel.send_message_to_server('setExtraHTTPHeaders',
        headers: HttpHeaders.new(headers).as_serialized)
    end

    def set_offline(offline)
      @channel.send_message_to_server('setOffline', offline: offline)
    end

    def add_init_script(path: nil, script: nil)
      source =
        if path
          File.read(path)
        elsif script
          script
        else
          raise ArgumentError.new('Either path or script parameter must be specified')
        end

      @channel.send_message_to_server('addInitScript', source: script)
      nil
    end

    def expose_binding(name, callback, handle: nil)
      if @pages.any? { |page| page.send(:has_bindings?, name) }
        raise ArgumentError.new("Function \"#{name}\" has been already registered in one of the pages")
      end
      if @bindings.key?(name)
        raise ArgumentError.new("Function \"#{name}\" has been already registered")
      end
      params = {
        name: name,
        needsHandle: handle,
      }.compact
      @bindings[name] = callback
      @channel.send_message_to_server('exposeBinding', params)
    end

    def expose_function(name, callback)
      expose_binding(name, ->(_source, *args) { callback.call(*args) }, )
    end

    def expect_event(event, predicate: nil, timeout: nil, &block)
      wait_helper = WaitHelper.new
      wait_helper.reject_on_timeout(timeout || @timeout_settings.timeout, "Timeout while waiting for event \"#{event}\"")
      wait_helper.wait_for_event(self, event, predicate: predicate)

      block&.call

      wait_helper.promise.value!
    end

    private def on_close
      @closed_or_closing = true
      @browser&.send(:remove_context, self)
      emit(Events::BrowserContext::Close)
    end

    def close
      return if @closed_or_closing
      @closed_or_closing = true
      @channel.send_message_to_server('close')
      nil
    rescue => err
      raise unless safe_close_error?(err)
    end

    def pause
      @channel.send_message_to_server('pause')
    end

    def expect_page(predicate: nil, timeout: nil)
      params = {
        predicate: predicate,
        timeout: timeout,
      }.compact
      expect_event(Events::BrowserContext::Page, params)
    end

    # called from Page#on_close with send(:remove_page, page), so keep private
    private def remove_page(page)
      @pages.delete(page)
    end

    # called from Page with send(:_timeout_settings), so keep private.
    private def _timeout_settings
      @timeout_settings
    end
  end
end
