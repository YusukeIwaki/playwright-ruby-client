---
sidebar_position: 10
---

# BrowserContext

- extends: [EventEmitter]

BrowserContexts provide a way to operate multiple independent browser sessions.

If a page opens another page, e.g. with a `window.open` call, the popup will belong to the parent page's browser
context.

Playwright allows creation of "incognito" browser contexts with [Browser#new_context](./browser#new_context) method. "Incognito" browser
contexts don't write any browsing data to disk.

```ruby
# create a new incognito browser context
context = browser.new_context

# create a new page inside context.
page = context.new_page
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

```ruby
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

```ruby
# in your playwright script, assuming the preload.js file is in same directory.
browser_context.add_init_script(path: "preload.js")
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

```ruby
context = browser.new_context
context.grant_permissions(["clipboard-read"])

# do stuff ..

context.clear_permissions
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

The first argument of the `callback` function contains information about the caller: `{ browser_context: BrowserContext, page: Page, frame: Frame }`.

See [Page#expose_binding](./page#expose_binding) for page-only version.

An example of exposing page URL to all frames in all pages in the context:

```ruby
browser_context.expose_binding("pageURL", ->(source) { source[:page].url })
page = browser_context.new_page

page.content = <<~HTML
<script>
  async function onClick() {
    document.querySelector('div').textContent = await window.pageURL();
  }
</script>
<button onclick="onClick()">Click me</button>
<div></div>
HTML

page.click("button")
```

An example of passing an element handle:

```ruby
def print_text(source, element)
  element.text_content
end

browser_context.expose_binding("clicked", method(:print_text), handle: true)
page = browser_context.new_page

page.content = <<~HTML
<script>
  document.addEventListener('click', async (event) => {
    alert(await window.clicked(event.target));
  })
</script>
<div>Click me</div>
<div>Or click me</div>
HTML

page.click('div')
```



## expose_function

```
def expose_function(name, callback)
```

The method adds a function called `name` on the `window` object of every frame in every page in the context. When
called, the function executes `callback` and returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) which resolves to the return value of `callback`.

If the `callback` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), it will be awaited.

See [Page#expose_function](./page#expose_function) for page-only version.

An example of adding a `sha256` function to all pages in the context:

```ruby
require 'digest'

def sha256(text)
  Digest::SHA256.hexdigest(text)
end

browser_context.expose_function("sha256", method(:sha256))
page = browser_context.new_page()
page.content = <<~HTML
<script>
  async function onClick() {
    document.querySelector('div').textContent = await window.sha256('PLAYWRIGHT');
  }
</script>
<button onclick="onClick()">Click me</button>
<div></div>
HTML
page.click("button")
```



## grant_permissions

```
def grant_permissions(permissions, origin: nil)
```

Grants specified permissions to the browser context. Only grants corresponding permissions to the given origin if
specified.

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
def route(url, handler)
```

Routing provides the capability to modify network requests that are made by any page in the browser context. Once route
is enabled, every request matching the url pattern will stall unless it's continued, fulfilled or aborted.

An example of a naive handler that aborts all image requests:

```ruby
context = browser.new_context
page = context.new_page
context.route("**/*.{png,jpg,jpeg}", ->(route, request) { route.abort })
page.goto("https://example.com")
```

or the same snippet using a regex pattern instead:

```ruby
context = browser.new_context
page = context.new_page
context.route(/\.(png|jpg)$/, ->(route, request) { route.abort })
page.goto("https://example.com")
```

It is possible to examine the request to decide the route action. For example, mocking all requests that contain some
post data, and leaving all other requests as is:

```ruby
def handle_route(route, request)
  if request.post_data["my-string"]
    mocked_data = request.post_data.merge({ "my-string" => 'mocked-data'})
    route.fulfill(postData: mocked_data)
  else
    route.continue
  end
end
context.route("/api/**", method(:handle_route))
```

Page routes (set up with [Page#route](./page#route)) take precedence over browser context routes when request matches both
handlers.

To remove a route with its handler you can use [BrowserContext#unroute](./browser_context#unroute).

> NOTE: Enabling routing disables http cache.

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

> NOTE: [Page#set_default_navigation_timeout](./page#set_default_navigation_timeout) and [Page#set_default_timeout](./page#set_default_timeout) take priority over
[BrowserContext#set_default_navigation_timeout](./browser_context#set_default_navigation_timeout).

## set_default_timeout

```
def set_default_timeout(timeout)
```
alias: `default_timeout=`

This setting will change the default maximum time for all the methods accepting `timeout` option.

> NOTE: [Page#set_default_navigation_timeout](./page#set_default_navigation_timeout), [Page#set_default_timeout](./page#set_default_timeout) and
[BrowserContext#set_default_navigation_timeout](./browser_context#set_default_navigation_timeout) take priority over [BrowserContext#set_default_timeout](./browser_context#set_default_timeout).

## set_extra_http_headers

```
def set_extra_http_headers(headers)
```
alias: `extra_http_headers=`

The extra HTTP headers will be sent with every request initiated by any page in the context. These headers are merged
with page-specific extra HTTP headers set with [Page#set_extra_http_headers](./page#set_extra_http_headers). If page overrides a particular
header, page-specific header value will be used instead of the browser context header value.

> NOTE: [BrowserContext#set_extra_http_headers](./browser_context#set_extra_http_headers) does not guarantee the order of headers in the outgoing requests.

## set_geolocation

```
def set_geolocation(geolocation)
```
alias: `geolocation=`

Sets the context's geolocation. Passing `null` or `undefined` emulates position unavailable.

```ruby
browser_context.geolocation = { latitude: 59.95, longitude: 30.31667 }
```

> NOTE: Consider using [BrowserContext#grant_permissions](./browser_context#grant_permissions) to grant permissions for the browser context pages to
read its geolocation.

## set_offline

```
def set_offline(offline)
```
alias: `offline=`



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

```ruby
new_page = browser_context.expect_event('page') do
  page.click('button')
end
```



## expect_page

```
def expect_page(predicate: nil, timeout: nil)
```

Performs action and waits for a new [Page](./page) to be created in the context. If predicate is provided, it passes [Page](./page) value into the `predicate` and waits for `predicate.call(page)` to return a truthy value. Will throw an error if
the context closes before new [Page](./page) is created.

## tracing
