module Playwright
  define_channel_owner :WebSocket do
    private def after_initialize
      @closed = false
    end

    def url
      @initializer['url']
    end

    def expect_event(event, predicate: nil, timeout: nil, &block)

    end
    alias_method :wait_for_event, :expect_event

    def closed?
      @closed
    end
  end
end
