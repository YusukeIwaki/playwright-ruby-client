module Playwright
  define_api_implementation :MouseImpl do
    def initialize(channel)
      @channel = channel
    end
  end
end
