---
sidebar_position: 10
---

# FrameLocator

FrameLocator represents a view to the `iframe` on the page. It captures the logic sufficient to retrieve the `iframe`
and locate elements in that iframe. FrameLocator can be created with either [Page#frame_locator](./page#frame_locator) or
[Locator#frame_locator](./locator#frame_locator) method.

```python sync title=example_4b7e4ce2b2fdb7e75c2145e4ba89216e4cbd2892caff1b05189e8729d3aa8dfb.py
locator = page.frame_locator("my-frame").get_by_text("Submit")
locator.click()

```

**Strictness**

Frame locators are strict. This means that all operations on frame locators will throw if more than one element matches
a given selector.

```ruby
# Throws if there are several frames in DOM:
page.frame_locator('.result-frame').get_by_role('button').click

# Works because we explicitly tell locator to pick the first frame:
page.frame_locator('.result-frame').first.get_by_role('button').click
```

**Converting Locator to FrameLocator**

If you have a [Locator](./locator) object pointing to an `iframe` it can be converted to [FrameLocator](./frame_locator) using
[`:scope`](https://developer.mozilla.org/en-US/docs/Web/CSS/:scope) CSS selector:

```python sync title=example_12733f9ff809e08435510bc818e9a4194f9f89cbf6de5c38bfb3e1dca9e72565.py
frameLocator = locator.frame_locator(":scope")

```



## first

```
def first
```

Returns locator to the first matching frame.

## frame_locator

```
def frame_locator(selector)
```

When working with iframes, you can create a frame locator that will enter the iframe and allow selecting elements in
that iframe.

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
[defined role](https://w3c.github.io/html-aam/#html-element-role-mappings) that is recognized by the role selector. You
can find all the [supported roles here](https://www.w3.org/TR/wai-aria-1.2/#role_definitions). ARIA guidelines **do not
recommend** duplicating implicit roles and attributes by setting `role` and/or `aria-*` attributes to default values.

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

```python sync title=example_cbf4890335f3140b7b275bdad85b330140e5fbb21e7f4b89643c73115ee62a17.py
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

See also [Locator#filter](./locator#filter) that allows to match by another criteria, like an accessible role, and then filter
by the text content.

> NOTE: Matching by text always normalizes whitespace, even with exact match. For example, it turns multiple spaces into
one, turns line breaks into spaces and ignores leading and trailing whitespace.
> NOTE: Input elements of the type `button` and `submit` are matched by their `value` instead of the text content. For
example, locating by text `"Log in"` matches `<input type=button value="Log in">`.

## get_by_title

```
def get_by_title(text, exact: nil)
```

Allows locating elements by their title. For example, this method will find the button by its title "Place the order":

```html
<button title='Place the order'>Order Now</button>
```


## last

```
def last
```

Returns locator to the last matching frame.

## locator

```
def locator(selector, has: nil, hasText: nil)
```

The method finds an element matching the specified selector in the locator's subtree. It also accepts filter options,
similar to [Locator#filter](./locator#filter) method.

[Learn more about locators](https://playwright.dev/python/docs/locators).

## nth

```
def nth(index)
```

Returns locator to the n-th matching frame. It's zero based, `nth(0)` selects the first frame.
