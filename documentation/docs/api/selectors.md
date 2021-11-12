---
sidebar_position: 10
---

# Selectors

Selectors can be used to install custom selector engines. See [Working with selectors](https://playwright.dev/python/docs/selectors) for more
information.

## register

```
def register(name, contentScript: nil, path: nil, script: nil)
```

An example of registering selector engine that queries elements based on a tag name:

```python sync title=example_a3760c848fe1796fedc319aa8ea6c85d3cf5ed986eba8efbdab821cafab64b0d.py
from playwright.sync_api import sync_playwright

def run(playwright):
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
    # Combine it with other selector engines.
    page.click('tag=div >> text="Click me"')
    # Can use it in any methods supporting selectors.
    button_count = page.locator('tag=button').count()
    print(button_count)
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```


