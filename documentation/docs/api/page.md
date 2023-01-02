---
sidebar_position: 10
---

# Page

- extends: [EventEmitter]

Page provides methods to interact with a single tab in a [Browser](./browser), or an
[extension background page](https://developer.chrome.com/extensions/background_pages) in Chromium. One [Browser](./browser)
instance might have multiple [Page](./page) instances.

This example creates a page, navigates it to a URL, and then saves a screenshot:

```py title=example_1dfeafea7c7b0910f24fb11812b1986c2d33d390dcb359f65be7939dda1d2a91.py
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    webkit = playwright.webkit
    browser = await webkit.launch()
    context = await browser.new_context()
    page = await context.new_page()
    await page.goto("https://example.com")
    await page.screenshot(path="screenshot.png")
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

```py title=example_e027fe5e1873f79a9c674d8f1c3381779a26b8ba27e5a399a05a45d64b0ba543.py
from playwright.sync_api import sync_playwright

def run(playwright):
    webkit = playwright.webkit
    browser = webkit.launch()
    context = browser.new_context()
    page = context.new_page()
    page.goto("https://example.com")
    page.screenshot(path="screenshot.png")
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

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
- Whenever the child frame is attached or navigated. In this case, the script is evaluated in the context of the
  newly attached frame.

The script is evaluated after the document was created but before any of its scripts were run. This is useful to
amend the JavaScript environment, e.g. to seed `Math.random`.

**Usage**

An example of overriding `Math.random` before the page loads:

```py title=example_ed62aab6595b424bfd9cbea78b7c06c368a8e1259a669c32a8cfda20c88c8522.py
# in your playwright script, assuming the preload.js file is in same directory
await page.add_init_script(path="./preload.js")

```

```py title=example_6a181945f3bf3f5bd126224414d8684a11032608e044f9b9df6edc06824a6fb7.py
# in your playwright script, assuming the preload.js file is in same directory
page.add_init_script(path="./preload.js")

```

**NOTE** The order of evaluation of multiple scripts installed via [BrowserContext#add_init_script](./browser_context#add_init_script) and
[Page#add_init_script](./page#add_init_script) is not defined.

## add_script_tag

```
def add_script_tag(content: nil, path: nil, type: nil, url: nil)
```

Adds a `<script>` tag into the page with the desired url or content. Returns the added tag when the script's onload
fires or when the script content was injected into frame.

## add_style_tag

```
def add_style_tag(content: nil, path: nil, url: nil)
```

Adds a `<link rel="stylesheet">` tag into the page with the desired url or a `<style type="text/css">` tag with the
content. Returns the added tag when the stylesheet's onload fires or when the CSS content was injected into frame.

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
      strict: nil,
      timeout: nil,
      trial: nil)
```

This method checks an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Ensure that matched element is a checkbox or a radio input. If not, this method throws. If the element is
   already checked, this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If
   the element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.
1. Ensure that the element is now checked. If not, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`.
Passing zero timeout disables this.

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
      strict: nil,
      timeout: nil,
      trial: nil)
```

This method clicks an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If
   the element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element, or the specified `position`.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`.
Passing zero timeout disables this.

## close

```
def close(runBeforeUnload: nil)
```

If `runBeforeUnload` is `false`, does not run any unload handlers and waits for the page to be closed. If
`runBeforeUnload` is `true` the method will run unload handlers, but will **not** wait for the page to close.

By default, `page.close()` **does not** run `beforeunload` handlers.

**NOTE** if `runBeforeUnload` is passed as true, a `beforeunload` dialog might be summoned and should be handled
manually via [`event: Page.dialog`] event.

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
      strict: nil,
      timeout: nil,
      trial: nil)
```

This method double clicks an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If
   the element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to double click in the center of the element, or the specified `position`.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set. Note that if
   the first click of the `dblclick()` triggers a navigation event, this method will throw.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`.
Passing zero timeout disables this.

**NOTE** `page.dblclick()` dispatches two `click` events and a single `dblclick` event.

## dispatch_event

```
def dispatch_event(
      selector,
      type,
      eventInit: nil,
      strict: nil,
      timeout: nil)
```

The snippet below dispatches the `click` event on the element. Regardless of the visibility state of the element,
`click` is dispatched. This is equivalent to calling
[element.click()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/click).

**Usage**

```py title=example_800167b5b3eff041b4b22f84e8f1075914134cf5e05870d74105f91bc0ed013c.py
await page.dispatch_event("button#submit", "click")

```

```py title=example_117a7994860d77d1683229c004539a6366f7fe1ad564147589a53c07198f3d6d.py
page.dispatch_event("button#submit", "click")

```

Under the hood, it creates an instance of an event based on the given `type`, initializes it with `eventInit`
properties and dispatches it on the element. Events are `composed`, `cancelable` and bubble by default.

