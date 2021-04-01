module Playwright
  # ref: https://github.com/microsoft/playwright-python/blob/30946ae3099d51f9b7f355f9ae7e8c04d748ce36/playwright/_impl/_wait_helper.py
  # ref: https://github.com/microsoft/playwright/blob/01fb3a6045cbdb4b5bcba0809faed85bd917ab87/src/client/waiter.ts#L21
  class WaitHelper
    def initialize
      @promise = AsyncValue.new
      @registered_listeners = Set.new
    end

    def reject_on_event(emitter, event, error, predicate: nil)
      listener = -> (*args) {
        if !predicate || predicate.call(*args)
          reject(error)
        end
      }
      emitter.on(event, listener)
      @registered_listeners << [emitter, event, listener]

      self
    end

    def reject_on_timeout(timeout_ms, message)
      return if timeout_ms <= 0

      @timeout_task&.stop
      @timeout_task = Async do |task|
        task.sleep(timeout_ms / 1000.0)
        reject(TimeoutError.new(message: message))
      end

      self
    end

    # @param [Playwright::EventEmitter]
    # @param
    def wait_for_event(emitter, event, predicate: nil)
      listener = -> (*args) {
        begin
          if !predicate || predicate.call(*args)
            fulfill(*args)
          end
        rescue => err
          reject(err)
        end
      }
      emitter.on(event, listener)
      @registered_listeners << [emitter, event, listener]

      self
    end

    attr_reader :promise

    private def cleanup
      @registered_listeners.each do |emitter, event, listener|
        emitter.off(event, listener)
      end
      @registered_listeners.clear
      Async { @timeout_task&.stop }
    end

    private def fulfill(*args)
      cleanup
      unless @promise.resolved?
        @promise.fulfill(args.first)
      end
    end

    private def reject(error)
      cleanup
      unless @promise.resolved?
        @promise.reject(error)
      end
    end
  end
end
