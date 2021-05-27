---
sidebar_position: 10
---

# Route

Whenever a network route is set up with [Page#route](./page#route) or [BrowserContext#route](./browser_context#route), the [Route](./route) object
allows to handle the route.

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

```python sync title=example_1960aabd58c9553683368e29429d39c1209d35e6e3625bbef1280a1fa022a9ee.py
def handle(route, request):
    # override headers
    headers = {
        **request.headers,
        "foo": "bar" # set "foo" header
        "origin": None # remove "origin" header
    }
    route.continue_(headers=headers)
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
      status: nil)
```

Fulfills route's request with given response.

An example of fulfilling all requests with 404 responses:

```python sync title=example_6d2dfd4bb5c8360f8d80bb91c563b0bd9b99aa24595063cf85e5a6e1b105f89c.py
page.route("**/*", lambda route: route.fulfill(
    status=404,
    content_type="text/plain",
    body="not found!"))

```

An example of serving static file:

```python sync title=example_c77fd0986d0b74c905cd9417756c76775e612cc86410f9a5aabc5b46d233d150.py
page.route("**/xhr_endpoint", lambda route: route.fulfill(path="mock_data.json"))

```



## request

```
def request
```

A request to be routed.
