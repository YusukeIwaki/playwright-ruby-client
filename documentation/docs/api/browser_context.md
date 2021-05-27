---
sidebar_position: 10
---

# BrowserContext

- extends: [EventEmitter]

BrowserContexts provide a way to operate multiple independent browser sessions.

If a page opens another page, e.g. with a `window.open` call, the popup will belong to the parent page's browser
context.

Playwright allows creation of "incognito" browser contexts with `browser.newContext()` method. "Incognito" browser
contexts don't write any browsing data to disk.

```python sync title=example_b9d02375c8dbbd86bc9ee14a9333ff363525bbec88d23ff8d8edbfda67301ad2.py
# create a new incognito browser context
context = browser.new_context()
# create a new page inside context.
page = context.new_page()
page.goto("https://example.com")
# dispose context once it is no longer needed.
context.close()

```



## add_cookies

```
def add_cookies(cookies)
```

Adds cookies into this browser context. All pages within this context will have these cookies installed. Cookies can be
obtained via [BrowserContext#cookies](./browser_context#cookies).

```python sync title=example_9a397455c0681f67226d5bcb8e14922d2a098e184daa133dc191b17bbf5c603e.py
browser_context.add_cookies([cookie_object1, cookie_object2])

```



## add_init_script

```
def add_init_script(path: nil, script: nil)
```

Adds a script which would be evaluated in one of the following scenarios:
- Whenever a page is created in the browser context or is navigated.
- Whenever a child frame is attached or navigated in any page in the browser context. In this case, the script is
  evaluated in the context of the newly attached frame.

The script is evaluated after the document was created but before any of its scripts were run. This is useful to amend
the JavaScript environment, e.g. to seed `Math.random`.

An example of overriding `Math.random` before the page loads:

```python sync title=example_16af9114b96dcc9b341808b8a5e2eb4bb1fa9541858e8d8432a33a979867ccc8.py
# in your playwright script, assuming the preload.js file is in same directory.
browser_context.add_init_script(path="preload.js")

```

> NOTE: The order of evaluation of multiple scripts installed via [BrowserContext#add_init_script](./browser_context#add_init_script) and
[Page#add_init_script](./page#add_init_script) is not defined.

## browser

```
def browser
```

Returns the browser instance of the context. If it was launched as a persistent context null gets returned.

## clear_cookies

```
def clear_cookies
```

Clears context cookies.

## clear_permissions

```
def clear_permissions
```

Clears all permission overrides for the browser context.

```python sync title=example_de61e349d06a98a38ba9bfccc5708125cd263b7d3a31b9a837eda3db0baac288.py
context = browser.new_context()
context.grant_permissions(["clipboard-read"])
# do stuff ..
context.clear_permissions()

```



## close

```
def close
```

Closes the browser context. All the pages that belong to the browser context will be closed.

> NOTE: The default browser context cannot be closed.

## cookies

```
def cookies(urls: nil)
```

If no URLs are specified, this method returns all cookies. If URLs are specified, only cookies that affect those URLs
are returned.

## expose_binding

```
def expose_binding(name, callback, handle: nil)
```

The method adds a function called `name` on the `window` object of every frame in every page in the context. When
called, the function executes `callback` and returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) which resolves to the return value of `callback`. If
the `callback` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), it will be awaited.

The first argument of the `callback` function contains information about the caller: `{ browserContext: BrowserContext,
page: Page, frame: Frame }`.

See [Page#expose_binding](./page#expose_binding) for page-only version.

An example of exposing page URL to all frames in all pages in the context:

```python sync title=example_81b90f669e98413d55dfbd74319b8b505b137187a593ed03c46b56125a286201.py
from playwright.sync_api import sync_playwright

def run(playwright):
    webkit = playwright.webkit
    browser = webkit.launch(headless=false)
    context = browser.new_context()
    context.expose_binding("pageURL", lambda source: source["page"].url)
    page = context.new_page()
    page.set_content("""
    <script>
      async function onClick() {
        document.querySelector('div').textContent = await window.pageURL();
      }
    </script>
    <button onclick="onClick()">Click me</button>
    <div></div>
    """)
    page.click("button")

with sync_playwright() as playwright:
    run(playwright)

```

An example of passing an element handle:

```python sync title=example_93e847f70b01456eec429a1ebfaa6b8f5334f4c227fd73e62dd6a7facb48dbbd.py
def print(source, element):
    print(element.text_content())

context.expose_binding("clicked", print, handle=true)
page.set_content("""
  <script>
    document.addEventListener('click', event => window.clicked(event.target));
  </script>
  <div>Click me</div>
  <div>Or click me</div>
""")

```



## expose_function

```
def expose_function(name, callback)
```

The method adds a function called `name` on the `window` object of every frame in every page in the context. When
called, the function executes `callback` and returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) which resolves to the return value of `callback`.

If the `callback` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), it will be awaited.

