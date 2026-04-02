module Playwright
  define_channel_owner :Disposable do
    def dispose
      @channel.send_message_to_server('dispose')
    end
  end
end
