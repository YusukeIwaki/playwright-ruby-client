module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_browser.py
  define_channel_owner :Browser do
    include Utils::Errors::SafeCloseError
    include Utils::PrepareBrowserContextOptions

    private def after_initialize
      @contexts = Set.new
      @channel.on('close', method(:on_close))
    end

    def contexts
      @contexts.to_a
    end

    def connected?
      @connected
    end

    def new_context(**options, &block)
      params = options.dup
      prepare_browser_context_options(params)

      resp = @channel.send_message_to_server('newContext', params.compact)
      context = ChannelOwners::BrowserContext.from(resp)
      @contexts << context
      context.browser = self
      context.options = params

      if block
        begin
          block.call(context)
        ensure
          context.close
        end
      else
        context
      end
    end

    def new_page(**options)
      context = new_context(**options)
      page = context.new_page
      page.owned_context = context
      context.owner_page = page
      page
    end

    def close
      return if @closed_or_closing
      @closed_or_closing = true
      @channel.send_message_to_server('close')
      nil
    rescue => err
      raise unless safe_close_error?(err)
    end

    def version
      @initializer['version']
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
      emit(Events::Browser::Disconnected)
      @closed_or_closing = false
    end

    # called from BrowserContext#on_close with send(:remove_context), so keep private.
    private def remove_context(context)
      @contexts.delete(context)
    end
  end
end
