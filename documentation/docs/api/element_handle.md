---
sidebar_position: 10
---

# ElementHandle

- extends: [JSHandle](./js_handle)

ElementHandle represents an in-page DOM element. ElementHandles can be created with the [Page#query_selector](./page#query_selector)
method.

```python sync title=example_5ba38bdc5d9e5ce7cfc9c8841eb0176efbb4690d18962066f9ee67f1e8b7b050.py
from playwright.sync_api import sync_playwright

def run(playwright):
    chromium = playwright.chromium
    browser = chromium.launch()
    page = browser.new_page()
    page.goto("https://example.com")
    href_element = page.query_selector("a")
    href_element.click()
    # ...

with sync_playwright() as playwright:
    run(playwright)

```

ElementHandle prevents DOM element from garbage collection unless the handle is disposed with
[JSHandle#dispose](./js_handle#dispose). ElementHandles are auto-disposed when their origin frame gets navigated.

ElementHandle instances can be used as an argument in [Page#eval_on_selector](./page#eval_on_selector) and [Page#evaluate](./page#evaluate)
methods.

## bounding_box

```
def bounding_box
```

This method returns the bounding box of the element, or `null` if the element is not visible. The bounding box is
calculated relative to the main frame viewport - which is usually the same as the browser window.

Scrolling affects the returned bonding box, similarly to
[Element.getBoundingClientRect](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect). That
means `x` and/or `y` may be negative.

Elements from child frames return the bounding box relative to the main frame, unlike the
[Element.getBoundingClientRect](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect).

Assuming the page is static, it is safe to use bounding box coordinates to perform input. For example, the following
snippet should click the center of the element.

```python sync title=example_8382aa7cfb42a9a17e348e2f738279f1bd9a038f1ea35cc3cb244cc64d768f93.py
box = element_handle.bounding_box()
page.mouse.click(box["x"] + box["width"] / 2, box["y"] + box["height"] / 2)

```



## check

```
def check(
      force: nil,
      noWaitAfter: nil,
      position: nil,
      timeout: nil,
      trial: nil)
```

This method checks the element by performing the following steps:
1. Ensure that element is a checkbox or a radio input. If not, this method throws. If the element is already checked,
   this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.
1. Ensure that the element is now checked. If not, this method throws.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`. Passing
zero timeout disables this.

## click

```
def click(
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

This method clicks the element by performing the following steps:
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element, or the specified `position`.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`. Passing
zero timeout disables this.

## content_frame

```
def content_frame
```

Returns the content frame for element handles referencing iframe nodes, or `null` otherwise

## dblclick

```
def dblclick(
      button: nil,
      delay: nil,
      force: nil,
      modifiers: nil,
      noWaitAfter: nil,
      position: nil,
      timeout: nil,
      trial: nil)
```

This method double clicks the element by performing the following steps:
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to double click in the center of the element, or the specified `position`.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set. Note that if the
   first click of the `dblclick()` triggers a navigation event, this method will throw.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`. Passing
zero timeout disables this.

> NOTE: `elementHandle.dblclick()` dispatches two `click` events and a single `dblclick` event.

## dispatch_event

```
def dispatch_event(type, eventInit: nil)
```

The snippet below dispatches the `click` event on the element. Regardless of the visibility state of the element,
`click` is dispatched. This is equivalent to calling
[element.click()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/click).

```python sync title=example_3b86add6ce355082cd43f4ac0ba9e69c15960bbd7ca601d0618355fe53aa8902.py
element_handle.dispatch_event("click")

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

```python sync title=example_6b70ea4cf0c7ae9c82cf0ed22ab0dbbb563e2d1419b35d04aa513cf91f0856f9.py
# note you can only create data_transfer in chromium and firefox
data_transfer = page.evaluate_handle("new DataTransfer()")
element_handle.dispatch_event("#source", "dragstart", {"dataTransfer": data_transfer})

```



## eval_on_selector

```
def eval_on_selector(selector, expression, arg: nil)
```

Returns the return value of `expression`.

The method finds an element matching the specified selector in the [ElementHandle](./element_handle)s subtree and passes it as a first
argument to `expression`. See [Working with selectors](https://playwright.dev/python/docs/selectors) for more details. If no elements match the
selector, the method throws an error.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [ElementHandle#eval_on_selector](./element_handle#eval_on_selector) would wait for the promise to resolve
and return its value.

Examples:

```python sync title=example_f6a83ec555fcf23877c11cf55f02a8c89a7fc11d3324859feda42e592e129f4f.py
tweet_handle = page.query_selector(".tweet")
assert tweet_handle.eval_on_selector(".like", "node => node.innerText") == "100"
assert tweet_handle.eval_on_selector(".retweets", "node => node.innerText") = "10"

```



## eval_on_selector_all

```
def eval_on_selector_all(selector, expression, arg: nil)
```

Returns the return value of `expression`.

The method finds all elements matching the specified selector in the [ElementHandle](./element_handle)'s subtree and passes an array of
matched elements as a first argument to `expression`. See [Working with selectors](https://playwright.dev/python/docs/selectors) for more details.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [ElementHandle#eval_on_selector_all](./element_handle#eval_on_selector_all) would wait for the promise to
resolve and return its value.

Examples:

```html
<div class="feed">
  <div class="tweet">Hello!</div>
  <div class="tweet">Hi!</div>
</div>
```

```python sync title=example_11b54bf5ec18a0d0ceee0868651bb41ab5cd3afcc6b20d5c44f90d835c8d6f81.py
feed_handle = page.query_selector(".feed")
assert feed_handle.eval_on_selector_all(".tweet", "nodes => nodes.map(n => n.innerText)") == ["hello!", "hi!"]

```



## fill

```
def fill(value, noWaitAfter: nil, timeout: nil)
```

This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, focuses the element, fills it and triggers an `input`
event after filling. Note that you can pass an empty string to clear the input field.

If the target element is not an `<input>`, `<textarea>` or `[contenteditable]` element, this method throws an error.
However, if the element is inside the `<label>` element that has an associated
[control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be filled
instead.

To send fine-grained keyboard events, use [ElementHandle#type](./element_handle#type).

## focus

```
def focus
```

Calls [focus](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/focus) on the element.

## get_attribute

```
def get_attribute(name)
```

Returns element attribute value.

## hover

```
def hover(
      force: nil,
      modifiers: nil,
      position: nil,
      timeout: nil,
      trial: nil)
```

This method hovers over the element by performing the following steps:
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to hover over the center of the element, or the specified `position`.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`. Passing
zero timeout disables this.

## inner_html

```
def inner_html
```

Returns the `element.innerHTML`.

## inner_text

```
def inner_text
```

Returns the `element.innerText`.

## checked?

```
def checked?
```

Returns whether the element is checked. Throws if the element is not a checkbox or radio input.

## disabled?

```
def disabled?
```

Returns whether the element is disabled, the opposite of [enabled](https://playwright.dev/python/docs/actionability).

## editable?

```
def editable?
```

Returns whether the element is [editable](https://playwright.dev/python/docs/actionability).

## enabled?

```
def enabled?
```

Returns whether the element is [enabled](https://playwright.dev/python/docs/actionability).

## hidden?

```
def hidden?
```

Returns whether the element is hidden, the opposite of [visible](https://playwright.dev/python/docs/actionability).

## visible?

```
def visible?
```

Returns whether the element is [visible](https://playwright.dev/python/docs/actionability).

## owner_frame

```
def owner_frame
```

Returns the frame containing the given element.

## press

```
def press(key, delay: nil, noWaitAfter: nil, timeout: nil)
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

## query_selector

```
def query_selector(selector)
```

The method finds an element matching the specified selector in the [ElementHandle](./element_handle)'s subtree. See
[Working with selectors](https://playwright.dev/python/docs/selectors) for more details. If no elements match the selector, returns `null`.

## query_selector_all

```
def query_selector_all(selector)
```

The method finds all elements matching the specified selector in the [ElementHandle](./element_handle)s subtree. See
[Working with selectors](https://playwright.dev/python/docs/selectors) for more details. If no elements match the selector, returns empty array.

## screenshot

```
def screenshot(
      omitBackground: nil,
      path: nil,
      quality: nil,
      timeout: nil,
      type: nil)
```

Returns the buffer with the captured screenshot.

This method waits for the [actionability](https://playwright.dev/python/docs/actionability) checks, then scrolls element into view before taking a
screenshot. If the element is detached from DOM, the method throws an error.

## scroll_into_view_if_needed

```
def scroll_into_view_if_needed(timeout: nil)
```

This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, then tries to scroll element into view, unless it is
completely visible as defined by
[IntersectionObserver](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API)'s `ratio`.

Throws when `elementHandle` does not point to an element
[connected](https://developer.mozilla.org/en-US/docs/Web/API/Node/isConnected) to a Document or a ShadowRoot.

## select_option

```
def select_option(
      element: nil,
      index: nil,
      value: nil,
      label: nil,
      noWaitAfter: nil,
      timeout: nil)
```

This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, waits until all specified options are present in the
`<select>` element and selects these options.

If the target element is not a `<select>` element, this method throws an error. However, if the element is inside the
`<label>` element that has an associated
[control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be used instead.

Returns the array of option values that have been successfully selected.

Triggers a `change` and `input` event once all the provided options have been selected.

```python sync title=example_dc2ce38846b91d234483ed8b915b785ffbd9403213279465acd6605f314fe736.py
# single selection matching the value
handle.select_option("blue")
# single selection matching both the label
handle.select_option(label="blue")
# multiple selection
handle.select_option(value=["red", "green", "blue"])

```

```python sync title=example_b4cdd4a1a4d0392c2d430e0fb5fc670df2d728b6907553650690a2d0377662e4.py
# single selection matching the value
handle.select_option("blue")
# single selection matching both the value and the label
handle.select_option(label="blue")
# multiple selection
handle.select_option("red", "green", "blue")
# multiple selection for blue, red and second option
handle.select_option(value="blue", { index: 2 }, "red")

```



## select_text

```
def select_text(timeout: nil)
```

This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, then focuses the element and selects all its text
content.

## set_input_files

```
def set_input_files(files, noWaitAfter: nil, timeout: nil)
```

This method expects `elementHandle` to point to an
[input element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input).

Sets the value of the file input to these file paths or files. If some of the `filePaths` are relative paths, then they
are resolved relative to the the current working directory. For empty array, clears the selected files.

## tap_point

```
def tap_point(
      force: nil,
      modifiers: nil,
      noWaitAfter: nil,
      position: nil,
      timeout: nil,
      trial: nil)
```

This method taps the element by performing the following steps:
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#touchscreen](./page#touchscreen) to tap the center of the element, or the specified `position`.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`. Passing
zero timeout disables this.

> NOTE: `elementHandle.tap()` requires that the `hasTouch` option of the browser context be set to true.

## text_content

```
def text_content
```

Returns the `node.textContent`.

## type

```
def type(text, delay: nil, noWaitAfter: nil, timeout: nil)
```

Focuses the element, and then sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text.

To press a special key, like `Control` or `ArrowDown`, use [ElementHandle#press](./element_handle#press).

```python sync title=example_2dc9720467640fd8bc581ed65159742e51ff91b209cb176fef8b95f14eaad54e.py
element_handle.type("hello") # types instantly
element_handle.type("world", delay=100) # types slower, like a user

```

An example of typing into a text field and then submitting the form:

```python sync title=example_d13faaf53454653ce45371b5cf337082a82bf7bbb0aada7e97f47d14963bd6b0.py
element_handle = page.query_selector("input")
element_handle.type("some text")
element_handle.press("Enter")

```



## uncheck

```
def uncheck(
      force: nil,
      noWaitAfter: nil,
      position: nil,
      timeout: nil,
      trial: nil)
```

This method checks the element by performing the following steps:
1. Ensure that element is a checkbox or a radio input. If not, this method throws. If the element is already
   unchecked, this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.
1. Ensure that the element is now unchecked. If not, this method throws.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`. Passing
zero timeout disables this.

## wait_for_element_state

```
def wait_for_element_state(state, timeout: nil)
```

Returns when the element satisfies the `state`.

Depending on the `state` parameter, this method waits for one of the [actionability](https://playwright.dev/python/docs/actionability) checks to pass.
This method throws when the element is detached while waiting, unless waiting for the `"hidden"` state.
- `"visible"` Wait until the element is [visible](https://playwright.dev/python/docs/actionability).
- `"hidden"` Wait until the element is [not visible](https://playwright.dev/python/docs/actionability) or
  [not attached](https://playwright.dev/python/docs/actionability). Note that waiting for hidden does not throw when the element detaches.
- `"stable"` Wait until the element is both [visible](https://playwright.dev/python/docs/actionability) and
  [stable](https://playwright.dev/python/docs/actionability).
- `"enabled"` Wait until the element is [enabled](https://playwright.dev/python/docs/actionability).
- `"disabled"` Wait until the element is [not enabled](https://playwright.dev/python/docs/actionability).
- `"editable"` Wait until the element is [editable](https://playwright.dev/python/docs/actionability).

If the element does not satisfy the condition for the `timeout` milliseconds, this method will throw.

## wait_for_selector

```
def wait_for_selector(selector, state: nil, timeout: nil)
```

Returns element specified by selector when it satisfies `state` option. Returns `null` if waiting for `hidden` or
`detached`.

Wait for the `selector` relative to the element handle to satisfy `state` option (either appear/disappear from dom, or
become visible/hidden). If at the moment of calling the method `selector` already satisfies the condition, the method
will return immediately. If the selector doesn't satisfy the condition for the `timeout` milliseconds, the function will
throw.

```python sync title=example_3b0f6c6573db513b7b707a39d6c5bbf5ce5896b4785466d80f525968cfbd0be7.py
page.set_content("<div><span></span></div>")
div = page.query_selector("div")
# waiting for the "span" selector relative to the div.
span = div.wait_for_selector("span", state="attached")

```

> NOTE: This method does not work across navigations, use [Page#wait_for_selector](./page#wait_for_selector) instead.
