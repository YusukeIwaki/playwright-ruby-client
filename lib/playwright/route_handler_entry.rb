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
      if url_match?(request.url)
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

    private def url_match?(request_url)
      if @url_value.is_a?(Regexp)
        @url_matcher.match?(request_url)
      else
        @url_matcher.match?(request_url) || File.fnmatch?(@url_value, request_url)
      end
    end
  end
end
