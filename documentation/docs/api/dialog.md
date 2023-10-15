---
sidebar_position: 10
---

# Dialog


[Dialog](./dialog) objects are dispatched by page via the [`event: Page.dialog`] event.

An example of using [Dialog](./dialog) class:

```python sync title=example_a7dcc75b7aa5544237ac3a964e9196d0445308864d3ce820f8cb8396f687b04a.py
from playwright.sync_api import sync_playwright, Playwright

def handle_dialog(dialog):
    print(dialog.message)
    dialog.dismiss()

def run(playwright: Playwright):
    chromium = playwright.chromium
    browser = chromium.launch()
    page = browser.new_page()
    page.on("dialog", handle_dialog)
    page.evaluate("alert('1')")
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

**NOTE**: Dialogs are dismissed automatically, unless there is a [`event: Page.dialog`] listener.
When listener is present, it **must** either [Dialog#accept](./dialog#accept) or [Dialog#dismiss](./dialog#dismiss) the dialog - otherwise the page will [freeze](https://developer.mozilla.org/en-US/docs/Web/JavaScript/EventLoop#never_blocking) waiting for the dialog, and actions like click will never finish.

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

## page

```
def page
```


The page that initiated this dialog, if available.

## type

```
def type
```


Returns dialog's type, can be one of `alert`, `beforeunload`, `confirm` or `prompt`.
