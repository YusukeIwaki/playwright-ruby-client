module Playwright
  class HttpHeaders
    # @param headers [Hash]
    def initialize(headers)
      @headers = headers
    end

    def as_serialized
      @headers.map do |key, value|
        { name: key, value: value }
      end
    end

    module Parser
      def parse_headers_as_array(serialized_headers, downcase)
        serialized_headers.map do |header|
          name = downcase ? header['name'].downcase : header['name']
          value = header['value']

          [name, value]
        end
      end
    end
  end
end
