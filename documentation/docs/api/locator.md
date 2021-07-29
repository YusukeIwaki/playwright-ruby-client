---
sidebar_position: 10
---

# Locator

Locator represents a view to the element(s) on the page. It captures the logic sufficient to retrieve the element at any
given moment. Locator can be created with the [Page#locator](./page#locator) method.

The difference between the Locator and [ElementHandle](./element_handle) is that the latter points to a particular element, while Locator
only captures the logic of how to retrieve an element at any given moment.

In the example below, handle points to a particular DOM element on page. If that element changes text or is used by
React to render an entirely different component, handle is still pointing to that very DOM element.

```python sync title=example_01a453e4368b0eae393813ed13b9cd67aa07743e178567efdf8822cfd9b3b232.py
handle = page.query_selector("text=Submit")
handle.hover()
handle.click()

```

With the locator, every time the `element` is used, corresponding DOM element is located in the page using given
selector. So in the snippet below, underlying DOM element is going to be located twice, using the given selector.

```python sync title=example_2afd3c53fa2e68c0d9ec7a61f84db4e92c2c5889255e194195066b5515d0e931.py
element = page.locator("text=Submit")
element.hover()
element.click()

```



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

```python sync title=example_4d635e937854fa2ee56b7c43151ded535940f0bbafc00cf48e8214bed86715eb.py
box = element.bounding_box()
page.mouse.click(box["x"] + box["width"] / 2, box["y"] + box["height"] / 2)

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

This method clicks the element by performing the following steps:
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element, or the specified `position`.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`. Passing
zero timeout disables this.

## element_handle

```
def element_handle(timeout: nil)
```

Resolves given locator to the first matching DOM element. If no elements matching the query are visible, waits for them
up to a given timeout. If multiple elements match the selector, throws.

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

Returns `input.value` for `<input>` or `<textarea>` element. Throws for non-input elements.

## text_content

```
def text_content(timeout: nil)
```

Returns the `node.textContent`.
