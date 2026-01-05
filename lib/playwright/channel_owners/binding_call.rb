module Playwright
  define_channel_owner :BindingCall do
    class << self
      def call_mutex
        @call_mutex ||= Mutex.new
      end

      def last_call_at
        @last_call_at ||= 0.0
      end

      def last_call_at=(value)
        @last_call_at = value
      end
    end

    def name
      @initializer['name']
    end

    def call_async(callback)
      Thread.new(callback) do
        # NOTE: Binding callbacks can be fired concurrently from multiple threads.
        # We only serialize the scheduling of the delay (not the callback itself)
        # so we can enforce a minimum gap (4ms) between *start times* while still
        # allowing the callbacks to run in parallel. This helps reduce flaky
        # ordering issues without blocking long-running user code.
        #
        # Use a monotonic clock to avoid issues with wall-clock jumps.
        self.class.call_mutex.synchronize do
          now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          elapsed = now - self.class.last_call_at
          wait = 0.004 - elapsed
          sleep(wait) if wait > 0
          # Record before running the callback so the interval is between
          # scheduled start times, not completion times.
          self.class.last_call_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        end
        call(callback)
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
        @channel.send_message_to_server('resolve', result: JavaScript::ValueSerializer.new(result).serialize)
      rescue => err
        @channel.send_message_to_server('reject', error: { error: { message: err.message, name: 'Error' }})
      end
    end
  end
end
