module Playwright
  define_channel_owner :ConsoleMessage do
    def type
      @initializer['type']
    end

    def text
      @initializer['text']
    end

    def args
      @initializer['args']&.map do |arg|
        ChannelOwner.from(arg)
      end
    end

    def location
      @initialize['location']
    end
  end
end
