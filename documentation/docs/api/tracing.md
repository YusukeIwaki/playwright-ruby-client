---
sidebar_position: 10
---

# Tracing

API for collecting and saving Playwright traces. Playwright traces can be opened in
[Trace Viewer](https://playwright.dev/python/docs/trace-viewer) after Playwright script runs.

Start recording a trace before performing actions. At the end, stop tracing and save it to a file.

```py title=example_e079b42d1407d0e26318e717f2fda15ccd828010b65008e0d178620e4fe10727.py
browser = await chromium.launch()
context = await browser.new_context()
await context.tracing.start(screenshots=True, snapshots=True)
page = await context.new_page()
await page.goto("https://playwright.dev")
await context.tracing.stop(path = "trace.zip")

```

```py title=example_a0f4f36f022cef400c035f754ff8466c79dbf1bd8d8bdca88b77063d40c2bf85.py
browser = chromium.launch()
context = browser.new_context()
context.tracing.start(screenshots=True, snapshots=True)
page = context.new_page()
page.goto("https://playwright.dev")
context.tracing.stop(path = "trace.zip")

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

```py title=example_e288d6b68bb4b852c030dea31d2335abb1037c66a80367bbfb2cb1aa612a0240.py
await context.tracing.start(name="trace", screenshots=True, snapshots=True)
page = await context.new_page()
await page.goto("https://playwright.dev")
await context.tracing.stop(path = "trace.zip")

```

```py title=example_32bf6a345ec98579c9299b22e8dbd26f7b3942297fd5619795ec0a0f61cf5f93.py
context.tracing.start(name="trace", screenshots=True, snapshots=True)
page = context.new_page()
page.goto("https://playwright.dev")
context.tracing.stop(path = "trace.zip")

```



## start_chunk

```
def start_chunk(title: nil)
```

Start a new trace chunk. If you'd like to record multiple traces on the same [BrowserContext](./browser_context), use
[Tracing#start](./tracing#start) once, and then create multiple trace chunks with [Tracing#start_chunk](./tracing#start_chunk) and
[Tracing#stop_chunk](./tracing#stop_chunk).

**Usage**

```py title=example_fa8100d21b7ff7f779b33ac24d368e36185ecaf336415bb86a38793bbf776e79.py
await context.tracing.start(name="trace", screenshots=True, snapshots=True)
page = await context.new_page()
await page.goto("https://playwright.dev")

await context.tracing.start_chunk()
await page.get_by_text("Get Started").click()
# Everything between start_chunk and stop_chunk will be recorded in the trace.
await context.tracing.stop_chunk(path = "trace1.zip")

await context.tracing.start_chunk()
await page.goto("http://example.com")
# Save a second trace file with different actions.
await context.tracing.stop_chunk(path = "trace2.zip")

```

```py title=example_9f83220984d3bbe679a6b42862c99279121cbe9b9e68e2500d1d0f2a8e97705b.py
context.tracing.start(name="trace", screenshots=True, snapshots=True)
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
