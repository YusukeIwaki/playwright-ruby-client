---
sidebar_position: 10
---

# LocatorAssertions


The [LocatorAssertions](./locator_assertions) class provides assertion methods that can be used to make assertions about the [Locator](./locator) state in the tests.

```python sync title=example_eff0600f575bf375d7372280ca8e6dfc51d927ced49fbcb75408c894b9e0564e.py
from playwright.sync_api import Page, expect

def test_status_becomes_submitted(page: Page) -> None:
    # ..
    page.get_by_role("button").click()
    expect(page.locator(".status")).to_have_text("Submitted")

```

## not_to_be_attached

```
def not_to_be_attached(attached: nil, timeout: nil)
```


The opposite of [LocatorAssertions#to_be_attached](./locator_assertions#to_be_attached).

## not_to_be_checked

```
def not_to_be_checked(timeout: nil)
```


The opposite of [LocatorAssertions#to_be_checked](./locator_assertions#to_be_checked).

## not_to_be_disabled

```
def not_to_be_disabled(timeout: nil)
```


The opposite of [LocatorAssertions#to_be_disabled](./locator_assertions#to_be_disabled).

## not_to_be_editable

```
def not_to_be_editable(editable: nil, timeout: nil)
```


The opposite of [LocatorAssertions#to_be_editable](./locator_assertions#to_be_editable).

## not_to_be_empty

```
def not_to_be_empty(timeout: nil)
```


The opposite of [LocatorAssertions#to_be_empty](./locator_assertions#to_be_empty).

## not_to_be_enabled

```
def not_to_be_enabled(enabled: nil, timeout: nil)
```


The opposite of [LocatorAssertions#to_be_enabled](./locator_assertions#to_be_enabled).

## not_to_be_focused

```
def not_to_be_focused(timeout: nil)
```


The opposite of [LocatorAssertions#to_be_focused](./locator_assertions#to_be_focused).

## not_to_be_hidden

```
def not_to_be_hidden(timeout: nil)
```


The opposite of [LocatorAssertions#to_be_hidden](./locator_assertions#to_be_hidden).

## not_to_be_in_viewport

```
def not_to_be_in_viewport(ratio: nil, timeout: nil)
```


The opposite of [LocatorAssertions#to_be_in_viewport](./locator_assertions#to_be_in_viewport).

## not_to_be_visible

```
def not_to_be_visible(timeout: nil, visible: nil)
```


The opposite of [LocatorAssertions#to_be_visible](./locator_assertions#to_be_visible).

## not_to_contain_text

```
def not_to_contain_text(expected, ignoreCase: nil, timeout: nil, useInnerText: nil)
```


The opposite of [LocatorAssertions#to_contain_text](./locator_assertions#to_contain_text).

## not_to_have_attribute

```
def not_to_have_attribute(name, value, timeout: nil)
```


The opposite of [LocatorAssertions#to_have_attribute](./locator_assertions#to_have_attribute).

## not_to_have_class

```
def not_to_have_class(expected, timeout: nil)
```


The opposite of [LocatorAssertions#to_have_class](./locator_assertions#to_have_class).

## not_to_have_count

```
def not_to_have_count(count, timeout: nil)
```


The opposite of [LocatorAssertions#to_have_count](./locator_assertions#to_have_count).

## not_to_have_css

```
def not_to_have_css(name, value, timeout: nil)
```


The opposite of [LocatorAssertions#to_have_css](./locator_assertions#to_have_css).

## not_to_have_id

```
def not_to_have_id(id, timeout: nil)
```


The opposite of [LocatorAssertions#to_have_id](./locator_assertions#to_have_id).

## not_to_have_js_property

```
def not_to_have_js_property(name, value, timeout: nil)
```


The opposite of [LocatorAssertions#to_have_js_property](./locator_assertions#to_have_js_property).

## not_to_have_text

```
def not_to_have_text(expected, ignoreCase: nil, timeout: nil, useInnerText: nil)
```


The opposite of [LocatorAssertions#to_have_text](./locator_assertions#to_have_text).

## not_to_have_value

```
def not_to_have_value(value, timeout: nil)
```


The opposite of [LocatorAssertions#to_have_value](./locator_assertions#to_have_value).

## not_to_have_values

```
def not_to_have_values(values, timeout: nil)
```


The opposite of [LocatorAssertions#to_have_values](./locator_assertions#to_have_values).

## to_be_attached

```
def to_be_attached(attached: nil, timeout: nil)
```


Ensures that [Locator](./locator) points to an [attached](https://playwright.dev/python/docs/actionability#attached) DOM node.

**Usage**

```python sync title=example_781b6f44dd462fc3753b3e48d6888f2ef4d0794253bf6ffb4c42c76f5ec3b454.py
expect(page.get_by_text("Hidden text")).to_be_attached()

```

## to_be_checked

```
def to_be_checked(checked: nil, timeout: nil)
```


Ensures the [Locator](./locator) points to a checked input.

**Usage**

```python sync title=example_00a58b66eec12973ab87c0ce5004126aa1f1af5a971a9e89638669f729bbb1b6.py
from playwright.sync_api import expect

locator = page.get_by_label("Subscribe to newsletter")
expect(locator).to_be_checked()

```

## to_be_disabled

```
def to_be_disabled(timeout: nil)
```


Ensures the [Locator](./locator) points to a disabled element. Element is disabled if it has "disabled" attribute
or is disabled via ['aria-disabled'](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-disabled).
Note that only native control elements such as HTML `button`, `input`, `select`, `textarea`, `option`, `optgroup`
can be disabled by setting "disabled" attribute. "disabled" attribute on other elements is ignored
by the browser.

**Usage**

```python sync title=example_fc3052bc38e6c1968f23f9185bda7f06478af4719ce96f6a49878ea7e72c9a82.py
from playwright.sync_api import expect

locator = page.locator("button.submit")
expect(locator).to_be_disabled()

```

## to_be_editable

```
def to_be_editable(editable: nil, timeout: nil)
```


Ensures the [Locator](./locator) points to an editable element.

**Usage**

```python sync title=example_a42b1e97cd0899ccd72bc4b74ab8f57c549814ca5b6d1bb912c870153d6d3f8d.py
from playwright.sync_api import expect

locator = page.get_by_role("textbox")
expect(locator).to_be_editable()

```

## to_be_empty

```
def to_be_empty(timeout: nil)
```


Ensures the [Locator](./locator) points to an empty editable element or to a DOM node that has no text.

**Usage**

```python sync title=example_1fb5a7ee389401cf5a6fb3ba90c5b58c42c93d43aa5e4e34d99a5c6265ce0b35.py
from playwright.sync_api import expect

locator = page.locator("div.warning")
expect(locator).to_be_empty()

```

## to_be_enabled

```
def to_be_enabled(enabled: nil, timeout: nil)
```


Ensures the [Locator](./locator) points to an enabled element.

**Usage**

```python sync title=example_0389b23d34a430ee418fd2138f9b8269df20fb6595f2618400e3d53b4f344a75.py
from playwright.sync_api import expect

locator = page.locator("button.submit")
expect(locator).to_be_enabled()

```

## to_be_focused

```
def to_be_focused(timeout: nil)
```


Ensures the [Locator](./locator) points to a focused DOM node.

**Usage**

```python sync title=example_9fc7c2560e0a8117bc4ba14d6133a3d9c66cf6461c29c5a74fe132dea8bd8d63.py
from playwright.sync_api import expect

locator = page.get_by_role("textbox")
expect(locator).to_be_focused()

```

## to_be_hidden

```
def to_be_hidden(timeout: nil)
```


Ensures that [Locator](./locator) either does not resolve to any DOM node, or resolves to a [non-visible](https://playwright.dev/python/docs/actionability#visible) one.

**Usage**

```python sync title=example_55b9181de8eb71936b5e5289631fca33d2100f47f4c4e832d92c23f923779c62.py
from playwright.sync_api import expect

locator = page.locator('.my-element')
expect(locator).to_be_hidden()

```

## to_be_in_viewport

```
def to_be_in_viewport(ratio: nil, timeout: nil)
```


Ensures the [Locator](./locator) points to an element that intersects viewport, according to the [intersection observer API](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API).

**Usage**

```python sync title=example_7d5d5657528a32a8fb24cbf30e7bb3154cdf4c426e84e40131445a38fe8df2ee.py
from playwright.sync_api import expect

locator = page.get_by_role("button")
# Make sure at least some part of element intersects viewport.
expect(locator).to_be_in_viewport()
# Make sure element is fully outside of viewport.
expect(locator).not_to_be_in_viewport()
# Make sure that at least half of the element intersects viewport.
expect(locator).to_be_in_viewport(ratio=0.5)

```

## to_be_visible

```
def to_be_visible(timeout: nil, visible: nil)
```


Ensures that [Locator](./locator) points to an [attached](https://playwright.dev/python/docs/actionability#attached) and [visible](https://playwright.dev/python/docs/actionability#visible) DOM node.

**Usage**

```python sync title=example_84ccd2ec31f9f00136a2931e9abb9c766eab967a6e892d3dcf90c02f14e5117f.py
expect(page.get_by_text("Welcome")).to_be_visible()

```

## to_contain_text

```
def to_contain_text(expected, ignoreCase: nil, timeout: nil, useInnerText: nil)
```


Ensures the [Locator](./locator) points to an element that contains the given text. You can use regular expressions for the value as well.

**Usage**

```python sync title=example_3553a48e2a15853f4869604ef20dae14952c16abfa0570b8f02e9b74e3d84faa.py
import re
from playwright.sync_api import expect

locator = page.locator('.title')
expect(locator).to_contain_text("substring")
expect(locator).to_contain_text(re.compile(r"\d messages"))

```

If you pass an array as an expected value, the expectations are:
1. Locator resolves to a list of elements.
1. Elements from a **subset** of this list contain text from the expected array, respectively.
1. The matching subset of elements has the same order as the expected array.
1. Each text value from the expected array is matched by some element from the list.

For example, consider the following list:

```html
<ul>
  <li>Item Text 1</li>
  <li>Item Text 2</li>
  <li>Item Text 3</li>
</ul>
```

Let's see how we can use the assertion:

```python sync title=example_fb3cde55b658aefe2e54f93e5b78d26f25cd376eaa469434631af079bb8d8a62.py
from playwright.sync_api import expect

# ✓ Contains the right items in the right order
expect(page.locator("ul > li")).to_contain_text(["Text 1", "Text 3", "Text 4"])

# ✖ Wrong order
expect(page.locator("ul > li")).to_contain_text(["Text 3", "Text 2"])

# ✖ No item contains this text
expect(page.locator("ul > li")).to_contain_text(["Some 33"])

# ✖ Locator points to the outer list element, not to the list items
expect(page.locator("ul")).to_contain_text(["Text 3"])

```

## to_have_attribute

```
def to_have_attribute(name, value, timeout: nil)
```


Ensures the [Locator](./locator) points to an element with given attribute.

**Usage**

```python sync title=example_709faaa456b4775109b1fbaca74a86ac5107af5e4801ea07cb690942f1d37f88.py
from playwright.sync_api import expect

locator = page.locator("input")
expect(locator).to_have_attribute("type", "text")

```

## to_have_class

```
def to_have_class(expected, timeout: nil)
```


Ensures the [Locator](./locator) points to an element with given CSS classes. This needs to be a full match
or using a relaxed regular expression.

**Usage**

```html
<div class='selected row' id='component'></div>
```

```python sync title=example_c16c6c567ee66b6d60de634c8a8a7c7c2b26f0e9ea8556e50a47d0c151935aa1.py
from playwright.sync_api import expect

locator = page.locator("#component")
expect(locator).to_have_class(re.compile(r"selected"))
expect(locator).to_have_class("selected row")

```

Note that if array is passed as an expected value, entire lists of elements can be asserted:

```python sync title=example_96b9affd86317eeafe4a419f6ec484d33cea4ee947297f44b7b4ebb373261f1d.py
from playwright.sync_api import expect

locator = page.locator("list > .component")
expect(locator).to_have_class(["component", "component selected", "component"])

```

## to_have_count

```
def to_have_count(count, timeout: nil)
```


Ensures the [Locator](./locator) resolves to an exact number of DOM nodes.

**Usage**

```python sync title=example_b3e3d5c7f2ff3a225541e57968953a77e32048daddaabe29ba84e93a1fcee84f.py
from playwright.sync_api import expect

locator = page.locator("list > .component")
expect(locator).to_have_count(3)

```

## to_have_css

```
def to_have_css(name, value, timeout: nil)
```


Ensures the [Locator](./locator) resolves to an element with the given computed CSS style.

**Usage**

```python sync title=example_12c52b928c1fac117b68573a914ce0ef9595becead95a0ee7c1f487ba1ad9010.py
from playwright.sync_api import expect

locator = page.get_by_role("button")
expect(locator).to_have_css("display", "flex")

```

## to_have_id

```
def to_have_id(id, timeout: nil)
```


Ensures the [Locator](./locator) points to an element with the given DOM Node ID.

**Usage**

```python sync title=example_5a4c0b1802f0751c2e1068d831ecd499b36a7860605050ba976c2290452bbd89.py
from playwright.sync_api import expect

locator = page.get_by_role("textbox")
expect(locator).to_have_id("lastname")

```

## to_have_js_property

```
def to_have_js_property(name, value, timeout: nil)
```


Ensures the [Locator](./locator) points to an element with given JavaScript property. Note that this property can be
of a primitive type as well as a plain serializable JavaScript object.

**Usage**

```python sync title=example_01cad4288f995d4b6253003eb0f4acb227e80553410cea0a8db0ab6927247d92.py
from playwright.sync_api import expect

locator = page.locator(".component")
expect(locator).to_have_js_property("loaded", True)

```

## to_have_text

```
def to_have_text(expected, ignoreCase: nil, timeout: nil, useInnerText: nil)
```


Ensures the [Locator](./locator) points to an element with the given text. You can use regular expressions for the value as well.

**Usage**

```python sync title=example_4ece81163bcb1edeccd7cea8f8c6158cf794c8ef88a673e8c5350a10eaa81542.py
import re
from playwright.sync_api import expect

locator = page.locator(".title")
expect(locator).to_have_text(re.compile(r"Welcome, Test User"))
expect(locator).to_have_text(re.compile(r"Welcome, .*"))

```

If you pass an array as an expected value, the expectations are:
1. Locator resolves to a list of elements.
1. The number of elements equals the number of expected values in the array.
1. Elements from the list have text matching expected array values, one by one, in order.

For example, consider the following list:

```html
<ul>
  <li>Text 1</li>
  <li>Text 2</li>
  <li>Text 3</li>
</ul>
```

Let's see how we can use the assertion:

```python sync title=example_2caa32069462b536399b1e7e9ade6388ab8b83912ae46ba293cf8ed241c48e85.py
from playwright.sync_api import expect

# ✓ Has the right items in the right order
expect(page.locator("ul > li")).to_have_text(["Text 1", "Text 2", "Text 3"])

# ✖ Wrong order
expect(page.locator("ul > li")).to_have_text(["Text 3", "Text 2", "Text 1"])

# ✖ Last item does not match
expect(page.locator("ul > li")).to_have_text(["Text 1", "Text 2", "Text"])

# ✖ Locator points to the outer list element, not to the list items
expect(page.locator("ul")).to_have_text(["Text 1", "Text 2", "Text 3"])

```

## to_have_value

```
def to_have_value(value, timeout: nil)
```


Ensures the [Locator](./locator) points to an element with the given input value. You can use regular expressions for the value as well.

**Usage**

```python sync title=example_84f23ac0426bebae60693613034771d70a26808dff53d1d476c3f5856346521a.py
import re
from playwright.sync_api import expect

locator = page.locator("input[type=number]")
expect(locator).to_have_value(re.compile(r"[0-9]"))

```

## to_have_values

```
def to_have_values(values, timeout: nil)
```


Ensures the [Locator](./locator) points to multi-select/combobox (i.e. a `select` with the `multiple` attribute) and the specified values are selected.

**Usage**

For example, given the following element:

```html
<select id="favorite-colors" multiple>
  <option value="R">Red</option>
  <option value="G">Green</option>
  <option value="B">Blue</option>
</select>
```

```python sync title=example_e5cce4bcdea914bbae14a3645b77f19c322038b0ef81d6ad2a1c9f5b0e21b1e9.py
import re
from playwright.sync_api import expect

locator = page.locator("id=favorite-colors")
locator.select_option(["R", "G"])
expect(locator).to_have_values([re.compile(r"R"), re.compile(r"G")])

```
