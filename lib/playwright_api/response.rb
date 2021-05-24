module Playwright
  # `Response` class represents responses which are received by page.
  class Response < PlaywrightApi

    # Returns the buffer with response body.
    def body
      wrap_impl(@impl.body)
    end

    # Waits for this response to finish, returns failure error if request failed.
    def finished
      wrap_impl(@impl.finished)
    end

    # Returns the `Frame` that initiated this response.
    def frame
      wrap_impl(@impl.frame)
    end

    # Returns the object with HTTP headers associated with the response. All header names are lower-case.
    def headers
      wrap_impl(@impl.headers)
    end

    # Returns the JSON representation of response body.
    # 
    # This method will throw if the response body is not parsable via `JSON.parse`.
    def json
      wrap_impl(@impl.json)
    end

    # Contains a boolean stating whether the response was successful (status in the range 200-299) or not.
    def ok
      wrap_impl(@impl.ok)
    end

    # Returns the matching `Request` object.
    def request
      wrap_impl(@impl.request)
    end

    # Contains the status code of the response (e.g., 200 for a success).
    def status
      wrap_impl(@impl.status)
    end

    # Contains the status text of the response (e.g. usually an "OK" for a success).
    def status_text
      wrap_impl(@impl.status_text)
    end

    # Returns the text representation of response body.
    def text
      wrap_impl(@impl.text)
    end

    # Contains the URL of the response.
    def url
      wrap_impl(@impl.url)
    end

    # @nodoc
    def after_initialize
      wrap_impl(@impl.after_initialize)
    end

    # @nodoc
    def ok?
      wrap_impl(@impl.ok?)
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

    # -- inherited from EventEmitter --
    # @nodoc
    def on(event, callback)
      event_emitter_proxy.on(event, callback)
    end

    private def event_emitter_proxy
      @event_emitter_proxy ||= EventEmitterProxy.new(self, @impl)
    end
  end
end