See [Page#expose_function](./page#expose_function) for page-only version.

An example of adding an `md5` function to all pages in the context:

```python sync title=example_ec3ef36671a002a6e12799fc5321ff60647c20c3f42fbd712d06e1c58cef75f5.py
import hashlib
from playwright.sync_api import sync_playwright

def sha1(text):
    m = hashlib.sha1()
    m.update(bytes(text, "utf8"))
    return m.hexdigest()


def run(playwright):
    webkit = playwright.webkit
    browser = webkit.launch(headless=False)
    context = browser.new_context()
    context.expose_function("sha1", sha1)
    page = context.new_page()
    page.expose_function("sha1", sha1)
    page.set_content("""
        <script>
          async function onClick() {
            document.querySelector('div').textContent = await window.sha1('PLAYWRIGHT');
          }
        </script>
        <button onclick="onClick()">Click me</button>
        <div></div>
    """)
    page.click("button")

with sync_playwright() as playwright:
    run(playwright)

```



## grant_permissions

```
def grant_permissions(permissions, origin: nil)
```

Grants specified permissions to the browser context. Only grants corresponding permissions to the given origin if
specified.

## new_page

```
def new_page
```

Creates a new page in the browser context.

## pages

```
def pages
```

Returns all open pages in the context.

## route

```
def route(url, handler)
```

Routing provides the capability to modify network requests that are made by any page in the browser context. Once route
is enabled, every request matching the url pattern will stall unless it's continued, fulfilled or aborted.

An example of a naive handler that aborts all image requests:

```python sync title=example_8bee851cbea1ae0c60fba8361af41cc837666490d20c25552a32f79c4e044721.py
context = browser.new_context()
page = context.new_page()
context.route("**/*.{png,jpg,jpeg}", lambda route: route.abort())
page.goto("https://example.com")
browser.close()

```

or the same snippet using a regex pattern instead:

```python sync title=example_aa8a83c2ddd0d9a327cfce8528c61f52cb5d6ec0f0258e03d73fad5481f15360.py
context = browser.new_context()
page = context.new_page()
context.route(re.compile(r"(\.png$)|(\.jpg$)"), lambda route: route.abort())
page = await context.new_page()
page = context.new_page()
page.goto("https://example.com")
browser.close()

```

It is possible to examine the request to decide the route action. For example, mocking all requests that contain some
post data, and leaving all other requests as is:

```python sync title=example_ac637e238bebf237fca2ef4fd8a2ef81644eefcf862b305de633c2fabc3b4721.py
def handle_route(route):
  if ("my-string" in route.request.post_data)
    route.fulfill(body="mocked-data")
  else
    route.continue_()
context.route("/api/**", handle_route)

```

Page routes (set up with [Page#route](./page#route)) take precedence over browser context routes when request matches both
handlers.

To remove a route with its handler you can use [BrowserContext#unroute](./browser_context#unroute).

> NOTE: Enabling routing disables http cache.

## set_default_navigation_timeout

```
def set_default_navigation_timeout(timeout)
```

This setting will change the default maximum navigation time for the following methods and related shortcuts:
- [Page#go_back](./page#go_back)
- [Page#go_forward](./page#go_forward)
- [Page#goto](./page#goto)
- [Page#reload](./page#reload)
- [Page#set_content](./page#set_content)
- [`method: Page.waitForNavigation`]

> NOTE: [Page#set_default_navigation_timeout](./page#set_default_navigation_timeout) and [Page#set_default_timeout](./page#set_default_timeout) take priority over
[BrowserContext#set_default_navigation_timeout](./browser_context#set_default_navigation_timeout).

## set_default_timeout

```
def set_default_timeout(timeout)
```

This setting will change the default maximum time for all the methods accepting `timeout` option.

> NOTE: [Page#set_default_navigation_timeout](./page#set_default_navigation_timeout), [Page#set_default_timeout](./page#set_default_timeout) and
[BrowserContext#set_default_navigation_timeout](./browser_context#set_default_navigation_timeout) take priority over [BrowserContext#set_default_timeout](./browser_context#set_default_timeout).

## set_extra_http_headers

```
def set_extra_http_headers(headers)
```

The extra HTTP headers will be sent with every request initiated by any page in the context. These headers are merged
with page-specific extra HTTP headers set with [Page#set_extra_http_headers](./page#set_extra_http_headers). If page overrides a particular
header, page-specific header value will be used instead of the browser context header value.

> NOTE: [BrowserContext#set_extra_http_headers](./browser_context#set_extra_http_headers) does not guarantee the order of headers in the outgoing requests.

## set_geolocation

```
def set_geolocation(geolocation)
```

Sets the context's geolocation. Passing `null` or `undefined` emulates position unavailable.

```python sync title=example_12142bb78171e322de3049ac91a332da192d99461076da67614b9520b7cd0c6f.py
browser_context.set_geolocation({"latitude": 59.95, "longitude": 30.31667})

```

> NOTE: Consider using [BrowserContext#grant_permissions](./browser_context#grant_permissions) to grant permissions for the browser context pages to
read its geolocation.

## set_offline

```
def set_offline(offline)
```



## unroute

```
def unroute(url, handler: nil)
```

Removes a route created with [BrowserContext#route](./browser_context#route). When `handler` is not specified, removes all routes for
the `url`.

## expect_event

```
def expect_event(event, predicate: nil, timeout: nil, &block)
```

Waits for event to fire and passes its value into the predicate function. Returns when the predicate returns truthy
value. Will throw an error if the context closes before the event is fired. Returns the event data value.

```python sync title=example_80ebd2eab628fbcf7b668dcf8abf7f058ec345ba2b67e6cc9330c1710c732240.py
with context.expect_event("page") as event_info:
    page.click("button")
page = event_info.value

```



## expect_page

```
def expect_page(predicate: nil, timeout: nil)
```

Performs action and waits for a new [Page](./page) to be created in the context. If predicate is provided, it passes [Page](./page)
value into the `predicate` function and waits for `predicate(event)` to return a truthy value. Will throw an error if
the context closes before new [Page](./page) is created.

## tracing
