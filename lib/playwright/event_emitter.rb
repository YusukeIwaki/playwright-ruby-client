module Playwright
  class EventEmitterCallback
    def initialize(callback_proc)
      @proc = callback_proc
    end

    def call(*args)
      @proc.call(*args)
      true
    end
  end

  class EventEmitterOnceCallback < EventEmitterCallback
    def call(*args)
      @__result ||= super
      true
    end
  end


  # A subset of Events/EventEmitter in Node.js
  module EventEmitter
    # @param event [String]
    def emit(event, *args)
      (@__event_emitter ||= {})[event.to_s]&.each do |callback|
        callback.call(*args)
      end
      self
    end

    # @param event [String]
    # @param callback [Proc]
    def on(event, callback)
      raise ArgumentError.new('callback must not be nil') if callback.nil?
      cb = (@__event_emitter_callback ||= {})["#{event}/#{callback.object_id}"] ||= EventEmitterCallback.new(callback)
      ((@__event_emitter ||= {})[event.to_s] ||= Set.new) << cb
      self
    end

    # @param event [String]
    # @param callback [Proc]
    def once(event, callback)
      raise ArgumentError.new('callback must not be nil') if callback.nil?

      cb = (@__event_emitter_callback ||= {})["#{event}/once/#{callback.object_id}"] ||= EventEmitterOnceCallback.new(callback)
      ((@__event_emitter ||= {})[event.to_s] ||= Set.new) << cb
      self
    end

    # @param event [String]
    # @param callback [Proc]
    def off(event, callback)
      raise ArgumentError.new('callback must not be nil') if callback.nil?

      cb = (@__event_emitter_callback ||= {})["#{event}/#{callback.object_id}"]
      if cb
        (@__event_emitter ||= {})[event.to_s]&.delete(cb)
      end
      self
    end
  end
end
