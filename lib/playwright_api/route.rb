module Playwright
  # Whenever a network route is set up with [`method: Page.route`] or [`method: BrowserContext.route`], the `Route` object
  # allows to handle the route.
  class Route < PlaywrightApi

    # Aborts the route's request.
    def abort(errorCode: nil)
      wrap_impl(@impl.abort(errorCode: unwrap_impl(errorCode)))
    end

    # Continues route's request with optional overrides.
    #
    #
    # ```js
    # await page.route('**/*', (route, request) => {
    #   // Override headers
    #   const headers = {
    #     ...request.headers(),
    #     foo: 'bar', // set "foo" header
    #     origin: undefined, // remove "origin" header
    #   };
    #   route.continue({headers});
    # });
    # ```
    #
    # ```java
    # page.route("**/*", route -> {
    #   // Override headers
    #   Map<String, String> headers = new HashMap<>(route.request().headers());
    #   headers.put("foo", "bar"); // set "foo" header
    #   headers.remove("origin"); // remove "origin" header
    #   route.resume(new Route.ResumeOptions().setHeaders(headers));
    # });
    # ```
    #
    # ```python async
    # async def handle(route, request):
    #     # override headers
    #     headers = {
    #         **request.headers,
    #         "foo": "bar" # set "foo" header
    #         "origin": None # remove "origin" header
    #     }
    #     await route.continue_(headers=headers)
    # }
    # await page.route("**/*", handle)
    # ```
    #
    # ```python sync
    # def handle(route, request):
    #     # override headers
    #     headers = {
    #         **request.headers,
    #         "foo": "bar" # set "foo" header
    #         "origin": None # remove "origin" header
    #     }
    #     route.continue_(headers=headers)
    # }
    # page.route("**/*", handle)
    # ```
    #
    # ```csharp
    # await page.RouteAsync("**/*", route =>
    # {
    #     var headers = new Dictionary<string, string>(route.Request.Headers) { { "foo", "bar" } };
    #     headers.Remove("origin");
    #     route.ContinueAsync(headers);
    # });
    # ```
    def continue(headers: nil, method: nil, postData: nil, url: nil)
      wrap_impl(@impl.continue(headers: unwrap_impl(headers), method: unwrap_impl(method), postData: unwrap_impl(postData), url: unwrap_impl(url)))
    end

    # Fulfills route's request with given response.
    #
    # An example of fulfilling all requests with 404 responses:
    #
    #
    # ```js
    # await page.route('**/*', route => {
    #   route.fulfill({
    #     status: 404,
    #     contentType: 'text/plain',
    #     body: 'Not Found!'
    #   });
    # });
    # ```
    #
    # ```java
    # page.route("**/*", route -> {
    #   route.fulfill(new Route.FulfillOptions()
    #     .setStatus(404)
    #     .setContentType("text/plain")
    #     .setBody("Not Found!"));
    # });
    # ```
    #
    # ```python async
    # await page.route("**/*", lambda route: route.fulfill(
    #     status=404,
    #     content_type="text/plain",
    #     body="not found!"))
    # ```
    #
    # ```python sync
    # page.route("**/*", lambda route: route.fulfill(
    #     status=404,
    #     content_type="text/plain",
    #     body="not found!"))
    # ```
    #
    # ```csharp
    # await page.RouteAsync("**/*", route => route.FulfillAsync(
    #     status: 404,
    #     contentType: "text/plain",
    #     body: "Not Found!"));
    # ```
    #
    # An example of serving static file:
    #
    #
    # ```js
    # await page.route('**/xhr_endpoint', route => route.fulfill({ path: 'mock_data.json' }));
    # ```
    #
    # ```java
    # page.route("**/xhr_endpoint", route -> route.fulfill(
    #   new Route.FulfillOptions().setPath(Paths.get("mock_data.json")));
    # ```
    #
    # ```python async
    # await page.route("**/xhr_endpoint", lambda route: route.fulfill(path="mock_data.json"))
    # ```
    #
    # ```python sync
    # page.route("**/xhr_endpoint", lambda route: route.fulfill(path="mock_data.json"))
    # ```
    #
    # ```csharp
    # await page.RouteAsync("**/xhr_endpoint", route => route.FulfillAsync(path: "mock_data.json"));
    # ```
    def fulfill(
          body: nil,
          contentType: nil,
          headers: nil,
          path: nil,
          status: nil)
      wrap_impl(@impl.fulfill(body: unwrap_impl(body), contentType: unwrap_impl(contentType), headers: unwrap_impl(headers), path: unwrap_impl(path), status: unwrap_impl(status)))
    end

    # A request to be routed.
    def request
      wrap_impl(@impl.request)
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
