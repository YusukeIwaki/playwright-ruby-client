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

```ruby
def handle(route, request)
  # override headers
  headers = request.headers
  headers['foo'] = 'bar' # set "foo" header
  headers['user-agent'] = 'Unknown Browser' # modify user-agent

  route.continue(headers: headers)
end
page.route("**/*", method(:handle))
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
