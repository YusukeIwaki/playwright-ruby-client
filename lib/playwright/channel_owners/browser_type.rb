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

    def connect_over_cdp(endpointURL, slowMo: nil, timeout: nil, &block)
      raise 'Connecting over CDP is only supported in Chromium.' unless name == 'chromium'

      params = {
        sdkLanguage: 'ruby',
        endpointURL: endpointURL,
        slowMo: slowMo,
        timeout: timeout,
      }.compact
      result = @channel.send_message_to_server_result('connectOverCDP', params)
      browser = ChannelOwners::Browser.from(result['browser'])
      browser.send(:update_as_remote)

      if result['defaultContext']
        context = ChannelOwners::BrowserContext.from(result['defaultContext'])
        browser.send(:add_context, context)
      end

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
