module Playwright
  define_channel_owner :BrowserType do
    include Utils::PrepareBrowserContextOptions

    def name
      @initializer['name']
    end

    def executable_path
      @initializer['executablePath']
    end

    def launch(options, &block)
      resp = @channel.send_message_to_server('launch', options.compact)
      browser = ChannelOwners::Browser.from(resp)
      return browser unless block

      begin
        block.call(browser)
      ensure
        browser.close
      end
    end

    def launch_persistent_context(userDataDir, **options, &block)
      params = options.dup
      prepare_browser_context_options(params)
      params['userDataDir'] = userDataDir

      resp = @channel.send_message_to_server('launchPersistentContext', params.compact)
      context = ChannelOwners::Browser.from(resp)
      return context unless block

      begin
        block.call(context)
      ensure
        context.close
      end
    end

    def connect_over_cdp(endpointURL, headers: nil, slowMo: nil, timeout: nil, &block)
      raise 'Connecting over CDP is only supported in Chromium.' unless name == 'chromium'

      params = {
        sdkLanguage: 'ruby',
        endpointURL: endpointURL,
        headers: headers,
        slowMo: slowMo,
        timeout: timeout,
      }.compact

      if headers
        params[:headers] = HttpHeaders.new(headers).as_serialized
      end

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
