---
sidebar_position: 10
---

# Playwright

Playwright module provides a method to launch a browser instance. The following is a typical example of using
Playwright to drive automation:

```py title=example_f16b97a99916b8c3dd5d17be75f2456d2e24138ddcef9224be19be9217f06900.py
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    chromium = playwright.chromium # or "firefox" or "webkit".
    browser = await chromium.launch()
    page = await browser.new_page()
    await page.goto("http://example.com")
    # other actions...
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

```py title=example_de51b112ac2f009edc92122d874f024ca41676465fdb51adf3a1666399f3b728.py
from playwright.sync_api import sync_playwright

def run(playwright):
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

```py title=example_424229226d9940733b1ba360b13a618963ab827cd0e4f6114f5fe958fbf5cb3f.py
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    webkit = playwright.webkit
    iphone = playwright.devices["iPhone 6"]
    browser = await webkit.launch()
    context = await browser.new_context(**iphone)
    page = await context.new_page()
    await page.goto("http://example.com")
    # other actions...
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

```py title=example_cd66fb063d6e600458c958cafa8fdc8e6654f2b43750a4ce590e884553127c8a.py
from playwright.sync_api import sync_playwright

def run(playwright):
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

Selectors can be used to install custom selector engines. See [extensibility](https://playwright.dev/python/docs/extensibility) for more
information.

## webkit

This object can be used to launch or connect to WebKit, returning instances of [Browser](./browser).
