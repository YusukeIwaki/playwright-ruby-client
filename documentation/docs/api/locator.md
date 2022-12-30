---
sidebar_position: 10
---

# Locator

Locators are the central piece of Playwright's auto-waiting and retry-ability. In a nutshell, locators represent a
way to find element(s) on the page at any moment. Locator can be created with the [Page#locator](./page#locator) method.

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

## blur

```
def blur(timeout: nil)
```

Calls [blur](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/blur) on the element.

## bounding_box

```
def bounding_box(timeout: nil)
```

This method returns the bounding box of the element, or `null` if the element is not visible. The bounding box is
calculated relative to the main frame viewport - which is usually the same as the browser window.

Scrolling affects the returned bounding box, similarly to
[Element.getBoundingClientRect](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect).
That means `x` and/or `y` may be negative.

Elements from child frames return the bounding box relative to the main frame, unlike the
[Element.getBoundingClientRect](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect).

Assuming the page is static, it is safe to use bounding box coordinates to perform input. For example, the
following snippet should click the center of the element.

**Usage**

```py title=example_cfa34b2c623b4a590ee9b26b6165f2b3670ee9cd07f1f8daa93588c526e32451.py
box = await element.bounding_box()
await page.mouse.click(box["x"] + box["width"] / 2, box["y"] + box["height"] / 2)

```

```py title=example_2577a5295157414174128624e2c79ce3742ff5752bed161d11505270ba02610f.py
box = element.bounding_box()
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
1. Ensure that element is a checkbox or a radio input. If not, this method throws. If the element is already
   checked, this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.
1. Ensure that the element is now checked. If not, this method throws.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`.
Passing zero timeout disables this.

## clear

```
def clear(force: nil, noWaitAfter: nil, timeout: nil)
```

This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, focuses the element, clears it and triggers an
`input` event after clearing.

If the target element is not an `<input>`, `<textarea>` or `[contenteditable]` element, this method throws an
error. However, if the element is inside the `<label>` element that has an associated
[control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be cleared
instead.

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

Click an element.

**Details**

This method clicks the element by performing the following steps:
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element, or the specified `position`.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`.
Passing zero timeout disables this.

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
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set. Note that if
   the first click of the `dblclick()` triggers a navigation event, this method will throw.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`.
Passing zero timeout disables this.

**NOTE** `element.dblclick()` dispatches two `click` events and a single `dblclick` event.

## dispatch_event

```
def dispatch_event(type, eventInit: nil, timeout: nil)
```

The snippet below dispatches the `click` event on the element. Regardless of the visibility state of the element,
`click` is dispatched. This is equivalent to calling
[element.click()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/click).

**Usage**

```py title=example_d618dd30ac13828f36d2e0a1dce74c3f5389c9b6b6745d6c119b0a66af150df8.py
await element.dispatch_event("click")

```

```py title=example_efd2bea7fb1affc05245e1f451d40fa6a44063b0a4a180a14be943aa851d9ab0.py
element.dispatch_event("click")

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

```py title=example_98ee89787a8212e3f7ba60f97472514f1924802dd49e17759fb7535e00547259.py
# note you can only create data_transfer in chromium and firefox
data_transfer = await page.evaluate_handle("new DataTransfer()")
await element.dispatch_event("#source", "dragstart", {"dataTransfer": data_transfer})

```

```py title=example_34a5c61a96f8ef906b285eb829620a43735c2f59f14ecc0744f6c25cfb355947.py
# note you can only create data_transfer in chromium and firefox
data_transfer = page.evaluate_handle("new DataTransfer()")
element.dispatch_event("#source", "dragstart", {"dataTransfer": data_transfer})

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

This method drags the locator to another target locator or target position. It will first move to the source
element, perform a `mousedown`, then move to the target element or position and perform a `mouseup`.

**Usage**

```py title=example_ff875cdc9bcaeed7ecccb5c7b55aaa4ce21f95144c204ce8ad45dea51761f556.py
source = page.locator("#source")
target = page.locator("#target")

await source.drag_to(target)
# or specify exact positions relative to the top-left corners of the elements:
await source.drag_to(
  target,
  source_position={"x": 34, "y": 7},
  target_position={"x": 10, "y": 20}
)

```

```py title=example_b10561ae981a153c470e22850cce7617b8ac17e36024d4df42f0289f03de6837.py
source = page.locator("#source")
target = page.locator("#target")

source.drag_to(target)
# or specify exact positions relative to the top-left corners of the elements:
source.drag_to(
  target,
  source_position={"x": 34, "y": 7},
  target_position={"x": 10, "y": 20}
)

```



## element_handle

```
def element_handle(timeout: nil)
```

Resolves given locator to the first matching DOM element. If no elements matching the query are visible, waits for
them up to a given timeout. If multiple elements match the selector, throws.

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

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then `handle.evaluate` would wait for the promise to resolve and return its
value.

**Usage**

```py title=example_3fde7298eff9c0f67528980134ab22504089b4ed40a1bff1fa9548c9eec25011.py
tweets = page.locator(".tweet .retweets")
assert await tweets.evaluate("node => node.innerText") == "10 retweets"

```

```py title=example_895807bd9867986347453eca7220409c312135e4c3facfa2f8d83fe5fe6f3649.py
tweets = page.locator(".tweet .retweets")
assert tweets.evaluate("node => node.innerText") == "10 retweets"

```



## evaluate_all

```
def evaluate_all(expression, arg: nil)
```

The method finds all elements matching the specified locator and passes an array of matched elements as a first
argument to `expression`. Returns the result of `expression` invocation.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Locator#evaluate_all](./locator#evaluate_all) would wait for the promise to resolve and
return its value.

**Usage**

```py title=example_1433660e197c6631f0c5635ff2b18a4ab710834e947a9e9e4b6cf309c98aa7da.py
elements = page.locator("div")
div_counts = await elements.evaluate_all("(divs, min) => divs.length >= min", 10)

```

```py title=example_70418147f96b27cb0fb48d8d3fe1e3af1e59d46029b6139cbe0e6d7e1361ad41.py
elements = page.locator("div")
div_counts = elements.evaluate_all("(divs, min) => divs.length >= min", 10)

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

This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, focuses the element, fills it and triggers an
`input` event after filling. Note that you can pass an empty string to clear the input field.

If the target element is not an `<input>`, `<textarea>` or `[contenteditable]` element, this method throws an
error. However, if the element is inside the `<label>` element that has an associated
[control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be filled
instead.

To send fine-grained keyboard events, use [Locator#type](./locator#type).

## filter

```
def filter(has: nil, hasText: nil)
```

This method narrows existing locator according to the options, for example filters by text. It can be chained to
filter multiple times.

**Usage**

```py title=example_f4d244f05ae747f66f94b5a3161171ee807e917f757d075b0303e6fea51a30f7.py
row_locator = page.locator("tr")
# ...
await row_locator
    .filter(has_text="text in column 1")
    .filter(has=page.get_by_role("button", name="column 2 button"))
    .screenshot()

```

```py title=example_0f12efd79a918f362304f4a5d7e7bb760254cee823919121fe639877f8df94a9.py
row_locator = page.locator("tr")
# ...
row_locator
    .filter(has_text="text in column 1")
    .filter(has=page.get_by_role("button", name="column 2 button"))
    .screenshot()

```



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

**Usage**

When working with iframes, you can create a frame locator that will enter the iframe and allow selecting elements
in that iframe:

```py title=example_a68ee6bb2135004c094807abc47c7355f9661d6cbc3d8bb5eac917756dfd6e6f.py
locator = page.frame_locator("iframe").get_by_text("Submit")
await locator.click()

```

```py title=example_d6dcf2277e215dd96b37a5171313ed8dc7ed66cb0b0a4cdf48b80b51ee9b18f8.py
locator = page.frame_locator("iframe").get_by_text("Submit")
locator.click()

```



## get_attribute

```
def get_attribute(name, timeout: nil)
```
alias: `[]`

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
      noWaitAfter: nil,
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

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`.
Passing zero timeout disables this.

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
[control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), returns the value of the
control.

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

The method finds an element matching the specified selector in the locator's subtree. It also accepts filter
options, similar to [Locator#filter](./locator#filter) method.

[Learn more about locators](https://playwright.dev/python/docs/locators).

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

This method captures a screenshot of the page, clipped to the size and position of a particular element matching
the locator. If the element is covered by other elements, it will not be actually visible on the screenshot. If the
element is a scrollable container, only the currently scrolled content will be visible on the screenshot.

This method waits for the [actionability](https://playwright.dev/python/docs/actionability) checks, then scrolls element into view before taking
a screenshot. If the element is detached from DOM, the method throws an error.

Returns the buffer with the captured screenshot.

## scroll_into_view_if_needed

```
def scroll_into_view_if_needed(timeout: nil)
```

This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, then tries to scroll element into view, unless
it is completely visible as defined by
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

Selects option or options in `<select>`.

**Details**

This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, waits until all specified options are present in
the `<select>` element and selects these options.

If the target element is not a `<select>` element, this method throws an error. However, if the element is inside
the `<label>` element that has an associated
[control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be used
instead.

Returns the array of option values that have been successfully selected.

Triggers a `change` and `input` event once all the provided options have been selected.

**Usage**

```html
<select multiple>
  <option value="red">Red</div>
  <option value="green">Green</div>
  <option value="blue">Blue</div>
</select>
```

```py title=example_fe5ed4db5dd1163c85ca463cad7b9ddbdad92ee18c1e0e2b3f6486a51b908de2.py
# single selection matching the value or label
await element.select_option("blue")
# single selection matching the label
await element.select_option(label="blue")
# multiple selection for blue, red and second option
await element.select_option(value=["red", "green", "blue"])

```

```py title=example_1e192b67d701475d337aef6eef9a4d48fe2679b63810d5d7f7c9f7598fe4e43e.py
# single selection matching the value or label
element.select_option("blue")
# single selection matching the label
element.select_option(label="blue")
# multiple selection for blue, red and second option
element.select_option(value=["red", "green", "blue"])

```



## select_text

```
def select_text(force: nil, timeout: nil)
```

This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, then focuses the element and selects all its
text content.

If the element is inside the `<label>` element that has an associated
[control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), focuses and selects text in
the control instead.

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
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If
   the element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.
1. Ensure that the element is now checked or unchecked. If not, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`.
Passing zero timeout disables this.

## set_input_files

```
def set_input_files(files, noWaitAfter: nil, timeout: nil)
```
alias: `input_files=`

Sets the value of the file input to these file paths or files. If some of the `filePaths` are relative paths, then
they are resolved relative to the current working directory. For empty array, clears the selected files.

This method expects [Locator](./locator) to point to an
[input element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input). However, if the element is inside
the `<label>` element that has an associated
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

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`.
Passing zero timeout disables this.

**NOTE** `element.tap()` requires that the `hasTouch` option of the browser context be set to true.

## text_content

```
def text_content(timeout: nil)
```

Returns the `node.textContent`.

## type

```
def type(text, delay: nil, noWaitAfter: nil, timeout: nil)
```

Focuses the element, and then sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the
text.

To press a special key, like `Control` or `ArrowDown`, use [Locator#press](./locator#press).

**Usage**

```py title=example_997f50bb1b869c17ebcea0484f7e6c173d52c554cb973bce61c47bae0700956c.py
await element.type("hello") # types instantly
await element.type("world", delay=100) # types slower, like a user

```

```py title=example_9625efb170dd15a824259f363a8eb286ab03df35b93015fcf408ba1d44c18d8b.py
element.type("hello") # types instantly
element.type("world", delay=100) # types slower, like a user

```

An example of typing into a text field and then submitting the form:

```py title=example_377406c5b83b0dfb0139c2ea63f828d3c944b8afc9efce95a632ccd92477845a.py
element = page.get_by_label("Password")
await element.type("my password")
await element.press("Enter")

```

```py title=example_30af71a32179d7582eeffc07e15c87899ec06088cc6e1fd68c9b74608542302b.py
element = page.get_by_label("Password")
element.type("my password")
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

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`.
Passing zero timeout disables this.

## wait_for

```
def wait_for(state: nil, timeout: nil)
```

Returns when element specified by locator satisfies the `state` option.

If target element already satisfies the condition, the method returns immediately. Otherwise, waits for up to
`timeout` milliseconds until the condition is met.

**Usage**

```py title=example_c9838fba05979f539519b1416778be185d105ea6be591feefcaaca79dff13eb4.py
order_sent = page.locator("#order-sent")
await order_sent.wait_for()

```

```py title=example_2c6e3463aca5430cf8b7dc63f4e347596b22d8807bd9a6a37670512d9d14aed0.py
order_sent = page.locator("#order-sent")
order_sent.wait_for()

```


