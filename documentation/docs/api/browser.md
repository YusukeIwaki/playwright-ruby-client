---
sidebar_position: 10
---

# Browser

- extends: [EventEmitter]

A Browser is created via [BrowserType#launch](./browser_type#launch). An example of using a [Browser](./browser) to create a [Page](./page):

```ruby
firefox = playwright.firefox
browser = firefox.launch
begin
  page = browser.new_page
  page.goto("https://example.com")
ensure
  browser.close
end
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

```ruby
playwright.webkit.launch do |browser|
  puts browser.contexts.count # => 0
  context = browser.new_context
  puts browser.contexts.count # => 1
end
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

```ruby
playwright.firefox.launch do |browser| # or "chromium.launch" or "webkit.launch".
  # create a new incognito browser context.
  context = browser.new_context

  # create a new page in a pristine context.
  page = context.new_page()
  page.goto("https://example.com")
end
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

```ruby
browser.start_tracing(page: page, path: "trace.json")
begin
  page.goto("https://www.google.com")
ensure
  browser.stop_tracing
end
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
