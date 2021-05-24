module Playwright
  # `ConsoleMessage` objects are dispatched by page via the [`event: Page.console`] event.
  class ConsoleMessage < PlaywrightApi

    # List of arguments passed to a `console` function call. See also [`event: Page.console`].
    def args
      wrap_impl(@impl.args)
    end

    def location
      wrap_impl(@impl.location)
    end

    # The text of the console message.
    def text
      wrap_impl(@impl.text)
    end

    # One of the following values: `'log'`, `'debug'`, `'info'`, `'error'`, `'warning'`, `'dir'`, `'dirxml'`, `'table'`,
    # `'trace'`, `'clear'`, `'startGroup'`, `'startGroupCollapsed'`, `'endGroup'`, `'assert'`, `'profile'`, `'profileEnd'`,
    # `'count'`, `'timeEnd'`.
    def type
      wrap_impl(@impl.type)
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def on(event, callback)
      event_emitter_proxy.on(event, callback)
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def off(event, callback)
      event_emitter_proxy.off(event, callback)
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def once(event, callback)
      event_emitter_proxy.once(event, callback)
    end

    private def event_emitter_proxy
      @event_emitter_proxy ||= EventEmitterProxy.new(self, @impl)
    end
  end
end
