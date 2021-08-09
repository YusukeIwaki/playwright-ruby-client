# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_5f3f4534ab17f584cfd41ca38448ce7de9490b6588e29e73116ede3cb15a25a5

```
page.on("requestfailed", lambda request: print(request.url + " " + request.failure))

```

### example_89568fc86bf623eef37b68c6659b1a8524647c8365bb32a7a8af63bd86111075

```
response = page.goto("http://example.com")
print(response.request.redirected_from.url) # "http://example.com"

```

### example_6d7b3fbf8d69dbe639b71fedc5a8977777fca29dfb16d38012bb07c496342472

```
response = page.goto("https://google.com")
print(response.request.redirected_from) # None

```

### example_922623f4033e7ec2158787e54a8554655f7e1e20a024e4bf4f69337f781ab88a

```
assert request.redirected_from.redirected_to == request

```

### example_e2a297fe95fd0699b6a856c3be2f28106daa2615c0f4d6084f5012682a619d20

```
with page.expect_event("requestfinished") as request_info:
    page.goto("http://example.com")
request = request_info.value
print(request.timing)

```

### example_3b0f6c6573db513b7b707a39d6c5bbf5ce5896b4785466d80f525968cfbd0be7

```
page.set_content("<div><span></span></div>")
div = page.query_selector("div")
# waiting for the "span" selector relative to the div.
span = div.wait_for_selector("span", state="attached")

```

### example_2e5019929403491cde0c78bed1e0e18e0c86ab423d7ac8715876c4de4814f483

```
snapshot = page.accessibility.snapshot()
print(snapshot)

```

### example_df2acadf9e261a7624d83399f0d8b0910293a6a7081c812474715f22f8af7a4a

```
def find_focused_node(node):
    if (node.get("focused"))
        return node
    for child in (node.get("children") or []):
        found_node = find_focused_node(child)
        return found_node
    return None

snapshot = page.accessibility.snapshot()
node = find_focused_node(snapshot)
if node:
    print(node["name"])

```

### example_a4a9e01d1e0879958d591c4bc9061574f5c035e821a94214e650d15564d77bf4

```
from playwright.sync_api import sync_playwright

def run(playwright):
    firefox = playwright.firefox
    browser = firefox.launch()
    page = browser.new_page()
    page.goto("https://www.theverge.com")
    dump_frame_tree(page.main_frame, "")
    browser.close()

def dump_frame_tree(frame, indent):
    print(indent + frame.name + '@' + frame.url)
    for child in frame.child_frames:
        dump_frame_tree(child, indent + "    ")

with sync_playwright() as playwright:
    run(playwright)

```

### example_de439a4f4839a9b1bc72dbe0890d6b989c437620ba1b88a2150faa79f98184fc

```
frame.dispatch_event("button#submit", "click")

```

### example_5410f49339561b3cc9d91c7548c8195a570c8be704bb62f45d90c68f869d450d

```
# note you can only create data_transfer in chromium and firefox
data_transfer = frame.evaluate_handle("new DataTransfer()")
frame.dispatch_event("#source", "dragstart", { "dataTransfer": data_transfer })

```

### example_6814d0e91763f4d27a0d6a380c36d62b551e4c3e902d1157012dde0a49122abe

```
search_value = frame.eval_on_selector("#search", "el => el.value")
preload_href = frame.eval_on_selector("link[rel=preload]", "el => el.href")
html = frame.eval_on_selector(".main-container", "(e, suffix) => e.outerHTML + suffix", "hello")

```

### example_618e7f8f681d1c4a1c0c9b8d23892e37cbbef013bf3d8906fd4311c51d9819d7

```
divs_counts = frame.eval_on_selector_all("div", "(divs, min) => divs.length >= min", 10)

```

### example_15a235841cd1bc56fad6e3c8aaea2a30e352fedd8238017f22f97fc70e058d2b

```
result = frame.evaluate("([x, y]) => Promise.resolve(x * y)", [7, 8])
print(result) # prints "56"

```

### example_9c73167b900498bca191abc2ce2627e063f84b0abc8ce3a117416cb734602760

```
print(frame.evaluate("1 + 2")) # prints "3"
x = 10
print(frame.evaluate(f"1 + {x}")) # prints "11"

```

### example_05568c81173717fa6841099571d8a66e14fc0853e01684630d1622baedc25f67

```
body_handle = frame.query_selector("body")
html = frame.evaluate("([body, suffix]) => body.innerHTML + suffix", [body_handle, "hello"])
body_handle.dispose()

```

### example_a1c8e837e826079359d01d6f7eecc64092a45d8c74280d23ee9039c379132c51

```
a_window_handle = frame.evaluate_handle("Promise.resolve(window)")
a_window_handle # handle for the window object.

```

### example_e6b4fdef29a401d84b17acfa319bee08f39e1f28e07c435463622220c6a24747

```
frame_element = frame.frame_element()
content_frame = frame_element.content_frame()
assert frame == content_frame

```

### example_230c12044664b222bf35d6163b1e415c011d87d9911a4d39648c7f601b344a31

```
# single selection matching the value
frame.select_option("select#colors", "blue")
# single selection matching both the label
frame.select_option("select#colors", label="blue")
# multiple selection
frame.select_option("select#colors", value=["red", "green", "blue"])

```

