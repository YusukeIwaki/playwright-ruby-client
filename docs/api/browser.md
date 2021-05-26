---
sidebar_position: 10
---

# Browser

- extends: [EventEmitter]

A Browser is created via [BrowserType#launch](./browser_type#launch). An example of using a [Browser](./browser) to create a [Page](./page):

```python sync title=example_b8acc529feb6c35ab828780a127d7bf2c079dc7f2847ef251c4c1a33b4197bf9.py
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



## close

```
def close
```

In case this browser is obtained using [BrowserType#launch](./browser_type#launch), closes the browser and all of its pages (if any
were opened).

In case this browser is connected to, clears all created contexts belonging to this browser and disconnects from the
browser server.

The [Browser](./browser) object itself is considered to be disposed and cannot be used anymore.

## contexts

```
def contexts
```

Returns an array of all open browser contexts. In a newly created browser, this will return zero browser contexts.

```python sync title=example_7f9edd4a42641957d48081449ceb3c54829485d152db1cc82a82f1f21191b90c.py
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

## new_context

```
def new_context(
      acceptDownloads: nil,
      bypassCSP: nil,
      colorScheme: nil,
      deviceScaleFactor: nil,
      extraHTTPHeaders: nil,
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
      record_har_omit_content: nil,
      record_har_path: nil,
      record_video_dir: nil,
      record_video_size: nil,
      screen: nil,
      storageState: nil,
      timezoneId: nil,
      userAgent: nil,
      viewport: nil,
      &block)
```

Creates a new browser context. It won't share cookies/cache with other browser contexts.

```python sync title=example_3661a62dd097b41417b066df731db5f80905ccb40be870c04c44980ee7425f56.py
browser = playwright.firefox.launch() # or "chromium" or "webkit".
# create a new incognito browser context.
context = browser.new_context()
# create a new page in a pristine context.
page = context.new_page()
page.goto("https://example.com")

```



## new_page

```
def new_page(
      acceptDownloads: nil,
      bypassCSP: nil,
      colorScheme: nil,
      deviceScaleFactor: nil,
      extraHTTPHeaders: nil,
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
      record_har_omit_content: nil,
      record_har_path: nil,
      record_video_dir: nil,
      record_video_size: nil,
      screen: nil,
      storageState: nil,
      timezoneId: nil,
      userAgent: nil,
      viewport: nil)
```

Creates a new page in a new browser context. Closing this page will close the context as well.

This is a convenience API that should only be used for the single-page scenarios and short snippets. Production code and
testing frameworks should explicitly create [Browser#new_context](./browser#new_context) followed by the
[BrowserContext#new_page](./browser_context#new_page) to control their exact life times.

## start_tracing

```
def start_tracing(page: nil, categories: nil, path: nil, screenshots: nil)
```

> NOTE: Tracing is only supported on Chromium-based browsers.

You can use [Browser#start_tracing](./browser#start_tracing) and [Browser#stop_tracing](./browser#stop_tracing) to create a trace file that can be
opened in Chrome DevTools performance panel.

```python sync title=example_5a1282084821fd9127ef5ca54bdda63cdff46564f3cb20e347317dee260d33b3.py
browser.start_tracing(page, path="trace.json")
page.goto("https://www.google.com")
browser.stop_tracing()

```


## stop_tracing

```
def stop_tracing
```

> NOTE: Tracing is only supported on Chromium-based browsers.

Returns the buffer with trace data.

## version

```
def version
```

Returns the browser version.
