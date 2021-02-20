require 'base64'

module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_network.py
  define_channel_owner :Request do
    private def after_initialize
      @redirected_from = ChannelOwners::Request.from_nullable(@initializer['redirectedFrom'])
      @redirected_from&.send(:update_redirected_to, self)
      @timing = {
        startTime: 0,
        domainLookupStart: -1,
        domainLookupEnd: -1,
        connectStart: -1,
        secureConnectionStart: -1,
        connectEnd: -1,
        requestStart: -1,
        responseStart: -1,
        responseEnd: -1,
      }
      @headers = parse_headers(@initializer['headers'])
    end

    def url
      @initializer['url']
    end

    def resource_type
      @initializer['resourceType']
    end

    def method
      @initialize['method']
    end

    def post_data
      post_data_buffer
    end

    def post_data_json
      data = post_data
      return unless data

      content_type = @headers['content-type']
      return unless content_type

      if content_type == "application/x-www-form-urlencoded"
        URI.decode_www_form(data).to_h
      else
        JSON.parse(data)
      end
    end

    def post_data_buffer
      base64_content = @initializer['postData']
      if base64_content
        Base64.strict_decode64(base64_content)
      else
        nil
      end
    end

    def headers
      @headers
    end

    def response
      resp = @channel.send_message_to_server('response')
      ChannelOwners::Response.from_nullable(resp)
    end

    def frame
      @initializer['frame']
    end

    def navigation_request?
      @initializer['isNavigationRequest']
    end

    def failure
      @failure_text
    end

    attr_reader :headers, :redirected_from, :redirected_to, :timing

    private def update_redirected_to(request)
      @redirected_to = request
    end

    private def update_failure_text(failure_text)
      @failure_text = failure_text
    end

    private def update_response_end_timing(response_end_timing)
      @timing[:responseEnd] = response_end_timing
    end

    private def parse_headers(headers)
      headers.map do |header|
        [header['name'].downcase, header['value']]
      end.to_h
    end
  end
end
