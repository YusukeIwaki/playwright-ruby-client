module Playwright
  define_channel_owner :Worker do
    attr_writer :context, :page

    private def after_initialize
      @channel.once('close', ->(_) { on_close })

      set_event_to_subscription_mapping({
        Events::Worker::Console => "console",
      })
    end

    private def on_close
      @page&.send(:remove_worker, self)
      @context&.send(:remove_service_worker, self)
      emit(Events::Worker::Close, self)
    end

    def url
      @initializer['url']
    end

    def evaluate(expression, arg: nil)
      JavaScript::Expression.new(expression, arg).evaluate(@channel)
    end

    def evaluate_handle(expression, arg: nil)
      JavaScript::Expression.new(expression, arg).evaluate_handle(@channel)
    end

    def expect_event(event, predicate: nil, timeout: nil, &block)
      waiter = Waiter.new(self, wait_name: "Worker.expect_event(#{event})")
      timeout_value = timeout || @page&.send(:_timeout_settings)&.timeout || @context&.send(:_timeout_settings)&.timeout
      waiter.reject_on_timeout(timeout_value, "Timeout #{timeout_value}ms exceeded while waiting for event \"#{event}\"")

      unless event == Events::Worker::Close
        waiter.reject_on_event(self, Events::Worker::Close, TargetClosedError.new)
      end

      waiter.wait_for_event(self, event, predicate: predicate)
      block&.call

      waiter.result.value!
    end
  end
end
