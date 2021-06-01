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

### example_1960aabd58c9553683368e29429d39c1209d35e6e3625bbef1280a1fa022a9ee

```
def handle(route, request):
    # override headers
    headers = {
        **request.headers,
        "foo": "bar" # set "foo" header
        "origin": None # remove "origin" header
    }
    route.continue_(headers=headers)
}
page.route("**/*", handle)

```

### example_6d2dfd4bb5c8360f8d80bb91c563b0bd9b99aa24595063cf85e5a6e1b105f89c

```
page.route("**/*", lambda route: route.fulfill(
    status=404,
    content_type="text/plain",
    body="not found!"))

```

### example_c77fd0986d0b74c905cd9417756c76775e612cc86410f9a5aabc5b46d233d150

```
page.route("**/xhr_endpoint", lambda route: route.fulfill(path="mock_data.json"))

```

### example_575870a45e4fe08d3e06be3420e8a11be03f85791cd8174f27198c016031ae72

```
page.keyboard.type("Hello World!")
page.keyboard.press("ArrowLeft")
page.keyboard.down("Shift")
for i in range(6):
    page.keyboard.press("ArrowLeft")
page.keyboard.up("Shift")
page.keyboard.press("Backspace")
# result text will end up saying "Hello!"

```

### example_a4f00f0cd486431b7eca785304f4e9715522da45b66dda7f3a5f6899b889b9fd

```
page.keyboard.press("Shift+KeyA")
# or
page.keyboard.press("Shift+A")

```

### example_2deda0786a20a28cec9e8b438078a5fc567f7c7e5cf369419ab3c4d80a319ff6

```
# on windows and linux
page.keyboard.press("Control+A")
# on mac_os
page.keyboard.press("Meta+A")

```

### example_a9cc2667e9f3e3b8c619649d7e4a7f5db9463e0b76d67a5e588158093a9e9124

```
page.keyboard.insert_text("嗨")

```

### example_88943eb85c1ac7c261601e6edbdead07a31c2784326c496e10667ede1a853bab

```
page = browser.new_page()
page.goto("https://keycode.info")
page.keyboard.press("a")
page.screenshot(path="a.png")
page.keyboard.press("ArrowLeft")
page.screenshot(path="arrow_left.png")
page.keyboard.press("Shift+O")
page.screenshot(path="o.png")
browser.close()

```

### example_d9ced919f139961fd2b795c71375ca96f788a19c1f8e1479c5ec905fb5c02d43

```
page.keyboard.type("Hello") # types instantly
page.keyboard.type("World", delay=100) # types slower, like a user

```

### example_ba01da1f358cafb4c22b792488ff2f3de4dbd82d4ee1cc4050e3f0c24a2bd7dd

```
# using ‘page.mouse’ to trace a 100x100 square.
page.mouse.move(0, 0)
page.mouse.down()
page.mouse.move(0, 100)
page.mouse.move(100, 100)
page.mouse.move(100, 0)
page.mouse.move(0, 0)
page.mouse.up()

```

### example_c408a96b8ac9c9bd54d915009c8b477eb75b7bf9e879fd76b32f3d4b6340a667

```
window_handle = page.evaluate_handle("window")
# ...

```

### example_2400f96eaaed3bc6ef6b0a16ba48e83d38a166c7d55a5dba0025472cffc6f2be

```
tweet_handle = page.query_selector(".tweet .retweets")
assert tweet_handle.evaluate("node => node.innerText") == "10 retweets"

```

### example_8292f0e8974d97d20be9bb303d55ccd2d50e42f954e0ada4958ddbef2c6c2977

```
handle = page.evaluate_handle("{window, document}")
properties = handle.get_properties()
window_handle = properties.get("window")
document_handle = properties.get("document")
handle.dispose()

```

### example_5ba38bdc5d9e5ce7cfc9c8841eb0176efbb4690d18962066f9ee67f1e8b7b050

```
from playwright.sync_api import sync_playwright

def run(playwright):
    chromium = playwright.chromium
    browser = chromium.launch()
    page = browser.new_page()
    page.goto("https://example.com")
    href_element = page.query_selector("a")
    href_element.click()
    # ...

with sync_playwright() as playwright:
    run(playwright)

```

### example_8382aa7cfb42a9a17e348e2f738279f1bd9a038f1ea35cc3cb244cc64d768f93

```
box = element_handle.bounding_box()
page.mouse.click(box["x"] + box["width"] / 2, box["y"] + box["height"] / 2)

```

### example_3b86add6ce355082cd43f4ac0ba9e69c15960bbd7ca601d0618355fe53aa8902

