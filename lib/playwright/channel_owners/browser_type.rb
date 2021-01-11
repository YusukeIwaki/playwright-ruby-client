module Playwright
  define_channel_owner :BrowserType do
    def name
      @initializer['name']
    end

    def executable_path
      @initializer['executablePath']
    end

    def launch(options, &block)
      resp = @channel.send_message_to_server('launch', options.compact)
      browser = ChannelOwners::Browser.from(resp)

      if block
        begin
          block.call(browser)
        ensure
          browser.close
        end
      else
        browser
      end
    end
  end
end
