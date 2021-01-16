module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_browser.py
  define_channel_owner :Browser do
    include Utils::Errors::SafeCloseError

    def after_initialize
      @contexts = Set.new
      @channel.on('close', method(:on_close))
    end

    def contexts
      @contexts.to_a
    end

    def connected?
      @connected
    end

    def new_context(**options)
      params = options.dup
      # @see https://github.com/microsoft/playwright/blob/5a2cfdbd47ed3c3deff77bb73e5fac34241f649d/src/client/browserContext.ts#L265
      if params[:viewport] == 0
        params.delete(:viewport)
        params[:noDefaultViewport] = true
      end
      if params[:extraHTTPHeaders]
        # TODO
      end
      if params[:storageState].is_a?(String)
        params[:storageState] = JSON.parse(File.read(params[:storageState]))
      end

      resp = @channel.send_message_to_server('newContext', params.compact)
      context = ChannelOwners::BrowserContext.from(resp)
      @contexts << context
      context.browser = self
      context.options = params
      context
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
