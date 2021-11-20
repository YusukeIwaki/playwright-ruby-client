---
sidebar_position: 10
---

# FrameLocator

FrameLocator represents a view to the `iframe` on the page. It captures the logic sufficient to retrieve the `iframe`
and locate elements in that iframe. FrameLocator can be created with either [Page#frame_locator](./page#frame_locator) or
[Locator#frame_locator](./locator#frame_locator) method.

```python sync title=example_532f18c59b0dfaae95be697748f0c1c035b46e4acfaf509542b9e23a65830dd1.py
locator = page.frame_locator("my-frame").locator("text=Submit")
locator.click()

```

**Strictness**

Frame locators are strict. This means that all operations on frame locators will throw if more than one element matches
given selector.

```python sync title=example_9487c6c0f622a64723782638d6e962a9b5637df47ab693ed110f7202e6d67ee2.py
# Throws if there are several frames in DOM:
page.frame_locator('.result-frame').locator('button').click()

# Works because we explicitly tell locator to pick the first frame:
page.frame_locator('.result-frame').first.locator('button').click()

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

## last

```
def last
```

Returns locator to the last matching frame.

## locator

```
def locator(selector)
```

The method finds an element matching the specified selector in the FrameLocator's subtree.

## nth

```
def nth(index)
```

Returns locator to the n-th matching frame.