Since `eventInit` is event-specific, please refer to the events documentation for the lists of initial properties:
- [DragEvent](https://developer.mozilla.org/en-US/docs/Web/API/DragEvent/DragEvent)
- [FocusEvent](https://developer.mozilla.org/en-US/docs/Web/API/FocusEvent/FocusEvent)
- [KeyboardEvent](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/KeyboardEvent)
- [MouseEvent](https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent/MouseEvent)
- [PointerEvent](https://developer.mozilla.org/en-US/docs/Web/API/PointerEvent/PointerEvent)
- [TouchEvent](https://developer.mozilla.org/en-US/docs/Web/API/TouchEvent/TouchEvent)
- [Event](https://developer.mozilla.org/en-US/docs/Web/API/Event/Event)

You can also specify [JSHandle](./js_handle) as the property value if you want live objects to be passed into the event:

```py title=example_8f98ab370bd573982e1bef068245008734eb75829df17f32513fc0d0b7a6289c.py
# note you can only create data_transfer in chromium and firefox
data_transfer = await page.evaluate_handle("new DataTransfer()")
await page.dispatch_event("#source", "dragstart", { "dataTransfer": data_transfer })

```

```py title=example_00b26820746466c8788341e55d126d6fc4c3774a518f24f14c164fcfd7c9ee4a.py
# note you can only create data_transfer in chromium and firefox
data_transfer = page.evaluate_handle("new DataTransfer()")
page.dispatch_event("#source", "dragstart", { "dataTransfer": data_transfer })

```



## drag_and_drop

```
def drag_and_drop(
      source,
      target,
      force: nil,
      noWaitAfter: nil,
      sourcePosition: nil,
      strict: nil,
      targetPosition: nil,
      timeout: nil,
      trial: nil)
```

This method drags the source element to the target element. It will first move to the source element, perform a
`mousedown`, then move to the target element and perform a `mouseup`.

**Usage**

```py title=example_e41549078b5dbb47eb44b1391e7a8e63736bee165e9d4fcdbecf23f0764816cd.py
await page.drag_and_drop("#source", "#target")
# or specify exact positions relative to the top-left corners of the elements:
await page.drag_and_drop(
  "#source",
  "#target",
  source_position={"x": 34, "y": 7},
  target_position={"x": 10, "y": 20}
)

```

```py title=example_941e96397e47965399015d883bb0f48a496fe3273f1257b4b2e2b4e2c81a6411.py
page.drag_and_drop("#source", "#target")
# or specify exact positions relative to the top-left corners of the elements:
page.drag_and_drop(
  "#source",
  "#target",
  source_position={"x": 34, "y": 7},
  target_position={"x": 10, "y": 20}
)

```



## emulate_media

```
def emulate_media(colorScheme: nil, forcedColors: nil, media: nil, reducedMotion: nil)
```

This method changes the `CSS media type` through the `media` argument, and/or the `'prefers-colors-scheme'` media
feature, using the `colorScheme` argument.

**Usage**

```py title=example_520445be43679bcf5047860b3055330c1f72c3d5228fd67a38f945c643801b34.py
await page.evaluate("matchMedia('screen').matches")
# → True
await page.evaluate("matchMedia('print').matches")
# → False

await page.emulate_media(media="print")
await page.evaluate("matchMedia('screen').matches")
# → False
await page.evaluate("matchMedia('print').matches")
# → True

await page.emulate_media()
await page.evaluate("matchMedia('screen').matches")
# → True
await page.evaluate("matchMedia('print').matches")
# → False

```

```py title=example_261f35f0113e44cd815c2edf55623655a1d26b80e7c5104511d4270915ad095b.py
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

```py title=example_fab77eafbb95ba57301ed81b60bc3c848e97b78b7e4cc1744a15ed8aefc3a685.py
await page.emulate_media(color_scheme="dark")
await page.evaluate("matchMedia('(prefers-color-scheme: dark)').matches")
# → True
await page.evaluate("matchMedia('(prefers-color-scheme: light)').matches")
# → False
await page.evaluate("matchMedia('(prefers-color-scheme: no-preference)').matches")
# → False

```

```py title=example_08016bbdc751dd39fabd0c352ebed4edf349ab03e3e54815982d5abbb2cb3bac.py
page.emulate_media(color_scheme="dark")
page.evaluate("matchMedia('(prefers-color-scheme: dark)').matches")
# → True
page.evaluate("matchMedia('(prefers-color-scheme: light)').matches")
# → False
page.evaluate("matchMedia('(prefers-color-scheme: no-preference)').matches")

```



## eval_on_selector

```
def eval_on_selector(selector, expression, arg: nil, strict: nil)
```

The method finds an element matching the specified selector within the page and passes it as a first argument to
`expression`. If no elements match the selector, the method throws an error. Returns the value of `expression`.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Page#eval_on_selector](./page#eval_on_selector) would wait for the promise to resolve and
return its value.

**Usage**

```py title=example_83439858a8cc6fee4df60a574e73b4066b6d182bc821ada96de1adafdf13b258.py
search_value = await page.eval_on_selector("#search", "el => el.value")
preload_href = await page.eval_on_selector("link[rel=preload]", "el => el.href")
html = await page.eval_on_selector(".main-container", "(e, suffix) => e.outer_html + suffix", "hello")

```

```py title=example_fbbf648e7e6e584f69180087098ee02252e9d942bf9f177d48183a17e9e9ce50.py
search_value = page.eval_on_selector("#search", "el => el.value")
preload_href = page.eval_on_selector("link[rel=preload]", "el => el.href")
html = page.eval_on_selector(".main-container", "(e, suffix) => e.outer_html + suffix", "hello")

```



## eval_on_selector_all

```
def eval_on_selector_all(selector, expression, arg: nil)
```

The method finds all elements matching the specified selector within the page and passes an array of matched
elements as a first argument to `expression`. Returns the result of `expression` invocation.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Page#eval_on_selector_all](./page#eval_on_selector_all) would wait for the promise to resolve
and return its value.

**Usage**

```py title=example_c382b058144338f04edb37e8484f01021e47153b94654f942b8cf9d852dfb0ef.py
div_counts = await page.eval_on_selector_all("div", "(divs, min) => divs.length >= min", 10)

```

```py title=example_49c241e7ef571e55412dc2041f8c16fcb5fdf22fb221236879d59bc61ae7ff50.py
div_counts = page.eval_on_selector_all("div", "(divs, min) => divs.length >= min", 10)

```



## evaluate

```
def evaluate(expression, arg: nil)
```

Returns the value of the `expression` invocation.

If the function passed to the [Page#evaluate](./page#evaluate) returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Page#evaluate](./page#evaluate) would
wait for the promise to resolve and return its value.

If the function passed to the [Page#evaluate](./page#evaluate) returns a non-[Serializable](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify#description) value, then
[Page#evaluate](./page#evaluate) resolves to `undefined`. Playwright also supports transferring some additional values
that are not serializable by `JSON`: `-0`, `NaN`, `Infinity`, `-Infinity`.

**Usage**

Passing argument to `expression`:

```py title=example_c7949c54234b8c330309fd90133fb90b942d87779faf3d66fce1f48a0b61e399.py
result = await page.evaluate("([x, y]) => Promise.resolve(x * y)", [7, 8])
print(result) # prints "56"

```

```py title=example_cab05223e2a430fb202831c3c3de2a9732056bd1477b2a8f5907987a4cc40f56.py
result = page.evaluate("([x, y]) => Promise.resolve(x * y)", [7, 8])
print(result) # prints "56"

```

A string can also be passed in instead of a function:

```py title=example_da6342e7a94c20ccda60c84cc81b5a9eb4b5238249842dc7e9f03e86537d8756.py
print(await page.evaluate("1 + 2")) # prints "3"
x = 10
print(await page.evaluate(f"1 + {x}")) # prints "11"

```

```py title=example_04e5e4cfd8ee566fe467dac01f8ea7688bd05794d946966508b0a2433a036f13.py
print(page.evaluate("1 + 2")) # prints "3"
x = 10
print(page.evaluate(f"1 + {x}")) # prints "11"

```

[ElementHandle](./element_handle) instances can be passed as an argument to the [Page#evaluate](./page#evaluate):

```py title=example_37a982e70895a2ec993769d8288618d91bc177cf72db4529ff0ba1b5549bdea0.py
body_handle = await page.evaluate("document.body")
html = await page.evaluate("([body, suffix]) => body.innerHTML + suffix", [body_handle, "hello"])
await body_handle.dispose()

```

```py title=example_3e25ebf63419b39d81c30f3f867f7528e90c16297d2cd9b71b0f2628c7865519.py
body_handle = page.evaluate("document.body")
html = page.evaluate("([body, suffix]) => body.innerHTML + suffix", [body_handle, "hello"])
body_handle.dispose()

```



## evaluate_handle

```
def evaluate_handle(expression, arg: nil)
```

Returns the value of the `expression` invocation as a [JSHandle](./js_handle).

The only difference between [Page#evaluate](./page#evaluate) and [Page#evaluate_handle](./page#evaluate_handle) is that
[Page#evaluate_handle](./page#evaluate_handle) returns [JSHandle](./js_handle).

If the function passed to the [Page#evaluate_handle](./page#evaluate_handle) returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then
[Page#evaluate_handle](./page#evaluate_handle) would wait for the promise to resolve and return its value.

**Usage**

```py title=example_cbe313321f4f565a3cca3bc8f4666f90edf78435630502f2122a8d221a17eb0b.py
a_window_handle = await page.evaluate_handle("Promise.resolve(window)")
a_window_handle # handle for the window object.

```

```py title=example_b9136581ad3e344d77f3892b38d86a5eb3f8f60fb570bb33b2bcb6a2ed7540da.py
a_window_handle = page.evaluate_handle("Promise.resolve(window)")
a_window_handle # handle for the window object.

```

A string can also be passed in instead of a function:

```py title=example_0d1e28bbd652512a14515e3b7379654bd71222d90d9c1c575814dfb169329380.py
a_handle = await page.evaluate_handle("document") # handle for the "document"

```

```py title=example_c681f8996c058c7f3f0720775a87f75611457b7e8b94b9d645b2f44ca0ffbd39.py
a_handle = page.evaluate_handle("document") # handle for the "document"

```

[JSHandle](./js_handle) instances can be passed as an argument to the [Page#evaluate_handle](./page#evaluate_handle):

```py title=example_0ae18f20ef6bf91a018b5362e56c867ddfccad677610a2b1dbc628e159b88d56.py
a_handle = await page.evaluate_handle("document.body")
result_handle = await page.evaluate_handle("body => body.innerHTML", a_handle)
print(await result_handle.json_value())
await result_handle.dispose()

```

```py title=example_da79d92242e58e9a49140f09273411ee9318e357d07fbdb2a63956f6cef638fa.py
a_handle = page.evaluate_handle("document.body")
result_handle = page.evaluate_handle("body => body.innerHTML", a_handle)
print(result_handle.json_value())
result_handle.dispose()

```



## expose_binding

```
def expose_binding(name, callback, handle: nil)
```

The method adds a function called `name` on the `window` object of every frame in this page. When called, the
function executes `callback` and returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) which resolves to the return value of `callback`. If the
`callback` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), it will be awaited.

The first argument of the `callback` function contains information about the caller: `{ browserContext:
BrowserContext, page: Page, frame: Frame }`.

See [BrowserContext#expose_binding](./browser_context#expose_binding) for the context-wide version.

**NOTE** Functions installed via [Page#expose_binding](./page#expose_binding) survive navigations.

**Usage**

An example of exposing page URL to all frames in a page:

```py title=example_a71d2863897d0c8fd95d967314e2e6d6c4b92f954d6c39ec51295b176ed98639.py
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    webkit = playwright.webkit
    browser = await webkit.launch(headless=false)
    context = await browser.new_context()
    page = await context.new_page()
    await page.expose_binding("pageURL", lambda source: source["page"].url)
    await page.set_content("""
    <script>
      async function onClick() {
        document.querySelector('div').textContent = await window.pageURL();
      }
    </script>
    <button onclick="onClick()">Click me</button>
    <div></div>
    """)
    await page.click("button")

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

```py title=example_27bd6ac97df3c18b4ef059be4cada4a7a7f0ff077e1dbaf7ee5d629d2e85ae78.py
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

```py title=example_1d453e776770bb6c0125978e84f80960f9f0a7ea4855c926ff7b2c8d15518d0f.py
async def print(source, element):
    print(await element.text_content())

await page.expose_binding("clicked", print, handle=true)
await page.set_content("""
  <script>
    document.addEventListener('click', event => window.clicked(event.target));
  </script>
  <div>Click me</div>
  <div>Or click me</div>
""")

```

```py title=example_4fbc6553706c0a670332f7b69b50824ea49bac67dade2e9122dbbd4dec7e349a.py
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

The method adds a function called `name` on the `window` object of every frame in the page. When called, the
function executes `callback` and returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) which resolves to the return value of `callback`.

If the `callback` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), it will be awaited.

See [BrowserContext#expose_function](./browser_context#expose_function) for context-wide exposed function.

**NOTE** Functions installed via [Page#expose_function](./page#expose_function) survive navigations.

**Usage**

An example of adding a `sha256` function to the page:

```py title=example_38a76ce9aed523164d04767aeed307d2bc6cb0b07aad3c3d86f4d73a55838568.py
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
    page = await browser.new_page()
    await page.expose_function("sha256", sha256)
    await page.set_content("""
        <script>
          async function onClick() {
            document.querySelector('div').textContent = await window.sha256('PLAYWRIGHT');
          }
        </script>
        <button onclick="onClick()">Click me</button>
        <div></div>
    """)
    await page.click("button")

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

```py title=example_02100c4444e1336b004a04e56143c14cb217bd04357885cc7316180281914552.py
import hashlib
from playwright.sync_api import sync_playwright

def sha256(text):
    m = hashlib.sha256()
    m.update(bytes(text, "utf8"))
    return m.hexdigest()


def run(playwright):
    webkit = playwright.webkit
    browser = webkit.launch(headless=False)
    page = browser.new_page()
    page.expose_function("sha256", sha256)
    page.set_content("""
        <script>
          async function onClick() {
            document.querySelector('div').textContent = await window.sha256('PLAYWRIGHT');
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
def fill(
      selector,
      value,
      force: nil,
      noWaitAfter: nil,
      strict: nil,
      timeout: nil)
```

This method waits for an element matching `selector`, waits for [actionability](https://playwright.dev/python/docs/actionability) checks,
focuses the element, fills it and triggers an `input` event after filling. Note that you can pass an empty string
to clear the input field.

If the target element is not an `<input>`, `<textarea>` or `[contenteditable]` element, this method throws an
error. However, if the element is inside the `<label>` element that has an associated
[control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be filled
instead.

To send fine-grained keyboard events, use [Page#type](./page#type).

## focus

```
def focus(selector, strict: nil, timeout: nil)
```

This method fetches an element with `selector` and focuses it. If there's no element matching `selector`, the
method waits until a matching element appears in the DOM.

## frame

```
def frame(name: nil, url: nil)
```

Returns frame matching the specified criteria. Either `name` or `url` must be specified.

**Usage**

```ruby
frame = page.frame(name: "frame-name")
```

```ruby
frame = page.frame(url: /.*domain.*/)
```



## frame_locator

```
def frame_locator(selector)
```

When working with iframes, you can create a frame locator that will enter the iframe and allow selecting elements
in that iframe.

**Usage**

Following snippet locates element with text "Submit" in the iframe with id `my-frame`, like `<iframe
id="my-frame">`:

```py title=example_ca8dce78d29c9529fc726a800a93462958b10af0fb06d9884420ca2f43ede7b9.py
locator = page.frame_locator("#my-iframe").get_by_text("Submit")
await locator.click()

```

```py title=example_6452b981d4f346d634923ce043402c2e3d242570afd83b9d1532e51b861640af.py
locator = page.frame_locator("#my-iframe").get_by_text("Submit")
locator.click()

```



## frames

```
def frames
```

An array of all frames attached to the page.

## get_attribute

```
def get_attribute(selector, name, strict: nil, timeout: nil)
```

Returns element attribute value.

## get_by_alt_text

```
def get_by_alt_text(text, exact: nil)
```

Allows locating elements by their alt text. For example, this method will find the image by alt text "Castle":

```html
<img alt='Castle'>
```


## get_by_label

```
def get_by_label(text, exact: nil)
```

Allows locating input elements by the text of the associated label. For example, this method will find the input by
label text "Password" in the following DOM:

```html
<label for="password-input">Password:</label>
<input id="password-input">
```


## get_by_placeholder

```
def get_by_placeholder(text, exact: nil)
```

Allows locating input elements by the placeholder text. For example, this method will find the input by placeholder
"Country":

```html
<input placeholder="Country">
```


## get_by_role

```
def get_by_role(
      role,
      checked: nil,
      disabled: nil,
      exact: nil,
      expanded: nil,
      includeHidden: nil,
      level: nil,
      name: nil,
      pressed: nil,
      selected: nil)
```

Allows locating elements by their [ARIA role](https://www.w3.org/TR/wai-aria-1.2/#roles),
[ARIA attributes](https://www.w3.org/TR/wai-aria-1.2/#aria-attributes) and
[accessible name](https://w3c.github.io/accname/#dfn-accessible-name). Note that role selector **does not replace**
accessibility audits and conformance tests, but rather gives early feedback about the ARIA guidelines.

Note that many html elements have an implicitly
[defined role](https://w3c.github.io/html-aam/#html-element-role-mappings) that is recognized by the role selector.
You can find all the [supported roles here](https://www.w3.org/TR/wai-aria-1.2/#role_definitions). ARIA guidelines
**do not recommend** duplicating implicit roles and attributes by setting `role` and/or `aria-*` attributes to
default values.

## get_by_test_id

```
def get_by_test_id(testId)
```

Locate element by the test id. By default, the `data-testid` attribute is used as a test id. Use
[Selectors#set_test_id_attribute](./selectors#set_test_id_attribute) to configure a different test id attribute if necessary.



## get_by_text

```
def get_by_text(text, exact: nil)
```

Allows locating elements that contain given text. Consider the following DOM structure:

```html
<div>Hello <span>world</span></div>
<div>Hello</div>
```

You can locate by text substring, exact string, or a regular expression:

```py title=example_c6955d996988d22b00dab15c3992b7961b9814c65a49cf0681728cd32653553c.py
# Matches <span>
page.get_by_text("world")

# Matches first <div>
page.get_by_text("Hello world")

# Matches second <div>
page.get_by_text("Hello", exact=True)

# Matches both <div>s
page.get_by_text(re.compile("Hello"))

# Matches second <div>
page.get_by_text(re.compile("^hello$", re.IGNORECASE))

```

```py title=example_c6955d996988d22b00dab15c3992b7961b9814c65a49cf0681728cd32653553c.py
# Matches <span>
page.get_by_text("world")

# Matches first <div>
page.get_by_text("Hello world")

# Matches second <div>
page.get_by_text("Hello", exact=True)

# Matches both <div>s
page.get_by_text(re.compile("Hello"))

# Matches second <div>
page.get_by_text(re.compile("^hello$", re.IGNORECASE))

```

See also [Locator#filter](./locator#filter) that allows to match by another criteria, like an accessible role, and then
filter by the text content.

**NOTE** Matching by text always normalizes whitespace, even with exact match. For example, it turns multiple
spaces into one, turns line breaks into spaces and ignores leading and trailing whitespace.

**NOTE** Input elements of the type `button` and `submit` are matched by their `value` instead of the text content.
For example, locating by text `"Log in"` matches `<input type=button value="Log in">`.

## get_by_title

```
def get_by_title(text, exact: nil)
```

Allows locating elements by their title. For example, this method will find the button by its title "Place the
order":

```html
<button title='Place the order'>Order Now</button>
```


## go_back

```
def go_back(timeout: nil, waitUntil: nil)
```

Returns the main resource response. In case of multiple redirects, the navigation will resolve with the response of
the last redirect. If can not go back, returns `null`.

Navigate to the previous page in history.

## go_forward

```
def go_forward(timeout: nil, waitUntil: nil)
```

Returns the main resource response. In case of multiple redirects, the navigation will resolve with the response of
the last redirect. If can not go forward, returns `null`.

Navigate to the next page in history.

## goto

```
def goto(url, referer: nil, timeout: nil, waitUntil: nil)
```

Returns the main resource response. In case of multiple redirects, the navigation will resolve with the first
non-redirect response.

The method will throw an error if:
- there's an SSL error (e.g. in case of self-signed certificates).
- target URL is invalid.
- the `timeout` is exceeded during navigation.
- the remote server does not respond or is unreachable.
- the main resource failed to load.

The method will not throw an error when any valid HTTP status code is returned by the remote server, including 404
"Not Found" and 500 "Internal Server Error".  The status code for such responses can be retrieved by calling
[Response#status](./response#status).

**NOTE** The method either throws an error or returns a main resource response. The only exceptions are navigation
to `about:blank` or navigation to the same URL with a different hash, which would succeed and return `null`.

**NOTE** Headless mode doesn't support navigation to a PDF document. See the
[upstream issue](https://bugs.chromium.org/p/chromium/issues/detail?id=761295).

## hover

```
def hover(
      selector,
      force: nil,
      modifiers: nil,
      noWaitAfter: nil,
      position: nil,
      strict: nil,
      timeout: nil,
      trial: nil)
```

This method hovers over an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If
   the element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to hover over the center of the element, or the specified `position`.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`.
Passing zero timeout disables this.

## inner_html

```
def inner_html(selector, strict: nil, timeout: nil)
```

Returns `element.innerHTML`.

## inner_text

```
def inner_text(selector, strict: nil, timeout: nil)
```

Returns `element.innerText`.

## input_value

```
def input_value(selector, strict: nil, timeout: nil)
```

Returns `input.value` for the selected `<input>` or `<textarea>` or `<select>` element.

Throws for non-input elements. However, if the element is inside the `<label>` element that has an associated
[control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), returns the value of the
control.

## checked?

```
def checked?(selector, strict: nil, timeout: nil)
```

Returns whether the element is checked. Throws if the element is not a checkbox or radio input.

## closed?

```
def closed?
```

Indicates that the page has been closed.

## disabled?

```
def disabled?(selector, strict: nil, timeout: nil)
```

Returns whether the element is disabled, the opposite of [enabled](https://playwright.dev/python/docs/actionability).

## editable?

```
def editable?(selector, strict: nil, timeout: nil)
```

Returns whether the element is [editable](https://playwright.dev/python/docs/actionability).

## enabled?

```
def enabled?(selector, strict: nil, timeout: nil)
```

Returns whether the element is [enabled](https://playwright.dev/python/docs/actionability).

## hidden?

```
def hidden?(selector, strict: nil, timeout: nil)
```

Returns whether the element is hidden, the opposite of [visible](https://playwright.dev/python/docs/actionability).  `selector` that
does not match any elements is considered hidden.

## visible?

```
def visible?(selector, strict: nil, timeout: nil)
```

Returns whether the element is [visible](https://playwright.dev/python/docs/actionability). `selector` that does not match any elements
is considered not visible.

## locator

```
def locator(selector, has: nil, hasText: nil)
```

The method returns an element locator that can be used to perform actions on this page / frame. Locator is resolved
to the element immediately before performing an action, so a series of actions on the same locator can in fact be
performed on different DOM elements. That would happen if the DOM structure between those actions has changed.

[Learn more about locators](https://playwright.dev/python/docs/locators).

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

## pause

```
def pause
```

Pauses script execution. Playwright will stop executing the script and wait for the user to either press 'Resume'
button in the page overlay or to call `playwright.resume()` in the DevTools console.

User can inspect selectors or perform manual steps while paused. Resume will continue running the original script
from the place it was paused.

**NOTE** This method requires Playwright to be started in a headed mode, with a falsy `headless` value in the
[BrowserType#launch](./browser_type#launch).

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

**NOTE** Generating a pdf is currently only supported in Chromium headless.

`page.pdf()` generates a pdf of the page with `print` css media. To generate a pdf with `screen` media, call
[Page#emulate_media](./page#emulate_media) before calling `page.pdf()`:

**NOTE** By default, `page.pdf()` generates a pdf with modified colors for printing. Use the
[`-webkit-print-color-adjust`](https://developer.mozilla.org/en-US/docs/Web/CSS/-webkit-print-color-adjust)
property to force rendering of exact colors.

**Usage**

```py title=example_85018ca43f1966cedc30fc02b200bed7d73f654e0446b95db3856f3ac9f9d4e1.py
# generates a pdf with "screen" media type.
await page.emulate_media(media="screen")
await page.pdf(path="page.pdf")

```

```py title=example_6ae1b99aa3ea6cd7a571de12031a563e7fc02f1f0b17958c263e0ba8395618f1.py
# generates a pdf with "screen" media type.
page.emulate_media(media="screen")
page.pdf(path="page.pdf")

```

The `width`, `height`, and `margin` options accept values labeled with units. Unlabeled values are treated as
pixels.

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

**NOTE** `headerTemplate` and `footerTemplate` markup have the following limitations: > 1. Script tags inside
templates are not evaluated. > 2. Page styles are not visible inside templates.

## press

```
def press(
      selector,
      key,
      delay: nil,
      noWaitAfter: nil,
      strict: nil,
      timeout: nil)
```

Focuses the element, and then uses [Keyboard#down](./keyboard#down) and [Keyboard#up](./keyboard#up).

`key` can specify the intended
[keyboardEvent.key](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key) value or a single character
to generate the text for. A superset of the `key` values can be found
[here](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values). Examples of the keys are:

`F1` - `F12`, `Digit0`- `Digit9`, `KeyA`- `KeyZ`, `Backquote`, `Minus`, `Equal`, `Backslash`, `Backspace`, `Tab`,
`Delete`, `Escape`, `ArrowDown`, `End`, `Enter`, `Home`, `Insert`, `PageDown`, `PageUp`, `ArrowRight`, `ArrowUp`,
etc.

Following modification shortcuts are also supported: `Shift`, `Control`, `Alt`, `Meta`, `ShiftLeft`.

Holding down `Shift` will type the text that corresponds to the `key` in the upper case.

If `key` is a single character, it is case-sensitive, so the values `a` and `A` will generate different respective
texts.

Shortcuts such as `key: "Control+o"` or `key: "Control+Shift+T"` are supported as well. When specified with the
modifier, modifier is pressed and being held while the subsequent key is being pressed.

**Usage**

```py title=example_a28964a09dac76b60d9e88cf889662252e621173047b38387f2cf510ac1e3f08.py
page = await browser.new_page()
await page.goto("https://keycode.info")
await page.press("body", "A")
await page.screenshot(path="a.png")
await page.press("body", "ArrowLeft")
await page.screenshot(path="arrow_left.png")
await page.press("body", "Shift+O")
await page.screenshot(path="o.png")
await browser.close()

```

```py title=example_2b3f0072bb23e7cbd8198467010305a4b63809c1f432d956f25b8bb5d6095df2.py
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
def query_selector(selector, strict: nil)
```

The method finds an element matching the specified selector within the page. If no elements match the selector, the
return value resolves to `null`. To wait for an element on the page, use [Locator#wait_for](./locator#wait_for).

## query_selector_all

```
def query_selector_all(selector)
```

The method finds all elements matching the specified selector within the page. If no elements match the selector,
the return value resolves to `[]`.

## reload

```
def reload(timeout: nil, waitUntil: nil)
```

This method reloads the current page, in the same way as if the user had triggered a browser refresh. Returns the
main resource response. In case of multiple redirects, the navigation will resolve with the response of the last
redirect.

## route

```
def route(url, handler, times: nil)
```

Routing provides the capability to modify network requests that are made by a page.

Once routing is enabled, every request matching the url pattern will stall unless it's continued, fulfilled or
aborted.

**NOTE** The handler will only be called for the first url if the response is a redirect.

**NOTE** [Page#route](./page#route) will not intercept requests intercepted by Service Worker. See
[this](https://github.com/microsoft/playwright/issues/1090) issue. We recommend disabling Service Workers when
using request interception by setting `Browser.newContext.serviceWorkers` to `'block'`.

**Usage**

An example of a naive handler that aborts all image requests:

```py title=example_8e341b80d87b75d20d31761c5d81a29f4979d2dcc83920bed57743678d0b0a9e.py
page = await browser.new_page()
await page.route("**/*.{png,jpg,jpeg}", lambda route: route.abort())
await page.goto("https://example.com")
await browser.close()

```

```py title=example_f263344629e850e1219ce3efdb9283eeb6c6c1c2f33d331c3be7fcf9dfe96e27.py
page = browser.new_page()
page.route("**/*.{png,jpg,jpeg}", lambda route: route.abort())
page.goto("https://example.com")
browser.close()

```

or the same snippet using a regex pattern instead:

```py title=example_dda8a7b535c1a028cde1f84913c993315b3e5bb39bc37f88443cab25de02fd40.py
page = await browser.new_page()
await page.route(re.compile(r"(\.png$)|(\.jpg$)"), lambda route: route.abort())
await page.goto("https://example.com")
await browser.close()

```

```py title=example_c95c3c6b06f099684f6c8b086b6c423137baa31396447cbbb756e3ad86b98771.py
page = browser.new_page()
page.route(re.compile(r"(\.png$)|(\.jpg$)"), lambda route: route.abort())
page.goto("https://example.com")
browser.close()

```

It is possible to examine the request to decide the route action. For example, mocking all requests that contain
some post data, and leaving all other requests as is:

```py title=example_e5cf80876bd0a46a6227fe2a84b67c8c277725e0b5d2629d992d2dd79990eaa5.py
def handle_route(route):
  if ("my-string" in route.request.post_data)
    route.fulfill(body="mocked-data")
  else
    route.continue_()
await page.route("/api/**", handle_route)

```

```py title=example_fefc682f8619031abbe6afa4f1cb3a509ce6bf4da689b1f05a7cdf264cf01291.py
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

**NOTE** Enabling routing disables http cache.

## route_from_har

```
def route_from_har(har, notFound: nil, update: nil, url: nil)
```

If specified the network requests that are made in the page will be served from the HAR file. Read more about
[Replaying from HAR](https://playwright.dev/python/docs/network).

Playwright will not serve requests intercepted by Service Worker from the HAR file. See
[this](https://github.com/microsoft/playwright/issues/1090) issue. We recommend disabling Service Workers when
using request interception by setting `Browser.newContext.serviceWorkers` to `'block'`.

## screenshot

```
def screenshot(
      animations: nil,
      caret: nil,
      clip: nil,
      fullPage: nil,
      mask: nil,
      omitBackground: nil,
      path: nil,
      quality: nil,
      scale: nil,
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
      force: nil,
      noWaitAfter: nil,
      strict: nil,
      timeout: nil)
```

This method waits for an element matching `selector`, waits for [actionability](https://playwright.dev/python/docs/actionability) checks, waits
until all specified options are present in the `<select>` element and selects these options.

If the target element is not a `<select>` element, this method throws an error. However, if the element is inside
the `<label>` element that has an associated
[control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be used
instead.

Returns the array of option values that have been successfully selected.

Triggers a `change` and `input` event once all the provided options have been selected.

**Usage**

```py title=example_92fba1d2324c392678327ffe5950b822e9031535a9dfeb40ceff1929d6141a93.py
# single selection matching the value
await page.select_option("select#colors", "blue")
# single selection matching the label
await page.select_option("select#colors", label="blue")
# multiple selection
await page.select_option("select#colors", value=["red", "green", "blue"])

```

```py title=example_317f52caef6dc0e027ce05a27eb9ab37a692f592b585690e32be86952ee739d3.py
# single selection matching the value
page.select_option("select#colors", "blue")
# single selection matching both the label
page.select_option("select#colors", label="blue")
# multiple selection
page.select_option("select#colors", value=["red", "green", "blue"])

```



## set_checked

```
def set_checked(
      selector,
      checked,
      force: nil,
      noWaitAfter: nil,
      position: nil,
      strict: nil,
      timeout: nil,
      trial: nil)
```

This method checks or unchecks an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Ensure that matched element is a checkbox or a radio input. If not, this method throws.
1. If the element already has the right checked state, this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If
   the element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.
1. Ensure that the element is now checked or unchecked. If not, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`.
Passing zero timeout disables this.

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
- [Page#expect_navigation](./page#expect_navigation)
- [Page#wait_for_url](./page#wait_for_url)

**NOTE** [Page#set_default_navigation_timeout](./page#set_default_navigation_timeout) takes priority over [Page#set_default_timeout](./page#set_default_timeout),
[BrowserContext#set_default_timeout](./browser_context#set_default_timeout) and [BrowserContext#set_default_navigation_timeout](./browser_context#set_default_navigation_timeout).

## set_default_timeout

```
def set_default_timeout(timeout)
```
alias: `default_timeout=`

This setting will change the default maximum time for all the methods accepting `timeout` option.

**NOTE** [Page#set_default_navigation_timeout](./page#set_default_navigation_timeout) takes priority over [Page#set_default_timeout](./page#set_default_timeout).

## set_extra_http_headers

```
def set_extra_http_headers(headers)
```
alias: `extra_http_headers=`

The extra HTTP headers will be sent with every request the page initiates.

**NOTE** [Page#set_extra_http_headers](./page#set_extra_http_headers) does not guarantee the order of headers in the outgoing requests.

## set_input_files

```
def set_input_files(
      selector,
      files,
      noWaitAfter: nil,
      strict: nil,
      timeout: nil)
```

Sets the value of the file input to these file paths or files. If some of the `filePaths` are relative paths, then
they are resolved relative to the current working directory. For empty array, clears the selected files.

This method expects `selector` to point to an
[input element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input). However, if the element is inside
the `<label>` element that has an associated
[control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), targets the control instead.

## set_viewport_size

```
def set_viewport_size(viewportSize)
```
alias: `viewport_size=`

In the case of multiple pages in a single browser, each page can have its own viewport size. However,
[Browser#new_context](./browser#new_context) allows to set viewport size (and more) for all pages in the context at once.

[Page#set_viewport_size](./page#set_viewport_size) will resize the page. A lot of websites don't expect phones to change size, so you
should set the viewport size before navigating to the page. [Page#set_viewport_size](./page#set_viewport_size) will also reset
`screen` size, use [Browser#new_context](./browser#new_context) with `screen` and `viewport` parameters if you need better
control of these properties.

**Usage**

```py title=example_4851705152b52b1417caf468eb7d14955a06be627a7a99abb3abecddf922ce6e.py
page = await browser.new_page()
await page.set_viewport_size({"width": 640, "height": 480})
await page.goto("https://example.com")

```

```py title=example_61594bc3b6911efe5257180bd4330905c5e85ac5160bef8065e974e65acb5979.py
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
      strict: nil,
      timeout: nil,
      trial: nil)
```

This method taps an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If
   the element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#touchscreen](./page#touchscreen) to tap the center of the element, or the specified `position`.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`.
Passing zero timeout disables this.

**NOTE** [Page#tap_point](./page#tap_point) requires that the `hasTouch` option of the browser context be set to true.

## text_content

```
def text_content(selector, strict: nil, timeout: nil)
```

Returns `element.textContent`.

## title

```
def title
```

Returns the page's title.

## type

```
def type(
      selector,
      text,
      delay: nil,
      noWaitAfter: nil,
      strict: nil,
      timeout: nil)
```

Sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text. `page.type` can be used to
send fine-grained keyboard events. To fill values in form fields, use [Page#fill](./page#fill).

To press a special key, like `Control` or `ArrowDown`, use [Keyboard#press](./keyboard#press).

**Usage**

```py title=example_2d2b9d7e2fe1efe8e98c87e3942b5735479932de0f5a1cf34bd6505081e90be5.py
await page.type("#mytextarea", "hello") # types instantly
await page.type("#mytextarea", "world", delay=100) # types slower, like a user

```

```py title=example_cb8aacbfa50c3c7929d638e7441078bc52be0e160fdaaf9595bcbd0e2b648489.py
page.type("#mytextarea", "hello") # types instantly
page.type("#mytextarea", "world", delay=100) # types slower, like a user

```



## uncheck

```
def uncheck(
      selector,
      force: nil,
      noWaitAfter: nil,
      position: nil,
      strict: nil,
      timeout: nil,
      trial: nil)
```

This method unchecks an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Ensure that matched element is a checkbox or a radio input. If not, this method throws. If the element is
   already unchecked, this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If
   the element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.
1. Ensure that the element is now unchecked. If not, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`.
Passing zero timeout disables this.

## unroute

```
def unroute(url, handler: nil)
```

Removes a route created with [Page#route](./page#route). When `handler` is not specified, removes all routes for the
`url`.

## url

```
def url
```



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
[ConsoleMessage](./console_message) value into the `predicate` function and waits for `predicate(message)` to return a truthy value.
Will throw an error if the page is closed before the [`event: Page.console`] event is fired.

## expect_download

```
def expect_download(predicate: nil, timeout: nil, &block)
```

Performs action and waits for a new [Download](./download). If predicate is provided, it passes [Download](./download) value into the
`predicate` function and waits for `predicate(download)` to return a truthy value. Will throw an error if the page
is closed before the download event is fired.

## expect_event

```
def expect_event(event, predicate: nil, timeout: nil, &block)
```

Waits for event to fire and passes its value into the predicate function. Returns when the predicate returns truthy
value. Will throw an error if the page is closed before the event is fired. Returns the event data value.

**Usage**

```py title=example_50a05313ff0c0420679df115704d9a2b05f3ac38ae1f60cc124cf8038424b731.py
async with page.expect_event("framenavigated") as event_info:
    await page.get_by_role("button")
frame = await event_info.value

```

```py title=example_0e9bb2e54a2b9ac634ff47e184ecce125ed6c6116d544a270aabdaa7d07aa211.py
with page.expect_event("framenavigated") as event_info:
    page.get_by_role("button")
frame = event_info.value

```


## expect_file_chooser

```
def expect_file_chooser(predicate: nil, timeout: nil, &block)
```

Performs action and waits for a new [FileChooser](./file_chooser) to be created. If predicate is provided, it passes [FileChooser](./file_chooser)
value into the `predicate` function and waits for `predicate.call(fileChooser)` to return a truthy value. Will throw an
error if the page is closed before the file chooser is opened.

## wait_for_function

```
def wait_for_function(expression, arg: nil, polling: nil, timeout: nil)
```

Returns when the `expression` returns a truthy value. It resolves to a JSHandle of the truthy value.

**Usage**

The [Page#wait_for_function](./page#wait_for_function) can be used to observe viewport size change:

```py title=example_a05818cc1560da9e71a3a591e690bc1cf4149053124b05b5540ae9b052f0f03a.py
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    webkit = playwright.webkit
    browser = await webkit.launch()
    page = await browser.new_page()
    await page.evaluate("window.x = 0; setTimeout(() => { window.x = 100 }, 1000);")
    await page.wait_for_function("() => window.x > 0")
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

```py title=example_32b5a7bc501489d14a0bc27d3416a01b7abb402733588a04a0728196e5140cb3.py
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

```py title=example_0db1e8ea8710b9a57ea2298490d7cc2eaab38ace0b3163fbc37270f37676b124.py
selector = ".foo"
await page.wait_for_function("selector => !!document.querySelector(selector)", selector)

```

```py title=example_d9cffcfc0a1939f612248a9c0ef8ee53ddc650e0d6c9e092f50e70e1137c015c.py
selector = ".foo"
page.wait_for_function("selector => !!document.querySelector(selector)", selector)

```



## wait_for_load_state

```
def wait_for_load_state(state: nil, timeout: nil)
```

Returns when the required load state has been reached.

This resolves when the page reaches a required load state, `load` by default. The navigation must have been
committed when this method is called. If current document has already reached the required state, resolves
immediately.

**Usage**

```py title=example_87ff554a532c3ad21f7279e805ddc1ea1d6a5e83cd22f4bf2d6876eeb970667a.py
await page.get_by_role("button").click() # click triggers navigation.
await page.wait_for_load_state() # the promise resolves after "load" event.

```

```py title=example_4a982464576c7e9c51248c9279e9446b18084e973268c8eb67595b050ccab590.py
page.get_by_role("button").click() # click triggers navigation.
page.wait_for_load_state() # the promise resolves after "load" event.

```

```py title=example_7fea1144705fad201a055f1ceb261eb8e66050fb044e5897413e73fb3e4b0d7c.py
async with page.expect_popup() as page_info:
    await page.get_by_role("button").click() # click triggers a popup.
popup = await page_info.value
# Wait for the "DOMContentLoaded" event.
await popup.wait_for_load_state("domcontentloaded")
print(await popup.title()) # popup is ready to use.

```

```py title=example_a7addfa268423d8a1c52aeba3919ae79614f18b93db457da1292242a56d6621b.py
with page.expect_popup() as page_info:
    page.get_by_role("button").click() # click triggers a popup.
popup = page_info.value
# Wait for the "DOMContentLoaded" event.
popup.wait_for_load_state("domcontentloaded")
print(popup.title()) # popup is ready to use.

```



## expect_navigation

```
def expect_navigation(timeout: nil, url: nil, waitUntil: nil, &block)
```

Waits for the main frame navigation and returns the main resource response. In case of multiple redirects, the
navigation will resolve with the response of the last redirect. In case of navigation to a different anchor or
navigation due to History API usage, the navigation will resolve with `null`.

**Usage**

This resolves when the page navigates to a new URL or reloads. It is useful for when you run code which will
indirectly cause the page to navigate. e.g. The click target has an `onclick` handler that triggers navigation from
a `setTimeout`. Consider this example:

```py title=example_29e37d3de68e80846769402da0d36aaa688c8047cef3b1e718ed62fe0995e166.py
async with page.expect_navigation():
    # This action triggers the navigation after a timeout.
    await page.get_by_text("Navigate after timeout").click()
# Resolves after navigation has finished

```

```py title=example_4e1ff20ee93eb61c5a68f3d9ec8c84cb449775356be2fc24dbd8859bac6b74fe.py
with page.expect_navigation():
    # This action triggers the navigation after a timeout.
    page.get_by_text("Navigate after timeout").click()
# Resolves after navigation has finished

```

**NOTE** Usage of the [History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API) to change the URL
is considered a navigation.

## expect_popup

```
def expect_popup(predicate: nil, timeout: nil, &block)
```

Performs action and waits for a popup [Page](./page). If predicate is provided, it passes [Popup] value into the
`predicate` function and waits for `predicate(page)` to return a truthy value. Will throw an error if the page is
closed before the popup event is fired.

## expect_request

```
def expect_request(urlOrPredicate, timeout: nil, &block)
```

Waits for the matching request and returns it. See [waiting for event](https://playwright.dev/python/docs/events) for more
details about events.

**Usage**

```py title=example_7d3637cf1b1c39f6e3dde152d7bebdfc090caa5344dcd68108d8e61274e2281e.py
async with page.expect_request("http://example.com/resource") as first:
    await page.get_by_text("trigger request").click()
first_request = await first.value

# or with a lambda
async with page.expect_request(lambda request: request.url == "http://example.com" and request.method == "get") as second:
    await page.get_by_text("trigger request").click()
second_request = await second.value

```

```py title=example_35f9b67d8d9ff416241657b566fa338f5a3fd06ddb1b6c5818e6d34280aea5c0.py
with page.expect_request("http://example.com/resource") as first:
    page.get_by_text("trigger request").click()
first_request = first.value

# or with a lambda
with page.expect_request(lambda request: request.url == "http://example.com" and request.method == "get") as second:
    page.get_by_text("trigger request").click()
second_request = second.value

```



## expect_request_finished

```
def expect_request_finished(predicate: nil, timeout: nil, &block)
```

Performs action and waits for a [Request](./request) to finish loading. If predicate is provided, it passes [Request](./request) value
into the `predicate` function and waits for `predicate(request)` to return a truthy value. Will throw an error if
the page is closed before the [`event: Page.requestFinished`] event is fired.

## expect_response

```
def expect_response(urlOrPredicate, timeout: nil, &block)
```

Returns the matched response. See [waiting for event](https://playwright.dev/python/docs/events) for more details about
events.

**Usage**

```py title=example_0c3ed1aea41d8149cf939321073cbbcf1f59e84015b6268bcfcd35df74840a03.py
async with page.expect_response("https://example.com/resource") as response_info:
    await page.get_by_text("trigger response").click()
response = await response_info.value
return response.ok

# or with a lambda
async with page.expect_response(lambda response: response.url == "https://example.com" and response.status == 200) as response_info:
    await page.get_by_text("trigger response").click()
response = await response_info.value
return response.ok

```

```py title=example_0efc7ae161fdbcafb9598f37908dc61876ec40160ef6deea1e35e6488420d507.py
with page.expect_response("https://example.com/resource") as response_info:
    page.get_by_text("trigger response").click()
response = response_info.value
return response.ok

# or with a lambda
with page.expect_response(lambda response: response.url == "https://example.com" and response.status == 200) as response_info:
    page.get_by_text("trigger response").click()
response = response_info.value
return response.ok

```



## wait_for_selector

```
def wait_for_selector(selector, state: nil, strict: nil, timeout: nil)
```

Returns when element specified by selector satisfies `state` option. Returns `null` if waiting for `hidden` or
`detached`.

**NOTE** Playwright automatically waits for element to be ready before performing an action. Using [Locator](./locator)
objects and web-first assertions makes the code wait-for-selector-free.

Wait for the `selector` to satisfy `state` option (either appear/disappear from dom, or become visible/hidden). If
at the moment of calling the method `selector` already satisfies the condition, the method will return immediately.
If the selector doesn't satisfy the condition for the `timeout` milliseconds, the function will throw.

**Usage**

This method works across navigations:

```py title=example_8fe0259d09f568eac9ef96ea8c867f167ad03baa2479377b0d53eb36ea0053e3.py
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    chromium = playwright.chromium
    browser = await chromium.launch()
    page = await browser.new_page()
    for current_url in ["https://google.com", "https://bbc.com"]:
        await page.goto(current_url, wait_until="domcontentloaded")
        element = await page.wait_for_selector("img")
        print("Loaded image: " + str(await element.get_attribute("src")))
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

```py title=example_ae4e484f9c5130216d5ae358ed7195475c5f29da39931209982feb30e776fc05.py
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



## wait_for_timeout

```
def wait_for_timeout(timeout)
```

Waits for the given `timeout` in milliseconds.

Note that `page.waitForTimeout()` should only be used for debugging. Tests using the timer in production are going
to be flaky. Use signals such as network events, selectors becoming visible and others instead.

**Usage**

```py title=example_6870202af66b6074403a9a41198465dec21c41c7305f87ef21276aaa174eb361.py
# wait for 1 second
await page.wait_for_timeout(1000)

```

```py title=example_df6f29d6ce17fe75b8813a95960b372ec97dee83b22f35878336eec8057797fd.py
# wait for 1 second
page.wait_for_timeout(1000)

```



## wait_for_url

```
def wait_for_url(url, timeout: nil, waitUntil: nil)
```

Waits for the main frame to navigate to the given URL.

**Usage**

```py title=example_141a6aba0f23a37e614e60dfd4fe42b6225df9733b21e5e8140e6c912da981ca.py
await page.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
await page.wait_for_url("**/target.html")

```

```py title=example_eaf38540aa7ddfa4b650e2eaba8fd60a5479e583663f73a6c5a406a86761732d.py
page.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
page.wait_for_url("**/target.html")

```



## expect_websocket

```
def expect_websocket(predicate: nil, timeout: nil, &block)
```

Performs action and waits for a new [WebSocket](./web_socket). If predicate is provided, it passes [WebSocket](./web_socket) value into the
`predicate` function and waits for `predicate(webSocket)` to return a truthy value. Will throw an error if the page
is closed before the WebSocket event is fired.

## expect_worker

```
def expect_worker(predicate: nil, timeout: nil, &block)
```

Performs action and waits for a new [Worker](./worker). If predicate is provided, it passes [Worker](./worker) value into the
`predicate` function and waits for `predicate(worker)` to return a truthy value. Will throw an error if the page is
closed before the worker event is fired.

## workers

```
def workers
```

This method returns all of the dedicated
[WebWorkers](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API) associated with the page.

**NOTE** This does not contain ServiceWorkers

## accessibility

## keyboard

## mouse

## request

API testing helper associated with this page. This method returns the same instance as
[BrowserContext#request](./browser_context#request) on the page's context. See [BrowserContext#request](./browser_context#request) for more
details.

## touchscreen
