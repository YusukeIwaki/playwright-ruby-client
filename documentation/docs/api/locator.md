---
sidebar_position: 10
---

# Locator


Locators are the central piece of Playwright's auto-waiting and retry-ability. In a nutshell, locators represent
a way to find element(s) on the page at any moment. Locator can be created with the [Page#locator](./page#locator) method.

[Learn more about locators](https://playwright.dev/python/docs/locators).

## all

```
def all
```


When locator points to a list of elements, returns array of locators, pointing
to respective elements.

**Usage**

```ruby
page.get_by_role('listitem').all.each do |li|
  li.click
end
```

## all_inner_texts

```
def all_inner_texts
```


Returns an array of `node.innerText` values for all matching nodes.

**Usage**

```python sync title=example_db3fbc8764290dcac5864a6d11dae6643865e74e0d1bb7e6a00ce777321a0b2f.py
texts = page.get_by_role("link").all_inner_texts()

```

## all_text_contents

```
def all_text_contents
```


Returns an array of `node.textContent` values for all matching nodes.

**Usage**

```python sync title=example_46e7add209e0c75ea54b931e47cefd095d989d034e76ec8918939e0f47b89ca3.py
texts = page.get_by_role("link").all_text_contents()

```

## blur

```
def blur(timeout: nil)
```


Calls [blur](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/blur) on the element.

## bounding_box

```
def bounding_box(timeout: nil)
```


This method returns the bounding box of the element matching the locator, or `null` if the element is not visible. The bounding box is
calculated relative to the main frame viewport - which is usually the same as the browser window.

**Details**

Scrolling affects the returned bounding box, similarly to
[Element.getBoundingClientRect](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect). That
means `x` and/or `y` may be negative.

Elements from child frames return the bounding box relative to the main frame, unlike the
[Element.getBoundingClientRect](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect).

Assuming the page is static, it is safe to use bounding box coordinates to perform input. For example, the following
snippet should click the center of the element.

**Usage**

```python sync title=example_09bf5cd40405b9e5cd84333743b6ef919d0714bb4da78c86404789d26ff196ae.py
box = page.get_by_role("button").bounding_box()
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


Ensure that checkbox or radio element is checked.

**Details**

Performs the following steps:
1. Ensure that element is a checkbox or a radio input. If not, this method throws. If the element is already checked, this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.
1. Ensure that the element is now checked. If not, this method throws.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

**Usage**

```python sync title=example_17dff0bf6d8bc93d2e17be7fd1c1231ee72555eabb19c063d71ee804928273a8.py
page.get_by_role("checkbox").check()

```

## clear

```
def clear(force: nil, noWaitAfter: nil, timeout: nil)
```


Clear the input field.

**Details**

This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, focuses the element, clears it and triggers an `input` event after clearing.

If the target element is not an `<input>`, `<textarea>` or `[contenteditable]` element, this method throws an error. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be cleared instead.

**Usage**

```python sync title=example_ccddf9c70c0dd2f6eaa85f46cf99155666e5be09f98bacfca21735d25e990707.py
page.get_by_role("textbox").clear()

```

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

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

**Usage**

Click a button:

```python sync title=example_0e93b0bcf462c0151fa70dfb6c3cb691c67ec10cdf0498478427a5c1d2a83521.py
page.get_by_role("button").click()

```

Shift-right-click at a specific position on a canvas:

```python sync title=example_855b70722b9c7795f29b6aa150ba7997d542adf67f9104638ca48fd680ad6d86.py
page.locator("canvas").click(
    button="right", modifiers=["Shift"], position={"x": 23, "y": 32}
)

```

## count

```
def count
```


Returns the number of elements matching the locator.

**Usage**

```python sync title=example_a711e425f2e4fe8cdd4e7ff99d609e607146ddb7b1fb5c5d8978bd0555ac1fcd.py
count = page.get_by_role("listitem").count()

```

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


Double-click an element.

**Details**

This method double clicks the element by performing the following steps:
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to double click in the center of the element, or the specified `position`.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set. Note that if the first click of the `dblclick()` triggers a navigation event, this method will throw.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

**NOTE**: `element.dblclick()` dispatches two `click` events and a single `dblclick` event.

## dispatch_event

```
def dispatch_event(type, eventInit: nil, timeout: nil)
```


Programmaticaly dispatch an event on the matching element.

**Usage**

```python sync title=example_72b38530862dccd8b3ad53982f45a24a5ee82fc6e50fccec328d544bf1a78909.py
locator.dispatch_event("click")

```

**Details**

The snippet above dispatches the `click` event on the element. Regardless of the visibility state of the element, `click`
is dispatched. This is equivalent to calling
[element.click()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/click).

Under the hood, it creates an instance of an event based on the given `type`, initializes it with
`eventInit` properties and dispatches it on the element. Events are `composed`, `cancelable` and bubble by
default.

Since `eventInit` is event-specific, please refer to the events documentation for the lists of initial
properties:
- [DragEvent](https://developer.mozilla.org/en-US/docs/Web/API/DragEvent/DragEvent)
- [FocusEvent](https://developer.mozilla.org/en-US/docs/Web/API/FocusEvent/FocusEvent)
- [KeyboardEvent](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/KeyboardEvent)
- [MouseEvent](https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent/MouseEvent)
- [PointerEvent](https://developer.mozilla.org/en-US/docs/Web/API/PointerEvent/PointerEvent)
- [TouchEvent](https://developer.mozilla.org/en-US/docs/Web/API/TouchEvent/TouchEvent)
- [Event](https://developer.mozilla.org/en-US/docs/Web/API/Event/Event)

You can also specify [JSHandle](./js_handle) as the property value if you want live objects to be passed into the event:

```python sync title=example_bf805bb1858c7b8ea50d9c52704fab32064e1c26fb608232e823fe87267a07b3.py
# note you can only create data_transfer in chromium and firefox
data_transfer = page.evaluate_handle("new DataTransfer()")
locator.dispatch_event("#source", "dragstart", {"dataTransfer": data_transfer})

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


Drag the source element towards the target element and drop it.

**Details**

This method drags the locator to another target locator or target position. It will
first move to the source element, perform a `mousedown`, then move to the target
element or position and perform a `mouseup`.

**Usage**

```ruby
source = page.locator("#source")
target = page.locator("#target")

source.drag_to(target)
# or specify exact positions relative to the top-left corners of the elements:
source.drag_to(
  target,
  sourcePosition: { x: 34, y: 7 },
  targetPosition: { x: 10, y: 20 },
)
```

## element_handle

```
def element_handle(timeout: nil)
```


Resolves given locator to the first matching DOM element. If there are no matching elements, waits for one. If multiple elements match the locator, throws.

## element_handles

```
def element_handles
```


Resolves given locator to all matching DOM elements. If there are no matching elements, returns an empty list.

## evaluate

```
def evaluate(expression, arg: nil, timeout: nil)
```


Execute JavaScript code in the page, taking the matching element as an argument.

**Details**

Returns the return value of `expression`, called with the matching element as a first argument, and `arg` as a second argument.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), this method will wait for the promise to resolve and return its value.

If `expression` throws or rejects, this method throws.

**Usage**

```ruby
tweet = page.query_selector(".tweet .retweets")
tweet.evaluate("node => node.innerText") # => "10 retweets"
```

## evaluate_all

```
def evaluate_all(expression, arg: nil)
```


Execute JavaScript code in the page, taking all matching elements as an argument.

**Details**

Returns the return value of `expression`, called with an array of all matching elements as a first argument, and `arg` as a second argument.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), this method will wait for the promise to resolve and return its value.

