---
sidebar_position: 10
---

# Playwright


Playwright module provides a method to launch a browser instance. The following is a typical example of using Playwright
to drive automation:

```python sync title=example_6647e5a44b0440884026a6142606dfddad75ba1e643919b015457df4ed2e198f.py
from playwright.sync_api import sync_playwright, Playwright

def run(playwright: Playwright):
    chromium = playwright.chromium # or "firefox" or "webkit".
    browser = chromium.launch()
    page = browser.new_page()
    page.goto("http://example.com")
    # other actions...
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

## chromium


This object can be used to launch or connect to Chromium, returning instances of [Browser](./browser).

## devices


Returns a dictionary of devices to be used with [Browser#new_context](./browser#new_context) or [Browser#new_page](./browser#new_page).

```python sync title=example_14d627977a4ad16a605ec5472d768a3324812fa8e7c57685561408fa6601e352.py
from playwright.sync_api import sync_playwright, Playwright

def run(playwright: Playwright):
    webkit = playwright.webkit
    iphone = playwright.devices["iPhone 6"]
    browser = webkit.launch()
    context = browser.new_context(**iphone)
    page = context.new_page()
    page.goto("http://example.com")
    # other actions...
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

## firefox


This object can be used to launch or connect to Firefox, returning instances of [Browser](./browser).

## selectors


Selectors can be used to install custom selector engines. See
[extensibility](https://playwright.dev/python/docs/extensibility) for more information.

## webkit


This object can be used to launch or connect to WebKit, returning instances of [Browser](./browser).
