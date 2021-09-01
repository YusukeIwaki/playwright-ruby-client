# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_4c3e7d3ff5866cd7fc56ca68dc38333760d280ebbcc3038295f985a9e8f47077

```
browser = chromium.launch()
context = browser.new_context()
context.tracing.start(screenshots=True, snapshots=True)
page = context.new_page()
page.goto("https://playwright.dev")
context.tracing.stop(path = "trace.zip")

```

### example_89f1898bef60f89ccf36656f6471cc0d2296bfd8cad633f1b8fd22ba4b4f65da

```
context.tracing.start(name="trace", screenshots=True, snapshots=True)
page = context.new_page()
page.goto("https://playwright.dev")
context.tracing.stop(path = "trace.zip")

```

### example_5c129e11b91105b449e998fc2944c4591340eca625fe27a86eb555d5959dfc14

```
# Throws if there are several buttons in DOM:
page.locator('button').click()

# Works because we explicitly tell locator to pick the first element:
page.locator('button').first.click()

# Works because count knows what to do with multiple matches:
page.locator('button').count()

```
