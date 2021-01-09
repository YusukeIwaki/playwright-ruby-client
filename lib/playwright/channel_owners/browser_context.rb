module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_browser_context.py
  define_channel_owner :BrowserContext do
    attr_writer :browser, :owner_page, :options

    # @returns [Playwright::Page]
    def new_page
      raise 'Please use browser.new_context' if @owner_page
      page = @channel.send_message_to_server('newPage')
      PlaywrightApi.from_channel_owner(page)
    end
  end
end
