require 'base64'
require 'json'
require_relative '../http_headers'

module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_network.py
  define_channel_owner :Response do
    include HttpHeaders::Parser

    private def after_initialize
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
      parse_headers_as_array(@initializer['headers'], true).to_h
    end

    private def raw_headers
      @raw_headers ||= raw_response_headers
    end

    private def raw_request_headers
      @channel.send_message_to_server('rawRequestHeaders')
    end

    private def raw_response_headers
      @channel.send_message_to_server('rawResponseHeaders')
    end

    def headers_array
      parse_headers_as_array(raw_headers, false)
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
      }
    end

    private def mark_as_finished
      @finished_promise.fulfill(nil)
    end
  end
end
