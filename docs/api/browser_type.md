---
sidebar_position: 10
---

# BrowserType

BrowserType provides methods to launch a specific browser instance or connect to an existing one. The following is a
typical example of using Playwright to drive automation:

```python sync title=example_554dfa8c71a3e87116c6f226d58cdb57d7993dd5df94e22c8fc74c0f83ef7b50.py
from playwright.sync_api import sync_playwright

def run(playwright):
    chromium = playwright.chromium
    browser = chromium.launch()
    page = browser.new_page()
    page.goto("https://example.com")
    # other actions...
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```



## connect_over_cdp

```
def connect_over_cdp(
      endpointURL,
      headers: nil,
      slowMo: nil,
      timeout: nil,
      &block)
```

This methods attaches Playwright to an existing browser instance using the Chrome DevTools Protocol.

The default browser context is accessible via [Browser#contexts](./browser#contexts).

> NOTE: Connecting over the Chrome DevTools Protocol is only supported for Chromium-based browsers.

## executable_path

```
def executable_path
```

A path where Playwright expects to find a bundled browser executable.

## launch

```
def launch(
      args: nil,
      channel: nil,
      chromiumSandbox: nil,
      devtools: nil,
      downloadsPath: nil,
      env: nil,
      executablePath: nil,
      firefoxUserPrefs: nil,
      handleSIGHUP: nil,
      handleSIGINT: nil,
      handleSIGTERM: nil,
      headless: nil,
      ignoreDefaultArgs: nil,
      proxy: nil,
      slowMo: nil,
      timeout: nil,
      traceDir: nil,
      &block)
```

Returns the browser instance.

You can use `ignoreDefaultArgs` to filter out `--mute-audio` from default arguments:

```python sync title=example_90d6ec37772ce92e29e8942ec516d4859264d02aa9b8b8e6f3a773318f567f90.py
browser = playwright.chromium.launch( # or "firefox" or "webkit".
    ignore_default_args=["--mute-audio"]
)

```

> **Chromium-only** Playwright can also be used to control the Google Chrome or Microsoft Edge browsers, but it works
best with the version of Chromium it is bundled with. There is no guarantee it will work with any other version. Use
`executablePath` option with extreme caution.
>
> If Google Chrome (rather than Chromium) is preferred, a
[Chrome Canary](https://www.google.com/chrome/browser/canary.html) or
[Dev Channel](https://www.chromium.org/getting-involved/dev-channel) build is suggested.
>
> Stock browsers like Google Chrome and Microsoft Edge are suitable for tests that require proprietary media codecs for
video playback. See
[this article](https://www.howtogeek.com/202825/what%E2%80%99s-the-difference-between-chromium-and-chrome/) for other
differences between Chromium and Chrome.
[This article](https://chromium.googlesource.com/chromium/src/+/lkgr/docs/chromium_browser_vs_google_chrome.md)
describes some differences for Linux users.

## name

```
def name
```

Returns browser name. For example: `'chromium'`, `'webkit'` or `'firefox'`.
