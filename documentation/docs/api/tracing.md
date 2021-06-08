---
sidebar_position: 10
---

# Tracing

API for collecting and saving Playwright traces. Playwright traces can be opened using the Playwright CLI after
Playwright script runs.

Start with specifying the folder traces will be stored in:

```python sync title=example_a767dfb400d98aef50f2767b94171d23474ea1ac1cf9b4d75d412936208e652d.py
browser = chromium.launch()
context = browser.new_context()
context.tracing.start(screenshots=True, snapshots=True)
page.goto("https://playwright.dev")
context.tracing.stop(path = "trace.zip")

```



## start

```
def start(name: nil, screenshots: nil, snapshots: nil)
```

Start tracing.

```python sync title=example_e611abc8b1066118d0c87eae1bbbb08df655f36d50a94402fc56b8713150997b.py
context.tracing.start(name="trace", screenshots=True, snapshots=True)
page.goto("https://playwright.dev")
context.tracing.stop()
context.tracing.stop(path = "trace.zip")

```



## stop

```
def stop(path: nil)
```

Stop tracing.
