module Playwright
  class UrlMatcher
    # @param url [String|Regexp]
    # @param base_url [String|nil]
    def initialize(url, base_url:)
      @url = url
      @base_url = base_url
      validate_glob_pattern if @url.is_a?(String)
    end

    def as_pattern
      case @url
      when String
        { glob: @url }
      when Regexp
        regex = JavaScript::Regex.new(@url)
        { regexSource: regex.source, regexFlags: regex.flag }
      else
        nil
      end
    end

    def match?(target_url)
      case @url
      when String
        joined_url == target_url || File.fnmatch?(@url, target_url)
      when Regexp
        @url.match?(target_url)
      else
        false
      end
    end

    private def joined_url
      if @base_url && !@url.start_with?('*')
        URI.join(@base_url, @url).to_s
      else
        @url
      end
    end

    private def validate_glob_pattern
      in_group = false
      escaped = false

      @url.each_char do |char|
        if escaped
          escaped = false
          next
        end

        if char == '\\'
          escaped = true
          next
        end

        case char
        when '{'
          if in_group
            raise ArgumentError.new("Invalid glob pattern #{@url.inspect}: nested '{' is not supported")
          end
          in_group = true
        when '}'
          unless in_group
            raise ArgumentError.new("Invalid glob pattern #{@url.inspect}: unmatched '}'")
          end
          in_group = false
        end
      end

      if in_group
        raise ArgumentError.new("Invalid glob pattern #{@url.inspect}: unmatched '{'")
      end
    end
  end
end