```
element_handle.dispatch_event("click")

```

### example_6b70ea4cf0c7ae9c82cf0ed22ab0dbbb563e2d1419b35d04aa513cf91f0856f9

```
# note you can only create data_transfer in chromium and firefox
data_transfer = page.evaluate_handle("new DataTransfer()")
element_handle.dispatch_event("#source", "dragstart", {"dataTransfer": data_transfer})

```

### example_f6a83ec555fcf23877c11cf55f02a8c89a7fc11d3324859feda42e592e129f4f

```
tweet_handle = page.query_selector(".tweet")
assert tweet_handle.eval_on_selector(".like", "node => node.innerText") == "100"
assert tweet_handle.eval_on_selector(".retweets", "node => node.innerText") = "10"

```

### example_11b54bf5ec18a0d0ceee0868651bb41ab5cd3afcc6b20d5c44f90d835c8d6f81

```
feed_handle = page.query_selector(".feed")
assert feed_handle.eval_on_selector_all(".tweet", "nodes => nodes.map(n => n.innerText)") == ["hello!", "hi!"]

```

### example_dc2ce38846b91d234483ed8b915b785ffbd9403213279465acd6605f314fe736

```
# single selection matching the value
handle.select_option("blue")
# single selection matching both the label
handle.select_option(label="blue")
# multiple selection
handle.select_option(value=["red", "green", "blue"])

```

### example_b4cdd4a1a4d0392c2d430e0fb5fc670df2d728b6907553650690a2d0377662e4

```
# single selection matching the value
handle.select_option("blue")
# single selection matching both the value and the label
handle.select_option(label="blue")
# multiple selection
handle.select_option("red", "green", "blue")
# multiple selection for blue, red and second option
handle.select_option(value="blue", { index: 2 }, "red")

```

### example_2dc9720467640fd8bc581ed65159742e51ff91b209cb176fef8b95f14eaad54e

```
element_handle.type("hello") # types instantly
element_handle.type("world", delay=100) # types slower, like a user

```

### example_d13faaf53454653ce45371b5cf337082a82bf7bbb0aada7e97f47d14963bd6b0

```
element_handle = page.query_selector("input")
element_handle.type("some text")
element_handle.press("Enter")

```

### example_3b0f6c6573db513b7b707a39d6c5bbf5ce5896b4785466d80f525968cfbd0be7

```
page.set_content("<div><span></span></div>")
div = page.query_selector("div")
# waiting for the "span" selector relative to the div.
span = div.wait_for_selector("span", state="attached")

```

### example_371975841dd417527a865b1501e3a8ba40f905b895cf3317ca90d9890e980843

```
with page.expect_file_chooser() as fc_info:
    page.click("upload")
file_chooser = fc_info.value
file_chooser.set_files("myfile.pdf")

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

### example_9daa37cfd3d747c9360d9544f64786bf49d291a6887b0efccc813215b62ae4c6

```
a_handle = page.evaluate_handle("document") # handle for the "document"

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

### example_c954c35627e62be69e1f138f25d7377b13e18d08039d476946217827fa95db52

```
from playwright.sync_api import sync_playwright

def handle_dialog(dialog):
    print(dialog.message)
    dialog.dismiss()

def run(playwright):
    chromium = playwright.chromium
    browser = chromium.launch()
    page = browser.new_page()
    page.on("dialog", handle_dialog)
    page.evaluate("alert('1')")
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

### example_9220b94fd2fa381ab91448dcb551e2eb9806ad331c83454a710f4d8a280990e8

```
page.dispatch_event("button#submit", "click")

```

### example_9b4482b7243b7ce304d6ce8454395e23db30f3d1d83229242ab7bd2abd5b72e0

```
# note you can only create data_transfer in chromium and firefox
data_transfer = page.evaluate_handle("new DataTransfer()")
page.dispatch_event("#source", "dragstart", { "dataTransfer": data_transfer })

```

### example_df304caf6c61f6f44b3e2b0006a7e05552362a47b17c9ba227df76e918d88a5c

```
page.evaluate("matchMedia('screen').matches")
# → True
page.evaluate("matchMedia('print').matches")
# → False

page.emulate_media(media="print")
page.evaluate("matchMedia('screen').matches")
# → False
page.evaluate("matchMedia('print').matches")
# → True

page.emulate_media()
page.evaluate("matchMedia('screen').matches")
# → True
page.evaluate("matchMedia('print').matches")
# → False

