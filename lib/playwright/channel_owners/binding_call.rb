module Playwright
  define_channel_owner :BindingCall do
    class << self
      def call_queue
        @call_queue ||= Queue.new
      end

      def worker_mutex
        @worker_mutex ||= Mutex.new
      end

      def ensure_worker
        worker_mutex.synchronize do
          return if @worker&.alive?

          @worker = Thread.new do
            loop do
              job = call_queue.pop
              begin
                job.call
              rescue => err
                $stderr.write("BindingCall worker error: #{err.class}: #{err.message}\n")
                err.backtrace&.each { |line| $stderr.write("#{line}\n") }
              end
            end
          end
        end
      end
    end

    def name
      @initializer['name']
    end

    def call_async(callback)
      # Binding callbacks can be fired concurrently from multiple threads.
      # Enqueue and execute them on a single worker thread so we:
      # - preserve the delivery order of binding calls
      # - avoid spawning a thread per call (bursty timers create many callbacks)
      # - keep the protocol dispatch thread unblocked
      self.class.ensure_worker
      self.class.call_queue << -> { call(callback) }
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
