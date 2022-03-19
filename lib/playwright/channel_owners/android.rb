module Playwright
  define_channel_owner :Android do
    private def after_initialize
      @timeout_settings = TimeoutSettings.new
    end

    def devices(port: nil)
      resp = @channel.send_message_to_server('devices', port: port)
      resp.map { |device| ChannelOwners::AndroidDevice.from(device) }
    end
  end
end
