module Playwright
  define_channel_owner :AndroidDevice do
    include Utils::PrepareBrowserContextOptions

    def serial
      @initializer['serial']
    end

    def model
      @initializer['model']
    end

    def shell(command)
      resp = @channel.send_message_to_server('shell', command: command)
      Base64.strict_decode64(resp)
    end

    def close
      @channel.send_message_to_server('close')
      emit(Events::AndroidDevice::Close)
    end

    def launch_browser(
          pkg: nil,
          acceptDownloads: nil,
          bypassCSP: nil,
          colorScheme: nil,
          deviceScaleFactor: nil,
          extraHTTPHeaders: nil,
          geolocation: nil,
          hasTouch: nil,
          httpCredentials: nil,
          ignoreHTTPSErrors: nil,
          isMobile: nil,
          javaScriptEnabled: nil,
          locale: nil,
          logger: nil,
          offline: nil,
          permissions: nil,
          proxy: nil,
          recordHar: nil,
          recordVideo: nil,
          storageState: nil,
          timezoneId: nil,
          userAgent: nil,
          videoSize: nil,
          videosPath: nil,
          viewport: nil,
          &block)
      params = {
        pkg: pkg,
        acceptDownloads: acceptDownloads,
        bypassCSP: bypassCSP,
        colorScheme: colorScheme,
        deviceScaleFactor: deviceScaleFactor,
        extraHTTPHeaders: extraHTTPHeaders,
        geolocation: geolocation,
        hasTouch: hasTouch,
        httpCredentials: httpCredentials,
        ignoreHTTPSErrors: ignoreHTTPSErrors,
        isMobile: isMobile,
        javaScriptEnabled: javaScriptEnabled,
        locale: locale,
        logger: logger,
        offline: offline,
        permissions: permissions,
        proxy: proxy,
        recordHar: recordHar,
        recordVideo: recordVideo,
        storageState: storageState,
        timezoneId: timezoneId,
        userAgent: userAgent,
        videoSize: videoSize,
        videosPath: videosPath,
        viewport: viewport,
      }.compact
      prepare_browser_context_options(params)

      resp = @channel.send_message_to_server('launchBrowser', params)
      context = ChannelOwners::BrowserContext.from(resp)

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
  end
end
