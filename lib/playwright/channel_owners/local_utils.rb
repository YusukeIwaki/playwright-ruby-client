module Playwright
  define_channel_owner :LocalUtils do
    # @param zip_file [String]
    # @param name_value_array [Array<Hash<{name: string, value: string}>>]
    def zip(zip_file, name_value_array)
      params = {
        zipFile: zip_file,
        entries: name_value_array,
      }
      @channel.send_message_to_server('zip', params)
      nil
    end


    # @param file [String]
    # @return [String] har ID
    def har_open(file)
      @channel.send_message_to_server('harOpen', file: file)
    end

    def har_lookup(har_id:, url:, method:, headers:, is_navigation_request:, post_data: nil)
      params = {
        harId: har_id,
        url: url,
        method: method,
        headers: headers,
        postData: post_data,
        isNavigationRequest: is_navigation_request,
      }.compact

      @channel.send_message_to_server_result('harLookup', params)
    end

    # @param har_id [String]
    def har_close(har_id)
      @channel.async_send_message_to_server('harClose', harId: har_id)
    end
  end
end
