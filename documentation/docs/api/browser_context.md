---
sidebar_position: 10
---

# BrowserContext

- extends: [EventEmitter]

BrowserContexts provide a way to operate multiple independent browser sessions.

If a page opens another page, e.g. with a `window.open` call, the popup will belong to the parent page's browser
context.

Playwright allows creating "incognito" browser contexts with [Browser#new_context](./browser#new_context) method. "Incognito"
browser contexts don't write any browsing data to disk.

```py title=example_020322a50b8dc608fa33c235a671e48663aa81f496f5d5dd13f687a3862591d8.py
# create a new incognito browser context
context = await browser.new_context()
# create a new page inside context.
page = await context.new_page()
await page.goto("https://example.com")
# dispose context once it is no longer needed.
await context.close()

```

```py title=example_b91bf8bde66c133e16f010d447991b1face05f1dbbd19a63078650f239798d0b.py
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

Adds cookies into this browser context. All pages within this context will have these cookies installed. Cookies
can be obtained via [BrowserContext#cookies](./browser_context#cookies).

**Usage**

```py title=example_78d28363130d1792dbc1001974cb8f9385c7fa40ef65b0d87dda916438fa1ca5.py
await browser_context.add_cookies([cookie_object1, cookie_object2])

```

```py title=example_fe865e261a072562c57af0b35937fe2014578f75d60089990774521e5c56be7c.py
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

The script is evaluated after the document was created but before any of its scripts were run. This is useful to
amend the JavaScript environment, e.g. to seed `Math.random`.

**Usage**

An example of overriding `Math.random` before the page loads:

```py title=example_12d70c83325be78806c334a8f3bd1b717a54ba64d4df5fb997b3b492b9bc0d4a.py
# in your playwright script, assuming the preload.js file is in same directory.
await browser_context.add_init_script(path="preload.js")

```

```py title=example_aa62e83764cf619192d335f2da300d285f4c10d6546a136b2507af4663cfa53a.py
# in your playwright script, assuming the preload.js file is in same directory.
browser_context.add_init_script(path="preload.js")

```

**NOTE** The order of evaluation of multiple scripts installed via [BrowserContext#add_init_script](./browser_context#add_init_script) and
[Page#add_init_script](./page#add_init_script) is not defined.

## background_pages

```
def background_pages
```

**NOTE** Background pages are only supported on Chromium-based browsers.

All existing background pages in the context.

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

**Usage**

```py title=example_c961afa052ca580c7a859ceb2e42bed2e7421b4522f41b3e0ed109ea7b593ca1.py
context = await browser.new_context()
await context.grant_permissions(["clipboard-read"])
# do stuff ..
context.clear_permissions()

```

```py title=example_bc598e39b92e30b5450b944e776329c5281c86a75a1c241d9095f8bae0ee0313.py
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

**NOTE** The default browser context cannot be closed.

## cookies

```
def cookies(urls: nil)
```

If no URLs are specified, this method returns all cookies. If URLs are specified, only cookies that affect those
URLs are returned.

## expose_binding

```
def expose_binding(name, callback, handle: nil)
```

The method adds a function called `name` on the `window` object of every frame in every page in the context. When
called, the function executes `callback` and returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) which resolves to the return value of `callback`.
If the `callback` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), it will be awaited.

The first argument of the `callback` function contains information about the caller: `{ browserContext:
BrowserContext, page: Page, frame: Frame }`.

See [Page#expose_binding](./page#expose_binding) for page-only version.

**Usage**

An example of exposing page URL to all frames in all pages in the context:

```py title=example_60539b6e03d9e600dab8d44fdb4f42de0aa65a41d2244948f4746bb0691b8a2b.py
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    webkit = playwright.webkit
    browser = await webkit.launch(headless=false)
    context = await browser.new_context()
    await context.expose_binding("pageURL", lambda source: source["page"].url)
    page = await context.new_page()
    await page.set_content("""
    <script>
      async function onClick() {
        document.querySelector('div').textContent = await window.pageURL();
      }
    </script>
    <button onclick="onClick()">Click me</button>
    <div></div>
    """)
    await page.get_by_role("button").click()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

```py title=example_c3e57462d511be77380e7f4e3a842043c543994b58256ed79f598d0d427ef3e5.py
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
    page.get_by_role("button").click()

with sync_playwright() as playwright:
    run(playwright)

```

An example of passing an element handle:

```py title=example_9a5b46c08a2631a58b2fe92b360b8ca420fbe73999bc11232a2aa5f3cc6a2ca4.py
async def print(source, element):
    print(await element.text_content())

await context.expose_binding("clicked", print, handle=true)
await page.set_content("""
  <script>
    document.addEventListener('click', event => window.clicked(event.target));
  </script>
  <div>Click me</div>
  <div>Or click me</div>
""")

```

```py title=example_667879293e0c7fae47ee11d7f9302e8209888b77db7c701c0e47ce59484e444d.py
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

**Usage**

An example of adding a `sha256` function to all pages in the context:

```py title=example_d68353678001695a91e66fe0a2bf04023922ef20369f542fadc1e1e73131b383.py
import asyncio
import hashlib
from playwright.async_api import async_playwright

def sha256(text):
    m = hashlib.sha256()
    m.update(bytes(text, "utf8"))
    return m.hexdigest()


async def run(playwright):
    webkit = playwright.webkit
    browser = await webkit.launch(headless=False)
    context = await browser.new_context()
    await context.expose_function("sha256", sha256)
    page = await context.new_page()
    await page.set_content("""
        <script>
          async function onClick() {
            document.querySelector('div').textContent = await window.sha256('PLAYWRIGHT');
          }
        </script>
        <button onclick="onClick()">Click me</button>
        <div></div>
    """)
    await page.get_by_role("button").click()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

```py title=example_828382ffa200879421f711ad0038d51ff0d60a8ff1e437930d170428f765ec07.py
import hashlib
from playwright.sync_api import sync_playwright

def sha256(text):
    m = hashlib.sha256()
    m.update(bytes(text, "utf8"))
    return m.hexdigest()


def run(playwright):
    webkit = playwright.webkit
    browser = webkit.launch(headless=False)
    context = browser.new_context()
    context.expose_function("sha256", sha256)
    page = context.new_page()
    page.set_content("""
        <script>
          async function onClick() {
            document.querySelector('div').textContent = await window.sha256('PLAYWRIGHT');
          }
        </script>
        <button onclick="onClick()">Click me</button>
        <div></div>
    """)
    page.get_by_role("button").click()

with sync_playwright() as playwright:
    run(playwright)

```



## grant_permissions

```
def grant_permissions(permissions, origin: nil)
```

Grants specified permissions to the browser context. Only grants corresponding permissions to the given origin if
specified.

## new_cdp_session

```
def new_cdp_session(page)
```

**NOTE** CDP sessions are only supported on Chromium-based browsers.

Returns the newly created session.

## new_page

```
def new_page(&block)
```

Creates a new page in the browser context.

## pages

```
def pages
```

Returns all open pages in the context.

## route

```
def route(url, handler, times: nil)
```

Routing provides the capability to modify network requests that are made by any page in the browser context. Once
route is enabled, every request matching the url pattern will stall unless it's continued, fulfilled or aborted.

**NOTE** [BrowserContext#route](./browser_context#route) will not intercept requests intercepted by Service Worker. See
[this](https://github.com/microsoft/playwright/issues/1090) issue. We recommend disabling Service Workers when
using request interception by setting `Browser.newContext.serviceWorkers` to `'block'`.

**Usage**

An example of a naive handler that aborts all image requests:

```py title=example_7040d21702f3f08ac71d49c7df013d85c00cb20141ea248241e51a33aa32413f.py
context = await browser.new_context()
page = await context.new_page()
await context.route("**/*.{png,jpg,jpeg}", lambda route: route.abort())
await page.goto("https://example.com")
await browser.close()

```

```py title=example_df7146a147a3f30db5f1191b8dc36a953ce63e68613de6646daf776461879a34.py
context = browser.new_context()
page = context.new_page()
context.route("**/*.{png,jpg,jpeg}", lambda route: route.abort())
page.goto("https://example.com")
browser.close()

```

or the same snippet using a regex pattern instead:

```py title=example_987f6f946d8bccb9b13a36a1a22be986ab70b78e63ef0cfddfd0f7d4757be0ba.py
context = await browser.new_context()
page = await context.new_page()
await context.route(re.compile(r"(\.png$)|(\.jpg$)"), lambda route: route.abort())
page = await context.new_page()
await page.goto("https://example.com")
await browser.close()

```

```py title=example_8b9f1b968d7727a6bb5a90587e19d26f2f4e8db804ef8c8c07e18a3f91620f45.py
context = browser.new_context()
page = context.new_page()
context.route(re.compile(r"(\.png$)|(\.jpg$)"), lambda route: route.abort())
page = await context.new_page()
page = context.new_page()
page.goto("https://example.com")
browser.close()

```

It is possible to examine the request to decide the route action. For example, mocking all requests that contain
some post data, and leaving all other requests as is:

```py title=example_cfc07cb3774fdf0af1e558f523a8aa19211b24bb2fcdf507366ee39b8f3a5f8f.py
def handle_route(route):
  if ("my-string" in route.request.post_data)
    route.fulfill(body="mocked-data")
  else
    route.continue_()
await context.route("/api/**", handle_route)

```

```py title=example_e75265767423dfd5097f05e0922cb03bfb21fa0b4f0ea26373c8fb4f520a1952.py
def handle_route(route):
  if ("my-string" in route.request.post_data)
    route.fulfill(body="mocked-data")
  else
    route.continue_()
context.route("/api/**", handle_route)

```

Page routes (set up with [Page#route](./page#route)) take precedence over browser context routes when request matches
both handlers.

To remove a route with its handler you can use [BrowserContext#unroute](./browser_context#unroute).

**NOTE** Enabling routing disables http cache.

## route_from_har

```
def route_from_har(har, notFound: nil, update: nil, url: nil)
```

If specified the network requests that are made in the context will be served from the HAR file. Read more about
[Replaying from HAR](https://playwright.dev/python/docs/network).

Playwright will not serve requests intercepted by Service Worker from the HAR file. See
[this](https://github.com/microsoft/playwright/issues/1090) issue. We recommend disabling Service Workers when
using request interception by setting `Browser.newContext.serviceWorkers` to `'block'`.

## service_workers

```
def service_workers
```

**NOTE** Service workers are only supported on Chromium-based browsers.

All existing service workers in the context.

## set_default_navigation_timeout

```
def set_default_navigation_timeout(timeout)
```
alias: `default_navigation_timeout=`

This setting will change the default maximum navigation time for the following methods and related shortcuts:
- [Page#go_back](./page#go_back)
- [Page#go_forward](./page#go_forward)
- [Page#goto](./page#goto)
- [Page#reload](./page#reload)
- [Page#set_content](./page#set_content)
- [Page#expect_navigation](./page#expect_navigation)

**NOTE** [Page#set_default_navigation_timeout](./page#set_default_navigation_timeout) and [Page#set_default_timeout](./page#set_default_timeout) take priority over
[BrowserContext#set_default_navigation_timeout](./browser_context#set_default_navigation_timeout).

## set_default_timeout

```
def set_default_timeout(timeout)
```
alias: `default_timeout=`

This setting will change the default maximum time for all the methods accepting `timeout` option.

**NOTE** [Page#set_default_navigation_timeout](./page#set_default_navigation_timeout), [Page#set_default_timeout](./page#set_default_timeout) and
[BrowserContext#set_default_navigation_timeout](./browser_context#set_default_navigation_timeout) take priority over
[BrowserContext#set_default_timeout](./browser_context#set_default_timeout).

## set_extra_http_headers

```
def set_extra_http_headers(headers)
```
alias: `extra_http_headers=`

The extra HTTP headers will be sent with every request initiated by any page in the context. These headers are
merged with page-specific extra HTTP headers set with [Page#set_extra_http_headers](./page#set_extra_http_headers). If page overrides a
particular header, page-specific header value will be used instead of the browser context header value.

**NOTE** [BrowserContext#set_extra_http_headers](./browser_context#set_extra_http_headers) does not guarantee the order of headers in the outgoing
requests.

## set_geolocation

```
def set_geolocation(geolocation)
```
alias: `geolocation=`

Sets the context's geolocation. Passing `null` or `undefined` emulates position unavailable.

**Usage**

```py title=example_cba077118aa07126ab350d068577d6e6e773f1ded7f667591695968f1766e45f.py
await browser_context.set_geolocation({"latitude": 59.95, "longitude": 30.31667})

```

```py title=example_9c8c7e9a664b97b3a7eced35b593c24fb5c390e420d3a8ff2a01a19f81b1c385.py
browser_context.set_geolocation({"latitude": 59.95, "longitude": 30.31667})

```

**NOTE** Consider using [BrowserContext#grant_permissions](./browser_context#grant_permissions) to grant permissions for the browser context
pages to read its geolocation.

## set_offline

```
def set_offline(offline)
```
alias: `offline=`



## storage_state

```
def storage_state(path: nil)
```

Returns storage state for this browser context, contains current cookies and local storage snapshot.

## unroute

```
def unroute(url, handler: nil)
```

Removes a route created with [BrowserContext#route](./browser_context#route). When `handler` is not specified, removes all routes
for the `url`.

## expect_event

```
def expect_event(event, predicate: nil, timeout: nil, &block)
```

Waits for event to fire and passes its value into the predicate function. Returns when the predicate returns truthy
value. Will throw an error if the context closes before the event is fired. Returns the event data value.

**Usage**

```py title=example_d3b3b841e07375654a1816e40c1c523d3142f1ede064ff9e98fd5f2f8564d85f.py
async with context.expect_event("page") as event_info:
    await page.get_by_role("button").click()
page = await event_info.value

```

```py title=example_eb91c13e380381cbdd6b7348784862bb703ed3742c390d96a4384f70125b3223.py
with context.expect_event("page") as event_info:
    page.get_by_role("button").click()
page = event_info.value

```



## expect_page

```
def expect_page(predicate: nil, timeout: nil)
```

Performs action and waits for a new [Page](./page) to be created in the context. If predicate is provided, it passes [Page](./page) value into the `predicate` and waits for `predicate.call(page)` to return a truthy value. Will throw an error
if the context closes before new [Page](./page) is created.

## request

API testing helper associated with this context. Requests made with this API will use context cookies.

## tracing
