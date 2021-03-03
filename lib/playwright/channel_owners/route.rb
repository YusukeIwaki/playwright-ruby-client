require 'base64'

module Playwright
  define_channel_owner :Route do
    def request
      ChannelOwners::Request.from(@initializer['request'])
    end

    def abort(errorCode: nil)
      params = { errorCode: errorCode }.compact
      @channel.async_send_message_to_server('abort', params)
    end

    # def fulfill(
    #   body: nil,
    #   contentType: nil,
    #   headers: nil,
    #   path: nil,
    #   status: nil)
    # end

    def continue(headers: nil, method: nil, postData: nil, url: nil)
      overrides = { url: url, method: method }.compact

      if headers
        overrides[:headers] = HttpHeaders.new(headers).as_serialized
      end

      if postData
        overrides[:postData] = Base64.strict_encode64(postData)
      end

      @channel.async_send_message_to_server('continue', overrides)
    end
  end
end
