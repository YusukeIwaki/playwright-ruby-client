require 'base64'
require 'json'

module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_network.py
  define_channel_owner :Response do
    def after_initialize
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
      @request.send(:update_headers, @initializer['requestHeaders'])
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
      @initializer['headers'].map do |header|
        [header['name'].downcase, header['value']]
      end.to_h
    end

    def finished
      @channel.send_message_to_server('finished')
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
  end
end
