module Playwright
  define_channel_owner :AndroidDevice do
    include Utils::PrepareBrowserContextOptions

    private def after_initialize
      @input = AndroidInputImpl.new(@channel)
    end

    attr_reader :input

    def serial
      @initializer['serial']
    end

    def model
      @initializer['model']
    end

    private def to_regex(value)
      case value
      when nil
        nil
      when Regexp
        value
      else
        Regexp.new("^#{value}$")
      end
    end

    private def to_selector_channel(selector)
      {
        checkable: selector[:checkable],
        checked: selector[:checked],
        clazz: to_regex(selector[:clazz]),
        pkg: to_regex(selector[:pkg]),
        desc: to_regex(selector[:desc]),
        res: to_regex(selector[:res]),
        text: to_regex(selector[:text]),
        clickable: selector[:clickable],
        depth: selector[:depth],
        enabled: selector[:enabled],
        focusable: selector[:focusable],
        focused: selector[:focused],
        hasChild: selector[:hasChild] ? { selector: to_selector_channel(selector[:hasChild][:selector]) } : nil,
        hasDescendant: selector[:hasDescendant] ? {
          selector: to_selector_channel(selector[:hasDescendant][:selector]),
          maxDepth: selector[:hasDescendant][:maxDepth],
        } : nil,
        longClickable: selector[:longClickable],
        scrollable: selector[:scrollable],
        selected: selector[:selected],
      }.compact
    end

    def tap_on(selector, duration: nil, timeout: nil)
      params = {
        selector: to_selector_channel(selector),
        duration: duration,
        timeout: timeout,
      }.compact
      @channel.send_message_to_server('tap', params)
    end

    def info(selector)
      @channel.send_message_to_server('info', selector: to_selector_channel(selector))
    end

    def tree
      @channel.send_message_to_server('tree')
    end

    def screenshot(path: nil)
      encoded_binary = @channel.send_message_to_server('screenshot')
      decoded_binary = Base64.strict_decode64(encoded_binary)
      if path
        File.open(path, 'wb') do |f|
          f.write(decoded_binary)
        end
      end
      decoded_binary
    end

    def close
      @channel.send_message_to_server('close')
      emit(Events::AndroidDevice::Close)
    end

    def shell(command)
      resp = @channel.send_message_to_server('shell', command: command)
      Base64.strict_decode64(resp)
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
          noViewport: nil,
          offline: nil,
          permissions: nil,
          proxy: nil,
          record_har_omit_content: nil,
          record_har_path: nil,
          record_video_dir: nil,
          record_video_size: nil,
          storageState: nil,
          timezoneId: nil,
          userAgent: nil,
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
        noViewport: noViewport,
        offline: offline,
        permissions: permissions,
        proxy: proxy,
        record_har_omit_content: record_har_omit_content,
        record_har_path: record_har_path,
        record_video_dir: record_video_dir,
        record_video_size: record_video_size,
        storageState: storageState,
        timezoneId: timezoneId,
        userAgent: userAgent,
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
