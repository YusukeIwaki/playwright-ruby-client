---
sidebar_position: 10
---

# Tracing


API for collecting and saving Playwright traces. Playwright traces can be opened in [Trace Viewer](https://playwright.dev/python/docs/trace-viewer) after Playwright script runs.

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
def start(
      name: nil,
      screenshots: nil,
      snapshots: nil,
      sources: nil,
      title: nil)
```


Start tracing.

**Usage**

```python sync title=example_c05d76146085d8afc519158aef621696f3458b669479d57b4560355c6b0c5ef7.py
context.tracing.start(screenshots=True, snapshots=True)
page = context.new_page()
page.goto("https://playwright.dev")
context.tracing.stop(path = "trace.zip")

```

## start_chunk

```
def start_chunk(name: nil, title: nil)
```


Start a new trace chunk. If you'd like to record multiple traces on the same [BrowserContext](./browser_context), use [Tracing#start](./tracing#start) once, and then create multiple trace chunks with [Tracing#start_chunk](./tracing#start_chunk) and [Tracing#stop_chunk](./tracing#stop_chunk).

**Usage**

```python sync title=example_c74a3f913c302bc9bf81146db28832bdfe33ab7721f1343efb1e207bb070abce.py
context.tracing.start(screenshots=True, snapshots=True)
page = context.new_page()
page.goto("https://playwright.dev")

context.tracing.start_chunk()
page.get_by_text("Get Started").click()
# Everything between start_chunk and stop_chunk will be recorded in the trace.
context.tracing.stop_chunk(path = "trace1.zip")

context.tracing.start_chunk()
page.goto("http://example.com")
# Save a second trace file with different actions.
context.tracing.stop_chunk(path = "trace2.zip")

```

## stop

```
def stop(path: nil)
```


Stop tracing.

## stop_chunk

```
def stop_chunk(path: nil)
```


Stop the trace chunk. See [Tracing#start_chunk](./tracing#start_chunk) for more details about multiple trace chunks.
