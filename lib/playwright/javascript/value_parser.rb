require 'date'

module Playwright
  module JavaScript
    class ValueParser
      def initialize(hash)
        @hash = hash
      end

      # @return [Hash]
      def parse
        if @hash.nil?
          nil
        else
          parse_hash(@hash)
        end
      end

      # ref: https://github.com/microsoft/playwright/blob/b45905ae3f1a066a8ecb358035ce745ddd21cf3a/src/protocol/serializers.ts#L42
      # ref: https://github.com/microsoft/playwright-python/blob/25a99d53e00e35365cf5113b9525272628c0e65f/playwright/_impl/_js_handle.py#L140
      private def parse_hash(hash)
        %w(n s b).each do |key|
          return hash[key] if hash.key?(key)
        end

        if hash.key?('v')
          return
            case hash['v']
            when 'undefined'
              nil
            when 'null'
              nil
            when 'NaN'
              Float::NAN
            when 'Infinity'
              Float::INFINITY
            when '-Infinity'
              -Float::INFINITY
            when '-0'
              -0
            end
        end

        if hash.key?('d')
          return DateTime.parse(hash['d'])
        end

        if hash.key?('r')
          # @see https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/RegExp
          # @see https://docs.ruby-lang.org/ja/latest/class/Regexp.html
          js_regex_flag = hash['r']['f']
          flags = []
          flags << Regexp::IGNORECASE if js_regex_flag.include?('i')
          flags << Regexp::MULTILINE if js_regex_flag.include?('m') || js_regex_flag.include?('s')

          return Regexp.compile(hash['r']['p'], flags.inject(:|))
        end

        if hash.key?('a')
          return hash['a'].map { |value| parse_hash(value) }
        end

        if hash.key?('o')
          return hash['o'].map { |obj| [obj['k'], parse_hash(obj['v'])] }.to_h
        end

        if hash.key?('h')
          return @handles[hash['h']]
        end

        raise ArgumentError.new("Unexpected value: #{hash}")
      end
    end
  end
end
