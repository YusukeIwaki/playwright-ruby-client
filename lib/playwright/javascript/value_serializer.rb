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

      private

      # ref: https://github.com/microsoft/playwright/blob/b45905ae3f1a066a8ecb358035ce745ddd21cf3a/src/protocol/serializers.ts#L84
      # ref: https://github.com/microsoft/playwright-python/blob/25a99d53e00e35365cf5113b9525272628c0e65f/playwright/_impl/_js_handle.py#L99
      def serialize_value(value)
        case value
        when JSHandle
          index = @handles.count
          @handles << v
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
          { b: v }
        when Numeric
          { n: v }
        when String
          { s: v }
        when Time
          require 'time'
          { d: v.utc.iso8601 }
        when Regexp
          flags = []
          flags << 'ms' if (v.options & Regexp::MULTILINE) != 0
          flags << 'i' if (v.options & Regexp::IGNORECASE) != 0
          { r: { p: v.source, f: flags.join('') } }
        when Array
          { a: v.map { |value| serialize_value(value) } }
        when Hash
          { o: v.map { |key, value| [key, serialize_value(value)] }.to_h }
        else
          raise ArgumentError.new("Unexpected value: #{value}")
        end
      end
    end
  end
end
