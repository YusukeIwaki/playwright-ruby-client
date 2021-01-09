module Playwright
  define_channel_owner :BrowserType do
    def name
      @initializer['name']
    end

    def executable_path
      @initializer['executablePath']
    end

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
