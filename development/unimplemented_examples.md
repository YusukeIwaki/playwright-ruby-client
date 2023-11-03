# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_eff0600f575bf375d7372280ca8e6dfc51d927ced49fbcb75408c894b9e0564e (LocatorAssertions)

```
from playwright.sync_api import Page, expect

def test_status_becomes_submitted(page: Page) -> None:
    # ..
    page.get_by_role("button").click()
    expect(page.locator(".status")).to_have_text("Submitted")

```

### example_781b6f44dd462fc3753b3e48d6888f2ef4d0794253bf6ffb4c42c76f5ec3b454 (LocatorAssertions#to_be_attached)

```
expect(page.get_by_text("Hidden text")).to_be_attached()

```

### example_00a58b66eec12973ab87c0ce5004126aa1f1af5a971a9e89638669f729bbb1b6 (LocatorAssertions#to_be_checked)

```
from playwright.sync_api import expect

locator = page.get_by_label("Subscribe to newsletter")
expect(locator).to_be_checked()

```

### example_fc3052bc38e6c1968f23f9185bda7f06478af4719ce96f6a49878ea7e72c9a82 (LocatorAssertions#to_be_disabled)

```
from playwright.sync_api import expect

locator = page.locator("button.submit")
expect(locator).to_be_disabled()

```

### example_a42b1e97cd0899ccd72bc4b74ab8f57c549814ca5b6d1bb912c870153d6d3f8d (LocatorAssertions#to_be_editable)

```
from playwright.sync_api import expect

locator = page.get_by_role("textbox")
expect(locator).to_be_editable()

```

### example_1fb5a7ee389401cf5a6fb3ba90c5b58c42c93d43aa5e4e34d99a5c6265ce0b35 (LocatorAssertions#to_be_empty)

```
from playwright.sync_api import expect

locator = page.locator("div.warning")
expect(locator).to_be_empty()

```

### example_0389b23d34a430ee418fd2138f9b8269df20fb6595f2618400e3d53b4f344a75 (LocatorAssertions#to_be_enabled)

```
from playwright.sync_api import expect

locator = page.locator("button.submit")
expect(locator).to_be_enabled()

```

### example_9fc7c2560e0a8117bc4ba14d6133a3d9c66cf6461c29c5a74fe132dea8bd8d63 (LocatorAssertions#to_be_focused)

```
from playwright.sync_api import expect

locator = page.get_by_role("textbox")
expect(locator).to_be_focused()

```

### example_55b9181de8eb71936b5e5289631fca33d2100f47f4c4e832d92c23f923779c62 (LocatorAssertions#to_be_hidden)

```
from playwright.sync_api import expect

locator = page.locator('.my-element')
expect(locator).to_be_hidden()

```

### example_7d5d5657528a32a8fb24cbf30e7bb3154cdf4c426e84e40131445a38fe8df2ee (LocatorAssertions#to_be_in_viewport)

```
from playwright.sync_api import expect

locator = page.get_by_role("button")
# Make sure at least some part of element intersects viewport.
expect(locator).to_be_in_viewport()
# Make sure element is fully outside of viewport.
expect(locator).not_to_be_in_viewport()
# Make sure that at least half of the element intersects viewport.
expect(locator).to_be_in_viewport(ratio=0.5)

```

### example_6c79cc47344706b2e463621209ddd4006848d57eb2074fb7467213756fb14752 (LocatorAssertions#to_be_visible)

```
# A specific element is visible.
expect(page.get_by_text("Welcome")).to_be_visible()

# At least one item in the list is visible.
expect(page.get_by_test_id("todo-item").first).to_be_visible()

# At least one of the two elements is visible, possibly both.
expect(
    page.get_by_role("button", name="Sign in")
    .or_(page.get_by_role("button", name="Sign up"))
    .first
).to_be_visible()

```

### example_3553a48e2a15853f4869604ef20dae14952c16abfa0570b8f02e9b74e3d84faa (LocatorAssertions#to_contain_text)

```
import re
from playwright.sync_api import expect

locator = page.locator('.title')
expect(locator).to_contain_text("substring")
expect(locator).to_contain_text(re.compile(r"\d messages"))

```

### example_fb3cde55b658aefe2e54f93e5b78d26f25cd376eaa469434631af079bb8d8a62 (LocatorAssertions#to_contain_text)

```
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

### example_709faaa456b4775109b1fbaca74a86ac5107af5e4801ea07cb690942f1d37f88 (LocatorAssertions#to_have_attribute)

```
from playwright.sync_api import expect

locator = page.locator("input")
expect(locator).to_have_attribute("type", "text")

```

### example_c16c6c567ee66b6d60de634c8a8a7c7c2b26f0e9ea8556e50a47d0c151935aa1 (LocatorAssertions#to_have_class)

```
from playwright.sync_api import expect

locator = page.locator("#component")
expect(locator).to_have_class(re.compile(r"selected"))
expect(locator).to_have_class("selected row")

```

### example_96b9affd86317eeafe4a419f6ec484d33cea4ee947297f44b7b4ebb373261f1d (LocatorAssertions#to_have_class)

```
from playwright.sync_api import expect

locator = page.locator("list > .component")
expect(locator).to_have_class(["component", "component selected", "component"])

```

### example_b3e3d5c7f2ff3a225541e57968953a77e32048daddaabe29ba84e93a1fcee84f (LocatorAssertions#to_have_count)

```
from playwright.sync_api import expect

locator = page.locator("list > .component")
expect(locator).to_have_count(3)

```

### example_12c52b928c1fac117b68573a914ce0ef9595becead95a0ee7c1f487ba1ad9010 (LocatorAssertions#to_have_css)

```
from playwright.sync_api import expect

locator = page.get_by_role("button")
expect(locator).to_have_css("display", "flex")

```

### example_5a4c0b1802f0751c2e1068d831ecd499b36a7860605050ba976c2290452bbd89 (LocatorAssertions#to_have_id)

```
from playwright.sync_api import expect

locator = page.get_by_role("textbox")
expect(locator).to_have_id("lastname")

```

### example_01cad4288f995d4b6253003eb0f4acb227e80553410cea0a8db0ab6927247d92 (LocatorAssertions#to_have_js_property)

```
from playwright.sync_api import expect

locator = page.locator(".component")
expect(locator).to_have_js_property("loaded", True)

```

### example_4ece81163bcb1edeccd7cea8f8c6158cf794c8ef88a673e8c5350a10eaa81542 (LocatorAssertions#to_have_text)

```
import re
from playwright.sync_api import expect

locator = page.locator(".title")
expect(locator).to_have_text(re.compile(r"Welcome, Test User"))
expect(locator).to_have_text(re.compile(r"Welcome, .*"))

```

### example_2caa32069462b536399b1e7e9ade6388ab8b83912ae46ba293cf8ed241c48e85 (LocatorAssertions#to_have_text)

```
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

### example_84f23ac0426bebae60693613034771d70a26808dff53d1d476c3f5856346521a (LocatorAssertions#to_have_value)

```
import re
from playwright.sync_api import expect

locator = page.locator("input[type=number]")
expect(locator).to_have_value(re.compile(r"[0-9]"))

```

### example_e5cce4bcdea914bbae14a3645b77f19c322038b0ef81d6ad2a1c9f5b0e21b1e9 (LocatorAssertions#to_have_values)

```
import re
from playwright.sync_api import expect

locator = page.locator("id=favorite-colors")
locator.select_option(["R", "G"])
expect(locator).to_have_values([re.compile(r"R"), re.compile(r"G")])

```
