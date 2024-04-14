# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_0ef62eead1348f28a69716a047f3b75c979d3230569d3720d4e7bdd0a22ef647 (Page#route)

```
def handle_route(route: Route):
  if ("my-string" in route.request.post_data):
    route.fulfill(body="mocked-data")
  else:
    route.continue_()
page.route("/api/**", handle_route)

```

### example_dc2ddfffc781ad5e734ad6fd70abb2d97e20b9d403e8f45a0ab01a65c9a2d4f8 (BrowserContext#clear_cookies)

```
context.clear_cookies()
context.clear_cookies(name="session-id")
context.clear_cookies(domain="my-origin.com")
context.clear_cookies(path="/api/v1")
context.clear_cookies(name="session-id", domain="my-origin.com")

```

### example_c78483d1434363f907c28aecef3a1c6d83c0136d98bb07c2bd326cd19e006aa9 (BrowserContext#route)

```
def handle_route(route: Route):
  if ("my-string" in route.request.post_data):
    route.fulfill(body="mocked-data")
  else:
    route.continue_()
context.route("/api/**", handle_route)

```