```

### example_f0479a2ee8d8f51dab94f48b7e121cade07e5026d4f602521cc6ccc47feb5a98

```
page.emulate_media(color_scheme="dark")
page.evaluate("matchMedia('(prefers-color-scheme: dark)').matches")
# → True
page.evaluate("matchMedia('(prefers-color-scheme: light)').matches")
# → False
page.evaluate("matchMedia('(prefers-color-scheme: no-preference)').matches")

```

### example_6802829f93cc4da7e67f3886b9773c7b84054afa84251add50704f8ca6837138

```
a_window_handle = page.evaluate_handle("Promise.resolve(window)")
a_window_handle # handle for the window object.

```

### example_9daa37cfd3d747c9360d9544f64786bf49d291a6887b0efccc813215b62ae4c6

```
a_handle = page.evaluate_handle("document") # handle for the "document"

```

### example_551f5963351bfd7141fa8c94f5f22c305ec1c01d617861953374e9290929a551

```
from playwright.sync_api import sync_playwright

def run(playwright):
    webkit = playwright.webkit
    browser = webkit.launch(headless=false)
    context = browser.new_context()
    page = context.new_page()
    page.expose_binding("pageURL", lambda source: source["page"].url)
    page.set_content("""
    <script>
      async function onClick() {
        document.querySelector('div').textContent = await window.pageURL();
      }
    </script>
    <button onclick="onClick()">Click me</button>
    <div></div>
    """)
    page.click("button")

with sync_playwright() as playwright:
    run(playwright)

```

### example_6534a792e99e05b5644cea6e5b77ca5d864675a3012f447f0f8318c4fa6a6a54

```
def print(source, element):
    print(element.text_content())

page.expose_binding("clicked", print, handle=true)
page.set_content("""
  <script>
    document.addEventListener('click', event => window.clicked(event.target));
  </script>
  <div>Click me</div>
  <div>Or click me</div>
""")

```

### example_496ab45e0c5f4c47869f66c2b738fbd9eef0ef4065fa923caf9c929e50e14c21

```
import hashlib
from playwright.sync_api import sync_playwright

def sha1(text):
    m = hashlib.sha1()
    m.update(bytes(text, "utf8"))
    return m.hexdigest()


def run(playwright):
    webkit = playwright.webkit
    browser = webkit.launch(headless=False)
    page = browser.new_page()
    page.expose_function("sha1", sha1)
    page.set_content("""
        <script>
          async function onClick() {
            document.querySelector('div').textContent = await window.sha1('PLAYWRIGHT');
          }
        </script>
        <button onclick="onClick()">Click me</button>
        <div></div>
    """)
    page.click("button")

with sync_playwright() as playwright:
    run(playwright)

```

### example_034f224ec0f7b4d98fdf875cefbc7e6c8726a6d615cbba9b1cb8c49180fd7d69

```
frame = page.frame(name="frame-name")

```

### example_a8a4717d8505a35662faafa9e6c2cfbbc0a44755c8e4d43252f882b7e4f1f04a

```
frame = page.frame(url=r".*domain.*")

```

### example_e079fbec8ee0607ee45cdca94df61dea36f7fd3840986d5f4ac24918569a5f5e

```
# generates a pdf with "screen" media type.
page.emulate_media(media="screen")
page.pdf(path="page.pdf")

```

### example_aa4598bd7dbeb8d2f8f5c0aa3bdc84042eb396de37b49f8ff8c1ea39f080f709

```
page = browser.new_page()
page.goto("https://keycode.info")
page.press("body", "A")
page.screenshot(path="a.png")
page.press("body", "ArrowLeft")
page.screenshot(path="arrow_left.png")
page.press("body", "Shift+O")
page.screenshot(path="o.png")
browser.close()

```

### example_a3038a6fd55b06cb841251877bf6eb781b08018695514c6e0054848d4e93d345

```
page = browser.new_page()
page.route("**/*.{png,jpg,jpeg}", lambda route: route.abort())
page.goto("https://example.com")
browser.close()

```

### example_7fda2a761bdd66b942415ab444c6b4bb89dd87ec0f0a4a03e6775feb694f7913

```
page = browser.new_page()
page.route(re.compile(r"(\.png$)|(\.jpg$)"), lambda route: route.abort())
page.goto("https://example.com")
browser.close()

```

### example_ff4fba1273c7e65f4d68b4fcdd9dc4b792bba435005f0b9e7066ca18ded750b5

```
def handle_route(route):
  if ("my-string" in route.request.post_data)
    route.fulfill(body="mocked-data")
  else
    route.continue_()
page.route("/api/**", handle_route)

