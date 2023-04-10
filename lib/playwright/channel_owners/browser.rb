module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_browser.py
  define_channel_owner :Browser do
    include Utils::Errors::SafeCloseError
    include Utils::PrepareBrowserContextOptions

    private def after_initialize
      @browser_type = @parent
      @connected = true
      @closed_or_closing = false
      @should_close_connection_on_close = false

      @contexts = Set.new
      @channel.on('close', method(:on_close))
    end

    def contexts
      @contexts.to_a
    end

    def browser_type
      @browser_type
    end

    def connected?
      @connected
    end

    def new_context(**options, &block)
      params = options.dup
      prepare_browser_context_options(params)

      resp = @channel.send_message_to_server('newContext', params.compact)
      context = ChannelOwners::BrowserContext.from(resp)
      @browser_type.send(:did_create_context, context, params)
      return context unless block

      begin
        block.call(context)
      ensure
        context.close
      end
    end

    def new_page(**options, &block)
      context = new_context(**options)
      page = context.new_page
      page.owned_context = context
      context.owner_page = page

      return page unless block

      begin
        block.call(page)
      ensure
        page.close
      end
    end

    private def update_browser_type(browser_type)
      @browser_type = browser_type
    end

    def close
      return if @closed_or_closing
      @closed_or_closing = true
      @channel.send_message_to_server('close')
      if @should_close_connection_on_close
        @connection.stop
      end
      nil
    rescue => err
      raise unless safe_close_error?(err)
    end

    def version
      @initializer['version']
    end

    def new_browser_cdp_session
      resp = @channel.send_message_to_server('newBrowserCDPSession')
      ChannelOwners::CDPSession.from(resp)
    end

    def start_tracing(page: nil, categories: nil, path: nil, screenshots: nil)
      params = {
        page: page&.channel,
        categories: categories,
        path: path,
        screenshots: screenshots,
      }.compact

      @channel.send_message_to_server('startTracing', params)
    end

    def stop_tracing
      encoded_binary = @channel.send_message_to_server("stopTracing")
      return Base64.strict_decode64(encoded_binary)
    end

    private def on_close(_ = {})
      @connected = false
      emit(Events::Browser::Disconnected, self)
      @closed_or_closing = true
    end

    # called from BrowserContext#initialize, BrowserType#connectOverCDP
    private def add_context(context)
      @contexts << context
    end

    private def should_close_connection_on_close!
      @should_close_connection_on_close = true
    end

    # called from BrowserContext#on_close with send(:remove_context), so keep private.
    private def remove_context(context)
      @contexts.delete(context)
    end
  end
end
