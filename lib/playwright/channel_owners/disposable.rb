module Playwright
  # Stub for Disposable channel owner introduced in Playwright 1.59.
  # Disposable is returned from various methods to allow undoing the corresponding action.
  define_channel_owner :Disposable do
    def dispose
      @channel.send_message_to_server('dispose')
    end
  end
end
