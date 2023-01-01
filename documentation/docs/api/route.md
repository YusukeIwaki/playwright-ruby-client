---
sidebar_position: 10
---

# Route

Whenever a network route is set up with [Page#route](./page#route) or [BrowserContext#route](./browser_context#route), the [Route](./route)
object allows to handle the route.

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

**Usage**

```py title=example_a9da256807ad7bc5787da691fc82b14b067741051d3d96c184e4e697dfaadede.py
async def handle(route, request):
    # override headers
    headers = {
        **request.headers,
        "foo": "foo-value" # set "foo" header
        "bar": None # remove "bar" header
    }
    await route.continue_(headers=headers)

await page.route("**/*", handle)

```

```py title=example_8e6c4877e6e55a6646c407efa694ca2b35325d25a177ec9eda7392d589f460f6.py
def handle(route, request):
    # override headers
    headers = {
        **request.headers,
        "foo": "foo-value" # set "foo" header
        "bar": None # remove "bar" header
    }
    route.continue_(headers=headers)

page.route("**/*", handle)

```



## fallback

```
def fallback(headers: nil, method: nil, postData: nil, url: nil)
```

When several routes match the given pattern, they run in the order opposite to their registration. That way the
last registered route can always override all the previous ones. In the example below, request will be handled by
the bottom-most handler first, then it'll fall back to the previous one and in the end will be aborted by the first
registered route.

**Usage**

```py title=example_5a1b25856c2e94c50fd5664e02964d1afd6d840d6c6a3602ee6b8c4a7eaf5193.py
await page.route("**/*", lambda route: route.abort())  # Runs last.
await page.route("**/*", lambda route: route.fallback())  # Runs second.
await page.route("**/*", lambda route: route.fallback())  # Runs first.

```

```py title=example_4dba0de94a24d0de1d6c888253b7c7295e931fb54ac2051cefe15102a3a1ea84.py
page.route("**/*", lambda route: route.abort())  # Runs last.
page.route("**/*", lambda route: route.fallback())  # Runs second.
page.route("**/*", lambda route: route.fallback())  # Runs first.

```

Registering multiple routes is useful when you want separate handlers to handle different kinds of requests, for
example API calls vs page resources or GET requests vs POST requests as in the example below.

```py title=example_85faf1b8f4fc6de3ee04b4e2a4851478912bcd52c29ac0a9d81a75e4a74a5c23.py
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

await page.route("**/*", handle_get)
await page.route("**/*", handle_post)

```

```py title=example_f34f68524339404dcaf6b44a69dd897c8841025e4870e6247f3e0cb64d6d8d50.py
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

One can also modify request while falling back to the subsequent handler, that way intermediate route handler can
modify url, method, headers and postData of the request.

```py title=example_ba1031939a1b970b94dc8d8a1394e0ebf19aaf5d44eed16bf4e832888397bcfd.py
async def handle(route, request):
    # override headers
    headers = {
        **request.headers,
        "foo": "foo-value" # set "foo" header
        "bar": None # remove "bar" header
    }
    await route.fallback(headers=headers)

await page.route("**/*", handle)

```

```py title=example_427da5039b64cbfd74a02afe147db3da6392eb5812c872722bae349ec2af04f7.py
def handle(route, request):
    # override headers
    headers = {
        **request.headers,
        "foo": "foo-value" # set "foo" header
        "bar": None # remove "bar" header
    }
    route.fallback(headers=headers)

page.route("**/*", handle)

```



## fetch

```
def fetch(headers: nil, method: nil, postData: nil, url: nil)
```

Performs the request and fetches result without fulfilling it, so that the response could be modified and then
fulfilled.

**Usage**

```py title=example_16dfd34f10f41f06ac49647fc6269cfeacdb1c9dbc899dcf3a4243283cd9839f.py
async def handle(route):
    response = await route.fulfill()
    json = await response.json()
    json["message"]["big_red_dog"] = []
    await route.fulfill(response=response, json=json)

await page.route("https://dog.ceo/api/breeds/list/all", handle)

```

```py title=example_ae03b1dcd71f7860d148d648ee165279204314e9967f74dd02010597fe8ef3ac.py
def handle(route):
    response = route.fulfill()
    json = response.json()
    json["message"]["big_red_dog"] = []
    route.fulfill(response=response, json=json)

page.route("https://dog.ceo/api/breeds/list/all", handle)

```



## fulfill

```
def fulfill(
      body: nil,
      contentType: nil,
      headers: nil,
      json: nil,
      path: nil,
      response: nil,
      status: nil)
```

Fulfills route's request with given response.

**Usage**

An example of fulfilling all requests with 404 responses:

```py title=example_4a076d47c9f849e2ca57423937c13605083c7201e2f45fa36030a143ba27ec01.py
await page.route("**/*", lambda route: route.fulfill(
    status=404,
    content_type="text/plain",
    body="not found!"))

```

```py title=example_c247074da17f235a5053019429413324002ae4ead5cc6a1afe8fa05211e83bd6.py
page.route("**/*", lambda route: route.fulfill(
    status=404,
    content_type="text/plain",
    body="not found!"))

```

An example of serving static file:

```py title=example_9a7610b98fe51671faea12afd7ddcf2eba2914a6dd1cd60cf00382833ed55105.py
await page.route("**/xhr_endpoint", lambda route: route.fulfill(path="mock_data.json"))

```

```py title=example_b517c4af01a97518ee777cc3cf0f29316c1838eaf8e0fd7253e0d4b4a9590140.py
page.route("**/xhr_endpoint", lambda route: route.fulfill(path="mock_data.json"))

```



## request

```
def request
```

A request to be routed.
