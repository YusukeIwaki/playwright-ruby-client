---
sidebar_position: 10
---

# Tracing

API for collecting and saving Playwright traces. Playwright traces can be opened using the Playwright CLI after
Playwright script runs.

Start with specifying the folder traces will be stored in:

```ruby
browser.new_page do |page|
  context = page.context

  context.tracing.start(screenshots: true, snapshots: true)
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
context = page.context

context.tracing.start(name: 'trace', screenshots: true, snapshots: true)
page.goto('https://playwright.dev')
context.tracing.stop(path: 'trace.zip')
```



## stop

```
def stop(path: nil)
```

Stop tracing.
