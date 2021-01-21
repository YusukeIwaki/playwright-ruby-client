module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_browser_context.py
  define_channel_owner :BrowserContext do
    include Utils::Errors::SafeCloseError
    attr_writer :browser, :owner_page, :options

    def after_initialize
      @pages = Set.new

      @channel.once('close', ->(_) { on_close })
      @channel.on('page', ->(hash) { on_page(ChannelOwners::Page.from(hash['page']) )})
    end

    private def on_page(page)
      page.send(:update_browser_context, self)
      @pages << page
      emit(Events::BrowserContext::Page, page)
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
