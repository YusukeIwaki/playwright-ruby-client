module Playwright
  define_api_implementation :TouchscreenImpl do
    def initialize(channel)
      @channel = channel
    end
  end
end
