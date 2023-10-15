---
sidebar_position: 10
---

# Selectors


Selectors can be used to install custom selector engines. See [extensibility](https://playwright.dev/python/docs/extensibility) for more
information.

## register

```
def register(name, script: nil, contentScript: nil, path: nil)
```


Selectors must be registered before creating the page.

**Usage**

An example of registering selector engine that queries elements based on a tag name:

```python sync title=example_3e739d4f0e30e20a6a698e0e17605a841c35e65e75aa3c2642f8bfc368b33f9e.py
from playwright.sync_api import sync_playwright, Playwright

def run(playwright: Playwright):
    tag_selector = """
      {
          // Returns the first element matching given selector in the root's subtree.
          query(root, selector) {
              return root.querySelector(selector);
          },
          // Returns all elements matching given selector in the root's subtree.
          queryAll(root, selector) {
              return Array.from(root.querySelectorAll(selector));
          }
      }"""

    # Register the engine. Selectors will be prefixed with "tag=".
    playwright.selectors.register("tag", tag_selector)
    browser = playwright.chromium.launch()
    page = browser.new_page()
    page.set_content('<div><button>Click me</button></div>')

    # Use the selector prefixed with its name.
    button = page.locator('tag=button')
    # Combine it with built-in locators.
    page.locator('tag=div').get_by_text('Click me').click()
    # Can use it in any methods supporting selectors.
    button_count = page.locator('tag=button').count()
    print(button_count)
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```
