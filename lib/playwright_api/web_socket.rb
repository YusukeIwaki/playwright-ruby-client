module Playwright
  # The `WebSocket` class represents websocket connections in the page.
  class WebSocket < PlaywrightApi

    # Indicates that the web socket has been closed.
    def closed?
      raise NotImplementedError.new('closed? is not implemented yet.')
    end

    # Contains the URL of the WebSocket.
    def url
      raise NotImplementedError.new('url is not implemented yet.')
    end

    # Waits for event to fire and passes its value into the predicate function. Returns when the predicate returns truthy
    # value. Will throw an error if the webSocket is closed before the event is fired. Returns the event data value.
    def expect_event(event, predicate: nil, timeout: nil)
      raise NotImplementedError.new('expect_event is not implemented yet.')
    end

    # > NOTE: In most cases, you should use [`method: WebSocket.waitForEvent`].
    #
    # Waits for given `event` to fire. If predicate is provided, it passes event's value into the `predicate` function and
    # waits for `predicate(event)` to return a truthy value. Will throw an error if the socket is closed before the `event` is
    # fired.
    def wait_for_event(event, predicate: nil, timeout: nil)
      raise NotImplementedError.new('wait_for_event is not implemented yet.')
    end
  end
end
