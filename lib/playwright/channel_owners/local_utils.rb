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
  end
end
