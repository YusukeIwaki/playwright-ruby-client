---
sidebar_position: 10
---

# Dialog

[Dialog](./dialog) objects are dispatched by page via the [`event: Page.dialog`] event.

An example of using [Dialog](./dialog) class:

```py title=example_7fb5b2cb8d04a1da91dc6f9c3ecf8c6cdbe0c605483cf46bbcca8bff5850ec95.py
import asyncio
from playwright.async_api import async_playwright

async def handle_dialog(dialog):
    print(dialog.message)
    await dialog.dismiss()

async def run(playwright):
    chromium = playwright.chromium
    browser = await chromium.launch()
    page = await browser.new_page()
    page.on("dialog", handle_dialog)
    page.evaluate("alert('1')")
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

```py title=example_e0a400dda0b0b538703f892c5f970ba129b2144c40fbbf1a63dfa74d2a52df75.py
from playwright.sync_api import sync_playwright

def handle_dialog(dialog):
    print(dialog.message)
    dialog.dismiss()

def run(playwright):
    chromium = playwright.chromium
    browser = chromium.launch()
    page = browser.new_page()
    page.on("dialog", handle_dialog)
    page.evaluate("alert('1')")
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

**NOTE** Dialogs are dismissed automatically, unless there is a [`event: Page.dialog`] listener. When listener is
present, it **must** either [Dialog#accept](./dialog#accept) or [Dialog#dismiss](./dialog#dismiss) the dialog - otherwise the page
will [freeze](https://developer.mozilla.org/en-US/docs/Web/JavaScript/EventLoop#never_blocking) waiting for the
dialog, and actions like click will never finish.

## accept

```
def accept(promptText: nil)
```

Returns when the dialog has been accepted.

## default_value

```
def default_value
```

If dialog is prompt, returns default prompt value. Otherwise, returns empty string.

## dismiss

```
def dismiss
```

Returns when the dialog has been dismissed.

## message

```
def message
```

A message displayed in the dialog.

## type

```
def type
```

Returns dialog's type, can be one of `alert`, `beforeunload`, `confirm` or `prompt`.
