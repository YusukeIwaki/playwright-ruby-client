module Playwright
  define_api_implementation :HeadersImpl do
    def initialize(headers)
      @headers = headers
      @headers_map = headers.each_with_object({}) do |header, m|
        key = header['name'].downcase
        value = header['value']

        m[key] ||= Set.new
        m[key] << value
      end
    end

    def get(name)
      @headers_map[name.downcase]&.join(', ')
    end

    def get_all(name)
      @headers_map[name.downcase].to_a || []
    end

    def header_names
      @headers_map.keys
    end

    def headers
      @headers_map.map do |name, values|
        [name, values.join(', ')]
      end.to_h
    end
  end
end
