require 'securerandom'

module Playwright
  # ref: https://github.com/microsoft/playwright-python/blob/v1.40.0/playwright/_impl/_waiter.py
  # ref: https://github.com/microsoft/playwright/blob/v1.40.0/packages/playwright-core/src/client/waiter.ts
  class Waiter
    def initialize(channel_owner, wait_name:)
      @result = Concurrent::Promises.resolvable_future
      @wait_id = SecureRandom.hex(16)
      @event = wait_name
      @channel = channel_owner.channel
      @registered_listeners = Set.new
      @listeners_mutex = Mutex.new
      @logs = []
      wait_for_event_info_before
    end

    private def wait_for_event_info_before
      @channel.async_send_message_to_server(
        "waitForEventInfo",
        {
          "info": {
            "waitId": @wait_id,
            "phase": "before",
            "event": @event,
          }
        },
      )
    end

    private def wait_for_event_info_after(error: nil)
      @channel.async_send_message_to_server(
        "waitForEventInfo",
        {
          "info": {
            "waitId": @wait_id,
            "phase": "after",
            "error": error,
          }.compact,
        },
      )
    end

    def reject_on_event(emitter, event, error_or_proc, predicate: nil)
      listener = -> (*args) {
        if !predicate || predicate.call(*args)
          if error_or_proc.respond_to?(:call)
            reject(error_or_proc.call)
          else
            reject(error_or_proc)
          end
        end
      }
      register_listener(emitter, event, listener)

      self
    end

    def reject_on_timeout(timeout_ms, message)
      return if timeout_ms <= 0

      Concurrent::Promises.schedule(timeout_ms / 1000.0) do
        reject(TimeoutError.new(message: message))
      end.rescue do |err|
        puts err, err.backtrace
      end

      self
    end

    private def cleanup
      listeners = @listeners_mutex.synchronize do
        @registered_listeners.to_a.tap { @registered_listeners.clear }
      end
      listeners.each do |emitter, event, listener|
        emitter.off(event, listener)
      end
    end

    def force_fulfill(result)
      fulfill(result)
    end

    def force_reject(error)
      reject(error)
    end

    private def fulfill(result)
      cleanup
      return if @result.resolved?
      @result.fulfill(result)
      wait_for_event_info_after
    end

    private def reject(error)
      cleanup
      return if @result.resolved?
      klass = error.is_a?(TimeoutError) ? TimeoutError : Error
      ex = klass.new(message: "#{error.message}#{format_log_recording(@logs)}")
      @result.reject(ex)
      wait_for_event_info_after(error: ex)
    end

    # @param [Playwright::EventEmitter]
    # @param
    def wait_for_event(emitter, event, predicate: nil)
      listener = -> (*args) {
        begin
          if !predicate || predicate.call(*args)
            fulfill(args.first)
          end
        rescue => err
          reject(err)
        end
      }
      register_listener(emitter, event, listener)

      self
    end

    private def register_listener(emitter, event, listener)
      emitter.on(event, listener)
      remove_later = false
      @listeners_mutex.synchronize do
        if @result.resolved?
          remove_later = true
        else
          @registered_listeners << [emitter, event, listener]
        end
      end
      emitter.off(event, listener) if remove_later
    end

    attr_reader :result

    def log(message)
      @logs << message
      begin
        @channel.async_send_message_to_server(
          "waitForEventInfo",
          {
            "info": {
              "waitId": @wait_id,
              "phase": "log",
              "message": message,
            },
          },
        )
      rescue => err
        # ignore
      end
    end

    # @param logs [Array<String>]
    private def format_log_recording(logs)
      return "" if logs.empty?

      header = " logs "
      header_length = 60
      left_length = ((header_length - header.length) / 2.0).to_i
      right_length = header_length - header.length - left_length
      new_line = "\n"
      "#{new_line}#{'=' * left_length}#{header}#{'=' * right_length}#{new_line}#{logs.join(new_line)}#{new_line}#{'=' * header_length}"
    end
  end
end