### example_beae7f0d11663c3c98b9d3a8e6ab76b762578cf2856e3b04ad8e42bfb23bb1e1

```
frame.type("#mytextarea", "hello") # types instantly
frame.type("#mytextarea", "world", delay=100) # types slower, like a user

```

### example_2f82dcf15fa9338be87a4faf7fe7de3c542040924db1e1ad1c98468ec0f425ce

```
from playwright.sync_api import sync_playwright

def run(playwright):
    webkit = playwright.webkit
    browser = webkit.launch()
    page = browser.new_page()
    page.evaluate("window.x = 0; setTimeout(() => { window.x = 100 }, 1000);")
    page.main_frame.wait_for_function("() => window.x > 0")
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

### example_8b95be0fb4d149890f7817d9473428a50dc631d3a75baf89846648ca6a157562

```
selector = ".foo"
frame.wait_for_function("selector => !!document.querySelector(selector)", selector)

```

### example_fe41b79b58d046cda4673ededd4d216cb97a63204fcba69375ce8a84ea3f6894

```
frame.click("button") # click triggers navigation.
frame.wait_for_load_state() # the promise resolves after "load" event.

```

### example_03f0ac17eb6c1ce8780cfa83c4ae15a9ddbfde3f96c96f36fdf3fbf9aac721f7

```
with frame.expect_navigation():
    frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
# Resolves after navigation has finished

```

### example_a5b9dd4745d45ac630e5953be1c1815ae8e8ab03399fb35f45ea77c434f17eea

```
from playwright.sync_api import sync_playwright

def run(playwright):
    chromium = playwright.chromium
    browser = chromium.launch()
    page = browser.new_page()
    for current_url in ["https://google.com", "https://bbc.com"]:
        page.goto(current_url, wait_until="domcontentloaded")
        element = page.main_frame.wait_for_selector("img")
        print("Loaded image: " + str(element.get_attribute("src")))
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

### example_86a9a19ec4c41e1a5ac302fbca9a3d3d6dca3fe3314e065b8062ddf5f75abfbd

```
frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
frame.wait_for_url("**/target.html")

```

### example_29716fdd4471a97923a64eebeee96330ab508226a496ae8fd13f12eb07d55ee6

```
def handle_worker(worker):
    print("worker created: " + worker.url)
    worker.on("close", lambda: print("worker destroyed: " + worker.url))

page.on('worker', handle_worker)

print("current workers:")
for worker in page.workers:
    print("    " + worker.url)

```

### example_49f0cb9b5a21d0d5fe2b180c847bdb21068b335b4c2f42d5c05eb1957297899f

```
# FIXME: add snippet

```

### example_9f72eed0cd4b2405e6a115b812b36ff2624e889f9086925c47665333a7edabbc

```
locator = page.locator("text=Submit")
locator.click()

```

### example_4d635e937854fa2ee56b7c43151ded535940f0bbafc00cf48e8214bed86715eb

```
box = element.bounding_box()
page.mouse.click(box["x"] + box["width"] / 2, box["y"] + box["height"] / 2)

```

### example_8d92b900a98c237ffdcb102ddc35660e37101bde7d107dc64d97a7edeed62a43

```
element.dispatch_event("click")

```

### example_e369442a3ff291ab476da408ef63a63dacf47984dc766ff7189d82008ae2848b

```
# note you can only create data_transfer in chromium and firefox
data_transfer = page.evaluate_handle("new DataTransfer()")
element.dispatch_event("#source", "dragstart", {"dataTransfer": data_transfer})

```

### example_df39b3df921f81e7cfb71cd873b76a5e91e46b4aa41e1f164128cb322aa38305

```
tweets = page.locator(".tweet .retweets")
assert tweets.evaluate("node => node.innerText") == "10 retweets"

```

### example_32478e941514ed28b6ac221e6d54b55cf117038ecac6f4191db676480ab68d44

```
elements = page.locator("div")
div_counts = elements("(divs, min) => divs.length >= min", 10)

```

### example_2825b0a50091868d1ce3ea0752d94ba32d826d504c1ac6842522796ca405913e

```
# single selection matching the value
element.select_option("blue")
# single selection matching both the label
element.select_option(label="blue")
# multiple selection
element.select_option(value=["red", "green", "blue"])

```

### example_3aaff4985dc38e64fad34696c88a6a68a633e26aabee6fc749125f3ee1784e34

```
# single selection matching the value
element.select_option("blue")
# single selection matching both the value and the label
element.select_option(label="blue")
# multiple selection
element.select_option("red", "green", "blue")
# multiple selection for blue, red and second option
element.select_option(value="blue", { index: 2 }, "red")

```

### example_fa1712c0b6ceb96fcaa74790d33f2c2eefe2bd1f06e61b78e0bb84a6f22c7961

```
element.type("hello") # types instantly
element.type("world", delay=100) # types slower, like a user

```

### example_adefe90dee78708d4375c20f081f12f2b71f2becb472a2e0d4fdc8cc49c37809

```
element = page.locator("input")
element.type("some text")
element.press("Enter")

```