```

### example_4b17eb65721c55859c50eb12b4ee762e65408618cf3b7d07958b68d60ea6be6c

```
# single selection matching the value
page.select_option("select#colors", "blue")
# single selection matching both the label
page.select_option("select#colors", label="blue")
# multiple selection
page.select_option("select#colors", value=["red", "green", "blue"])

```

### example_e3883d51c0785c34b62633fe311c4f1252dd9f29e6b4b6c7719f1eb74384e6e9

```
page = browser.new_page()
page.set_viewport_size({"width": 640, "height": 480})
page.goto("https://example.com")

```

### example_4c7291f6023d2fe4f957cb7727646b50fdee40275db330a6f4517e349ea7f916

```
page.type("#mytextarea", "hello") # types instantly
page.type("#mytextarea", "world", delay=100) # types slower, like a user

```

### example_1b007e0db5f2b594b586367be3b56f9eb9b928740efbceada2c60cb7794592d4

```
with page.expect_event("framenavigated") as event_info:
    page.click("button")
frame = event_info.value

```

### example_e50869c913bec2f0a89a22ff1c438128c3c8f2e3710acb10665445cf52e3ec73

```
from playwright.sync_api import sync_playwright

def run(playwright):
    webkit = playwright.webkit
    browser = webkit.launch()
    page = browser.new_page()
    page.evaluate("window.x = 0; setTimeout(() => { window.x = 100 }, 1000);")
    page.wait_for_function("() => window.x > 0")
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

### example_04c93558dde8de62944515a8ed91fda6e0d01feca4d3bb2e58c6fda10a8c6ade

```
selector = ".foo"
page.wait_for_function("selector => !!document.querySelector(selector)", selector)

```

### example_cd35fb085612055231ddf97f68bc5331b4620914e0686b889f2cd4061836cff8

```
page.click("button") # click triggers navigation.
page.wait_for_load_state() # the promise resolves after "load" event.

```

### example_51ba8a745d5093516e9a50482d8bf3ce29afe507ca5cfe89f4a0e35963f52a36

```
with page.expect_popup() as page_info:
    page.click("button") # click triggers a popup.
popup = page_info.value
 # Following resolves after "domcontentloaded" event.
popup.wait_for_load_state("domcontentloaded")
print(popup.title()) # popup is ready to use.

```

### example_bc5a01f756c1275b9942c4b3e50a9f1748c04da8d5f8f697567b9d04806ec0dc

```
with page.expect_navigation():
    page.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
# Resolves after navigation has finished

```

### example_9246912bc386c2f9310662279b12200ae131f724a1ec1ca99e511568767cb9c8

```
with page.expect_request("http://example.com/resource") as first:
    page.click('button')
first_request = first.value

# or with a lambda
with page.expect_request(lambda request: request.url == "http://example.com" and request.method == "get") as second:
    page.click('img')
second_request = second.value

```

### example_d2a76790c0bb59bf5ae2f41d1a29b50954412136de3699ec79dc33cdfd56004b

```
with page.expect_response("https://example.com/resource") as response_info:
    page.click("input")
response = response_info.value
return response.ok

# or with a lambda
with page.expect_response(lambda response: response.url == "https://example.com" and response.status === 200) as response_info:
    page.click("input")
response = response_info.value
return response.ok

```

### example_0a62ff34b0d31a64dd1597b9dff456e4139b36207d26efdec7109e278dc315a3

```
from playwright.sync_api import sync_playwright

def run(playwright):
    chromium = playwright.chromium
    browser = chromium.launch()
    page = browser.new_page()
    for current_url in ["https://google.com", "https://bbc.com"]:
        page.goto(current_url, wait_until="domcontentloaded")
        element = page.wait_for_selector("img")
        print("Loaded image: " + str(element.get_attribute("src")))
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

### example_a49b1deed2b93fe358b57bca9c4032f44b3d24436a78720421ba040aad4d661c

```
page.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
page.wait_for_url("**/target.html")

```

### example_b375e389cd6685ec49d1ef57f3186da60ef682785c646fe8db351b6f39b1a34c

```
browser = chromium.launch(traceDir='traces')
context = browser.new_context()
context.tracing.start(name="trace", screenshots=True, snapshots=True)
page.goto("https://playwright.dev")
context.tracing.stop()
context.tracing.export("trace.zip")

```

### example_4c72a858b35ec7bd7aaba231cb93acecb7ee4b7ea8048a534f28f7e16af966b8

```
context.tracing.start(name="trace", screenshots=True, snapshots=True)
page.goto("https://playwright.dev")
context.tracing.stop()
context.tracing.export("trace.zip")

```
