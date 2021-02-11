module Playwright
  class TimeoutSettings
    DEFAULT_TIMEOUT = 30000

    def initialize(parent = nil)
      @parent = parent
    end

    attr_writer :default_timeout, :default_navigation_timeout

    def navigation_timeout
      @default_navigation_timeout || @default_timeout || @parent&.navigation_timeout || DEFAULT_TIMEOUT
    end

    def timeout
      @default_timeout || @parent&.timeout || DEFAULT_TIMEOUT
    end
  end
end
