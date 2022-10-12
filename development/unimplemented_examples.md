# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_1b16c833a5a31719df85ea8c7d134c3199d3396171a69df3f0c80e67cc0df538

```
page.drag_and_drop("#source", "#target")
# or specify exact positions relative to the top-left corners of the elements:
page.drag_and_drop(
  "#source",
  "#target",
  source_position={"x": 34, "y": 7},
  target_position={"x": 10, "y": 20}
)

```

### example_e2abd82db97f2a0531855941d4ae70ef68fe8f844318e7a474d14a217dfd2595

```
locator = page.frame_locator("#my-iframe").get_by_text("Submit")
locator.click()

```

### example_37a07ca53382af80ed79aeaa2d65e450d4a8f6ee9753eb3c22ae2125d9cf83c8

```
with page.expect_event("framenavigated") as event_info:
    page.get_by_role("button")
frame = event_info.value

```

### example_c20d17a107bdb6b05189fa02485e9c32a290ae0052686ac9d9611312995c5eed

```
page.get_by_role("button").click() # click triggers navigation.
page.wait_for_load_state() # the promise resolves after "load" event.

```

### example_8b3643dc7effb0afc06a5aacd17473b73535d351d55cb0d532497fa565024d48

```
with page.expect_popup() as page_info:
    page.get_by_role("button").click() # click triggers a popup.
popup = page_info.value
 # Following resolves after "domcontentloaded" event.
popup.wait_for_load_state("domcontentloaded")
print(popup.title()) # popup is ready to use.

```

### example_fac8dd8edc4c565fc04b423141a6881aab2388e7951e425c43865ddd656ffad6

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
    page.get_by_role("button").click()

with sync_playwright() as playwright:
    run(playwright)

```

### example_3465d6b0d3caee840bd7e5ca7076e4def34af07010caca46ea35d2a536d7445d

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
    page.get_by_role("button").click()

with sync_playwright() as playwright:
    run(playwright)

```

### example_6619b3b87b68e56013f61689b1e1df60f6bf2950241ef796dd2dc58b7d3292c8

```
with context.expect_event("page") as event_info:
    page.get_by_role("button").click()
page = event_info.value

```

### example_e04b4e47771d459712f345ce14b805815a7240ddf2b30b0ae0395d4f62741043

```
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

### example_f4046df878cf5096f750d2865c48060a3d7dd5e198e508776f9a09afbc567763

```
source = page.locator("#source")
target = page.locator("#target")

source.drag_to(target)
# or specify exact positions relative to the top-left corners of the elements:
source.drag_to(
  target,
  source_position={"x": 34, "y": 7},
  target_position={"x": 10, "y": 20}
)

```

### example_516c962e3016789b2f0d21854daed72507a490b018b3f0213d4ae25f9ee03267

```
row_locator = page.locator("tr")
# ...
row_locator
    .filter(has_text="text in column 1")
    .filter(has=page.get_by_role("button", name="column 2 button"))
    .screenshot()

```

### example_0ec60e5949820a3a318c7e05ea06b826218f2d79a94f8d599a29c8b07b2c1e63

```
locator = page.frame_locator("iframe").get_by_text("Submit")
locator.click()

```

### example_c52737358713c715eb9607198a15d3e7533c8ca126cf61fa58d6cb31a701585b

```
element = page.get_by_label("Password")
element.type("my password")
element.press("Enter")

```

### example_e2ea8f31994ab012b3f8cd7f5abfb4cb610286a4be96c9d4d6f1ad9f9678a0ed

```
# Throws if there are several frames in DOM:
page.frame_locator('.result-frame').get_by_role('button').click()

# Works because we explicitly tell locator to pick the first frame:
page.frame_locator('.result-frame').first.get_by_role('button').click()

```

### example_19c86319c1f40a2cae90cfaf7f6471c50b59319e8b08d6e37d9be9d4697de0b8

```
data = {
    "title": "Book Title",
    "body": "John Doe",
}
api_request_context.fetch("https://example.com/api/createBook", method="post", data=data)

```

### example_c5f1dfbcb296a3bc1e1e9e0216dacb2ee7c2af8685053b9e4bb44c823d82767c

```
api_request_context.fetch(
  "https://example.com/api/uploadScrip'",
  method="post",
  multipart={
    "fileField": {
      "name": "f.js",
      "mimeType": "text/javascript",
      "buffer": b"console.log(2022);",
    },
  })

```

### example_cf0d399f908388d6949e0fd2a750800a486e56e31ddc57b5b8f685b94cccfed8

```
query_params = {
  "isbn": "1234",
  "page": "23"
}
api_request_context.get("https://example.com/api/getText", params=query_params)

```

### example_d42fb8f54175536448ed40ab14732e18bb20140493c96e5d07990ef7c200ac15

```
data = {
    "title": "Book Title",
    "body": "John Doe",
}
api_request_context.post("https://example.com/api/createBook", data=data)

```

### example_858c53bcbc4088deffa2489935a030bb6a485ae8927e43b393b38fd7e4414c17

```
formData = {
    "title": "Book Title",
    "body": "John Doe",
}
api_request_context.post("https://example.com/api/findBook", form=formData)

```

### example_3a940e5f148822e63981b92e0dd21748d81cdebc826935849d9fa08723fbccdc

```
api_request_context.post(
  "https://example.com/api/uploadScrip'",
  multipart={
    "fileField": {
      "name": "f.js",
      "mimeType": "text/javascript",
      "buffer": b"console.log(2022);",
    },
  })

```
