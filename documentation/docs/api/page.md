---
sidebar_position: 10
---

# Page

- extends: [EventEmitter]

Page provides methods to interact with a single tab in a [Browser](./browser), or an
[extension background page](https://developer.chrome.com/extensions/background_pages) in Chromium. One [Browser](./browser)
instance might have multiple [Page](./page) instances.

This example creates a page, navigates it to a URL, and then saves a screenshot:

```ruby
playwright.webkit.launch do |browser|
  page = browser.new_page
  page.goto('https://example.com/')
  page.screenshot(path: 'screenshot.png')
end
```

The Page class emits various events (described below) which can be handled using any of Node's native
[`EventEmitter`](https://nodejs.org/api/events.html#events_class_eventemitter) methods, such as `on`, `once` or
`removeListener`.

This example logs a message for a single page `load` event:

```ruby
page.once("load", -> (page) { puts "page loaded!" })
```

To unsubscribe from events use the `removeListener` method:

```ruby
listener = -> (req) { puts "a request was made: #{req.url}" }
page.on('request', listener)
page.goto('https://example.com/') # => prints 'a request was made: https://example.com/'
page.off('request', listener)
page.goto('https://example.com/') # => no print
```



## add_init_script

```
def add_init_script(path: nil, script: nil)
```

Adds a script which would be evaluated in one of the following scenarios:
- Whenever the page is navigated.
- Whenever the child frame is attached or navigated. In this case, the script is evaluated in the context of the newly
  attached frame.

The script is evaluated after the document was created but before any of its scripts were run. This is useful to amend
the JavaScript environment, e.g. to seed `Math.random`.

An example of overriding `Math.random` before the page loads:

```ruby
# in your playwright script, assuming the preload.js file is in same directory
page.add_init_script(path: "./preload.js")
```

> NOTE: The order of evaluation of multiple scripts installed via [BrowserContext#add_init_script](./browser_context#add_init_script) and
[Page#add_init_script](./page#add_init_script) is not defined.

## add_script_tag

```
def add_script_tag(content: nil, path: nil, type: nil, url: nil)
```

Adds a `<script>` tag into the page with the desired url or content. Returns the added tag when the script's onload
fires or when the script content was injected into frame.

Shortcut for main frame's [Frame#add_script_tag](./frame#add_script_tag).

## add_style_tag

```
def add_style_tag(content: nil, path: nil, url: nil)
```

Adds a `<link rel="stylesheet">` tag into the page with the desired url or a `<style type="text/css">` tag with the
content. Returns the added tag when the stylesheet's onload fires or when the CSS content was injected into frame.

Shortcut for main frame's [Frame#add_style_tag](./frame#add_style_tag).

## bring_to_front

```
def bring_to_front
```

Brings page to front (activates tab).

## check

```
def check(
      selector,
      force: nil,
      noWaitAfter: nil,
      position: nil,
      timeout: nil,
      trial: nil)
```

This method checks an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Ensure that matched element is a checkbox or a radio input. If not, this method throws. If the element is already
   checked, this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If the
   element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.
1. Ensure that the element is now checked. If not, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`. Passing
zero timeout disables this.

Shortcut for main frame's [Frame#check](./frame#check).

## click

```
def click(
      selector,
      button: nil,
      clickCount: nil,
      delay: nil,
      force: nil,
      modifiers: nil,
      noWaitAfter: nil,
      position: nil,
      timeout: nil,
      trial: nil)
```

This method clicks an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If the
   element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element, or the specified `position`.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`. Passing
zero timeout disables this.

Shortcut for main frame's [Frame#click](./frame#click).

## close

```
def close(runBeforeUnload: nil)
```

If `runBeforeUnload` is `false`, does not run any unload handlers and waits for the page to be closed. If
`runBeforeUnload` is `true` the method will run unload handlers, but will **not** wait for the page to close.

By default, `page.close()` **does not** run `beforeunload` handlers.

> NOTE: if `runBeforeUnload` is passed as true, a `beforeunload` dialog might be summoned and should be handled manually
via [`event: Page.dialog`] event.

## content

```
def content
```

Gets the full HTML contents of the page, including the doctype.

## context

```
def context
```

Get the browser context that the page belongs to.

## dblclick

```
def dblclick(
      selector,
      button: nil,
      delay: nil,
      force: nil,
      modifiers: nil,
      noWaitAfter: nil,
      position: nil,
      timeout: nil,
      trial: nil)
```

This method double clicks an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If the
   element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to double click in the center of the element, or the specified `position`.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set. Note that if the
   first click of the `dblclick()` triggers a navigation event, this method will throw.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`. Passing
zero timeout disables this.

> NOTE: `page.dblclick()` dispatches two `click` events and a single `dblclick` event.

Shortcut for main frame's [Frame#dblclick](./frame#dblclick).

## dispatch_event

```
def dispatch_event(selector, type, eventInit: nil, timeout: nil)
```

The snippet below dispatches the `click` event on the element. Regardless of the visibility state of the element,
`click` is dispatched. This is equivalent to calling
[element.click()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/click).

```python sync title=example_9220b94fd2fa381ab91448dcb551e2eb9806ad331c83454a710f4d8a280990e8.py
page.dispatch_event("button#submit", "click")

```

Under the hood, it creates an instance of an event based on the given `type`, initializes it with `eventInit` properties
and dispatches it on the element. Events are `composed`, `cancelable` and bubble by default.

Since `eventInit` is event-specific, please refer to the events documentation for the lists of initial properties:
- [DragEvent](https://developer.mozilla.org/en-US/docs/Web/API/DragEvent/DragEvent)
- [FocusEvent](https://developer.mozilla.org/en-US/docs/Web/API/FocusEvent/FocusEvent)
- [KeyboardEvent](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/KeyboardEvent)
- [MouseEvent](https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent/MouseEvent)
- [PointerEvent](https://developer.mozilla.org/en-US/docs/Web/API/PointerEvent/PointerEvent)
- [TouchEvent](https://developer.mozilla.org/en-US/docs/Web/API/TouchEvent/TouchEvent)
- [Event](https://developer.mozilla.org/en-US/docs/Web/API/Event/Event)

You can also specify [JSHandle](./js_handle) as the property value if you want live objects to be passed into the event:

```python sync title=example_9b4482b7243b7ce304d6ce8454395e23db30f3d1d83229242ab7bd2abd5b72e0.py
# note you can only create data_transfer in chromium and firefox
data_transfer = page.evaluate_handle("new DataTransfer()")
page.dispatch_event("#source", "dragstart", { "dataTransfer": data_transfer })

```



## emulate_media

```
def emulate_media(colorScheme: nil, media: nil)
```

This method changes the `CSS media type` through the `media` argument, and/or the `'prefers-colors-scheme'` media
feature, using the `colorScheme` argument.

```python sync title=example_df304caf6c61f6f44b3e2b0006a7e05552362a47b17c9ba227df76e918d88a5c.py
page.evaluate("matchMedia('screen').matches")
# → True
page.evaluate("matchMedia('print').matches")
# → False

page.emulate_media(media="print")
page.evaluate("matchMedia('screen').matches")
# → False
page.evaluate("matchMedia('print').matches")
# → True

page.emulate_media()
page.evaluate("matchMedia('screen').matches")
# → True
page.evaluate("matchMedia('print').matches")
# → False

```

```python sync title=example_f0479a2ee8d8f51dab94f48b7e121cade07e5026d4f602521cc6ccc47feb5a98.py
page.emulate_media(color_scheme="dark")
page.evaluate("matchMedia('(prefers-color-scheme: dark)').matches")
# → True
page.evaluate("matchMedia('(prefers-color-scheme: light)').matches")
# → False
page.evaluate("matchMedia('(prefers-color-scheme: no-preference)').matches")

```



## eval_on_selector

```
def eval_on_selector(selector, expression, arg: nil)
```

The method finds an element matching the specified selector within the page and passes it as a first argument to
`expression`. If no elements match the selector, the method throws an error. Returns the value of `expression`.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Page#eval_on_selector](./page#eval_on_selector) would wait for the promise to resolve and
return its value.

Examples:

```ruby
search_value = page.eval_on_selector("#search", "el => el.value")
preload_href = page.eval_on_selector("link[rel=preload]", "el => el.href")
html = page.eval_on_selector(".main-container", "(e, suffix) => e.outer_html + suffix", arg: "hello")
```

Shortcut for main frame's [Frame#eval_on_selector](./frame#eval_on_selector).

## eval_on_selector_all

```
def eval_on_selector_all(selector, expression, arg: nil)
```

The method finds all elements matching the specified selector within the page and passes an array of matched elements as
a first argument to `expression`. Returns the result of `expression` invocation.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Page#eval_on_selector_all](./page#eval_on_selector_all) would wait for the promise to resolve and
return its value.

Examples:

```ruby
div_counts = page.eval_on_selector_all("div", "(divs, min) => divs.length >= min", arg: 10)
```



## evaluate

```
def evaluate(expression, arg: nil)
```

Returns the value of the `expression` invocation.

If the function passed to the [Page#evaluate](./page#evaluate) returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Page#evaluate](./page#evaluate) would wait
for the promise to resolve and return its value.

If the function passed to the [Page#evaluate](./page#evaluate) returns a non-[Serializable](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify#description) value, then
[Page#evaluate](./page#evaluate) resolves to `undefined`. Playwright also supports transferring some additional values that are
not serializable by `JSON`: `-0`, `NaN`, `Infinity`, `-Infinity`.

Passing argument to `expression`:

```ruby
result = page.evaluate("([x, y]) => Promise.resolve(x * y)", arg: [7, 8])
puts result # => "56"
```

A string can also be passed in instead of a function:

```ruby
puts page.evaluate("1 + 2") # => 3
x = 10
puts page.evaluate("1 + #{x}") # => "11"
```

[ElementHandle](./element_handle) instances can be passed as an argument to the [Page#evaluate](./page#evaluate):

```ruby
body_handle = page.query_selector("body")
html = page.evaluate("([body, suffix]) => body.innerHTML + suffix", arg: [body_handle, "hello"])
body_handle.dispose()
```

Shortcut for main frame's [Frame#evaluate](./frame#evaluate).

## evaluate_handle

```
def evaluate_handle(expression, arg: nil)
```

Returns the value of the `expression` invocation as a [JSHandle](./js_handle).

The only difference between [Page#evaluate](./page#evaluate) and [Page#evaluate_handle](./page#evaluate_handle) is that
[Page#evaluate_handle](./page#evaluate_handle) returns [JSHandle](./js_handle).

If the function passed to the [Page#evaluate_handle](./page#evaluate_handle) returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Page#evaluate_handle](./page#evaluate_handle)
would wait for the promise to resolve and return its value.

```python sync title=example_6802829f93cc4da7e67f3886b9773c7b84054afa84251add50704f8ca6837138.py
a_window_handle = page.evaluate_handle("Promise.resolve(window)")
a_window_handle # handle for the window object.

```

A string can also be passed in instead of a function:

```python sync title=example_9daa37cfd3d747c9360d9544f64786bf49d291a6887b0efccc813215b62ae4c6.py
a_handle = page.evaluate_handle("document") # handle for the "document"

```

[JSHandle](./js_handle) instances can be passed as an argument to the [Page#evaluate_handle](./page#evaluate_handle):

```ruby
body_handle = page.evaluate_handle("document.body")
result_handle = page.evaluate_handle("body => body.innerHTML", arg: body_handle)
puts result_handle.json_value()
result_handle.dispose()
```



## expose_binding

```
def expose_binding(name, callback, handle: nil)
```

The method adds a function called `name` on the `window` object of every frame in this page. When called, the function
executes `callback` and returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) which resolves to the return value of `callback`. If the `callback` returns
a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), it will be awaited.

The first argument of the `callback` function contains information about the caller: `{ browserContext: BrowserContext,
page: Page, frame: Frame }`.

See [BrowserContext#expose_binding](./browser_context#expose_binding) for the context-wide version.

> NOTE: Functions installed via [Page#expose_binding](./page#expose_binding) survive navigations.

An example of exposing page URL to all frames in a page:

```python sync title=example_551f5963351bfd7141fa8c94f5f22c305ec1c01d617861953374e9290929a551.py
from playwright.sync_api import sync_playwright

def run(playwright):
    webkit = playwright.webkit
    browser = webkit.launch(headless=false)
    context = browser.new_context()
    page = context.new_page()
    page.expose_binding("pageURL", lambda source: source["page"].url)
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

```python sync title=example_6534a792e99e05b5644cea6e5b77ca5d864675a3012f447f0f8318c4fa6a6a54.py
def print(source, element):
    print(element.text_content())

page.expose_binding("clicked", print, handle=true)
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

The method adds a function called `name` on the `window` object of every frame in the page. When called, the function
executes `callback` and returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) which resolves to the return value of `callback`.

If the `callback` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), it will be awaited.

See [BrowserContext#expose_function](./browser_context#expose_function) for context-wide exposed function.

> NOTE: Functions installed via [Page#expose_function](./page#expose_function) survive navigations.

An example of adding an `sha1` function to the page:

```python sync title=example_496ab45e0c5f4c47869f66c2b738fbd9eef0ef4065fa923caf9c929e50e14c21.py
import hashlib
from playwright.sync_api import sync_playwright

def sha1(text):
    m = hashlib.sha1()
    m.update(bytes(text, "utf8"))
    return m.hexdigest()


def run(playwright):
    webkit = playwright.webkit
    browser = webkit.launch(headless=False)
    page = browser.new_page()
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



## fill

```
def fill(selector, value, noWaitAfter: nil, timeout: nil)
```

This method waits for an element matching `selector`, waits for [actionability](https://playwright.dev/python/docs/actionability) checks, focuses the
element, fills it and triggers an `input` event after filling. Note that you can pass an empty string to clear the input
field.

If the target element is not an `<input>`, `<textarea>` or `[contenteditable]` element, this method throws an error.
However, if the element is inside the `<label>` element that has an associated
[control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be filled
instead.

To send fine-grained keyboard events, use [Page#type](./page#type).

Shortcut for main frame's [Frame#fill](./frame#fill).

## focus

```
def focus(selector, timeout: nil)
```

This method fetches an element with `selector` and focuses it. If there's no element matching `selector`, the method
waits until a matching element appears in the DOM.

Shortcut for main frame's [Frame#focus](./frame#focus).

## frame

```
def frame(name: nil, url: nil)
```

Returns frame matching the specified criteria. Either `name` or `url` must be specified.

```py title=example_034f224ec0f7b4d98fdf875cefbc7e6c8726a6d615cbba9b1cb8c49180fd7d69.py
frame = page.frame(name="frame-name")

```

```py title=example_a8a4717d8505a35662faafa9e6c2cfbbc0a44755c8e4d43252f882b7e4f1f04a.py
frame = page.frame(url=r".*domain.*")

```



## frames

```
def frames
```

An array of all frames attached to the page.

## get_attribute

```
def get_attribute(selector, name, timeout: nil)
```

Returns element attribute value.

## go_back

```
def go_back(timeout: nil, waitUntil: nil)
```

Returns the main resource response. In case of multiple redirects, the navigation will resolve with the response of the
last redirect. If can not go back, returns `null`.

Navigate to the previous page in history.

## go_forward

```
def go_forward(timeout: nil, waitUntil: nil)
```

Returns the main resource response. In case of multiple redirects, the navigation will resolve with the response of the
last redirect. If can not go forward, returns `null`.

Navigate to the next page in history.

## goto

```
def goto(url, referer: nil, timeout: nil, waitUntil: nil)
```

Returns the main resource response. In case of multiple redirects, the navigation will resolve with the response of the
last redirect.

`page.goto` will throw an error if:
- there's an SSL error (e.g. in case of self-signed certificates).
- target URL is invalid.
- the `timeout` is exceeded during navigation.
- the remote server does not respond or is unreachable.
- the main resource failed to load.

`page.goto` will not throw an error when any valid HTTP status code is returned by the remote server, including 404 "Not
Found" and 500 "Internal Server Error".  The status code for such responses can be retrieved by calling
[Response#status](./response#status).

> NOTE: `page.goto` either throws an error or returns a main resource response. The only exceptions are navigation to
`about:blank` or navigation to the same URL with a different hash, which would succeed and return `null`.
> NOTE: Headless mode doesn't support navigation to a PDF document. See the
[upstream issue](https://bugs.chromium.org/p/chromium/issues/detail?id=761295).

Shortcut for main frame's [Frame#goto](./frame#goto)

## hover

```
def hover(
      selector,
      force: nil,
      modifiers: nil,
      position: nil,
      timeout: nil,
      trial: nil)
```

This method hovers over an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If the
   element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to hover over the center of the element, or the specified `position`.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`. Passing
zero timeout disables this.

Shortcut for main frame's [Frame#hover](./frame#hover).

## inner_html

```
def inner_html(selector, timeout: nil)
```

Returns `element.innerHTML`.

## inner_text

```
def inner_text(selector, timeout: nil)
```

Returns `element.innerText`.

## checked?

```
def checked?(selector, timeout: nil)
```

Returns whether the element is checked. Throws if the element is not a checkbox or radio input.

## closed?

```
def closed?
```

Indicates that the page has been closed.

## disabled?

```
def disabled?(selector, timeout: nil)
```

Returns whether the element is disabled, the opposite of [enabled](https://playwright.dev/python/docs/actionability).

## editable?

```
def editable?(selector, timeout: nil)
```

Returns whether the element is [editable](https://playwright.dev/python/docs/actionability).

## enabled?

```
def enabled?(selector, timeout: nil)
```

Returns whether the element is [enabled](https://playwright.dev/python/docs/actionability).

## hidden?

```
def hidden?(selector, timeout: nil)
```

Returns whether the element is hidden, the opposite of [visible](https://playwright.dev/python/docs/actionability).  `selector` that does not
match any elements is considered hidden.

## visible?

```
def visible?(selector, timeout: nil)
```

Returns whether the element is [visible](https://playwright.dev/python/docs/actionability). `selector` that does not match any elements is
considered not visible.

## main_frame

```
def main_frame
```

The page's main frame. Page is guaranteed to have a main frame which persists during navigations.

## opener

```
def opener
```

Returns the opener for popup pages and `null` for others. If the opener has been closed already the returns `null`.

## pdf

```
def pdf(
      displayHeaderFooter: nil,
      footerTemplate: nil,
      format: nil,
      headerTemplate: nil,
      height: nil,
      landscape: nil,
      margin: nil,
      pageRanges: nil,
      path: nil,
      preferCSSPageSize: nil,
      printBackground: nil,
      scale: nil,
      width: nil)
```

Returns the PDF buffer.

> NOTE: Generating a pdf is currently only supported in Chromium headless.

`page.pdf()` generates a pdf of the page with `print` css media. To generate a pdf with `screen` media, call
[Page#emulate_media](./page#emulate_media) before calling `page.pdf()`:

> NOTE: By default, `page.pdf()` generates a pdf with modified colors for printing. Use the
[`-webkit-print-color-adjust`](https://developer.mozilla.org/en-US/docs/Web/CSS/-webkit-print-color-adjust) property to
force rendering of exact colors.

```python sync title=example_e079fbec8ee0607ee45cdca94df61dea36f7fd3840986d5f4ac24918569a5f5e.py
# generates a pdf with "screen" media type.
page.emulate_media(media="screen")
page.pdf(path="page.pdf")

```

The `width`, `height`, and `margin` options accept values labeled with units. Unlabeled values are treated as pixels.

A few examples:
- `page.pdf({width: 100})` - prints with width set to 100 pixels
- `page.pdf({width: '100px'})` - prints with width set to 100 pixels
- `page.pdf({width: '10cm'})` - prints with width set to 10 centimeters.

All possible units are:
- `px` - pixel
- `in` - inch
- `cm` - centimeter
- `mm` - millimeter

The `format` options are:
- `Letter`: 8.5in x 11in
- `Legal`: 8.5in x 14in
- `Tabloid`: 11in x 17in
- `Ledger`: 17in x 11in
- `A0`: 33.1in x 46.8in
- `A1`: 23.4in x 33.1in
- `A2`: 16.54in x 23.4in
- `A3`: 11.7in x 16.54in
- `A4`: 8.27in x 11.7in
- `A5`: 5.83in x 8.27in
- `A6`: 4.13in x 5.83in

> NOTE: `headerTemplate` and `footerTemplate` markup have the following limitations: > 1. Script tags inside templates
are not evaluated. > 2. Page styles are not visible inside templates.

## press

```
def press(
      selector,
      key,
      delay: nil,
      noWaitAfter: nil,
      timeout: nil)
```

Focuses the element, and then uses [Keyboard#down](./keyboard#down) and [Keyboard#up](./keyboard#up).

`key` can specify the intended [keyboardEvent.key](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key)
value or a single character to generate the text for. A superset of the `key` values can be found
[here](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values). Examples of the keys are:

`F1` - `F12`, `Digit0`- `Digit9`, `KeyA`- `KeyZ`, `Backquote`, `Minus`, `Equal`, `Backslash`, `Backspace`, `Tab`,
`Delete`, `Escape`, `ArrowDown`, `End`, `Enter`, `Home`, `Insert`, `PageDown`, `PageUp`, `ArrowRight`, `ArrowUp`, etc.

Following modification shortcuts are also supported: `Shift`, `Control`, `Alt`, `Meta`, `ShiftLeft`.

Holding down `Shift` will type the text that corresponds to the `key` in the upper case.

If `key` is a single character, it is case-sensitive, so the values `a` and `A` will generate different respective
texts.

Shortcuts such as `key: "Control+o"` or `key: "Control+Shift+T"` are supported as well. When specified with the
modifier, modifier is pressed and being held while the subsequent key is being pressed.

```python sync title=example_aa4598bd7dbeb8d2f8f5c0aa3bdc84042eb396de37b49f8ff8c1ea39f080f709.py
page = browser.new_page()
page.goto("https://keycode.info")
page.press("body", "A")
page.screenshot(path="a.png")
page.press("body", "ArrowLeft")
page.screenshot(path="arrow_left.png")
page.press("body", "Shift+O")
page.screenshot(path="o.png")
browser.close()

```



## query_selector

```
def query_selector(selector)
```

The method finds an element matching the specified selector within the page. If no elements match the selector, the
return value resolves to `null`. To wait for an element on the page, use [Page#wait_for_selector](./page#wait_for_selector).

Shortcut for main frame's [Frame#query_selector](./frame#query_selector).

## query_selector_all

```
def query_selector_all(selector)
```

The method finds all elements matching the specified selector within the page. If no elements match the selector, the
return value resolves to `[]`.

Shortcut for main frame's [Frame#query_selector_all](./frame#query_selector_all).

## reload

```
def reload(timeout: nil, waitUntil: nil)
```

Returns the main resource response. In case of multiple redirects, the navigation will resolve with the response of the
last redirect.

## route

```
def route(url, handler)
```

Routing provides the capability to modify network requests that are made by a page.

Once routing is enabled, every request matching the url pattern will stall unless it's continued, fulfilled or aborted.

> NOTE: The handler will only be called for the first url if the response is a redirect.

An example of a naive handler that aborts all image requests:

```python sync title=example_a3038a6fd55b06cb841251877bf6eb781b08018695514c6e0054848d4e93d345.py
page = browser.new_page()
page.route("**/*.{png,jpg,jpeg}", lambda route: route.abort())
page.goto("https://example.com")
browser.close()

```

or the same snippet using a regex pattern instead:

```python sync title=example_7fda2a761bdd66b942415ab444c6b4bb89dd87ec0f0a4a03e6775feb694f7913.py
page = browser.new_page()
page.route(re.compile(r"(\.png$)|(\.jpg$)"), lambda route: route.abort())
page.goto("https://example.com")
browser.close()

```

It is possible to examine the request to decide the route action. For example, mocking all requests that contain some
post data, and leaving all other requests as is:

```python sync title=example_ff4fba1273c7e65f4d68b4fcdd9dc4b792bba435005f0b9e7066ca18ded750b5.py
def handle_route(route):
  if ("my-string" in route.request.post_data)
    route.fulfill(body="mocked-data")
  else
    route.continue_()
page.route("/api/**", handle_route)

```

Page routes take precedence over browser context routes (set up with [BrowserContext#route](./browser_context#route)) when request
matches both handlers.

To remove a route with its handler you can use [Page#unroute](./page#unroute).

> NOTE: Enabling routing disables http cache.

## screenshot

```
def screenshot(
      clip: nil,
      fullPage: nil,
      omitBackground: nil,
      path: nil,
      quality: nil,
      timeout: nil,
      type: nil)
```

Returns the buffer with the captured screenshot.

## select_option

```
def select_option(
      selector,
      element: nil,
      index: nil,
      value: nil,
      label: nil,
      noWaitAfter: nil,
      timeout: nil)
```

This method waits for an element matching `selector`, waits for [actionability](https://playwright.dev/python/docs/actionability) checks, waits until
all specified options are present in the `<select>` element and selects these options.

If the target element is not a `<select>` element, this method throws an error. However, if the element is inside the
`<label>` element that has an associated
[control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be used instead.

Returns the array of option values that have been successfully selected.

Triggers a `change` and `input` event once all the provided options have been selected.

```python sync title=example_4b17eb65721c55859c50eb12b4ee762e65408618cf3b7d07958b68d60ea6be6c.py
# single selection matching the value
page.select_option("select#colors", "blue")
# single selection matching both the label
page.select_option("select#colors", label="blue")
# multiple selection
page.select_option("select#colors", value=["red", "green", "blue"])

```

Shortcut for main frame's [Frame#select_option](./frame#select_option).

## set_content

```
def set_content(html, timeout: nil, waitUntil: nil)
```
alias: `content=`



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
- [`method: Page.waitForNavigation`]
- [Page#wait_for_url](./page#wait_for_url)

> NOTE: [Page#set_default_navigation_timeout](./page#set_default_navigation_timeout) takes priority over [Page#set_default_timeout](./page#set_default_timeout),
[BrowserContext#set_default_timeout](./browser_context#set_default_timeout) and [BrowserContext#set_default_navigation_timeout](./browser_context#set_default_navigation_timeout).

## set_default_timeout

```
def set_default_timeout(timeout)
```
alias: `default_timeout=`

This setting will change the default maximum time for all the methods accepting `timeout` option.

> NOTE: [Page#set_default_navigation_timeout](./page#set_default_navigation_timeout) takes priority over [Page#set_default_timeout](./page#set_default_timeout).

## set_extra_http_headers

```
def set_extra_http_headers(headers)
```
alias: `extra_http_headers=`

The extra HTTP headers will be sent with every request the page initiates.

> NOTE: [Page#set_extra_http_headers](./page#set_extra_http_headers) does not guarantee the order of headers in the outgoing requests.

## set_input_files

```
def set_input_files(selector, files, noWaitAfter: nil, timeout: nil)
```

This method expects `selector` to point to an
[input element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input).

Sets the value of the file input to these file paths or files. If some of the `filePaths` are relative paths, then they
are resolved relative to the the current working directory. For empty array, clears the selected files.

## set_viewport_size

```
def set_viewport_size(viewportSize)
```
alias: `viewport_size=`

In the case of multiple pages in a single browser, each page can have its own viewport size. However,
[Browser#new_context](./browser#new_context) allows to set viewport size (and more) for all pages in the context at once.

`page.setViewportSize` will resize the page. A lot of websites don't expect phones to change size, so you should set the
viewport size before navigating to the page.

```python sync title=example_e3883d51c0785c34b62633fe311c4f1252dd9f29e6b4b6c7719f1eb74384e6e9.py
page = browser.new_page()
page.set_viewport_size({"width": 640, "height": 480})
page.goto("https://example.com")

```



## tap_point

```
def tap_point(
      selector,
      force: nil,
      modifiers: nil,
      noWaitAfter: nil,
      position: nil,
      timeout: nil,
      trial: nil)
```

This method taps an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If the
   element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#touchscreen](./page#touchscreen) to tap the center of the element, or the specified `position`.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`. Passing
zero timeout disables this.

> NOTE: [Page#tap_point](./page#tap_point) requires that the `hasTouch` option of the browser context be set to true.

Shortcut for main frame's [Frame#tap_point](./frame#tap_point).

## text_content

```
def text_content(selector, timeout: nil)
```

Returns `element.textContent`.

## title

```
def title
```

Returns the page's title. Shortcut for main frame's [Frame#title](./frame#title).

## type

```
def type(
      selector,
      text,
      delay: nil,
      noWaitAfter: nil,
      timeout: nil)
```

Sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text. `page.type` can be used to send
fine-grained keyboard events. To fill values in form fields, use [Page#fill](./page#fill).

To press a special key, like `Control` or `ArrowDown`, use [Keyboard#press](./keyboard#press).

```python sync title=example_4c7291f6023d2fe4f957cb7727646b50fdee40275db330a6f4517e349ea7f916.py
page.type("#mytextarea", "hello") # types instantly
page.type("#mytextarea", "world", delay=100) # types slower, like a user

```

Shortcut for main frame's [Frame#type](./frame#type).

## uncheck

```
def uncheck(
      selector,
      force: nil,
      noWaitAfter: nil,
      position: nil,
      timeout: nil,
      trial: nil)
```

This method unchecks an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Ensure that matched element is a checkbox or a radio input. If not, this method throws. If the element is already
   unchecked, this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If the
   element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.
1. Ensure that the element is now unchecked. If not, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`. Passing
zero timeout disables this.

Shortcut for main frame's [Frame#uncheck](./frame#uncheck).

## unroute

```
def unroute(url, handler: nil)
```

Removes a route created with [Page#route](./page#route). When `handler` is not specified, removes all routes for the `url`.

## url

```
def url
```

Shortcut for main frame's [Frame#url](./frame#url).

## video

```
def video
```

Video object associated with this page.

## viewport_size

```
def viewport_size
```



## expect_console_message

```
def expect_console_message(predicate: nil, timeout: nil, &block)
```

Performs action and waits for a [ConsoleMessage](./console_message) to be logged by in the page. If predicate is provided, it passes
[ConsoleMessage](./console_message) value into the `predicate` function and waits for `predicate(message)` to return a truthy value. Will
throw an error if the page is closed before the console event is fired.

## expect_download

```
def expect_download(predicate: nil, timeout: nil, &block)
```

Performs action and waits for a new `Download`. If predicate is provided, it passes `Download` value into the
`predicate` function and waits for `predicate(download)` to return a truthy value. Will throw an error if the page is
closed before the download event is fired.

## expect_event

```
def expect_event(event, predicate: nil, timeout: nil, &block)
```

Waits for event to fire and passes its value into the predicate function. Returns when the predicate returns truthy
value. Will throw an error if the page is closed before the event is fired. Returns the event data value.

```python sync title=example_1b007e0db5f2b594b586367be3b56f9eb9b928740efbceada2c60cb7794592d4.py
with page.expect_event("framenavigated") as event_info:
    page.click("button")
frame = event_info.value

```



## expect_file_chooser

```
def expect_file_chooser(predicate: nil, timeout: nil, &block)
```

Performs action and waits for a new [FileChooser](./file_chooser) to be created. If predicate is provided, it passes [FileChooser](./file_chooser) value
into the `predicate` function and waits for `predicate(fileChooser)` to return a truthy value. Will throw an error if
the page is closed before the file chooser is opened.

## wait_for_function

```
def wait_for_function(expression, arg: nil, polling: nil, timeout: nil)
```

Returns when the `expression` returns a truthy value. It resolves to a JSHandle of the truthy value.

The [Page#wait_for_function](./page#wait_for_function) can be used to observe viewport size change:

```python sync title=example_e50869c913bec2f0a89a22ff1c438128c3c8f2e3710acb10665445cf52e3ec73.py
from playwright.sync_api import sync_playwright

def run(playwright):
    webkit = playwright.webkit
    browser = webkit.launch()
    page = browser.new_page()
    page.evaluate("window.x = 0; setTimeout(() => { window.x = 100 }, 1000);")
    page.wait_for_function("() => window.x > 0")
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

To pass an argument to the predicate of [Page#wait_for_function](./page#wait_for_function) function:

```python sync title=example_04c93558dde8de62944515a8ed91fda6e0d01feca4d3bb2e58c6fda10a8c6ade.py
selector = ".foo"
page.wait_for_function("selector => !!document.querySelector(selector)", selector)

```

Shortcut for main frame's [Frame#wait_for_function](./frame#wait_for_function).

## wait_for_load_state

```
def wait_for_load_state(state: nil, timeout: nil)
```

Returns when the required load state has been reached.

This resolves when the page reaches a required load state, `load` by default. The navigation must have been committed
when this method is called. If current document has already reached the required state, resolves immediately.

```python sync title=example_cd35fb085612055231ddf97f68bc5331b4620914e0686b889f2cd4061836cff8.py
page.click("button") # click triggers navigation.
page.wait_for_load_state() # the promise resolves after "load" event.

```

```python sync title=example_51ba8a745d5093516e9a50482d8bf3ce29afe507ca5cfe89f4a0e35963f52a36.py
with page.expect_popup() as page_info:
    page.click("button") # click triggers a popup.
popup = page_info.value
 # Following resolves after "domcontentloaded" event.
popup.wait_for_load_state("domcontentloaded")
print(popup.title()) # popup is ready to use.

```

Shortcut for main frame's [Frame#wait_for_load_state](./frame#wait_for_load_state).

## expect_navigation

```
def expect_navigation(timeout: nil, url: nil, waitUntil: nil, &block)
```

Waits for the main frame navigation and returns the main resource response. In case of multiple redirects, the
navigation will resolve with the response of the last redirect. In case of navigation to a different anchor or
navigation due to History API usage, the navigation will resolve with `null`.

This resolves when the page navigates to a new URL or reloads. It is useful for when you run code which will indirectly
cause the page to navigate. e.g. The click target has an `onclick` handler that triggers navigation from a `setTimeout`.
Consider this example:

```python sync title=example_bc5a01f756c1275b9942c4b3e50a9f1748c04da8d5f8f697567b9d04806ec0dc.py
with page.expect_navigation():
    page.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
# Resolves after navigation has finished

```

> NOTE: Usage of the [History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API) to change the URL is
considered a navigation.

Shortcut for main frame's [`method: Frame.waitForNavigation`].

## expect_popup

```
def expect_popup(predicate: nil, timeout: nil, &block)
```

Performs action and waits for a popup [Page](./page). If predicate is provided, it passes [Popup] value into the `predicate`
function and waits for `predicate(page)` to return a truthy value. Will throw an error if the page is closed before the
popup event is fired.

## expect_request

```
def expect_request(urlOrPredicate, timeout: nil)
```

Waits for the matching request and returns it.  See [waiting for event](https://playwright.dev/python/docs/events) for more details
about events.

```python sync title=example_9246912bc386c2f9310662279b12200ae131f724a1ec1ca99e511568767cb9c8.py
with page.expect_request("http://example.com/resource") as first:
    page.click('button')
first_request = first.value

# or with a lambda
with page.expect_request(lambda request: request.url == "http://example.com" and request.method == "get") as second:
    page.click('img')
second_request = second.value

```



## expect_response

```
def expect_response(urlOrPredicate, timeout: nil)
```

Returns the matched response. See [waiting for event](https://playwright.dev/python/docs/events) for more details about events.

```python sync title=example_d2a76790c0bb59bf5ae2f41d1a29b50954412136de3699ec79dc33cdfd56004b.py
with page.expect_response("https://example.com/resource") as response_info:
    page.click("input")
response = response_info.value
return response.ok

# or with a lambda
with page.expect_response(lambda response: response.url == "https://example.com" and response.status === 200) as response_info:
    page.click("input")
response = response_info.value
return response.ok

```



## wait_for_selector

```
def wait_for_selector(selector, state: nil, timeout: nil)
```

Returns when element specified by selector satisfies `state` option. Returns `null` if waiting for `hidden` or
`detached`.

Wait for the `selector` to satisfy `state` option (either appear/disappear from dom, or become visible/hidden). If at
the moment of calling the method `selector` already satisfies the condition, the method will return immediately. If the
selector doesn't satisfy the condition for the `timeout` milliseconds, the function will throw.

This method works across navigations:

```python sync title=example_0a62ff34b0d31a64dd1597b9dff456e4139b36207d26efdec7109e278dc315a3.py
from playwright.sync_api import sync_playwright

def run(playwright):
    chromium = playwright.chromium
    browser = chromium.launch()
    page = browser.new_page()
    for current_url in ["https://google.com", "https://bbc.com"]:
        page.goto(current_url, wait_until="domcontentloaded")
        element = page.wait_for_selector("img")
        print("Loaded image: " + str(element.get_attribute("src")))
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```



## wait_for_url

```
def wait_for_url(url, timeout: nil, waitUntil: nil)
```

Waits for the main frame to navigate to the given URL.

```python sync title=example_a49b1deed2b93fe358b57bca9c4032f44b3d24436a78720421ba040aad4d661c.py
page.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
page.wait_for_url("**/target.html")

```

Shortcut for main frame's [Frame#wait_for_url](./frame#wait_for_url).

## accessibility

## keyboard

## mouse

## touchscreen
