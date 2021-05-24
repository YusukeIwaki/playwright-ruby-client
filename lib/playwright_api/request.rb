module Playwright
  # Whenever the page sends a request for a network resource the following sequence of events are emitted by `Page`:
  # - [`event: Page.request`] emitted when the request is issued by the page.
  # - [`event: Page.response`] emitted when/if the response status and headers are received for the request.
  # - [`event: Page.requestFinished`] emitted when the response body is downloaded and the request is complete.
  # 
  # If request fails at some point, then instead of `'requestfinished'` event (and possibly instead of 'response' event),
  # the  [`event: Page.requestFailed`] event is emitted.
  # 
  # > NOTE: HTTP Error responses, such as 404 or 503, are still successful responses from HTTP standpoint, so request will
  # complete with `'requestfinished'` event.
  # 
  # If request gets a 'redirect' response, the request is successfully finished with the 'requestfinished' event, and a new
  # request is  issued to a redirected url.
  class Request < PlaywrightApi

    # The method returns `null` unless this request has failed, as reported by `requestfailed` event.
    # 
    # Example of logging of all the failed requests:
    # 
    #
    # ```js
    # page.on('requestfailed', request => {
    #   console.log(request.url() + ' ' + request.failure().errorText);
    # });
    # ```
    # 
    # ```java
    # page.onRequestFailed(request -> {
    #   System.out.println(request.url() + " " + request.failure());
    # });
    # ```
    # 
    # ```py
    # page.on("requestfailed", lambda request: print(request.url + " " + request.failure))
    # ```
    # 
    # ```csharp
    # page.RequestFailed += (_, request) =>
    # {
    #     Console.WriteLine(request.Failure);
    # };
    # ```
    def failure
      wrap_impl(@impl.failure)
    end

    # Returns the `Frame` that initiated this request.
    def frame
      wrap_impl(@impl.frame)
    end

    # An object with HTTP headers associated with the request. All header names are lower-case.
    def headers
      wrap_impl(@impl.headers)
    end

    # Whether this request is driving frame's navigation.
    def navigation_request?
      wrap_impl(@impl.navigation_request?)
    end

    # Request's method (GET, POST, etc.)
    def method
      wrap_impl(@impl.method)
    end

    # Request's post body, if any.
    def post_data
      wrap_impl(@impl.post_data)
    end

    # Request's post body in a binary form, if any.
    def post_data_buffer
      wrap_impl(@impl.post_data_buffer)
    end

    # Returns parsed request's body for `form-urlencoded` and JSON as a fallback if any.
    # 
    # When the response is `application/x-www-form-urlencoded` then a key/value object of the values will be returned.
    # Otherwise it will be parsed as JSON.
    def post_data_json
      wrap_impl(@impl.post_data_json)
    end

    # Request that was redirected by the server to this one, if any.
    # 
    # When the server responds with a redirect, Playwright creates a new `Request` object. The two requests are connected by
    # `redirectedFrom()` and `redirectedTo()` methods. When multiple server redirects has happened, it is possible to
    # construct the whole redirect chain by repeatedly calling `redirectedFrom()`.
    # 
    # For example, if the website `http://example.com` redirects to `https://example.com`:
    # 
    #
    # ```js
    # const response = await page.goto('http://example.com');
    # console.log(response.request().redirectedFrom().url()); // 'http://example.com'
    # ```
    # 
    # ```java
    # Response response = page.navigate("http://example.com");
    # System.out.println(response.request().redirectedFrom().url()); // "http://example.com"
    # ```
    # 
    # ```python async
    # response = await page.goto("http://example.com")
    # print(response.request.redirected_from.url) # "http://example.com"
    # ```
    # 
    # ```python sync
    # response = page.goto("http://example.com")
    # print(response.request.redirected_from.url) # "http://example.com"
    # ```
    # 
    # ```csharp
    # var response = await page.GotoAsync("http://www.microsoft.com");
    # Console.WriteLine(response.Request.RedirectedFrom?.Url); // http://www.microsoft.com
    # ```
    # 
    # If the website `https://google.com` has no redirects:
    # 
    #
    # ```js
    # const response = await page.goto('https://google.com');
    # console.log(response.request().redirectedFrom()); // null
    # ```
    # 
    # ```java
    # Response response = page.navigate("https://google.com");
    # System.out.println(response.request().redirectedFrom()); // null
    # ```
    # 
    # ```python async
    # response = await page.goto("https://google.com")
    # print(response.request.redirected_from) # None
    # ```
    # 
    # ```python sync
    # response = page.goto("https://google.com")
    # print(response.request.redirected_from) # None
    # ```
    # 
    # ```csharp
    # var response = await page.GotoAsync("https://www.google.com");
    # Console.WriteLine(response.Request.RedirectedFrom?.Url); // null
    # ```
    def redirected_from
      wrap_impl(@impl.redirected_from)
    end

    # New request issued by the browser if the server responded with redirect.
    # 
    # This method is the opposite of [`method: Request.redirectedFrom`]:
    # 
    #
    # ```js
    # console.log(request.redirectedFrom().redirectedTo() === request); // true
    # ```
    # 
    # ```java
    # System.out.println(request.redirectedFrom().redirectedTo() == request); // true
    # ```
    # 
    # ```py
    # assert request.redirected_from.redirected_to == request
    # ```
    # 
    # ```csharp
    # Console.WriteLine(request.RedirectedFrom?.RedirectedTo == request); // True
    # ```
    def redirected_to
      wrap_impl(@impl.redirected_to)
    end

    # Contains the request's resource type as it was perceived by the rendering engine. ResourceType will be one of the
    # following: `document`, `stylesheet`, `image`, `media`, `font`, `script`, `texttrack`, `xhr`, `fetch`, `eventsource`,
    # `websocket`, `manifest`, `other`.
    def resource_type
      wrap_impl(@impl.resource_type)
    end

    # Returns the matching `Response` object, or `null` if the response was not received due to error.
    def response
      wrap_impl(@impl.response)
    end

    # Returns resource timing information for given request. Most of the timing values become available upon the response,
    # `responseEnd` becomes available when request finishes. Find more information at
    # [Resource Timing API](https://developer.mozilla.org/en-US/docs/Web/API/PerformanceResourceTiming).
    # 
    #
    # ```js
    # const [request] = await Promise.all([
    #   page.waitForEvent('requestfinished'),
    #   page.goto('http://example.com')
    # ]);
    # console.log(request.timing());
    # ```
    # 
    # ```java
    # page.onRequestFinished(request -> {
    #   Timing timing = request.timing();
    #   System.out.println(timing.responseEnd - timing.startTime);
    # });
    # page.navigate("http://example.com");
    # ```
    # 
    # ```python async
    # async with page.expect_event("requestfinished") as request_info:
    #     await page.goto("http://example.com")
    # request = await request_info.value
    # print(request.timing)
    # ```
    # 
    # ```python sync
    # with page.expect_event("requestfinished") as request_info:
    #     page.goto("http://example.com")
    # request = request_info.value
    # print(request.timing)
    # ```
    # 
    # ```csharp
    # var waitForEventTask = page.WaitForEventAsync(PageEvent.RequestFinished);
    # await page.GotoAsync("https://www.microsoft.com");
    # var request = await waitForEventTask;
    # Console.WriteLine(request.Timing.ResponseEnd);
    # ```
    def timing
      wrap_impl(@impl.timing)
    end

    # URL of the request.
    def url
      wrap_impl(@impl.url)
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
