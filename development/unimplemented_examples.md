# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_397d9396d0ac4796aa46eec83d1527a664de97335868540229391d545cf6d9d7 (Locator#evaluate)

```
result = page.get_by_testid("myId").evaluate("(element, [x, y]) => element.textContent + ' ' + x * y", [7, 8])
print(result) # prints "myId text 56"

```

### example_d4669942897f42b24d218b847e98fc5490f69a52e6c72d278a2781bcba67245f (LocatorAssertions#to_contain_class)

```
from playwright.sync_api import expect

locator = page.locator(".list > .component")
await expect(locator).to_contain_class(["inactive", "active", "inactive"])

```

### example_a596f37c41d76277b59ed7eb46969c178c89770d0da91bdff20f36d438aa32cd (LocatorAssertions#to_have_class)

```
from playwright.sync_api import expect

locator = page.locator("#component")
expect(locator).to_have_class("middle selected row")
expect(locator).to_have_class(re.compile(r"(^|\\s)selected(\\s|$)"))

```

### example_aa26b270cde98bc57b4e98f69ef26ca30ac89d719799f52940ef4e8b9fb01bcd (LocatorAssertions#to_have_class)

```
from playwright.sync_api import expect

locator = page.locator(".list > .component")
expect(locator).to_have_class(["component", "component selected", "component"])

```
