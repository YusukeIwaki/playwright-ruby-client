module Playwright
  class RouteHandlerEntry
    # @param url [String]
    # @param handler [Proc]
    def initialize(url, handler)
      @url_value = url
      @url_matcher = UrlMatcher.new(url)
      @handler = handler
    end

    def handle(route, request)
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
