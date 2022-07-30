---
sidebar_position: 10
---

# Route

Whenever a network route is set up with [Page#route](./page#route) or [BrowserContext#route](./browser_context#route), the [Route](./route) object
allows to handle the route.

Learn more about [networking](https://playwright.dev/python/docs/network).

## abort

```
def abort(errorCode: nil)
```

Aborts the route's request.

## continue

```
def continue(headers: nil, method: nil, postData: nil, url: nil)
```

Continues route's request with optional overrides.

```python sync title=example_bbeb6c856287d9a14962cd222891b682b8f1c52dafcf933198e651e634906122.py
def handle(route, request):
    # override headers
    headers = {
        **request.headers,
        "foo": "foo-value" # set "foo" header
        "bar": None # remove "bar" header
    }
    route.continue_(headers=headers)
}
page.route("**/*", handle)

```



## fallback

```
def fallback(headers: nil, method: nil, postData: nil, url: nil)
```

When several routes match the given pattern, they run in the order opposite to their registration. That way the last
registered route can always override all the previos ones. In the example below, request will be handled by the
bottom-most handler first, then it'll fall back to the previous one and in the end will be aborted by the first
registered route.

```python sync title=example_347531c10d6bf4b1f6e727494b385f224aa59a068df9073b0afaa2ca1b66362d.py
page.route("**/*", lambda route: route.abort())  # Runs last.
page.route("**/*", lambda route: route.fallback())  # Runs second.
page.route("**/*", lambda route: route.fallback())  # Runs first.

```

Registering multiple routes is useful when you want separate handlers to handle different kinds of requests, for example
API calls vs page resources or GET requests vs POST requests as in the example below.

```python sync title=example_2b4eca732c7ed8d0d22b23cd55d462cdd20bfc2f94f19640e744e265f53286ca.py
# Handle GET requests.
def handle_post(route):
    if route.request.method != "GET":
        route.fallback()
        return
  # Handling GET only.
  # ...

# Handle POST requests.
def handle_post(route):
    if route.request.method != "POST":
        route.fallback()
        return
  # Handling POST only.
  # ...

page.route("**/*", handle_get)
page.route("**/*", handle_post)

```

One can also modify request while falling back to the subsequent handler, that way intermediate route handler can modify
url, method, headers and postData of the request.

```python sync title=example_457b18e26c0c4a1a8074c8678d0377ba50fe9d0eeb1ef2b520acbb2c68da240a.py
def handle(route, request):
    # override headers
    headers = {
        **request.headers,
        "foo": "foo-value" # set "foo" header
        "bar": None # remove "bar" header
    }
    route.fallback(headers=headers)
}
page.route("**/*", handle)

```



## fulfill

```
def fulfill(
      body: nil,
      contentType: nil,
      headers: nil,
      path: nil,
      response: nil,
      status: nil)
```

Fulfills route's request with given response.

An example of fulfilling all requests with 404 responses:

```ruby
page.route("**/*", ->(route, request) {
  route.fulfill(
    status: 404,
    contentType: 'text/plain',
    body: 'not found!!',
  )
})
```

An example of serving static file:

```ruby
page.route("**/xhr_endpoint", ->(route, _) { route.fulfill(path: "mock_data.json") })
```



## request

```
def request
```

A request to be routed.
