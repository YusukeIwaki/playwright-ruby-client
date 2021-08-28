module Playwright
  class RouteHandler
    class CountDown
      def initialize(count)
        @count = count
      end

      def handle
        return false if @count <= 0

        @count = @count - 1
        true
      end
    end

    class StubCounter
      def handle
        true
      end
    end

    # @param url [String]
    # @param base_url [String|nil]
    # @param handler [Proc]
    # @param times [Integer|nil]
    def initialize(url, base_url, handler, times)
      @url_value = url
      @url_matcher = UrlMatcher.new(url, base_url: base_url)
      @handler = handler
      @counter =
        if times
          CountDown.new(times)
        else
          StubCounter.new
        end
    end

    def handle(route, request)
      return false unless @counter.handle

      if @url_matcher.match?(request.url)
        @handler.call(route, request)
        true
      else
        false
      end
    end

    def same_value?(url:, handler: nil)
      if handler
        @url_value == url && @handler == handler
      else
        @url_value == url
      end
    end
  end
end
