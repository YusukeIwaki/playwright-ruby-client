module Playwright
  define_channel_owner :Playwright do
    def chromium
      @chromium ||= ::Playwright::ChannelOwners::BrowserType.from(@initializer['chromium'])
    end

    def firefox
      @firefox ||= ::Playwright::ChannelOwners::BrowserType.from(@initializer['firefox'])
    end

    def webkit
      @webkit ||= ::Playwright::ChannelOwners::BrowserType.from(@initializer['webkit'])
    end

    def android
      @android ||= ::Playwright::ChannelOwners::Android.from(@initializer['android'])
    end

    def electron
      @electron ||= ::Playwright::ChannelOwners::Electron.from(@initializer['electron'])
    end

    def selectors
      @selectors ||= ::Playwright::ChannelOwners::Selectors.from(@initializer['selectors'])
    end

    def devices
      @devices ||= @initializer['deviceDescriptors'].map do |item|
        [item['name'], parse_device_descriptor(item['descriptor'])]
      end.to_h
    end

    private def parse_device_descriptor(descriptor)
      # This return value can be passed into Browser#new_context as it is.
      # ex:
      # ```
      #   iPhone = playwright.devices['iPhone 6']
      #   context = browser.new_context(**iPhone)
      #   page = context.new_page
      #
      # ```
      {
        userAgent: descriptor['userAgent'],
        viewport: {
          width: descriptor['viewport']['width'],
          height: descriptor['viewport']['height'],
        },
        deviceScaleFactor: descriptor['deviceScaleFactor'],
        isMobile: descriptor['isMobile'],
        hasTouch: descriptor['hasTouch'],
      }
    end
  end
end
