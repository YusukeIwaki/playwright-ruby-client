---
sidebar_position: 10
---

# Locator

Locators are the central piece of Playwright's auto-waiting and retry-ability. In a nutshell, locators represent a way
to find element(s) on the page at any moment. Locator can be created with the [Page#locator](./page#locator) method.

[Learn more about locators](https://playwright.dev/python/docs/locators).

## all_inner_texts

```
def all_inner_texts
```

Returns an array of `node.innerText` values for all matching nodes.

## all_text_contents

```
def all_text_contents
```

Returns an array of `node.textContent` values for all matching nodes.

## bounding_box

```
def bounding_box(timeout: nil)
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

```ruby
box = element.bounding_box
page.mouse.click(
  box["x"] + box["width"] / 2,
  box["y"] + box["height"] / 2,
)
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

## count

```
def count
```

Returns the number of elements matching given selector.

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

> NOTE: `element.dblclick()` dispatches two `click` events and a single `dblclick` event.

## dispatch_event

```
def dispatch_event(type, eventInit: nil, timeout: nil)
```

The snippet below dispatches the `click` event on the element. Regardless of the visibility state of the element,
`click` is dispatched. This is equivalent to calling
[element.click()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/click).

```ruby
element.dispatch_event("click")
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

```ruby
# note you can only create data_transfer in chromium and firefox
data_transfer = page.evaluate_handle("new DataTransfer()")
element.dispatch_event("dragstart", eventInit: { dataTransfer: data_transfer })
```



## drag_to

```
def drag_to(
      target,
      force: nil,
      noWaitAfter: nil,
      sourcePosition: nil,
      targetPosition: nil,
      timeout: nil,
      trial: nil)
```



## element_handle

```
def element_handle(timeout: nil)
```

Resolves given locator to the first matching DOM element. If no elements matching the query are visible, waits for them
up to a given timeout. If multiple elements match the selector, throws.

## element_handles

```
def element_handles
```

Resolves given locator to all matching DOM elements.

## evaluate

```
def evaluate(expression, arg: nil, timeout: nil)
```

Returns the return value of `expression`.

This method passes this handle as the first argument to `expression`.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then `handle.evaluate` would wait for the promise to resolve and return its value.

Examples:

```ruby
tweet = page.query_selector(".tweet .retweets")
tweet.evaluate("node => node.innerText") # => "10 retweets"
```



## evaluate_all

```
def evaluate_all(expression, arg: nil)
```

The method finds all elements matching the specified locator and passes an array of matched elements as a first argument
to `expression`. Returns the result of `expression` invocation.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Locator#evaluate_all](./locator#evaluate_all) would wait for the promise to resolve and
return its value.

Examples:

```ruby
elements = page.locator("div")
elements.evaluate_all("(divs, min) => divs.length >= min", arg: 10)
```



## evaluate_handle

```
def evaluate_handle(expression, arg: nil, timeout: nil)
```

Returns the return value of `expression` as a [JSHandle](./js_handle).

This method passes this handle as the first argument to `expression`.

The only difference between [Locator#evaluate](./locator#evaluate) and [Locator#evaluate_handle](./locator#evaluate_handle) is that
[Locator#evaluate_handle](./locator#evaluate_handle) returns [JSHandle](./js_handle).

If the function passed to the [Locator#evaluate_handle](./locator#evaluate_handle) returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then
[Locator#evaluate_handle](./locator#evaluate_handle) would wait for the promise to resolve and return its value.

See [Page#evaluate_handle](./page#evaluate_handle) for more details.

## fill

```
def fill(value, force: nil, noWaitAfter: nil, timeout: nil)
```

This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, focuses the element, fills it and triggers an `input`
event after filling. Note that you can pass an empty string to clear the input field.

If the target element is not an `<input>`, `<textarea>` or `[contenteditable]` element, this method throws an error.
However, if the element is inside the `<label>` element that has an associated
[control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be filled
instead.

To send fine-grained keyboard events, use [Locator#type](./locator#type).

## first

```
def first
```

Returns locator to the first matching element.

## focus

```
def focus(timeout: nil)
```

Calls [focus](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/focus) on the element.

## frame_locator

```
def frame_locator(selector)
```

When working with iframes, you can create a frame locator that will enter the iframe and allow selecting elements in
that iframe:

```ruby
locator = page.frame_locator("iframe").locator("text=Submit")
locator.click
```



## get_attribute

```
def get_attribute(name, timeout: nil)
```

Returns element attribute value.

## highlight

```
def highlight
```

Highlight the corresponding element(s) on the screen. Useful for debugging, don't commit the code that uses
[Locator#highlight](./locator#highlight).

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
def inner_html(timeout: nil)
```

Returns the `element.innerHTML`.

## inner_text

```
def inner_text(timeout: nil)
```

Returns the `element.innerText`.

## input_value

```
def input_value(timeout: nil)
```

Returns `input.value` for the selected `<input>` or `<textarea>` or `<select>` element.

Throws for non-input elements. However, if the element is inside the `<label>` element that has an associated
[control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), returns the value of the control.

## checked?

```
def checked?(timeout: nil)
```

Returns whether the element is checked. Throws if the element is not a checkbox or radio input.

## disabled?

```
def disabled?(timeout: nil)
```

Returns whether the element is disabled, the opposite of [enabled](https://playwright.dev/python/docs/actionability).

## editable?

```
def editable?(timeout: nil)
```

Returns whether the element is [editable](https://playwright.dev/python/docs/actionability).

## enabled?

```
def enabled?(timeout: nil)
```

Returns whether the element is [enabled](https://playwright.dev/python/docs/actionability).

## hidden?

```
def hidden?(timeout: nil)
```

Returns whether the element is hidden, the opposite of [visible](https://playwright.dev/python/docs/actionability).

## visible?

```
def visible?(timeout: nil)
```

Returns whether the element is [visible](https://playwright.dev/python/docs/actionability).

## last

```
def last
```

Returns locator to the last matching element.

## locator

```
def locator(selector, has: nil, hasText: nil)
```

The method finds an element matching the specified selector in the [Locator](./locator)'s subtree. It also accepts filter options,
similar to [Locator#filter](./locator#filter) method.

## nth

```
def nth(index)
```

Returns locator to the n-th matching element. It's zero based, `nth(0)` selects the first element.

## page

```
def page
```

A page this locator belongs to.

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

## screenshot

```
def screenshot(
      animations: nil,
      caret: nil,
      mask: nil,
      omitBackground: nil,
      path: nil,
      quality: nil,
      scale: nil,
      timeout: nil,
      type: nil)
```

This method captures a screenshot of the page, clipped to the size and position of a particular element matching the
locator. If the element is covered by other elements, it will not be actually visible on the screenshot. If the element
is a scrollable container, only the currently scrolled content will be visible on the screenshot.

This method waits for the [actionability](https://playwright.dev/python/docs/actionability) checks, then scrolls element into view before taking a
screenshot. If the element is detached from DOM, the method throws an error.

Returns the buffer with the captured screenshot.

## scroll_into_view_if_needed

```
def scroll_into_view_if_needed(timeout: nil)
```

This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, then tries to scroll element into view, unless it is
completely visible as defined by
[IntersectionObserver](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API)'s `ratio`.

## select_option

```
def select_option(
      element: nil,
      index: nil,
      value: nil,
      label: nil,
      force: nil,
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

```ruby
# single selection matching the value
element.select_option(value: "blue")
# single selection matching both the label
element.select_option(label: "blue")
# multiple selection
element.select_option(value: ["red", "green", "blue"])
```

```ruby
# multiple selection for blue, red and second option
element.select_option(value: "blue", index: 2, label: "red")
```



## select_text

```
def select_text(force: nil, timeout: nil)
```

This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, then focuses the element and selects all its text
content.

If the element is inside the `<label>` element that has an associated
[control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), focuses and selects text in the
control instead.

## set_checked

```
def set_checked(
      checked,
      force: nil,
      noWaitAfter: nil,
      position: nil,
      timeout: nil,
      trial: nil)
```
alias: `checked=`

This method checks or unchecks an element by performing the following steps:
1. Ensure that matched element is a checkbox or a radio input. If not, this method throws.
1. If the element already has the right checked state, this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If the
   element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.
1. Ensure that the element is now checked or unchecked. If not, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`. Passing
zero timeout disables this.

## set_input_files

```
def set_input_files(files, noWaitAfter: nil, timeout: nil)
```
alias: `input_files=`

Sets the value of the file input to these file paths or files. If some of the `filePaths` are relative paths, then they
are resolved relative to the current working directory. For empty array, clears the selected files.

This method expects [Locator](./locator) to point to an
[input element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input). However, if the element is inside the
`<label>` element that has an associated
[control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), targets the control instead.

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

> NOTE: `element.tap()` requires that the `hasTouch` option of the browser context be set to true.

## text_content

```
def text_content(timeout: nil)
```

Returns the `node.textContent`.

## type

```
def type(text, delay: nil, noWaitAfter: nil, timeout: nil)
```

Focuses the element, and then sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text.

To press a special key, like `Control` or `ArrowDown`, use [Locator#press](./locator#press).

```ruby
element.type("hello") # types instantly
element.type("world", delay: 100) # types slower, like a user
```

An example of typing into a text field and then submitting the form:

```ruby
element = page.locator("input")
element.type("some text")
element.press("Enter")
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

## wait_for

```
def wait_for(state: nil, timeout: nil)
```

Returns when element specified by locator satisfies the `state` option.

If target element already satisfies the condition, the method returns immediately. Otherwise, waits for up to `timeout`
milliseconds until the condition is met.

```ruby
order_sent = page.locator("#order-sent")
order_sent.wait_for
```


