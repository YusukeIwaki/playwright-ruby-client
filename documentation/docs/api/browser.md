---
sidebar_position: 10
---

# Browser

- extends: [EventEmitter]

A Browser is created via [BrowserType#launch](./browser_type#launch). An example of using a [Browser](./browser) to create a [Page](./page):

```py title=example_f5c9c6dc93c87c0b6ac6dbb692a189539f8252930a4966ebc3a1dd68dad75e3c.py
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    firefox = playwright.firefox
    browser = await firefox.launch()
    page = await browser.new_page()
    await page.goto("https://example.com")
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

```py title=example_a094ff37f6218e68d45cf46f74756adaca14d796014d8aa483537204eac0c14c.py
from playwright.sync_api import sync_playwright

def run(playwright):
    firefox = playwright.firefox
    browser = firefox.launch()
    page = browser.new_page()
    page.goto("https://example.com")
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```



## browser_type

```
def browser_type
```

Get the browser type (chromium, firefox or webkit) that the browser belongs to.

## close

```
def close
```

In case this browser is obtained using [BrowserType#launch](./browser_type#launch), closes the browser and all of its pages (if
any were opened).

In case this browser is connected to, clears all created contexts belonging to this browser and disconnects from
the browser server.

**NOTE** This is similar to force quitting the browser. Therefore, you should call [BrowserContext#close](./browser_context#close)
on any [BrowserContext](./browser_context)'s you explicitly created earlier with [Browser#new_context](./browser#new_context) **before** calling
[Browser#close](./browser#close).

The [Browser](./browser) object itself is considered to be disposed and cannot be used anymore.

## contexts

```
def contexts
```

Returns an array of all open browser contexts. In a newly created browser, this will return zero browser contexts.

**Usage**

```py title=example_5dcbbaa56b46c70c697229942fb3cc61129d598550a123625d4f1ec5f9e844a9.py
browser = await pw.webkit.launch()
print(len(browser.contexts())) # prints `0`
context = await browser.new_context()
print(len(browser.contexts())) # prints `1`

```

```py title=example_31ccf8b183cccf81e84df3d50e2872e4aa71e6dc1a13270da4ac0da8ed27f81f.py
browser = pw.webkit.launch()
print(len(browser.contexts())) # prints `0`
context = browser.new_context()
print(len(browser.contexts())) # prints `1`

```



## connected?

```
def connected?
```

Indicates that the browser is connected.

## new_browser_cdp_session

```
def new_browser_cdp_session
```

**NOTE** CDP Sessions are only supported on Chromium-based browsers.

Returns the newly created browser session.

## new_context

```
def new_context(
      acceptDownloads: nil,
      baseURL: nil,
      bypassCSP: nil,
      colorScheme: nil,
      deviceScaleFactor: nil,
      extraHTTPHeaders: nil,
      forcedColors: nil,
      geolocation: nil,
      hasTouch: nil,
      httpCredentials: nil,
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
      storageState: nil,
      strictSelectors: nil,
      timezoneId: nil,
      userAgent: nil,
      viewport: nil,
      &block)
```

Creates a new browser context. It won't share cookies/cache with other browser contexts.

**NOTE** If directly using this method to create [BrowserContext](./browser_context)s, it is best practice to explicitly close the
returned context via [BrowserContext#close](./browser_context#close) when your code is done with the [BrowserContext](./browser_context), and before
calling [Browser#close](./browser#close). This will ensure the `context` is closed gracefully and any artifacts—like HARs
and videos—are fully flushed and saved.

**Usage**

```py title=example_86f075e015bf0da085ea967315d9b43f9b3fa455bb5a5af877e8b1086eb11ed0.py
browser = await playwright.firefox.launch() # or "chromium" or "webkit".
# create a new incognito browser context.
context = await browser.new_context()
# create a new page in a pristine context.
page = await context.new_page()
await page.goto("https://example.com")

# gracefully close up everything
await context.close()
await browser.close()

```

```py title=example_9f9d052b43e67f65a6176ab4e169e57e2a2de518e66711b8d268601139aa9fb8.py
browser = playwright.firefox.launch() # or "chromium" or "webkit".
# create a new incognito browser context.
context = browser.new_context()
# create a new page in a pristine context.
page = context.new_page()
page.goto("https://example.com")

# gracefully close up everything
context.close()
browser.close()

```



## new_page

```
def new_page(
      acceptDownloads: nil,
      baseURL: nil,
      bypassCSP: nil,
      colorScheme: nil,
      deviceScaleFactor: nil,
      extraHTTPHeaders: nil,
      forcedColors: nil,
      geolocation: nil,
      hasTouch: nil,
      httpCredentials: nil,
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
      storageState: nil,
      strictSelectors: nil,
      timezoneId: nil,
      userAgent: nil,
      viewport: nil,
      &block)
```

Creates a new page in a new browser context. Closing this page will close the context as well.

This is a convenience API that should only be used for the single-page scenarios and short snippets. Production
code and testing frameworks should explicitly create [Browser#new_context](./browser#new_context) followed by the
[BrowserContext#new_page](./browser_context#new_page) to control their exact life times.

## start_tracing

```
def start_tracing(page: nil, categories: nil, path: nil, screenshots: nil)
```

**NOTE** This API controls
[Chromium Tracing](https://www.chromium.org/developers/how-tos/trace-event-profiling-tool) which is a low-level
chromium-specific debugging tool. API to control [Playwright Tracing](https://playwright.dev/python/docs/trace-viewer) could be found
[here](./tracing).

You can use [Browser#start_tracing](./browser#start_tracing) and [Browser#stop_tracing](./browser#stop_tracing) to create a trace file that can be
opened in Chrome DevTools performance panel.

**Usage**

```py title=example_aa372513cba86d24a8c95babf42c8545f9df9894c1f4986d119fb517290e27d8.py
await browser.start_tracing(page, path="trace.json")
await page.goto("https://www.google.com")
await browser.stop_tracing()

```

```py title=example_1498031e3bdf580457eac0cb8d2b803fe6bcd25029a6be0412d385954a0c5090.py
browser.start_tracing(page, path="trace.json")
page.goto("https://www.google.com")
browser.stop_tracing()

```


## stop_tracing

```
def stop_tracing
```

**NOTE** This API controls
[Chromium Tracing](https://www.chromium.org/developers/how-tos/trace-event-profiling-tool) which is a low-level
chromium-specific debugging tool. API to control [Playwright Tracing](https://playwright.dev/python/docs/trace-viewer) could be found
[here](./tracing).

Returns the buffer with trace data.

## version

```
def version
```

Returns the browser version.
