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

    class DeviceDescriptor
      class Viewport
        def initialize(hash)
          @width = hash['width']
          @heirhgt = hash['height']
        end
        attr_reader :width, :height
      end

      def initialize(hash)
        @user_agent = hash["userAgent"]
        @viewport = Viewport.new(hash["viewport"])
        @device_scale_factor = hash["deviceScaleFactor"]
        @is_mobile = hash["isMobile"]
        @has_touch = hash["hasTouch"]
      end

      attr_reader :user_agent, :viewport, :device_scale_factor

      def mobile?
        @is_mobile
      end

      def has_touch?
        @has_touch
      end
    end

    def devices
      @devices ||= @initializer['deviceDescriptors'].map do |item|
        [item['name'], DeviceDescriptor.new(item['descriptor'])]
      end.to_h
    end
  end
end
