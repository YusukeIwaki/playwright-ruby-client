module Playwright
  define_channel_owner :Android do
    private def after_initialize
      @timeout_settings = TimeoutSettings.new
    end

    def devices(host: nil, omitDriverInstall: nil, port: nil)
      params = { host: host, port: port, omitDriverInstall: omitDriverInstall }.compact
      resp = @channel.send_message_to_server('devices', params)
      resp.map { |device| ChannelOwners::AndroidDevice.from(device) }
    end
  end
end
