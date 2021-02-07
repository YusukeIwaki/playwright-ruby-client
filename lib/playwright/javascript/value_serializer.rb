module Playwright
  module JavaScript
    class ValueSerializer
      def initialize(ruby_value)
        @value = ruby_value
      end

      # @return [Hash]
      def serialize
        @handles = []
        { value: serialize_value(@value), handles: @handles }
      end

      # ref: https://github.com/microsoft/playwright/blob/b45905ae3f1a066a8ecb358035ce745ddd21cf3a/src/protocol/serializers.ts#L84
      # ref: https://github.com/microsoft/playwright-python/blob/25a99d53e00e35365cf5113b9525272628c0e65f/playwright/_impl/_js_handle.py#L99
      private def serialize_value(value)
        case value
        when ChannelOwners::JSHandle
          index = @handles.count
          @handles << value.channel
          { h: index }
        when nil
          { v: 'undefined' }
        when Float::NAN
          { v: 'NaN'}
        when Float::INFINITY
          { v: 'Infinity' }
        when -Float::INFINITY
          { v: '-Infinity' }
        when true, false
          { b: value }
        when Numeric
          { n: value }
        when String
          { s: value }
        when Time
          require 'time'
          { d: value.utc.iso8601 }
        when Regexp
          flags = []
          flags << 'ms' if (value.options & Regexp::MULTILINE) != 0
          flags << 'i' if (value.options & Regexp::IGNORECASE) != 0
          { r: { p: value.source, f: flags.join('') } }
        when Array
          { a: value.map { |v| serialize_value(v) } }
        when Hash
          { o: value.map { |key, v| { k: key, v: serialize_value(v) } } }
        else
          raise ArgumentError.new("Unexpected value: #{value}")
        end
      end
    end
  end
end