If `expression` throws or rejects, this method throws.

**Usage**

```python sync title=example_877178e12857c7b3ef09f6c50606489c9d9894220622379b72e1e180a2970b96.py
locator = page.locator("div")
more_than_ten = locator.evaluate_all("(divs, min) => divs.length > min", 10)

```

## evaluate_handle

```
def evaluate_handle(expression, arg: nil, timeout: nil)
```


Execute JavaScript code in the page, taking the matching element as an argument, and return a [JSHandle](./js_handle) with the result.

**Details**

Returns the return value of `expression` as a[JSHandle](./js_handle), called with the matching element as a first argument, and `arg` as a second argument.

The only difference between [Locator#evaluate](./locator#evaluate) and [Locator#evaluate_handle](./locator#evaluate_handle) is that [Locator#evaluate_handle](./locator#evaluate_handle) returns [JSHandle](./js_handle).

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), this method will wait for the promise to resolve and return its value.

If `expression` throws or rejects, this method throws.

See [Page#evaluate_handle](./page#evaluate_handle) for more details.

## fill

```
def fill(value, force: nil, noWaitAfter: nil, timeout: nil)
```


Set a value to the input field.

**Usage**

```python sync title=example_77567051f4c8531c719eb0b94e53a061ffe9a414e3bb131cbc956d1fdcf6eab3.py
page.get_by_role("textbox").fill("example value")

```

**Details**

This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, focuses the element, fills it and triggers an `input` event after filling. Note that you can pass an empty string to clear the input field.

If the target element is not an `<input>`, `<textarea>` or `[contenteditable]` element, this method throws an error. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be filled instead.

To send fine-grained keyboard events, use [Locator#type](./locator#type).

## filter

```
def filter(has: nil, hasText: nil)
```


This method narrows existing locator according to the options, for example filters by text.
It can be chained to filter multiple times.

**Usage**

```ruby
row_locator = page.locator("tr")
# ...
row_locator.
    filter(hasText: "text in column 1").
    filter(has: page.get_by_role("button", name: "column 2 button")).
    screenshot
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


Calls [focus](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/focus) on the matching element.

## frame_locator

```
def frame_locator(selector)
```


When working with iframes, you can create a frame locator that will enter the iframe and allow locating elements
in that iframe:

**Usage**

```ruby
locator = page.frame_locator("iframe").get_by_text("Submit")
locator.click
```

## get_attribute

```
def get_attribute(name, timeout: nil)
```
alias: `[]`


Returns the matching element's attribute value.

## get_by_alt_text

```
def get_by_alt_text(text, exact: nil)
```


Allows locating elements by their alt text.

**Usage**

For example, this method will find the image by alt text "Playwright logo":

```html
<img alt='Playwright logo'>
```

```python sync title=example_40a7d124045a4f729e0deddcfb511b9232ada7f16e0caa4e07ea083c2bfd3c16.py
page.get_by_alt_text("Playwright logo").click()

```

## get_by_label

```
def get_by_label(text, exact: nil)
```


Allows locating input elements by the text of the associated label.

**Usage**

For example, this method will find the input by label text "Password" in the following DOM:

```html
<label for="password-input">Password:</label>
<input id="password-input">
```

```python sync title=example_c19c4ba9cb058cdfedf7fd87eb1634459f0b62d9ee872e61272414b0fb69a01c.py
page.get_by_label("Password").fill("secret")

```

## get_by_placeholder

```
def get_by_placeholder(text, exact: nil)
```


Allows locating input elements by the placeholder text.

**Usage**

For example, consider the following DOM structure.

```html
<input type="email" placeholder="name@example.com" />
```

You can fill the input after locating it by the placeholder text:

```python sync title=example_c521b79be0a480325f84dc2c110a9803f0d74b2042da32c84660abe90ab7bb37.py
page.get_by_placeholder("name@example.com").fill("playwright@microsoft.com")

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


Allows locating elements by their [ARIA role](https://www.w3.org/TR/wai-aria-1.2/#roles), [ARIA attributes](https://www.w3.org/TR/wai-aria-1.2/#aria-attributes) and [accessible name](https://w3c.github.io/accname/#dfn-accessible-name).

**Usage**

Consider the following DOM structure.

```html
<h3>Sign up</h3>
<label>
  <input type="checkbox" /> Subscribe
</label>
<br/>
<button>Submit</button>
```

You can locate each element by it's implicit role:

```python sync title=example_d0da510d996da8a4b3e0505412b0b651049ab11b56317300ba3dc52e928500b3.py
expect(page.get_by_role("heading", name="Sign up")).to_be_visible()

page.get_by_role("checkbox", name="Subscribe").check()

page.get_by_role("button", name=re.compile("submit", re.IGNORECASE)).click()

```

**Details**

Role selector **does not replace** accessibility audits and conformance tests, but rather gives early feedback about the ARIA guidelines.

Many html elements have an implicitly [defined role](https://w3c.github.io/html-aam/#html-element-role-mappings) that is recognized by the role selector. You can find all the [supported roles here](https://www.w3.org/TR/wai-aria-1.2/#role_definitions). ARIA guidelines **do not recommend** duplicating implicit roles and attributes by setting `role` and/or `aria-*` attributes to default values.

## get_by_test_id

```
def get_by_test_id(testId)
```


Locate element by the test id.

**Usage**

Consider the following DOM structure.

```html
<button data-testid="directions">Itinéraire</button>
```

You can locate the element by it's test id:

```python sync title=example_291583061a6a67f91ea5f926eac4b5cd6c351d7009ddfef39b52efba03909ca0.py
page.get_by_test_id("directions").click()

```

**Details**

By default, the `data-testid` attribute is used as a test id. Use [Selectors#set_test_id_attribute](./selectors#set_test_id_attribute) to configure a different test id attribute if necessary.

## get_by_text

```
def get_by_text(text, exact: nil)
```


Allows locating elements that contain given text.

See also [Locator#filter](./locator#filter) that allows to match by another criteria, like an accessible role, and then filter by the text content.

**Usage**

Consider the following DOM structure:

```html
<div>Hello <span>world</span></div>
<div>Hello</div>
```

You can locate by text substring, exact string, or a regular expression:

```ruby
page.content = <<~HTML
  <div>Hello <span>world</span></div>
  <div>Hello</div>
HTML

# Matches <span>
locator = page.get_by_text("world")
expect(locator.evaluate('e => e.outerHTML')).to eq('<span>world</span>')

# Matches first <div>
locator = page.get_by_text("Hello world")
expect(locator.evaluate('e => e.outerHTML')).to eq('<div>Hello <span>world</span></div>')

# Matches second <div>
locator = page.get_by_text("Hello", exact: true)
expect(locator.evaluate('e => e.outerHTML')).to eq('<div>Hello</div>')

# Matches both <div>s
locator = page.get_by_text(/Hello/)
expect(locator.count).to eq(2)
expect(locator.first.evaluate('e => e.outerHTML')).to eq('<div>Hello <span>world</span></div>')
expect(locator.last.evaluate('e => e.outerHTML')).to eq('<div>Hello</div>')

# Matches second <div>
locator = page.get_by_text(/^hello$/i)
expect(locator.evaluate('e => e.outerHTML')).to eq('<div>Hello</div>')
```

**Details**

Matching by text always normalizes whitespace, even with exact match. For example, it turns multiple spaces into one, turns line breaks into spaces and ignores leading and trailing whitespace.

Input elements of the type `button` and `submit` are matched by their `value` instead of the text content. For example, locating by text `"Log in"` matches `<input type=button value="Log in">`.

## get_by_title

```
def get_by_title(text, exact: nil)
```


Allows locating elements by their title attribute.

**Usage**

Consider the following DOM structure.

```html
<span title='Issues count'>25 issues</span>
```

You can check the issues count after locating it by the title text:

```python sync title=example_0aecb761822601bd6adf174c0aeb9db69bf4880a62eb4a1cdeb67c2f57c7149e.py
expect(page.get_by_title("Issues count")).to_have_text("25 issues")

```

## highlight

```
def highlight
```


Highlight the corresponding element(s) on the screen. Useful for debugging, don't commit the code that uses [Locator#highlight](./locator#highlight).

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


Hover over the matching element.

**Usage**

```python sync title=example_0a9e085f6c2ab04459adc2bf6ec73a06ff3cde201943ff8f4965552528b73f89.py
page.get_by_role("link").hover()

```

**Details**

This method hovers over the element by performing the following steps:
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to hover over the center of the element, or the specified `position`.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

## inner_html

```
def inner_html(timeout: nil)
```


Returns the [`element.innerHTML`](https://developer.mozilla.org/en-US/docs/Web/API/Element/innerHTML).

## inner_text

```
def inner_text(timeout: nil)
```


Returns the [`element.innerText`](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/innerText).

## input_value

```
def input_value(timeout: nil)
```


Returns the value for the matching `<input>` or `<textarea>` or `<select>` element.

**Usage**

```python sync title=example_bb8cec73e5210f884833e04e6d71f7c035451bafd39500e057e6d6325c990474.py
value = page.get_by_role("textbox").input_value()

```

**Details**

Throws elements that are not an input, textarea or a select. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), returns the value of the control.

## checked?

```
def checked?(timeout: nil)
```


Returns whether the element is checked. Throws if the element is not a checkbox or radio input.

**Usage**

```python sync title=example_f617df59758f06107dd5c79e986aabbfde5861fbda6ccc5d8b91a508ebdc48f7.py
checked = page.get_by_role("checkbox").is_checked()

```

## disabled?

```
def disabled?(timeout: nil)
```


Returns whether the element is disabled, the opposite of [enabled](https://playwright.dev/python/docs/actionability#enabled).

**Usage**

```python sync title=example_5c008cd1a3ece779fe8c29092643a482cd0215d5c09001cd9ef08c444ea6cdd1.py
disabled = page.get_by_role("button").is_disabled()

```

## editable?

```
def editable?(timeout: nil)
```


Returns whether the element is [editable](https://playwright.dev/python/docs/actionability#editable).

**Usage**

```python sync title=example_10e437a8b21b128feda412f1e3cf85615fe260be2ad08758a3c5e5216b46187b.py
editable = page.get_by_role("textbox").is_editable()

```

## enabled?

```
def enabled?(timeout: nil)
```


Returns whether the element is [enabled](https://playwright.dev/python/docs/actionability#enabled).

**Usage**

```python sync title=example_69710ffa4599909a9ae6cd570a2b88f6981c064c577b1e255fe5cc21b07d033c.py
enabled = page.get_by_role("button").is_enabled()

```

## hidden?

```
def hidden?(timeout: nil)
```


Returns whether the element is hidden, the opposite of [visible](https://playwright.dev/python/docs/actionability#visible).

**Usage**

```python sync title=example_f25a3bde8e8a1d091d01321314daa6059cb8aa026a3c2c4be50b1611bbdb3c19.py
hidden = page.get_by_role("button").is_hidden()

```

## visible?

```
def visible?(timeout: nil)
```


Returns whether the element is [visible](https://playwright.dev/python/docs/actionability#visible).

**Usage**

```python sync title=example_b54ab20fe81143e0242d5d001ce2b1af4a272a2cc7c9d6925551de10f46a68c4.py
visible = page.get_by_role("button").is_visible()

```

## last

```
def last
```


Returns locator to the last matching element.

**Usage**

```python sync title=example_37f239c3646f77e0658c12f139a5883eb99d9952f7761ad58ffb629fa385c7bb.py
banana = page.get_by_role("listitem").last()

```

## locator

```
def locator(selector, has: nil, hasText: nil)
```


The method finds an element matching the specified selector in the locator's subtree. It also accepts filter options, similar to [Locator#filter](./locator#filter) method.

[Learn more about locators](https://playwright.dev/python/docs/locators).

## nth

```
def nth(index)
```


Returns locator to the n-th matching element. It's zero based, `nth(0)` selects the first element.

**Usage**

```python sync title=example_d6cc7c4a653d7139137c582ad853bebd92e3b97893fb6d5f88919553404c57e4.py
banana = page.get_by_role("listitem").nth(2)

```

## page

```
def page
```


A page this locator belongs to.

## press

```
def press(key, delay: nil, noWaitAfter: nil, timeout: nil)
```


Focuses the mathing element and presses a combintation of the keys.

**Usage**

```python sync title=example_29eed7b713b928678523c677c788808779cf13dda2bb117aab2562cef3b08647.py
page.get_by_role("textbox").press("Backspace")

```

**Details**

Focuses the element, and then uses [Keyboard#down](./keyboard#down) and [Keyboard#up](./keyboard#up).

`key` can specify the intended
[keyboardEvent.key](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key) value or a single character to
generate the text for. A superset of the `key` values can be found
[here](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values). Examples of the keys are:

`F1` - `F12`, `Digit0`- `Digit9`, `KeyA`- `KeyZ`, `Backquote`, `Minus`, `Equal`, `Backslash`, `Backspace`, `Tab`,
`Delete`, `Escape`, `ArrowDown`, `End`, `Enter`, `Home`, `Insert`, `PageDown`, `PageUp`, `ArrowRight`, `ArrowUp`, etc.

Following modification shortcuts are also supported: `Shift`, `Control`, `Alt`, `Meta`, `ShiftLeft`.

Holding down `Shift` will type the text that corresponds to the `key` in the upper case.

If `key` is a single character, it is case-sensitive, so the values `a` and `A` will generate different
respective texts.

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


Take a screenshot of the element matching the locator.

**Usage**

```python sync title=example_43381950beaa21258e3f378d4b6aff54b83fa3eba52f36c65f4ca2d3d6df248d.py
page.get_by_role("link").screenshot()

```

Disable animations and save screenshot to a file:

```python sync title=example_d787f101e95d45bbcf3184b241bab4925e68d8e5c117299d0a95bf66f19bbdaa.py
page.get_by_role("link").screenshot(animations="disabled", path="link.png")

```

**Details**

This method captures a screenshot of the page, clipped to the size and position of a particular element matching the locator. If the element is covered by other elements, it will not be actually visible on the screenshot. If the element is a scrollable container, only the currently scrolled content will be visible on the screenshot.

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


Selects option or options in `<select>`.

**Details**

This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, waits until all specified options are present in the `<select>` element and selects these options.

If the target element is not a `<select>` element, this method throws an error. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be used instead.

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

```ruby
# single selection matching the value or label
element.select_option(value: "blue")
# single selection matching both the label
element.select_option(label: "blue")
# multiple selection
element.select_option(value: ["red", "green", "blue"])
```

## select_text

```
def select_text(force: nil, timeout: nil)
```


This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, then focuses the element and selects all its text
content.

If the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), focuses and selects text in the control instead.

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


Set the state of a checkbox or a radio element.

**Usage**

```python sync title=example_bab309d5b9f84c3b57a3057462dbddf7436cba6181457788c8e302d8e20aa108.py
page.get_by_role("checkbox").set_checked(True)

```

**Details**

This method checks or unchecks an element by performing the following steps:
1. Ensure that matched element is a checkbox or a radio input. If not, this method throws.
1. If the element already has the right checked state, this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If the element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.
1. Ensure that the element is now checked or unchecked. If not, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

## set_input_files

```
def set_input_files(files, noWaitAfter: nil, timeout: nil)
```
alias: `input_files=`


Upload file or multiple files into `<input type=file>`.

**Usage**

```python sync title=example_f1bf5c6c31c8405ce60cee9138c6d6dc6923be52e61ff8c2a3c3d28186b72282.py
# Select one file
page.get_by_label("Upload file").set_input_files('myfile.pdf')

# Select multiple files
page.get_by_label("Upload files").set_input_files(['file1.txt', 'file2.txt'])

# Remove all the selected files
page.get_by_label("Upload file").set_input_files([])

# Upload buffer from memory
page.get_by_label("Upload file").set_input_files(
    files=[
        {"name": "test.txt", "mimeType": "text/plain", "buffer": b"this is a test"}
    ],
)

```

**Details**

Sets the value of the file input to these file paths or files. If some of the `filePaths` are relative paths, then they
are resolved relative to the current working directory. For empty array, clears the selected files.

This method expects [Locator](./locator) to point to an
[input element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input). However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), targets the control instead.

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


Perform a tap gesture on the element matching the locator.

**Details**

This method taps the element by performing the following steps:
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#touchscreen](./page#touchscreen) to tap the center of the element, or the specified `position`.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

**NOTE**: `element.tap()` requires that the `hasTouch` option of the browser context be set to true.

## text_content

```
def text_content(timeout: nil)
```


Returns the [`node.textContent`](https://developer.mozilla.org/en-US/docs/Web/API/Node/textContent).

## type

```
def type(text, delay: nil, noWaitAfter: nil, timeout: nil)
```


Focuses the element, and then sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text.

To press a special key, like `Control` or `ArrowDown`, use [Locator#press](./locator#press).

**Usage**

```ruby
element.type("hello") # types instantly
element.type("world", delay: 100) # types slower, like a user
```

An example of typing into a text field and then submitting the form:

```ruby
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


Ensure that checkbox or radio element is unchecked.

**Usage**

```python sync title=example_ead0dc91ccaf4d3de1e28cccdadfacb0e75c79ffcfb8fc5a2b55afa736870fa6.py
page.get_by_role("checkbox").uncheck()

```

**Details**

This method unchecks the element by performing the following steps:
1. Ensure that element is a checkbox or a radio input. If not, this method throws. If the element is already unchecked, this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.
1. Ensure that the element is now unchecked. If not, this method throws.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

## wait_for

```
def wait_for(state: nil, timeout: nil)
```


Returns when element specified by locator satisfies the `state` option.

If target element already satisfies the condition, the method returns immediately. Otherwise, waits for up to
`timeout` milliseconds until the condition is met.

**Usage**

```ruby
order_sent = page.locator("#order-sent")
order_sent.wait_for
```
