module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_browser_context.py
  define_channel_owner :BrowserContext do
    include Utils::Errors::SafeCloseError
    attr_accessor :browser
    attr_writer :owner_page, :options
    attr_reader :tracing

    private def after_initialize
      @pages = Set.new
      @routes = []
      @bindings = {}
      @timeout_settings = TimeoutSettings.new
      @background_pages = Set.new

      @tracing = TracingImpl.new(@channel, self)
      @channel.on('bindingCall', ->(params) { on_binding(ChannelOwners::BindingCall.from(params['binding'])) })
      @channel.once('close', ->(_) { on_close })
      @channel.on('page', ->(params) { on_page(ChannelOwners::Page.from(params['page']) )})
      @channel.on('route', ->(params) {
        on_route(ChannelOwners::Route.from(params['route']), ChannelOwners::Request.from(params['request']))
      })
      @channel.on('backgroundPage', ->(params) {
        on_background_page(ChannelOwners::Page.from(params['page']))
      })
      @channel.on('request', ->(params) {
        on_request(
          ChannelOwners::Request.from(params['request']),
          ChannelOwners::Request.from_nullable(params['page']),
        )
      })
      @channel.on('requestFailed', ->(params) {
        on_request_failed(
          ChannelOwners::Request.from(params['request']),
          params['responseEndTiming'],
          params['failureText'],
          ChannelOwners::Request.from_nullable(params['page']),
        )
      })
      @channel.on('requestFinished', ->(params) {
        on_request_finished(
          ChannelOwners::Request.from(params['request']),
          params['responseEndTiming'],
          ChannelOwners::Request.from_nullable(params['page']),
        )
      })
      @channel.on('response', ->(params) {
        on_response(
          ChannelOwners::Response.from(params['response']),
          ChannelOwners::Request.from_nullable(params['page']),
        )
      })

      @closed_promise = Concurrent::Promises.resolvable_future
    end

    private def on_page(page)
      @pages << page
      emit(Events::BrowserContext::Page, page)
      page.send(:emit_popup_event_from_browser_context)
    end

    private def on_background_page(page)
      @background_pages << page
      emit(Events::BrowserContext::BackgroundPage, page)
    end

    private def on_route(route, request)
      # It is not desired to use PlaywrightApi.wrap directly.
      # However it is a little difficult to define wrapper for `handler` parameter in generate_api.
      # Just a workaround...
      wrapped_route = PlaywrightApi.wrap(route)
      wrapped_request = PlaywrightApi.wrap(request)

      if @routes.none? { |handler_entry| handler_entry.handle(wrapped_route, wrapped_request) }
        route.continue
      end
    end

    private def on_binding(binding_call)
      func = @bindings[binding_call.name]
      if func
        binding_call.call_async(func)
      end
    end

    private def on_request_failed(request, response_end_timing, failure_text, page)
      request.send(:update_failure_text, failure_text)
      request.send(:update_response_end_timing, response_end_timing)
      emit(Events::BrowserContext::RequestFailed, request)
      page&.emit(Events::Page::RequestFailed, request)
    end

    private def on_request_finished(request, response_end_timing, page)
      request.send(:update_response_end_timing, response_end_timing)
      emit(Events::BrowserContext::RequestFinished, request)
      page&.emit(Events::Page::RequestFinished, request)
    end

    private def on_request(request, page)
      emit(Events::BrowserContext::Request, request)
      page&.emit(Events::Page::Request, request)
    end

    private def on_response(response, page)
      emit(Events::BrowserContext::Response, response)
      page&.emit(Events::Page::Response, response)
    end

    def background_pages
      @background_pages.to_a
    end

    def new_cdp_session(page)
      resp = @channel.send_message_to_server('newCDPSession', page: page.channel)
      ChannelOwners::CDPSession.from(resp)
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
    def new_page(&block)
      raise 'Please use browser.new_context' if @owner_page
      resp = @channel.send_message_to_server('newPage')
      page = ChannelOwners::Page.from(resp)
      return page unless block

      begin
        block.call(page)
      ensure
        page.close
      end
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

    def route(url, handler)
      entry = RouteHandlerEntry.new(url, base_url, handler)
      @routes.unshift(entry)
      if @routes.count >= 1
        @channel.send_message_to_server('setNetworkInterceptionEnabled', enabled: true)
      end
    end

    def unroute(url, handler: nil)
      @routes.reject! do |handler_entry|
        handler_entry.same_value?(url: url, handler: handler)
      end
      if @routes.count == 0
        @channel.send_message_to_server('setNetworkInterceptionEnabled', enabled: false)
      end
    end

    def expect_event(event, predicate: nil, timeout: nil, &block)
      wait_helper = WaitHelper.new
      wait_helper.reject_on_timeout(timeout || @timeout_settings.timeout, "Timeout while waiting for event \"#{event}\"")
      wait_helper.wait_for_event(self, event, predicate: predicate)

      block&.call

      wait_helper.promise.value!
    end

    private def on_close
      @browser&.send(:remove_context, self)
      emit(Events::BrowserContext::Close)
      @closed_promise.fulfill(true)
    end

    def close
      @channel.send_message_to_server('close')
      @closed_promise.value!
      nil
    rescue => err
      raise unless safe_close_error?(err)
    end

    # REMARK: enable_debug_console is playwright-ruby-client specific method.
    def enable_debug_console!
      # Ruby is not supported in Playwright officially,
      # and causes error:
      #
      #  Error:
      #  ===============================
      #  Unsupported language: 'ruby'
      #  ===============================
      #
      # So, launch inspector as Python app.
      # NOTE: This should be used only for Page#pause at this moment.
      @channel.send_message_to_server('recorderSupplementEnable', language: :python)
      @debug_console_enabled = true
    end

    class DebugConsoleNotEnabledError < StandardError
      def initialize
        super('Debug console should be enabled in advance, by calling `browser_context.enable_debug_console!`')
      end
    end

    def pause
      unless @debug_console_enabled
        raise DebugConsoleNotEnabledError.new
      end
      @channel.send_message_to_server('pause')
    end

    def storage_state(path: nil)
      @channel.send_message_to_server_result('storageState', {}).tap do |result|
        if path
          File.open(path, 'w') do |f|
            f.write(JSON.dump(result))
          end
        end
      end
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

    private def remove_background_page(page)
      @background_pages.delete(page)
    end

    # called from Page with send(:_timeout_settings), so keep private.
    private def _timeout_settings
      @timeout_settings
    end

    private def has_record_video_option?
      @options.key?(:recordVideo)
    end

    private def base_url
      @options[:baseURL]
    end
  end
end
