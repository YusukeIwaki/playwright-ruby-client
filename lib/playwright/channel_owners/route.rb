require 'base64'
require 'mime/types'

module Playwright
  define_channel_owner :Route do
    def request
      ChannelOwners::Request.from(@initializer['request'])
    end

    def abort(errorCode: nil)
      params = { errorCode: errorCode }.compact
      @channel.async_send_message_to_server('abort', params)
    end

    def fulfill(
          body: nil,
          contentType: nil,
          headers: nil,
          path: nil,
          status: nil)
      params = {
        contentType: contentType,
        status: status,
      }.compact

      length = 0
      content =
        if body
          body
        elsif path
          File.read(path)
        else
          nil
        end

      param_headers = headers || {}
      if contentType
        param_headers['content-type'] = contentType
      elsif path
        param_headers['content-type'] = mime_type_for(path)
      end

      if content
        if content.is_a?(String)
          params[:body] = content
          params[:isBase64] = false
        else
          params[:body] = Base64.strict_encode64(content)
          params[:isBase64] = true
        end
        param_headers['content-length'] ||= content.length.to_s
      end

      params[:headers] = HttpHeaders.new(param_headers).as_serialized

      @channel.async_send_message_to_server('fulfill', params)
    end

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

    private def mime_type_for(filepath)
      mime_types = MIME::Types.type_for(filepath)
      mime_types.first.to_s || 'application/octet-stream'
    end
  end
end
