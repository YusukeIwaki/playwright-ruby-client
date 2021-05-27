---
sidebar_position: 10
---

# Tracing

API for collecting and saving Playwright traces. Playwright traces can be opened using the Playwright CLI after
Playwright script runs.

Start with specifying the folder traces will be stored in:

```python sync title=example_b375e389cd6685ec49d1ef57f3186da60ef682785c646fe8db351b6f39b1a34c.py
browser = chromium.launch(traceDir='traces')
context = browser.new_context()
context.tracing.start(name="trace", screenshots=True, snapshots=True)
page.goto("https://playwright.dev")
context.tracing.stop()
context.tracing.export("trace.zip")

```


## export

```
def export(path)
```

Export trace into the file with the given name. Should be called after the tracing has stopped.

## start

```
def start(name: nil, screenshots: nil, snapshots: nil)
```

Start tracing.

```python sync title=example_4c72a858b35ec7bd7aaba231cb93acecb7ee4b7ea8048a534f28f7e16af966b8.py
context.tracing.start(name="trace", screenshots=True, snapshots=True)
page.goto("https://playwright.dev")
context.tracing.stop()
context.tracing.export("trace.zip")

```


## stop

```
def stop
```

Stop tracing.
