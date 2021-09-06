require 'base64'
require 'json'

module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_network.py
  define_channel_owner :Response do
    private def after_initialize
      @headers = parse_headers(@initializer['headers'])
      @request = ChannelOwners::Request.from(@initializer['request'])
      timing = @initializer['timing']
      @request.send(:update_timings,
        start_time: timing["startTime"],
        domain_lookup_start: timing["domainLookupStart"],
        domain_lookup_end: timing["domainLookupEnd"],
        connect_start: timing["connectStart"],
        secure_connection_start: timing["secureConnectionStart"],
        connect_end: timing["connectEnd"],
        request_start: timing["requestStart"],
        response_start: timing["responseStart"],
      )
      @finished_promise = Concurrent::Promises.resolvable_future
    end
    attr_reader :request

    def url
      @initializer['url']
    end

    def ok
      status == 0 || (200...300).include?(status)
    end
    alias_method :ok?, :ok

    def status
      @initializer['status']
    end

    def status_text
      @initializer['statusText']
    end

    def headers
      @headers
    end

    def server_addr
      @channel.send_message_to_server('serverAddr')
    end

    def security_details
      @channel.send_message_to_server('securityDetails')
    end

    def finished
      @finished_promise.value!
    end

    def body
      binary = @channel.send_message_to_server("body")
      Base64.strict_decode64(binary)
    end
    alias_method :text, :body

    def json
      JSON.parse(text)
    end

    def frame
      @request.frame
    end

    private def sizes
      resp = @channel.send_message_to_server('sizes')

      {
        requestBodySize: resp['requestBodySize'],
        requestHeadersSize: resp['requestHeadersSize'],
        responseBodySize: resp['responseBodySize'],
        responseHeadersSize: resp['responseHeadersSize'],
        responseTransferSize: resp['responseTransferSize'],
      }
    end

    private def mark_as_finished
      @finished_promise.fulfill(nil)
    end

    private def parse_headers(headers)
      headers.map do |header|
        [header['name'].downcase, header['value']]
      end.to_h
    end
  end
end
