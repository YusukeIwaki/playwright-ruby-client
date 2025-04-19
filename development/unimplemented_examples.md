# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_a596f37c41d76277b59ed7eb46969c178c89770d0da91bdff20f36d438aa32cd (LocatorAssertions#to_have_class)

```
from playwright.sync_api import expect

locator = page.locator("#component")
expect(locator).to_have_class("middle selected row")
expect(locator).to_have_class(re.compile(r"(^|\\s)selected(\\s|$)"))

```
