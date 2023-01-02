---
sidebar_position: 10
---

# BrowserType

BrowserType provides methods to launch a specific browser instance or connect to an existing one. The following is
a typical example of using Playwright to drive automation:

```py title=example_b8af68101a9c3416ce98d4a9e7dc7dbffbf2942c9a3302a5c9de83949c4f415d.py
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    chromium = playwright.chromium
    browser = await chromium.launch()
    page = await browser.new_page()
    await page.goto("https://example.com")
    # other actions...
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

```py title=example_3129411f9b39671407a5ef7b3166b79c9a276343aeb2cddcb32a66d0dfe98b6a.py
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

This method attaches Playwright to an existing browser instance using the Chrome DevTools Protocol.

The default browser context is accessible via [Browser#contexts](./browser#contexts).

**NOTE** Connecting over the Chrome DevTools Protocol is only supported for Chromium-based browsers.

**Usage**

```py title=example_e3394274245ab8a4232580a495133b7c8ffe4ff115de15beed2c172d0c529d58.py
browser = await playwright.chromium.connect_over_cdp("http://localhost:9222")
default_context = browser.contexts[0]
page = default_context.pages[0]

```

```py title=example_d4cd91a13c9c84ee6e9768c603751b6386f0b46a15be0526e206196423a4abe4.py
browser = playwright.chromium.connect_over_cdp("http://localhost:9222")
default_context = browser.contexts[0]
page = default_context.pages[0]

```



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
      tracesDir: nil,
      &block)
```

Returns the browser instance.

**Usage**

You can use `ignoreDefaultArgs` to filter out `--mute-audio` from default arguments:

```py title=example_711634d1fa2c081d640b6e7a900b05c693ce5561753cfb1c1987aeb22db1654a.py
browser = await playwright.chromium.launch( # or "firefox" or "webkit".
    ignore_default_args=["--mute-audio"]
)

```

```py title=example_6556c029d76ac60be292651bed6372b0512d228b6681172d26d388fbe2700af2.py
browser = playwright.chromium.launch( # or "firefox" or "webkit".
    ignore_default_args=["--mute-audio"]
)

```

> **Chromium-only** Playwright can also be used to control the Google Chrome or Microsoft Edge browsers, but it
works best with the version of Chromium it is bundled with. There is no guarantee it will work with any other
version. Use `executablePath` option with extreme caution.
>
> If Google Chrome (rather than Chromium) is preferred, a
[Chrome Canary](https://www.google.com/chrome/browser/canary.html) or
[Dev Channel](https://www.chromium.org/getting-involved/dev-channel) build is suggested.
>
> Stock browsers like Google Chrome and Microsoft Edge are suitable for tests that require proprietary media codecs
for video playback. See
[this article](https://www.howtogeek.com/202825/what%E2%80%99s-the-difference-between-chromium-and-chrome/) for
other differences between Chromium and Chrome.
[This article](https://chromium.googlesource.com/chromium/src/+/lkgr/docs/chromium_browser_vs_google_chrome.md)
describes some differences for Linux users.

## launch_persistent_context

```
def launch_persistent_context(
      userDataDir,
      acceptDownloads: nil,
      args: nil,
      baseURL: nil,
      bypassCSP: nil,
      channel: nil,
      chromiumSandbox: nil,
      colorScheme: nil,
      deviceScaleFactor: nil,
      devtools: nil,
      downloadsPath: nil,
      env: nil,
      executablePath: nil,
      extraHTTPHeaders: nil,
      forcedColors: nil,
      geolocation: nil,
      handleSIGHUP: nil,
      handleSIGINT: nil,
      handleSIGTERM: nil,
      hasTouch: nil,
      headless: nil,
      httpCredentials: nil,
      ignoreDefaultArgs: nil,
      ignoreHTTPSErrors: nil,
      isMobile: nil,
      javaScriptEnabled: nil,
      locale: nil,
      noViewport: nil,
      offline: nil,
      permissions: nil,
      proxy: nil,
      record_har_content: nil,
      record_har_mode: nil,
      record_har_omit_content: nil,
      record_har_path: nil,
      record_har_url_filter: nil,
      record_video_dir: nil,
      record_video_size: nil,
      reducedMotion: nil,
      screen: nil,
      serviceWorkers: nil,
      slowMo: nil,
      strictSelectors: nil,
      timeout: nil,
      timezoneId: nil,
      tracesDir: nil,
      userAgent: nil,
      viewport: nil,
      &block)
```

Returns the persistent browser context instance.

Launches browser that uses persistent storage located at `userDataDir` and returns the only context. Closing this
context will automatically close the browser.

## name

```
def name
```

Returns browser name. For example: `'chromium'`, `'webkit'` or `'firefox'`.
