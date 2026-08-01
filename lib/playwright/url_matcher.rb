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
        joined_url == target_url || File.fnmatch?(joined_url, target_url)
      when Regexp
        @url.match?(target_url)
      else
        false
      end
    end

    private def joined_url
      normalized_url = normalize_literal_url(@url)
      if @base_url && !normalized_url.start_with?('*')
        normalize_literal_url(URI.join(normalize_literal_url(@base_url), normalized_url).to_s)
      else
        normalized_url
      end
    end

    private def normalize_literal_url(url)
      match = url.match(/\A([a-z][a-z0-9+.-]*):\/\/([^\/?#]*)(.*)\z/i)
      return percent_encode_literal_characters(url) unless match

      scheme = match[1].downcase
      authority = match[2]
      suffix = percent_encode_literal_characters(match[3])

      before, separator, after = authority.rpartition('@')
      if separator.empty?
        userinfo = nil
        host_port = authority
      else
        userinfo = before
        host_port = after
      end

      if host_port.start_with?('[')
        host = host_port
        port = nil
      else
        host, separator, candidate_port = host_port.rpartition(':')
        if separator.empty? || candidate_port !~ /\A\d+\z/
          host = host_port
          port = nil
        else
          port = candidate_port
        end
        host = host.split('.').map { |label| punycode_label(label.downcase) }.join('.')
      end

      port = nil if (scheme == 'http' && port == '80') || (scheme == 'https' && port == '443')
      normalized_authority = String.new
      normalized_authority << "#{userinfo}@" if userinfo
      normalized_authority << host
      normalized_authority << ":#{port}" if port
      "#{scheme}://#{normalized_authority}#{suffix}"
    end

    private def percent_encode_literal_characters(value)
      value.each_char.map do |char|
        if char == ' '
          '%20'
        elsif char.ascii_only?
          char
        else
          char.encode(Encoding::UTF_8).bytes.map { |byte| format('%%%02X', byte) }.join
        end
      end.join
    end

    # RFC 3492 Punycode encoder for the non-ASCII URL host labels normalized by WHATWG URL.
    private def punycode_label(label)
      return label if label.ascii_only?

      codepoints = label.codepoints
      output = codepoints.select { |codepoint| codepoint < 0x80 }.map(&:chr).join
      basic_length = output.length
      output << '-' if basic_length > 0

      handled = basic_length
      n = 128
      delta = 0
      bias = 72
      while handled < codepoints.length
        next_codepoint = codepoints.select { |codepoint| codepoint >= n }.min
        delta += (next_codepoint - n) * (handled + 1)
        n = next_codepoint

        codepoints.each do |codepoint|
          delta += 1 if codepoint < n
          next unless codepoint == n

          q = delta
          k = 36
          loop do
            threshold = if k <= bias
                          1
                        elsif k >= bias + 26
                          26
                        else
                          k - bias
                        end
            break if q < threshold

            output << punycode_digit(threshold + ((q - threshold) % (36 - threshold)))
            q = (q - threshold) / (36 - threshold)
            k += 36
          end
          output << punycode_digit(q)
          bias = adapt_punycode_bias(delta, handled + 1, handled == basic_length)
          delta = 0
          handled += 1
        end
        delta += 1
        n += 1
      end
      "xn--#{output}"
    end

    private def punycode_digit(value)
      value < 26 ? (value + 97).chr : (value - 26 + 48).chr
    end

    private def adapt_punycode_bias(delta, points, first_time)
      delta = first_time ? delta / 700 : delta / 2
      delta += delta / points
      k = 0
      while delta > 455
        delta /= 35
        k += 36
      end
      k + ((36 * delta) / (delta + 38))
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
