# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_a455277e025b97b226ec675888cebfd13b06e296accc56892e5c4ed164cfc317 (Clock#pause_at)

```
# Initialize clock with some time before the test time and let the page load
# naturally. `Date.now` will progress as the timers fire.
page.clock.install(time=datetime.datetime(2024, 12, 10, 8, 0, 0))
page.goto("http://localhost:3333")
page.clock.pause_at(datetime.datetime(2024, 12, 10, 10, 0, 0))

```

### example_472d69650f95db85a03c0badae236103133ca72a1e046201f323781424707f68 (Locator#dispatch_event)

```
data_transfer = page.evaluate_handle("new DataTransfer()")
locator.dispatch_event("#source", "dragstart", {"dataTransfer": data_transfer})

```

### example_66fc739781815cb05dad77527d405e72e1cd6c2b923bd48ef47e83078363fb26 (Locator#or)

```
new_email = page.get_by_role("button", name="New")
dialog = page.get_by_text("Confirm security settings")
expect(new_email.or_(dialog).first).to_be_visible()
if (dialog.is_visible()):
  page.get_by_role("button", name="Dismiss").click()
new_email.click()

```

### example_7778d4f89215025560ecd192d60831f898331a0f339607a657c038207951e473 (LocatorAssertions#to_have_class)

```
from playwright.sync_api import expect

locator = page.locator("#component")
expect(locator).to_have_class(re.compile(r"(^|\\s)selected(\\s|$)"))
expect(locator).to_have_class("middle selected row")

```
