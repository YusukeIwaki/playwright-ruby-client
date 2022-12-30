---
sidebar_position: 10
---

# Frame

At every point of time, page exposes its current frame tree via the [Page#main_frame](./page#main_frame) and
[Frame#child_frames](./frame#child_frames) methods.

[Frame](./frame) object's lifecycle is controlled by three events, dispatched on the page object:
- [`event: Page.frameAttached`] - fired when the frame gets attached to the page. A Frame can be attached to the
  page only once.
- [`event: Page.frameNavigated`] - fired when the frame commits navigation to a different URL.
- [`event: Page.frameDetached`] - fired when the frame gets detached from the page.  A Frame can be detached from
  the page only once.

An example of dumping frame tree:

```py title=example_175fd16e6b0841edb87c9aee59a0b516c765c7306ca63ce0157360dbf853f881.py
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    firefox = playwright.firefox
    browser = await firefox.launch()
    page = await browser.new_page()
    await page.goto("https://www.theverge.com")
    dump_frame_tree(page.main_frame, "")
    await browser.close()

def dump_frame_tree(frame, indent):
    print(indent + frame.name + '@' + frame.url)
    for child in frame.child_frames:
        dump_frame_tree(child, indent + "    ")

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

```py title=example_eba0a73d122f4092a4a4d63dd7b1c6c5f42bffaaa995bfe8b5ebd710f57537a4.py
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

**NOTE** `frame.dblclick()` dispatches two `click` events and a single `dblclick` event.

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

```py title=example_c62b55d6fab824aee86cb8a7e59a61e5046977ad9cded5ca191797783113a116.py
await frame.dispatch_event("button#submit", "click")

```

```py title=example_8563baa1d3c1890559d7c4f7108ce9a70722d9f7ff41e6a4a6ca11c3bac79601.py
frame.dispatch_event("button#submit", "click")

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

```py title=example_9e3753444751db32be227c85448a0a4bb9368d7588ea0261bf5d019ca75330a3.py
# note you can only create data_transfer in chromium and firefox
data_transfer = await frame.evaluate_handle("new DataTransfer()")
await frame.dispatch_event("#source", "dragstart", { "dataTransfer": data_transfer })

```

```py title=example_b3223f34267568b0a81da5b2ca3b75dfc3c7996a9a2d588ef5da310e897d8a3c.py
# note you can only create data_transfer in chromium and firefox
data_transfer = frame.evaluate_handle("new DataTransfer()")
frame.dispatch_event("#source", "dragstart", { "dataTransfer": data_transfer })

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



## eval_on_selector

```
def eval_on_selector(selector, expression, arg: nil, strict: nil)
```

Returns the return value of `expression`.

The method finds an element matching the specified selector within the frame and passes it as a first argument to
`expression`. If no elements match the selector, the method throws an error.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Frame#eval_on_selector](./frame#eval_on_selector) would wait for the promise to resolve
and return its value.

**Usage**

```py title=example_e31ee0acc0eddc6723acf0bed10173080440eaed71813ec4a490803646e7b346.py
search_value = await frame.eval_on_selector("#search", "el => el.value")
preload_href = await frame.eval_on_selector("link[rel=preload]", "el => el.href")
html = await frame.eval_on_selector(".main-container", "(e, suffix) => e.outerHTML + suffix", "hello")

```

```py title=example_dee76da85498e028e59ce16468316429c6e604abed984f213ab3342125bbe83e.py
search_value = frame.eval_on_selector("#search", "el => el.value")
preload_href = frame.eval_on_selector("link[rel=preload]", "el => el.href")
html = frame.eval_on_selector(".main-container", "(e, suffix) => e.outerHTML + suffix", "hello")

```



## eval_on_selector_all

```
def eval_on_selector_all(selector, expression, arg: nil)
```

Returns the return value of `expression`.

The method finds all elements matching the specified selector within the frame and passes an array of matched
elements as a first argument to `expression`.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Frame#eval_on_selector_all](./frame#eval_on_selector_all) would wait for the promise to resolve
and return its value.

**Usage**

```py title=example_9926f4d8ce7d10cf6769357f6307501e1a934bb9f5c4ee027f34735568e278ed.py
divs_counts = await frame.eval_on_selector_all("div", "(divs, min) => divs.length >= min", 10)

```

```py title=example_95cf43dae25f1a42399dadafdb382b2e6039f679b22480028306b9d0c9ac6644.py
divs_counts = frame.eval_on_selector_all("div", "(divs, min) => divs.length >= min", 10)

```



## evaluate

```
def evaluate(expression, arg: nil)
```

Returns the return value of `expression`.

If the function passed to the [Frame#evaluate](./frame#evaluate) returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Frame#evaluate](./frame#evaluate) would
wait for the promise to resolve and return its value.

If the function passed to the [Frame#evaluate](./frame#evaluate) returns a non-[Serializable](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify#description) value, then
[Frame#evaluate](./frame#evaluate) returns `undefined`. Playwright also supports transferring some additional values that
are not serializable by `JSON`: `-0`, `NaN`, `Infinity`, `-Infinity`.

**Usage**

```py title=example_731b92cfb2a6e7b10c9e431f61eade78981095370b537b5ddafc08e3c265feaf.py
result = await frame.evaluate("([x, y]) => Promise.resolve(x * y)", [7, 8])
print(result) # prints "56"

```

```py title=example_2ceb005a189affdaae9fdefa7b8b6a8177e6ce393c691e96371e761893e97e18.py
result = frame.evaluate("([x, y]) => Promise.resolve(x * y)", [7, 8])
print(result) # prints "56"

```

A string can also be passed in instead of a function.

```py title=example_72471bba25eb55af92715405b999fab369561bb31e0c6d05d9ea253a5a9d1eac.py
print(await frame.evaluate("1 + 2")) # prints "3"
x = 10
print(await frame.evaluate(f"1 + {x}")) # prints "11"

```

```py title=example_d93dd3af855b542980415a68ed9fe272670097f783558d4b155a9b2edd8e21e2.py
print(frame.evaluate("1 + 2")) # prints "3"
x = 10
print(frame.evaluate(f"1 + {x}")) # prints "11"

```

[ElementHandle](./element_handle) instances can be passed as an argument to the [Frame#evaluate](./frame#evaluate):

```py title=example_7801394beb3a8d89e170432d8f5a4984941b7bac238b4b3b1e1bfa51ab2cc643.py
body_handle = await frame.evaluate("document.body")
html = await frame.evaluate("([body, suffix]) => body.innerHTML + suffix", [body_handle, "hello"])
await body_handle.dispose()

```

```py title=example_91e777aa2bcf88bd0a1deaea03e28b99a6cc3a69703ea8f92f69207f0b4f44d8.py
body_handle = frame.evaluate("document.body")
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

**Usage**

```py title=example_52f6c5c8f26a8e7c53153b939d9f254e4e31408422ccdcbc197cbc331949f35a.py
a_window_handle = await frame.evaluate_handle("Promise.resolve(window)")
a_window_handle # handle for the window object.

```

```py title=example_4dc6725db9c6f5bc2a4114ad85bdbe92be629d471536442a8345c64f07a986c8.py
a_window_handle = frame.evaluate_handle("Promise.resolve(window)")
a_window_handle # handle for the window object.

```

A string can also be passed in instead of a function.

```py title=example_0d1e28bbd652512a14515e3b7379654bd71222d90d9c1c575814dfb169329380.py
a_handle = await page.evaluate_handle("document") # handle for the "document"

```

```py title=example_c681f8996c058c7f3f0720775a87f75611457b7e8b94b9d645b2f44ca0ffbd39.py
a_handle = page.evaluate_handle("document") # handle for the "document"

```

[JSHandle](./js_handle) instances can be passed as an argument to the [Frame#evaluate_handle](./frame#evaluate_handle):

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

To send fine-grained keyboard events, use [Frame#type](./frame#type).

## focus

```
def focus(selector, strict: nil, timeout: nil)
```

This method fetches an element with `selector` and focuses it. If there's no element matching `selector`, the
method waits until a matching element appears in the DOM.

## frame_element

```
def frame_element
```

Returns the `frame` or `iframe` element handle which corresponds to this frame.

This is an inverse of [ElementHandle#content_frame](./element_handle#content_frame). Note that returned handle actually belongs to the
parent frame.

This method throws an error if the frame has been detached before `frameElement()` returns.

**Usage**

```py title=example_56af94a7bf4e38d915ba3b38914ea4bb72f5403f52a3213999b7c7288c65352b.py
frame_element = await frame.frame_element()
content_frame = await frame_element.content_frame()
assert frame == content_frame

```

```py title=example_fbce8bbd14c4b4000e080c9e3d6bcdaa849c31aef0ed2375b481c5d5d3e396a2.py
frame_element = frame.frame_element()
content_frame = frame_element.content_frame()
assert frame == content_frame

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

```py title=example_f269b53c1792c35e0176da6eabdec5e71e9afe9a87d80b52f8f8a8f9a78c1960.py
locator = frame.frame_locator("#my-iframe").get_by_text("Submit")
await locator.click()

```

```py title=example_56f3867098abaeccf774057a244744131b192e9700e88a3a1e6da916d452c486.py
locator = frame.frame_locator("#my-iframe").get_by_text("Submit")
locator.click()

```



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


## goto

```
def goto(url, referer: nil, timeout: nil, waitUntil: nil)
```

Returns the main resource response. In case of multiple redirects, the navigation will resolve with the response of
the last redirect.

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

## detached?

```
def detached?
```

Returns `true` if the frame has been detached, or `false` otherwise.

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

[Learn more about locators](https://playwright.dev/python/docs/locators).

## name

```
def name
```

Returns frame's name attribute as specified in the tag.

If the name is empty, returns the id attribute instead.

**NOTE** This value is calculated once when the frame is created, and will not update if the attribute is changed
later.

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
      strict: nil,
      timeout: nil)
```

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

## query_selector

```
def query_selector(selector, strict: nil)
```

Returns the ElementHandle pointing to the frame element.

**NOTE** The use of [ElementHandle](./element_handle) is discouraged, use [Locator](./locator) objects and web-first assertions instead.

The method finds an element matching the specified selector within the frame. If no elements match the selector,
returns `null`.

## query_selector_all

```
def query_selector_all(selector)
```

Returns the ElementHandles pointing to the frame elements.

**NOTE** The use of [ElementHandle](./element_handle) is discouraged, use [Locator](./locator) objects instead.

The method finds all elements matching the specified selector within the frame. If no elements match the selector,
returns empty array.

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

```py title=example_7c29a4e7e49b7b7a13107624cc32d4c3a9aaca7a5d9a3aa0e9618d876557cd7d.py
# single selection matching the value
await frame.select_option("select#colors", "blue")
# single selection matching the label
await frame.select_option("select#colors", label="blue")
# multiple selection
await frame.select_option("select#colors", value=["red", "green", "blue"])

```

```py title=example_19e36d77b4eb60448e1d0ee4b7e702b5d75078eba306401a2c4ac26d41245c32.py
# single selection matching the value
frame.select_option("select#colors", "blue")
# single selection matching both the label
frame.select_option("select#colors", label="blue")
# multiple selection
frame.select_option("select#colors", value=["red", "green", "blue"])

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

**NOTE** `frame.tap()` requires that the `hasTouch` option of the browser context be set to true.

## text_content

```
def text_content(selector, strict: nil, timeout: nil)
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
      strict: nil,
      timeout: nil)
```

Sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text. `frame.type` can be used
to send fine-grained keyboard events. To fill values in form fields, use [Frame#fill](./frame#fill).

To press a special key, like `Control` or `ArrowDown`, use [Keyboard#press](./keyboard#press).

**Usage**

```py title=example_03b9b247956ab0b0bf574e387a4549ed2343a91f28338df4af3a95d54d408150.py
await frame.type("#mytextarea", "hello") # types instantly
await frame.type("#mytextarea", "world", delay=100) # types slower, like a user

```

```py title=example_8f3e0d9b4038d73208e0c365595fc09ebf99de6eefda9f8010f357450e0c6695.py
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
      strict: nil,
      timeout: nil,
      trial: nil)
```

This method checks an element matching `selector` by performing the following steps:
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

**Usage**

The [Frame#wait_for_function](./frame#wait_for_function) can be used to observe viewport size change:

```py title=example_ab1be034c9d5b5ffc8c8520417c934d61e5c86f9814343313917a890f96b2c9e.py
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    webkit = playwright.webkit
    browser = await webkit.launch()
    page = await browser.new_page()
    await page.evaluate("window.x = 0; setTimeout(() => { window.x = 100 }, 1000);")
    await page.main_frame.wait_for_function("() => window.x > 0")
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

```py title=example_38741630ac091d734722fec3eed87a1c27894bd5911666c4c8cd526dd63ce359.py
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

```py title=example_8e909d06071e97938c274dd45b053b104b2370990d55efc9a629799c3e4d101b.py
selector = ".foo"
await frame.wait_for_function("selector => !!document.querySelector(selector)", selector)

```

```py title=example_6839e8d54ba0e660815f8175d26e07afa565f9df984d93dbbb8adfa9e080b924.py
selector = ".foo"
frame.wait_for_function("selector => !!document.querySelector(selector)", selector)

```



## wait_for_load_state

```
def wait_for_load_state(state: nil, timeout: nil)
```

Waits for the required load state to be reached.

This returns when the frame reaches a required load state, `load` by default. The navigation must have been
committed when this method is called. If current document has already reached the required state, resolves
immediately.

**Usage**

```py title=example_83e3206eb7570f416e9d72fb3e8412e7f67acd9f27c2bd0bdca4686bb47ca97b.py
await frame.click("button") # click triggers navigation.
await frame.wait_for_load_state() # the promise resolves after "load" event.

```

```py title=example_c128a8d89c6459508f13ba3df9befc21245b106de1402ca25b08d62a689ced63.py
frame.click("button") # click triggers navigation.
frame.wait_for_load_state() # the promise resolves after "load" event.

```



## expect_navigation

```
def expect_navigation(timeout: nil, url: nil, waitUntil: nil, &block)
```

Waits for the frame navigation and returns the main resource response. In case of multiple redirects, the
navigation will resolve with the response of the last redirect. In case of navigation to a different anchor or
navigation due to History API usage, the navigation will resolve with `null`.

**Usage**

This method waits for the frame to navigate to a new URL. It is useful for when you run code which will indirectly
cause the frame to navigate. Consider this example:

```py title=example_0ecaca6f3bb7365bfb9b4de9bfbeb8c66abe5e8215482300d705a8ae4aad6ce9.py
async with frame.expect_navigation():
    await frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
# Resolves after navigation has finished

```

```py title=example_a981f569233adde812187ebb512e515f82cd675f4abfd9616b5feae7119aed65.py
with frame.expect_navigation():
    frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
# Resolves after navigation has finished

```

**NOTE** Usage of the [History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API) to change the URL
is considered a navigation.

## wait_for_selector

```
def wait_for_selector(selector, state: nil, strict: nil, timeout: nil)
```

Returns when element specified by selector satisfies `state` option. Returns `null` if waiting for `hidden` or
`detached`.

**NOTE** Playwright automatically waits for element to be ready before performing an action. Using [Locator](./locator)
objects and web-first assertions make the code wait-for-selector-free.

Wait for the `selector` to satisfy `state` option (either appear/disappear from dom, or become visible/hidden). If
at the moment of calling the method `selector` already satisfies the condition, the method will return immediately.
If the selector doesn't satisfy the condition for the `timeout` milliseconds, the function will throw.

**Usage**

This method works across navigations:

```py title=example_1ade1c9b9b3c2c1cc3883c412da42ce838f1bdcac87653bc067a58f15e64771a.py
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    chromium = playwright.chromium
    browser = await chromium.launch()
    page = await browser.new_page()
    for current_url in ["https://google.com", "https://bbc.com"]:
        await page.goto(current_url, wait_until="domcontentloaded")
        element = await page.main_frame.wait_for_selector("img")
        print("Loaded image: " + str(await element.get_attribute("src")))
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

```py title=example_2d72f1ca5d1595557870054d84b0045c60acde8aa5ab85e96726294cd85082ee.py
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



## wait_for_timeout

```
def wait_for_timeout(timeout)
```

Waits for the given `timeout` in milliseconds.

Note that `frame.waitForTimeout()` should only be used for debugging. Tests using the timer in production are going
to be flaky. Use signals such as network events, selectors becoming visible and others instead.

## wait_for_url

```
def wait_for_url(url, timeout: nil, waitUntil: nil)
```

Waits for the frame to navigate to the given URL.

**Usage**

```py title=example_dcacaec290ce7eb5e165c5d601c52438794ec3c84aa24f8a247ddb569879930e.py
await frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
await frame.wait_for_url("**/target.html")

```

```py title=example_34ddd17f8e72fe0ceaeb14bfe55b1e2ba4b3266ddde301f33700ae0f0ff10c2d.py
frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
frame.wait_for_url("**/target.html")

```


