# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_0511532585a1977c2f90ae3606eb154fbd89087e50e61add1189d555044a53e7

```
with page.expect_file_chooser() as fc_info:
    page.locator("upload").click()
file_chooser = fc_info.value
file_chooser.set_files("myfile.pdf")

```

### example_2a1ca76da8b425f9c7c34806bd0468a41808d975ce8d0e3887995b6ef785318d

```
from playwright.sync_api import sync_playwright

def run(playwright):
    tag_selector = """
      {
          // Returns the first element matching given selector in the root's subtree.
          query(root, selector) {
              return root.querySelector(selector);
          },
          // Returns all elements matching given selector in the root's subtree.
          queryAll(root, selector) {
              return Array.from(root.querySelectorAll(selector));
          }
      }"""

    # Register the engine. Selectors will be prefixed with "tag=".
    playwright.selectors.register("tag", tag_selector)
    browser = playwright.chromium.launch()
    page = browser.new_page()
    page.set_content('<div><button>Click me</button></div>')

    # Use the selector prefixed with its name.
    button = page.locator('tag=button')
    # Combine it with other selector engines.
    page.locator('tag=div >> text="Click me"').click()
    # Can use it in any methods supporting selectors.
    button_count = page.locator('tag=button').count()
    print(button_count)
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

### example_57ba49c8dae5a0b6903980e8329cd393ceb9b066488ea8a0f37299d949a79755

```
with page.expect_download() as download_info:
    page.locator("a").click()
download = download_info.value
# wait for download to complete
path = download.path()

```

### example_b5278c03b97db04837578d9c4b3127e749c5631b3913c394d87fd2eb7c60d6fd

```
from playwright.sync_api import sync_playwright

def run(playwright):
    webkit = playwright.webkit
    browser = webkit.launch(headless=false)
    context = browser.new_context()
    context.expose_binding("pageURL", lambda source: source["page"].url)
    page = context.new_page()
    page.set_content("""
    <script>
      async function onClick() {
        document.querySelector('div').textContent = await window.pageURL();
      }
    </script>
    <button onclick="onClick()">Click me</button>
    <div></div>
    """)
    page.locator("button").click()

with sync_playwright() as playwright:
    run(playwright)

```

### example_c522a7b05c05a56efaa701e7f606bb933c695fe49d80cc094776ee9a6b0430c9

```
import hashlib
from playwright.sync_api import sync_playwright

def sha256(text):
    m = hashlib.sha256()
    m.update(bytes(text, "utf8"))
    return m.hexdigest()


def run(playwright):
    webkit = playwright.webkit
    browser = webkit.launch(headless=False)
    context = browser.new_context()
    context.expose_function("sha256", sha256)
    page = context.new_page()
    page.set_content("""
        <script>
          async function onClick() {
            document.querySelector('div').textContent = await window.sha256('PLAYWRIGHT');
          }
        </script>
        <button onclick="onClick()">Click me</button>
        <div></div>
    """)
    page.locator("button").click()

with sync_playwright() as playwright:
    run(playwright)

```

### example_975e00f210447a2dc27c6cba698d8926f949ac6e3a1c663680bf83a2409ab319

```
with context.expect_event("page") as event_info:
    page.locator("button").click()
page = event_info.value

```

### example_7c214a04c3801b617a25fc020a766d671422782121b1ec7e1876d10789385c9c

```
browser = playwright.firefox.launch() # or "chromium" or "webkit".
# create a new incognito browser context.
context = browser.new_context()
# create a new page in a pristine context.
page = context.new_page()
page.goto("https://example.com")

# gracefully close up everything
context.close()
browser.close()

```

### example_20726490b43bb0d4f3a8ec9f7d9b08bad90ac24377cec399737fc5bdf537ca4b

```
context.tracing.start(name="trace", screenshots=True, snapshots=True)
page = context.new_page()
page.goto("https://playwright.dev")

context.tracing.start_chunk()
page.locator("text=Get Started").click()
# Everything between start_chunk and stop_chunk will be recorded in the trace.
context.tracing.stop_chunk(path = "trace1.zip")

context.tracing.start_chunk()
page.goto("http://example.com")
# Save a second trace file with different actions.
context.tracing.stop_chunk(path = "trace2.zip")

```

### example_e2c1d5cff1ee10c126c8add2674c81927966bacadaacd4ed283eeb4319d8495f

```
row_locator = page.locator("tr")
# ...
row_locator
    .filter(has_text="text in column 1")
    .filter(has=page.locator("tr", has_text="column 2 button"))
    .screenshot()

```
