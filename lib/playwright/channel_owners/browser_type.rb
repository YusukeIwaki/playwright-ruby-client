module Playwright
  define_channel_owner :BrowserType do
    define_initializer_reader \
      name: 'name',
      executable_path: 'executablePath'

    def launch(options, &block)
      browser = @channel.send_message_to_server('launch', options.compact)

      if block
        browser_api = ::Playwright::PlaywrightApi.from_channel_owner(browser)
        begin
          block.call(browser_api)
        ensure
          browser.close
        end
      else
        browser
      end
    end
  end
end
