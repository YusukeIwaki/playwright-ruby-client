module Playwright
  define_channel_owner :BindingCall do
    class << self
      def call_mutex
        @call_mutex ||= Mutex.new
      end
    end

    def name
      @initializer['name']
    end

    def call_async(callback)
      Thread.new(callback) do
        # Binding callbacks can be fired concurrently from multiple threads.
        # Serialize execution to preserve call order and avoid flaky interleaving.
        self.class.call_mutex.synchronize do
          call(callback)
        end
      end
    end

    # @param callback [Proc]
    def call(callback)
      frame = ChannelOwners::Frame.from(@initializer['frame'])
      # It is not desired to use PlaywrightApi.wrap directly.
      # However it is a little difficult to define wrapper for `source` parameter in generate_api.
      # Just a workaround...
      source = {
        context: PlaywrightApi.wrap(frame.page.context),
        page: PlaywrightApi.wrap(frame.page),
        frame: PlaywrightApi.wrap(frame),
      }
      args =
        if @initializer['handle']
          handle = ChannelOwners::ElementHandle.from(@initializer['handle'])
          [handle]
        else
          @initializer['args'].map do |arg|
            JavaScript::ValueParser.new(arg).parse
          end
        end

      begin
        result = PlaywrightApi.unwrap(callback.call(source, *args))
        @channel.async_send_message_to_server('resolve', result: JavaScript::ValueSerializer.new(result).serialize)
      rescue => err
        @channel.async_send_message_to_server('reject', error: { error: { message: err.message, name: 'Error' }})
      end
    end
  end
end
