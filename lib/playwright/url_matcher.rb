module Playwright
  class UrlMatcher
    # @param url [String|Regexp]
    def initialize(url)
      @url = url
    end

    def match?(target_url)
      case @url
      when String
        @url == target_url || File.fnmatch?(@url, target_url)
      when Regexp
        @url.match?(target_url)
      else
        false
      end
    end
  end
end
