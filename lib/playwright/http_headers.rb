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

    def self.parse_serialized(serialized_headers)
      new(serialized_headers.map do |header|
        [header['name'].downcase, header['value']]
      end.to_h)
    end
  end
end
