---
sidebar_position: 10
---

# Tracing

API for collecting and saving Playwright traces. Playwright traces can be opened in [Trace Viewer](https://playwright.dev/python/docs/trace-viewer)
after Playwright script runs.

Start recording a trace before performing actions. At the end, stop tracing and save it to a file.

```ruby
browser.new_context do |context|
  context.tracing.start(screenshots: true, snapshots: true)
  page = context.new_page
  page.goto('https://playwright.dev')
  context.tracing.stop(path: 'trace.zip')
end
```



## start

```
def start(name: nil, screenshots: nil, snapshots: nil)
```

Start tracing.

```ruby
context.tracing.start(name: 'trace', screenshots: true, snapshots: true)
page = context.new_page
page.goto('https://playwright.dev')
context.tracing.stop(path: 'trace.zip')
```



## stop

```
def stop(path: nil)
```

Stop tracing.
