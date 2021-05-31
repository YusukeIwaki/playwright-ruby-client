---
sidebar_position: 10
---

# Frame

At every point of time, page exposes its current frame tree via the [Page#main_frame](./page#main_frame) and
[Frame#child_frames](./frame#child_frames) methods.

[Frame](./frame) object's lifecycle is controlled by three events, dispatched on the page object:
- [`event: Page.frameAttached`] - fired when the frame gets attached to the page. A Frame can be attached to the page
  only once.
- [`event: Page.frameNavigated`] - fired when the frame commits navigation to a different URL.
- [`event: Page.frameDetached`] - fired when the frame gets detached from the page.  A Frame can be detached from the
  page only once.

An example of dumping frame tree:

```python sync title=example_a4a9e01d1e0879958d591c4bc9061574f5c035e821a94214e650d15564d77bf4.py
from playwright.sync_api import sync_playwright

def run(playwright):
    firefox = playwright.firefox
    browser = firefox.launch()
    page = browser.new_page()
    page.goto("https://www.theverge.com")
    dump_frame_tree(page.main_frame, "")
    browser.close()

def dump_frame_tree(frame, indent):
    print(indent + frame.name + '@' + frame.url)
    for child in frame.child_frames:
        dump_frame_tree(child, indent + "    ")

with sync_playwright() as playwright:
    run(playwright)

```



## add_script_tag

```
def add_script_tag(content: nil, path: nil, type: nil, url: nil)
```

Returns the added tag when the script's onload fires or when the script content was injected into frame.

Adds a `<script>` tag into the page with the desired url or content.

## add_style_tag

```
def add_style_tag(content: nil, path: nil, url: nil)
```

Returns the added tag when the stylesheet's onload fires or when the CSS content was injected into frame.

Adds a `<link rel="stylesheet">` tag into the page with the desired url or a `<style type="text/css">` tag with the
content.

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

## child_frames

```
def child_frames
```



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

## content

```
def content
```

Gets the full HTML contents of the frame, including the doctype.

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

> NOTE: `frame.dblclick()` dispatches two `click` events and a single `dblclick` event.

## dispatch_event

```
def dispatch_event(selector, type, eventInit: nil, timeout: nil)
```

The snippet below dispatches the `click` event on the element. Regardless of the visibility state of the element,
`click` is dispatched. This is equivalent to calling
[element.click()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/click).

```python sync title=example_de439a4f4839a9b1bc72dbe0890d6b989c437620ba1b88a2150faa79f98184fc.py
frame.dispatch_event("button#submit", "click")

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

```python sync title=example_5410f49339561b3cc9d91c7548c8195a570c8be704bb62f45d90c68f869d450d.py
# note you can only create data_transfer in chromium and firefox
data_transfer = frame.evaluate_handle("new DataTransfer()")
frame.dispatch_event("#source", "dragstart", { "dataTransfer": data_transfer })

```



## eval_on_selector

```
def eval_on_selector(selector, expression, arg: nil)
```

Returns the return value of `expression`.

The method finds an element matching the specified selector within the frame and passes it as a first argument to
`expression`. See [Working with selectors](https://playwright.dev/python/docs/selectors) for more details. If no elements match the selector, the
method throws an error.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Frame#eval_on_selector](./frame#eval_on_selector) would wait for the promise to resolve and
return its value.

Examples:

```python sync title=example_6814d0e91763f4d27a0d6a380c36d62b551e4c3e902d1157012dde0a49122abe.py
search_value = frame.eval_on_selector("#search", "el => el.value")
preload_href = frame.eval_on_selector("link[rel=preload]", "el => el.href")
html = frame.eval_on_selector(".main-container", "(e, suffix) => e.outerHTML + suffix", "hello")

```



## eval_on_selector_all

```
def eval_on_selector_all(selector, expression, arg: nil)
```

Returns the return value of `expression`.

The method finds all elements matching the specified selector within the frame and passes an array of matched elements
as a first argument to `expression`. See [Working with selectors](https://playwright.dev/python/docs/selectors) for more details.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Frame#eval_on_selector_all](./frame#eval_on_selector_all) would wait for the promise to resolve and
return its value.

Examples:

```python sync title=example_618e7f8f681d1c4a1c0c9b8d23892e37cbbef013bf3d8906fd4311c51d9819d7.py
divs_counts = frame.eval_on_selector_all("div", "(divs, min) => divs.length >= min", 10)

```



## evaluate

```
def evaluate(expression, arg: nil)
```

Returns the return value of `expression`.

If the function passed to the [Frame#evaluate](./frame#evaluate) returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Frame#evaluate](./frame#evaluate) would wait
for the promise to resolve and return its value.

If the function passed to the [Frame#evaluate](./frame#evaluate) returns a non-[Serializable](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify#description) value, then
[Frame#evaluate](./frame#evaluate) returns `undefined`. Playwright also supports transferring some additional values that are
not serializable by `JSON`: `-0`, `NaN`, `Infinity`, `-Infinity`.

```python sync title=example_15a235841cd1bc56fad6e3c8aaea2a30e352fedd8238017f22f97fc70e058d2b.py
result = frame.evaluate("([x, y]) => Promise.resolve(x * y)", [7, 8])
print(result) # prints "56"

```

A string can also be passed in instead of a function.

```python sync title=example_9c73167b900498bca191abc2ce2627e063f84b0abc8ce3a117416cb734602760.py
print(frame.evaluate("1 + 2")) # prints "3"
x = 10
print(frame.evaluate(f"1 + {x}")) # prints "11"

```

[ElementHandle](./element_handle) instances can be passed as an argument to the [Frame#evaluate](./frame#evaluate):

```python sync title=example_05568c81173717fa6841099571d8a66e14fc0853e01684630d1622baedc25f67.py
body_handle = frame.query_selector("body")
html = frame.evaluate("([body, suffix]) => body.innerHTML + suffix", [body_handle, "hello"])
body_handle.dispose()

```



## evaluate_handle

```
def evaluate_handle(expression, arg: nil)
```

Returns the return value of `expression` as a [JSHandle](./js_handle).

The only difference between [Frame#evaluate](./frame#evaluate) and [Frame#evaluate_handle](./frame#evaluate_handle) is that
[Frame#evaluate_handle](./frame#evaluate_handle) returns [JSHandle](./js_handle).

If the function, passed to the [Frame#evaluate_handle](./frame#evaluate_handle), returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then
[Frame#evaluate_handle](./frame#evaluate_handle) would wait for the promise to resolve and return its value.

```python sync title=example_a1c8e837e826079359d01d6f7eecc64092a45d8c74280d23ee9039c379132c51.py
a_window_handle = frame.evaluate_handle("Promise.resolve(window)")
a_window_handle # handle for the window object.

```

A string can also be passed in instead of a function.

```ruby
a_handle = page.evaluate_handle("document") # handle for the "document"
```

[JSHandle](./js_handle) instances can be passed as an argument to the [Frame#evaluate_handle](./frame#evaluate_handle):

```ruby
body_handle = page.evaluate_handle("document.body")
result_handle = page.evaluate_handle("body => body.innerHTML", arg: body_handle)
puts result_handle.json_value
result_handle.dispose
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

To send fine-grained keyboard events, use [Frame#type](./frame#type).

## focus

```
def focus(selector, timeout: nil)
```

This method fetches an element with `selector` and focuses it. If there's no element matching `selector`, the method
waits until a matching element appears in the DOM.

## frame_element

```
def frame_element
```

Returns the `frame` or `iframe` element handle which corresponds to this frame.

This is an inverse of [ElementHandle#content_frame](./element_handle#content_frame). Note that returned handle actually belongs to the parent
frame.

This method throws an error if the frame has been detached before `frameElement()` returns.

```python sync title=example_e6b4fdef29a401d84b17acfa319bee08f39e1f28e07c435463622220c6a24747.py
frame_element = frame.frame_element()
content_frame = frame_element.content_frame()
assert frame == content_frame

```



## get_attribute

```
def get_attribute(selector, name, timeout: nil)
```

Returns element attribute value.

## goto

```
def goto(url, referer: nil, timeout: nil, waitUntil: nil)
```

Returns the main resource response. In case of multiple redirects, the navigation will resolve with the response of the
last redirect.

`frame.goto` will throw an error if:
- there's an SSL error (e.g. in case of self-signed certificates).
- target URL is invalid.
- the `timeout` is exceeded during navigation.
- the remote server does not respond or is unreachable.
- the main resource failed to load.

`frame.goto` will not throw an error when any valid HTTP status code is returned by the remote server, including 404
"Not Found" and 500 "Internal Server Error".  The status code for such responses can be retrieved by calling
[Response#status](./response#status).

> NOTE: `frame.goto` either throws an error or returns a main resource response. The only exceptions are navigation to
`about:blank` or navigation to the same URL with a different hash, which would succeed and return `null`.
> NOTE: Headless mode doesn't support navigation to a PDF document. See the
[upstream issue](https://bugs.chromium.org/p/chromium/issues/detail?id=761295).

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

## detached?

```
def detached?
```

Returns `true` if the frame has been detached, or `false` otherwise.

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

## name

```
def name
```

Returns frame's name attribute as specified in the tag.

If the name is empty, returns the id attribute instead.

> NOTE: This value is calculated once when the frame is created, and will not update if the attribute is changed later.

## page

```
def page
```

Returns the page containing this frame.

## parent_frame

```
def parent_frame
```

Parent frame, if any. Detached frames and main frames return `null`.

## press

```
def press(
      selector,
      key,
      delay: nil,
      noWaitAfter: nil,
      timeout: nil)
```

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

## query_selector

```
def query_selector(selector)
```

Returns the ElementHandle pointing to the frame element.

The method finds an element matching the specified selector within the frame. See
[Working with selectors](https://playwright.dev/python/docs/selectors) for more details. If no elements match the selector, returns `null`.

## query_selector_all

```
def query_selector_all(selector)
```

Returns the ElementHandles pointing to the frame elements.

The method finds all elements matching the specified selector within the frame. See
[Working with selectors](https://playwright.dev/python/docs/selectors) for more details. If no elements match the selector, returns empty array.

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

```python sync title=example_230c12044664b222bf35d6163b1e415c011d87d9911a4d39648c7f601b344a31.py
# single selection matching the value
frame.select_option("select#colors", "blue")
# single selection matching both the label
frame.select_option("select#colors", label="blue")
# multiple selection
frame.select_option("select#colors", value=["red", "green", "blue"])

```



## set_content

```
def set_content(html, timeout: nil, waitUntil: nil)
```
alias: `content=`



## set_input_files

```
def set_input_files(selector, files, noWaitAfter: nil, timeout: nil)
```

This method expects `selector` to point to an
[input element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input).

Sets the value of the file input to these file paths or files. If some of the `filePaths` are relative paths, then they
are resolved relative to the the current working directory. For empty array, clears the selected files.

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

> NOTE: `frame.tap()` requires that the `hasTouch` option of the browser context be set to true.

## text_content

```
def text_content(selector, timeout: nil)
```

Returns `element.textContent`.

## title

```
def title
```

Returns the page title.

## type

```
def type(
      selector,
      text,
      delay: nil,
      noWaitAfter: nil,
      timeout: nil)
```

Sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text. `frame.type` can be used to
send fine-grained keyboard events. To fill values in form fields, use [Frame#fill](./frame#fill).

To press a special key, like `Control` or `ArrowDown`, use [Keyboard#press](./keyboard#press).

```python sync title=example_beae7f0d11663c3c98b9d3a8e6ab76b762578cf2856e3b04ad8e42bfb23bb1e1.py
frame.type("#mytextarea", "hello") # types instantly
frame.type("#mytextarea", "world", delay=100) # types slower, like a user

```



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

This method checks an element matching `selector` by performing the following steps:
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

## url

```
def url
```

Returns frame's url.

## wait_for_function

```
def wait_for_function(expression, arg: nil, polling: nil, timeout: nil)
```

Returns when the `expression` returns a truthy value, returns that value.

The [Frame#wait_for_function](./frame#wait_for_function) can be used to observe viewport size change:

```python sync title=example_2f82dcf15fa9338be87a4faf7fe7de3c542040924db1e1ad1c98468ec0f425ce.py
from playwright.sync_api import sync_playwright

def run(playwright):
    webkit = playwright.webkit
    browser = webkit.launch()
    page = browser.new_page()
    page.evaluate("window.x = 0; setTimeout(() => { window.x = 100 }, 1000);")
    page.main_frame.wait_for_function("() => window.x > 0")
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

To pass an argument to the predicate of `frame.waitForFunction` function:

```python sync title=example_8b95be0fb4d149890f7817d9473428a50dc631d3a75baf89846648ca6a157562.py
selector = ".foo"
frame.wait_for_function("selector => !!document.querySelector(selector)", selector)

```



## wait_for_load_state

```
def wait_for_load_state(state: nil, timeout: nil)
```

Waits for the required load state to be reached.

This returns when the frame reaches a required load state, `load` by default. The navigation must have been committed
when this method is called. If current document has already reached the required state, resolves immediately.

```python sync title=example_fe41b79b58d046cda4673ededd4d216cb97a63204fcba69375ce8a84ea3f6894.py
frame.click("button") # click triggers navigation.
frame.wait_for_load_state() # the promise resolves after "load" event.

```



## expect_navigation

```
def expect_navigation(timeout: nil, url: nil, waitUntil: nil, &block)
```

Waits for the frame navigation and returns the main resource response. In case of multiple redirects, the navigation
will resolve with the response of the last redirect. In case of navigation to a different anchor or navigation due to
History API usage, the navigation will resolve with `null`.

This method waits for the frame to navigate to a new URL. It is useful for when you run code which will indirectly cause
the frame to navigate. Consider this example:

```python sync title=example_03f0ac17eb6c1ce8780cfa83c4ae15a9ddbfde3f96c96f36fdf3fbf9aac721f7.py
with frame.expect_navigation():
    frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
# Resolves after navigation has finished

```

> NOTE: Usage of the [History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API) to change the URL is
considered a navigation.

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

```python sync title=example_a5b9dd4745d45ac630e5953be1c1815ae8e8ab03399fb35f45ea77c434f17eea.py
from playwright.sync_api import sync_playwright

def run(playwright):
    chromium = playwright.chromium
    browser = chromium.launch()
    page = browser.new_page()
    for current_url in ["https://google.com", "https://bbc.com"]:
        page.goto(current_url, wait_until="domcontentloaded")
        element = page.main_frame.wait_for_selector("img")
        print("Loaded image: " + str(element.get_attribute("src")))
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```



## wait_for_url

```
def wait_for_url(url, timeout: nil, waitUntil: nil)
```

Waits for the frame to navigate to the given URL.

```python sync title=example_86a9a19ec4c41e1a5ac302fbca9a3d3d6dca3fe3314e065b8062ddf5f75abfbd.py
frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
frame.wait_for_url("**/target.html")

```


