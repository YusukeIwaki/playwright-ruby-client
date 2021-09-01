---
sidebar_position: 10
---

# Tracing

API for collecting and saving Playwright traces. Playwright traces can be opened in [Trace Viewer](https://playwright.dev/python/docs/trace-viewer)
after Playwright script runs.

Start recording a trace before performing actions. At the end, stop tracing and save it to a file.

```python sync title=example_4c3e7d3ff5866cd7fc56ca68dc38333760d280ebbcc3038295f985a9e8f47077.py
browser = chromium.launch()
context = browser.new_context()
context.tracing.start(screenshots=True, snapshots=True)
page = context.new_page()
page.goto("https://playwright.dev")
context.tracing.stop(path = "trace.zip")

```



## start

```
def start(name: nil, screenshots: nil, snapshots: nil)
```

Start tracing.

```python sync title=example_89f1898bef60f89ccf36656f6471cc0d2296bfd8cad633f1b8fd22ba4b4f65da.py
context.tracing.start(name="trace", screenshots=True, snapshots=True)
page = context.new_page()
page.goto("https://playwright.dev")
context.tracing.stop(path = "trace.zip")

```



## stop

```
def stop(path: nil)
```

Stop tracing.
