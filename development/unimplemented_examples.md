# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_b32fe2f633a7879ff5023d4a2b820d10d225ad5078a2a2034b0781159e7983a0

```
response = await page.goto("http://example.com")
print(response.request.redirected_from.url) # "http://example.com"

```

### example_b33082ad183920ec77a72169c2f1b12b1f70bc70c280e761c1e9d7284a3cdd42

```
response = page.goto("http://example.com")
print(response.request.redirected_from.url) # "http://example.com"

```

### example_1a8c712da7e8a552bdda1433b80674421b2e60e5da442efd44614a17b32ce46d

```
response = await page.goto("https://google.com")
print(response.request.redirected_from) # None

```

### example_edaa5af7c2aa595c532ffda589a6b75245acdc06117642455a1784d66f393235

```
response = page.goto("https://google.com")
print(response.request.redirected_from) # None

```

### example_76fa4b1944457cd4b7d2334344fefeed5000705b35d7a138cb648a1129a8a159

```
async with page.expect_event("requestfinished") as request_info:
    await page.goto("http://example.com")
request = await request_info.value
print(request.timing)

```

### example_21bc2dce9e8c8b65dc1e8e1a6027ca43ec57cf5ff64deee99077733cebd62253

```
with page.expect_event("requestfinished") as request_info:
    page.goto("http://example.com")
request = request_info.value
print(request.timing)

```

### example_a9da256807ad7bc5787da691fc82b14b067741051d3d96c184e4e697dfaadede

```
async def handle(route, request):
    # override headers
    headers = {
        **request.headers,
        "foo": "foo-value" # set "foo" header
        "bar": None # remove "bar" header
    }
    await route.continue_(headers=headers)

await page.route("**/*", handle)

```

### example_8e6c4877e6e55a6646c407efa694ca2b35325d25a177ec9eda7392d589f460f6

```
def handle(route, request):
    # override headers
    headers = {
        **request.headers,
        "foo": "foo-value" # set "foo" header
        "bar": None # remove "bar" header
    }
    route.continue_(headers=headers)

page.route("**/*", handle)

```

### example_5a1b25856c2e94c50fd5664e02964d1afd6d840d6c6a3602ee6b8c4a7eaf5193

```
await page.route("**/*", lambda route: route.abort())  # Runs last.
await page.route("**/*", lambda route: route.fallback())  # Runs second.
await page.route("**/*", lambda route: route.fallback())  # Runs first.

```

### example_4dba0de94a24d0de1d6c888253b7c7295e931fb54ac2051cefe15102a3a1ea84

```
page.route("**/*", lambda route: route.abort())  # Runs last.
page.route("**/*", lambda route: route.fallback())  # Runs second.
page.route("**/*", lambda route: route.fallback())  # Runs first.

```

### example_85faf1b8f4fc6de3ee04b4e2a4851478912bcd52c29ac0a9d81a75e4a74a5c23

```
# Handle GET requests.
def handle_post(route):
    if route.request.method != "GET":
        route.fallback()
        return
  # Handling GET only.
  # ...

# Handle POST requests.
def handle_post(route):
    if route.request.method != "POST":
        route.fallback()
        return
  # Handling POST only.
  # ...

await page.route("**/*", handle_get)
await page.route("**/*", handle_post)

```

### example_f34f68524339404dcaf6b44a69dd897c8841025e4870e6247f3e0cb64d6d8d50

```
# Handle GET requests.
def handle_post(route):
    if route.request.method != "GET":
        route.fallback()
        return
  # Handling GET only.
  # ...

# Handle POST requests.
def handle_post(route):
    if route.request.method != "POST":
        route.fallback()
        return
  # Handling POST only.
  # ...

page.route("**/*", handle_get)
page.route("**/*", handle_post)

```

### example_ba1031939a1b970b94dc8d8a1394e0ebf19aaf5d44eed16bf4e832888397bcfd

```
async def handle(route, request):
    # override headers
    headers = {
        **request.headers,
        "foo": "foo-value" # set "foo" header
        "bar": None # remove "bar" header
    }
    await route.fallback(headers=headers)

await page.route("**/*", handle)

```

### example_427da5039b64cbfd74a02afe147db3da6392eb5812c872722bae349ec2af04f7

```
def handle(route, request):
    # override headers
    headers = {
        **request.headers,
        "foo": "foo-value" # set "foo" header
        "bar": None # remove "bar" header
    }
    route.fallback(headers=headers)

page.route("**/*", handle)

```

### example_4a076d47c9f849e2ca57423937c13605083c7201e2f45fa36030a143ba27ec01

```
await page.route("**/*", lambda route: route.fulfill(
    status=404,
    content_type="text/plain",
    body="not found!"))

```

### example_c247074da17f235a5053019429413324002ae4ead5cc6a1afe8fa05211e83bd6

```
page.route("**/*", lambda route: route.fulfill(
    status=404,
    content_type="text/plain",
    body="not found!"))

```

### example_9a7610b98fe51671faea12afd7ddcf2eba2914a6dd1cd60cf00382833ed55105

```
await page.route("**/xhr_endpoint", lambda route: route.fulfill(path="mock_data.json"))

```

### example_b517c4af01a97518ee777cc3cf0f29316c1838eaf8e0fd7253e0d4b4a9590140

```
page.route("**/xhr_endpoint", lambda route: route.fulfill(path="mock_data.json"))

```

### example_26fdb75d3fe4e80f629487f25c35515d365860e505e0977afcb20dd5d78235c8

```
await page.keyboard.type("Hello World!")
await page.keyboard.press("ArrowLeft")
await page.keyboard.down("Shift")
for i in range(6):
    await page.keyboard.press("ArrowLeft")
await page.keyboard.up("Shift")
await page.keyboard.press("Backspace")
# result text will end up saying "Hello!"

```

### example_19a77495692b3afbd629d289f1aadabc0fd088677467a575846b1feec3051458

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

### example_87f353333929066f58d052e716ef214077a81be6bf1bc24c032ebe79a44163ca

```
await page.keyboard.press("Shift+KeyA")
# or
await page.keyboard.press("Shift+A")

```

### example_18b2427ff9a00609db64c555409debfafdfdc9695c26b2a09ede974ae1f10786

```
page.keyboard.press("Shift+KeyA")
# or
page.keyboard.press("Shift+A")

```

### example_a02bb1f3511c4cccffee3b291e4066418af6755e719fcccad4b798368b0d2a26

```
# on windows and linux
await page.keyboard.press("Control+A")
# on mac_os
await page.keyboard.press("Meta+A")

```

### example_d8372cc5ab4f4a816e0ffec961c3802d82562db37ed49a2e8df7ec5a88d3603a

```
# on windows and linux
page.keyboard.press("Control+A")
# on mac_os
page.keyboard.press("Meta+A")

```

### example_fb0a4454fb1b47814df4a012361a55dd89935f9679f8d562fc28a0d6d09b681b

```
await page.keyboard.insert_text("嗨")

```

### example_9c4592c489be2b1ddf0b5eed3e3bfecbdb001c4af918115d5011f3ff01d95ef6

```
page.keyboard.insert_text("嗨")

```

### example_9cf34d1b8089c7c78b22be1e423a512a140c63aaa15df97acdd00f1ee6f899c6

```
page = await browser.new_page()
await page.goto("https://keycode.info")
await page.keyboard.press("a")
await page.screenshot(path="a.png")
await page.keyboard.press("ArrowLeft")
await page.screenshot(path="arrow_left.png")
await page.keyboard.press("Shift+O")
await page.screenshot(path="o.png")
await browser.close()

```

### example_e9c1ca558c39e9b93a6f51b294f4b157eff8285a28e4b80994d2b6fa0632dfad

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

### example_c9d633f2ee63eb8ddcbe6cca7370621fe19b56d8b23faed55ad96584f7c358a8

```
await page.keyboard.type("Hello") # types instantly
await page.keyboard.type("World", delay=100) # types slower, like a user

```

### example_b88ab9f788db040043a217be7557a2c809804cbd42f4988d47668c8dc792c1b3

```
page.keyboard.type("Hello") # types instantly
page.keyboard.type("World", delay=100) # types slower, like a user

```

### example_adbe40ae54d19e3e57a3e18ea638c1d3380fec4520e1e81fd841612512c66cf4

```
# using ‘page.mouse’ to trace a 100x100 square.
await page.mouse.move(0, 0)
await page.mouse.down()
await page.mouse.move(0, 100)
await page.mouse.move(100, 100)
await page.mouse.move(100, 0)
await page.mouse.move(0, 0)
await page.mouse.up()

```

### example_4c269cf509274f0565d4307f2e48580958b5f12bb8a39f326fc747707dc4c101

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

### example_17146524853cd5b870cf5c993385a7126575cf88028e7d90169004a05aa04837

```
window_handle = await page.evaluate_handle("window")
# ...

```

### example_3c7d10533f6a8963517e3163c66a67a91d9a8949f5ec46eff99a34c00f0d7b44

```
window_handle = page.evaluate_handle("window")
# ...

```

### example_74096f4c9d345dfdae2af95915fa304cfa139510c2609f4922da0f226438c1a7

```
tweet_handle = await page.query_selector(".tweet .retweets")
assert await tweet_handle.evaluate("node => node.innerText") == "10 retweets"

```

### example_ce17e3fa4ba162c686f91326e6eb216dc476d2193eb618d4755bd0bb5d6e8ca9

```
tweet_handle = page.query_selector(".tweet .retweets")
assert tweet_handle.evaluate("node => node.innerText") == "10 retweets"

```

### example_bcf32c51c8d6ea2c9147accc061ad381155e791596499a2fc217c37ac35d06ca

```
handle = await page.evaluate_handle("({window, document})")
properties = await handle.get_properties()
window_handle = properties.get("window")
document_handle = properties.get("document")
await handle.dispose()

```

### example_cb9a1c6393e8de14b45b2797c873237d62c714015fb69c5b8cd32a6cfc7159f2

```
handle = page.evaluate_handle("({window, document})")
properties = handle.get_properties()
window_handle = properties.get("window")
document_handle = properties.get("document")
handle.dispose()

```

### example_003ef5265c6b438ccc97356a1b004a18ae9c6afdd6727e2f1e41e31f60aebb6a

```
href_element = await page.query_selector("a")
await href_element.click()

```

### example_be421f129af285cf4c6b484f87db60a9b81fa8d5676b8fd00204278745ee2b0a

```
href_element = page.query_selector("a")
href_element.click()

```

### example_0136bef886b574bfb5a6616e81aad697f5de56022031a4a8c600cb9cfaf60258

```
handle = await page.query_selector("text=Submit")
await handle.hover()
await handle.click()

```

### example_0ebc13ab09503c7e9c706b9794050b99245358c59377cc2eb7badef3d67c08e2

```
handle = page.query_selector("text=Submit")
handle.hover()
handle.click()

```

### example_0769d09c1bea4cf82aff6712966483dca3e26b7db120faa744de14c6542247bb

```
locator = page.get_by_text("Submit")
await locator.hover()
await locator.click()

```

### example_b5ee113cf8244bdd6213cc47f922eb4fbc97058ce0e4cd679811f8bdc23960ba

```
locator = page.get_by_text("Submit")
locator.hover()
locator.click()

```

### example_95802fdf636a746395c07cb19cfe2eefe6e370c449ce9b62c8fc50a6e94c1eac

```
box = await element_handle.bounding_box()
await page.mouse.click(box["x"] + box["width"] / 2, box["y"] + box["height"] / 2)

```

### example_b0a076e71b9a3250d782bc17362a158419f0d5be9efd80d9974cc671290c4f0b

```
box = element_handle.bounding_box()
page.mouse.click(box["x"] + box["width"] / 2, box["y"] + box["height"] / 2)

```

### example_93c2c58690aec8371e806dd3bfcc855ca4a303db42db3315b3eba045ff99b7b4

```
await element_handle.dispatch_event("click")

```

### example_999e06ce7abd21fae51950cb2e5ca29afca67e947db2fa3c59b40ee49d6c2e22

```
element_handle.dispatch_event("click")

```

### example_6e7b29e37e6e72e5921acf40777e7aa6fa39a76fbd538c1197344beab6df75da

```
# note you can only create data_transfer in chromium and firefox
data_transfer = await page.evaluate_handle("new DataTransfer()")
await element_handle.dispatch_event("#source", "dragstart", {"dataTransfer": data_transfer})

```

### example_a59abead73af578fd1627f5034369fef4da1e0abfa30ba784a81c4a07f77f7b6

```
# note you can only create data_transfer in chromium and firefox
data_transfer = page.evaluate_handle("new DataTransfer()")
element_handle.dispatch_event("#source", "dragstart", {"dataTransfer": data_transfer})

```

### example_d5e7d0a8ab397cda203833c19b7db68e19b5444a57b506a9106adf62edc5a831

```
tweet_handle = await page.query_selector(".tweet")
assert await tweet_handle.eval_on_selector(".like", "node => node.innerText") == "100"
assert await tweet_handle.eval_on_selector(".retweets", "node => node.innerText") = "10"

```

### example_d894a05ee8eb9e84de356c3aa6e76a50751bd662a32f7e5d536e9b4dd9b84517

```
tweet_handle = page.query_selector(".tweet")
assert tweet_handle.eval_on_selector(".like", "node => node.innerText") == "100"
assert tweet_handle.eval_on_selector(".retweets", "node => node.innerText") = "10"

```

### example_1b7d8b5c0dd59ffb49c78009c8c9e1facfe80745abf04dff833eca6569eea2c8

```
feed_handle = await page.query_selector(".feed")
assert await feed_handle.eval_on_selector_all(".tweet", "nodes => nodes.map(n => n.innerText)") == ["hello!", "hi!"]

```

### example_0dede309377308fdeba1b3c1e79630ed9bcd66e3511a044ea55adf3ea29ed64e

```
feed_handle = page.query_selector(".feed")
assert feed_handle.eval_on_selector_all(".tweet", "nodes => nodes.map(n => n.innerText)") == ["hello!", "hi!"]

```

### example_66a6046454a334951dc465668acae4c6e9f3de8c21a1814f80374198ddf6be25

```
# single selection matching the value
await handle.select_option("blue")
# single selection matching the label
await handle.select_option(label="blue")
# multiple selection
await handle.select_option(value=["red", "green", "blue"])

```

### example_535adfb17f00750f09fae7dbeeea286e2797fa6ba94520e9ec700d61f128444f

```
# single selection matching the value
handle.select_option("blue")
# single selection matching both the label
handle.select_option(label="blue")
# multiple selection
handle.select_option(value=["red", "green", "blue"])

```

### example_e1fa0225bea06160bdcd5cdfd920eb2fb5bc11334ce6ab63ddd2a188238ace14

```
await element_handle.type("hello") # types instantly
await element_handle.type("world", delay=100) # types slower, like a user

```

### example_dd510898fda0f6d62a7c98bd3232a1369b0d8d0464306142b02cab91fa6f3e8d

```
element_handle.type("hello") # types instantly
element_handle.type("world", delay=100) # types slower, like a user

```

### example_0ffabfcaadde559721b819f25825d124d67c0718862e2588261eeb127d671c48

```
element_handle = await page.query_selector("input")
await element_handle.type("some text")
await element_handle.press("Enter")

```

### example_f0fdb7a804e04e6285d250115e31516afe3046209233377aedcd13c8c57e0ca6

```
element_handle = page.query_selector("input")
element_handle.type("some text")
element_handle.press("Enter")

```

### example_e7820ad3695f5e6071e3be60147b794eaa8a026e67ef3617f8445418d9980511

```
await page.set_content("<div><span></span></div>")
div = await page.query_selector("div")
# waiting for the "span" selector relative to the div.
span = await div.wait_for_selector("span", state="attached")

```

### example_7d8545f5c597d3ad1ae485d6ad97200ce3c70b16addf2679237c460e1b0c394f

```
page.set_content("<div><span></span></div>")
div = page.query_selector("div")
# waiting for the "span" selector relative to the div.
span = div.wait_for_selector("span", state="attached")

```

### example_d2caa2d871e91e70d303b96634b06cf6a7ab99de947c8510794204827f0f8a83

```
snapshot = await page.accessibility.snapshot()
print(snapshot)

```

### example_321883625cabef121ccada23e807b2759d691bb929ba34843cc78a2219a71b10

```
snapshot = page.accessibility.snapshot()
print(snapshot)

```

### example_b21345cac0c9e7f5abb1ba36c1093be03c489d8fcdf4f018aecc07f062dee563

```
def find_focused_node(node):
    if (node.get("focused"))
        return node
    for child in (node.get("children") or []):
        found_node = find_focused_node(child)
        if (found_node)
            return found_node
    return None

snapshot = await page.accessibility.snapshot()
node = find_focused_node(snapshot)
if node:
    print(node["name"])

```

### example_3f5026589176f924fc99775945d7919c977e8c88f9fd94771bbcf7156853b9a4

```
def find_focused_node(node):
    if (node.get("focused"))
        return node
    for child in (node.get("children") or []):
        found_node = find_focused_node(child)
        if (found_node)
            return found_node
    return None

snapshot = page.accessibility.snapshot()
node = find_focused_node(snapshot)
if node:
    print(node["name"])

```

### example_7a1d0490f41c1b1ab1ebd7495fafd769b4f337b4755d19af4785796c8ac3e121

```
async with page.expect_file_chooser() as fc_info:
    await page.get_by_text("Upload file").click()
file_chooser = await fc_info.value
await file_chooser.set_files("myfile.pdf")

```

### example_e33aff4cd491e76d860c1c5498a25a331b0b99cae9c161baeea0f3190552e2d1

```
with page.expect_file_chooser() as fc_info:
    page.get_by_text("Upload file").click()
file_chooser = fc_info.value
file_chooser.set_files("myfile.pdf")

```

### example_175fd16e6b0841edb87c9aee59a0b516c765c7306ca63ce0157360dbf853f881

```
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    firefox = playwright.firefox
    browser = await firefox.launch()
    page = await browser.new_page()
    await page.goto("https://www.theverge.com")
    dump_frame_tree(page.main_frame, "")
    await browser.close()

def dump_frame_tree(frame, indent):
    print(indent + frame.name + '@' + frame.url)
    for child in frame.child_frames:
        dump_frame_tree(child, indent + "    ")

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

### example_eba0a73d122f4092a4a4d63dd7b1c6c5f42bffaaa995bfe8b5ebd710f57537a4

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

### example_c62b55d6fab824aee86cb8a7e59a61e5046977ad9cded5ca191797783113a116

```
await frame.dispatch_event("button#submit", "click")

```

### example_8563baa1d3c1890559d7c4f7108ce9a70722d9f7ff41e6a4a6ca11c3bac79601

```
frame.dispatch_event("button#submit", "click")

```

### example_9e3753444751db32be227c85448a0a4bb9368d7588ea0261bf5d019ca75330a3

```
# note you can only create data_transfer in chromium and firefox
data_transfer = await frame.evaluate_handle("new DataTransfer()")
await frame.dispatch_event("#source", "dragstart", { "dataTransfer": data_transfer })

```

### example_b3223f34267568b0a81da5b2ca3b75dfc3c7996a9a2d588ef5da310e897d8a3c

```
# note you can only create data_transfer in chromium and firefox
data_transfer = frame.evaluate_handle("new DataTransfer()")
frame.dispatch_event("#source", "dragstart", { "dataTransfer": data_transfer })

```

### example_e31ee0acc0eddc6723acf0bed10173080440eaed71813ec4a490803646e7b346

```
search_value = await frame.eval_on_selector("#search", "el => el.value")
preload_href = await frame.eval_on_selector("link[rel=preload]", "el => el.href")
html = await frame.eval_on_selector(".main-container", "(e, suffix) => e.outerHTML + suffix", "hello")

```

### example_dee76da85498e028e59ce16468316429c6e604abed984f213ab3342125bbe83e

```
search_value = frame.eval_on_selector("#search", "el => el.value")
preload_href = frame.eval_on_selector("link[rel=preload]", "el => el.href")
html = frame.eval_on_selector(".main-container", "(e, suffix) => e.outerHTML + suffix", "hello")

```

### example_9926f4d8ce7d10cf6769357f6307501e1a934bb9f5c4ee027f34735568e278ed

```
divs_counts = await frame.eval_on_selector_all("div", "(divs, min) => divs.length >= min", 10)

```

### example_95cf43dae25f1a42399dadafdb382b2e6039f679b22480028306b9d0c9ac6644

```
divs_counts = frame.eval_on_selector_all("div", "(divs, min) => divs.length >= min", 10)

```

### example_731b92cfb2a6e7b10c9e431f61eade78981095370b537b5ddafc08e3c265feaf

```
result = await frame.evaluate("([x, y]) => Promise.resolve(x * y)", [7, 8])
print(result) # prints "56"

```

### example_2ceb005a189affdaae9fdefa7b8b6a8177e6ce393c691e96371e761893e97e18

```
result = frame.evaluate("([x, y]) => Promise.resolve(x * y)", [7, 8])
print(result) # prints "56"

```

### example_72471bba25eb55af92715405b999fab369561bb31e0c6d05d9ea253a5a9d1eac

```
print(await frame.evaluate("1 + 2")) # prints "3"
x = 10
print(await frame.evaluate(f"1 + {x}")) # prints "11"

```

### example_d93dd3af855b542980415a68ed9fe272670097f783558d4b155a9b2edd8e21e2

```
print(frame.evaluate("1 + 2")) # prints "3"
x = 10
print(frame.evaluate(f"1 + {x}")) # prints "11"

```

### example_7801394beb3a8d89e170432d8f5a4984941b7bac238b4b3b1e1bfa51ab2cc643

```
body_handle = await frame.evaluate("document.body")
html = await frame.evaluate("([body, suffix]) => body.innerHTML + suffix", [body_handle, "hello"])
await body_handle.dispose()

```

### example_91e777aa2bcf88bd0a1deaea03e28b99a6cc3a69703ea8f92f69207f0b4f44d8

```
body_handle = frame.evaluate("document.body")
html = frame.evaluate("([body, suffix]) => body.innerHTML + suffix", [body_handle, "hello"])
body_handle.dispose()

```

### example_52f6c5c8f26a8e7c53153b939d9f254e4e31408422ccdcbc197cbc331949f35a

```
a_window_handle = await frame.evaluate_handle("Promise.resolve(window)")
a_window_handle # handle for the window object.

```

### example_4dc6725db9c6f5bc2a4114ad85bdbe92be629d471536442a8345c64f07a986c8

```
a_window_handle = frame.evaluate_handle("Promise.resolve(window)")
a_window_handle # handle for the window object.

```

### example_0d1e28bbd652512a14515e3b7379654bd71222d90d9c1c575814dfb169329380

```
a_handle = await page.evaluate_handle("document") # handle for the "document"

```

### example_c681f8996c058c7f3f0720775a87f75611457b7e8b94b9d645b2f44ca0ffbd39

```
a_handle = page.evaluate_handle("document") # handle for the "document"

```

### example_0ae18f20ef6bf91a018b5362e56c867ddfccad677610a2b1dbc628e159b88d56

```
a_handle = await page.evaluate_handle("document.body")
result_handle = await page.evaluate_handle("body => body.innerHTML", a_handle)
print(await result_handle.json_value())
await result_handle.dispose()

```

### example_da79d92242e58e9a49140f09273411ee9318e357d07fbdb2a63956f6cef638fa

```
a_handle = page.evaluate_handle("document.body")
result_handle = page.evaluate_handle("body => body.innerHTML", a_handle)
print(result_handle.json_value())
result_handle.dispose()

```

### example_56af94a7bf4e38d915ba3b38914ea4bb72f5403f52a3213999b7c7288c65352b

```
frame_element = await frame.frame_element()
content_frame = await frame_element.content_frame()
assert frame == content_frame

```

### example_fbce8bbd14c4b4000e080c9e3d6bcdaa849c31aef0ed2375b481c5d5d3e396a2

```
frame_element = frame.frame_element()
content_frame = frame_element.content_frame()
assert frame == content_frame

```

### example_f269b53c1792c35e0176da6eabdec5e71e9afe9a87d80b52f8f8a8f9a78c1960

```
locator = frame.frame_locator("#my-iframe").get_by_text("Submit")
await locator.click()

```

### example_56f3867098abaeccf774057a244744131b192e9700e88a3a1e6da916d452c486

```
locator = frame.frame_locator("#my-iframe").get_by_text("Submit")
locator.click()

```

### example_c6955d996988d22b00dab15c3992b7961b9814c65a49cf0681728cd32653553c

```
# Matches <span>
page.get_by_text("world")

# Matches first <div>
page.get_by_text("Hello world")

# Matches second <div>
page.get_by_text("Hello", exact=True)

# Matches both <div>s
page.get_by_text(re.compile("Hello"))

# Matches second <div>
page.get_by_text(re.compile("^hello$", re.IGNORECASE))

```

### example_c6955d996988d22b00dab15c3992b7961b9814c65a49cf0681728cd32653553c

```
# Matches <span>
page.get_by_text("world")

# Matches first <div>
page.get_by_text("Hello world")

# Matches second <div>
page.get_by_text("Hello", exact=True)

# Matches both <div>s
page.get_by_text(re.compile("Hello"))

# Matches second <div>
page.get_by_text(re.compile("^hello$", re.IGNORECASE))

```

### example_7c29a4e7e49b7b7a13107624cc32d4c3a9aaca7a5d9a3aa0e9618d876557cd7d

```
# single selection matching the value
await frame.select_option("select#colors", "blue")
# single selection matching the label
await frame.select_option("select#colors", label="blue")
# multiple selection
await frame.select_option("select#colors", value=["red", "green", "blue"])

```

### example_19e36d77b4eb60448e1d0ee4b7e702b5d75078eba306401a2c4ac26d41245c32

```
# single selection matching the value
frame.select_option("select#colors", "blue")
# single selection matching both the label
frame.select_option("select#colors", label="blue")
# multiple selection
frame.select_option("select#colors", value=["red", "green", "blue"])

```

### example_03b9b247956ab0b0bf574e387a4549ed2343a91f28338df4af3a95d54d408150

```
await frame.type("#mytextarea", "hello") # types instantly
await frame.type("#mytextarea", "world", delay=100) # types slower, like a user

```

### example_8f3e0d9b4038d73208e0c365595fc09ebf99de6eefda9f8010f357450e0c6695

```
frame.type("#mytextarea", "hello") # types instantly
frame.type("#mytextarea", "world", delay=100) # types slower, like a user

```

### example_ab1be034c9d5b5ffc8c8520417c934d61e5c86f9814343313917a890f96b2c9e

```
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    webkit = playwright.webkit
    browser = await webkit.launch()
    page = await browser.new_page()
    await page.evaluate("window.x = 0; setTimeout(() => { window.x = 100 }, 1000);")
    await page.main_frame.wait_for_function("() => window.x > 0")
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

### example_38741630ac091d734722fec3eed87a1c27894bd5911666c4c8cd526dd63ce359

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

### example_8e909d06071e97938c274dd45b053b104b2370990d55efc9a629799c3e4d101b

```
selector = ".foo"
await frame.wait_for_function("selector => !!document.querySelector(selector)", selector)

```

### example_6839e8d54ba0e660815f8175d26e07afa565f9df984d93dbbb8adfa9e080b924

```
selector = ".foo"
frame.wait_for_function("selector => !!document.querySelector(selector)", selector)

```

### example_83e3206eb7570f416e9d72fb3e8412e7f67acd9f27c2bd0bdca4686bb47ca97b

```
await frame.click("button") # click triggers navigation.
await frame.wait_for_load_state() # the promise resolves after "load" event.

```

### example_c128a8d89c6459508f13ba3df9befc21245b106de1402ca25b08d62a689ced63

```
frame.click("button") # click triggers navigation.
frame.wait_for_load_state() # the promise resolves after "load" event.

```

### example_0ecaca6f3bb7365bfb9b4de9bfbeb8c66abe5e8215482300d705a8ae4aad6ce9

```
async with frame.expect_navigation():
    await frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
# Resolves after navigation has finished

```

### example_a981f569233adde812187ebb512e515f82cd675f4abfd9616b5feae7119aed65

```
with frame.expect_navigation():
    frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
# Resolves after navigation has finished

```

### example_1ade1c9b9b3c2c1cc3883c412da42ce838f1bdcac87653bc067a58f15e64771a

```
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    chromium = playwright.chromium
    browser = await chromium.launch()
    page = await browser.new_page()
    for current_url in ["https://google.com", "https://bbc.com"]:
        await page.goto(current_url, wait_until="domcontentloaded")
        element = await page.main_frame.wait_for_selector("img")
        print("Loaded image: " + str(await element.get_attribute("src")))
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

### example_2d72f1ca5d1595557870054d84b0045c60acde8aa5ab85e96726294cd85082ee

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

### example_dcacaec290ce7eb5e165c5d601c52438794ec3c84aa24f8a247ddb569879930e

```
await frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
await frame.wait_for_url("**/target.html")

```

### example_34ddd17f8e72fe0ceaeb14bfe55b1e2ba4b3266ddde301f33700ae0f0ff10c2d

```
frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
frame.wait_for_url("**/target.html")

```

### example_8a096dcc3c2ce58eb6c0651d77e79fa1d126fccce8fc09055c52d34a2773e652

```
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
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
    await playwright.selectors.register("tag", tag_selector)
    browser = await playwright.chromium.launch()
    page = await browser.new_page()
    await page.set_content('<div><button>Click me</button></div>')

    # Use the selector prefixed with its name.
    button = await page.query_selector('tag=button')
    # Combine it with other selector engines.
    await page.locator('tag=div >> text="Click me"').click()
    # Can use it in any methods supporting selectors.
    button_count = await page.locator('tag=button').count()
    print(button_count)
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)

asyncio.run(main())

```

### example_4be2918da73e62c8b805729ca84070657a8006ae6faac3d88aa917b9526d66b2

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

### example_b90d8e782c1c573e6f11d8ece3fe3ad06c7ebd6eda60859a4f0544ad5131652d

```
# Listen for all console logs
page.on("console", lambda msg: print(msg.text))

# Listen for all console events and handle errors
page.on("console", lambda msg: print(f"error: {msg.text}") if msg.type == "error" else None)

# Get the next console log
async with page.expect_console_message() as msg_info:
    # Issue console.log inside the page
    await page.evaluate("console.log('hello', 42, { foo: 'bar' })")
msg = await msg_info.value

# Deconstruct print arguments
await msg.args[0].json_value() # hello
await msg.args[1].json_value() # 42

```

### example_9d404329108c69b16e9e327a86f38e44c10d28762278b5d7a3e5339f3d12cf1f

```
# Listen for all console logs
page.on("console", lambda msg: print(msg.text))

# Listen for all console events and handle errors
page.on("console", lambda msg: print(f"error: {msg.text}") if msg.type == "error" else None)

# Get the next console log
with page.expect_console_message() as msg_info:
    # Issue console.log inside the page
    page.evaluate("console.log('hello', 42, { foo: 'bar' })")
msg = msg_info.value

# Deconstruct print arguments
msg.args[0].json_value() # hello
msg.args[1].json_value() # 42

```

### example_7fb5b2cb8d04a1da91dc6f9c3ecf8c6cdbe0c605483cf46bbcca8bff5850ec95

```
import asyncio
from playwright.async_api import async_playwright

async def handle_dialog(dialog):
    print(dialog.message)
    await dialog.dismiss()

async def run(playwright):
    chromium = playwright.chromium
    browser = await chromium.launch()
    page = await browser.new_page()
    page.on("dialog", handle_dialog)
    page.evaluate("alert('1')")
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

### example_e0a400dda0b0b538703f892c5f970ba129b2144c40fbbf1a63dfa74d2a52df75

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

### example_31c8c0c365b2871c56ba48c85ab8152b3e538d01f399232ad3fb65918dafd7ea

```
async with page.expect_download() as download_info:
    await page.get_by_text("Download file").click()
download = await download_info.value
# waits for download to complete
path = await download.path()

```

### example_d5326a0e969ff7ff7651c944af492b72a2383b7479e4b5e244b0530c0ce494e0

```
with page.expect_download() as download_info:
    page.get_by_text("Download file").click()
download = download_info.value
# wait for download to complete
path = download.path()

```

### example_1dfeafea7c7b0910f24fb11812b1986c2d33d390dcb359f65be7939dda1d2a91

```
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    webkit = playwright.webkit
    browser = await webkit.launch()
    context = await browser.new_context()
    page = await context.new_page()
    await page.goto("https://example.com")
    await page.screenshot(path="screenshot.png")
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

### example_e027fe5e1873f79a9c674d8f1c3381779a26b8ba27e5a399a05a45d64b0ba543

```
from playwright.sync_api import sync_playwright

def run(playwright):
    webkit = playwright.webkit
    browser = webkit.launch()
    context = browser.new_context()
    page = context.new_page()
    page.goto("https://example.com")
    page.screenshot(path="screenshot.png")
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

### example_ed62aab6595b424bfd9cbea78b7c06c368a8e1259a669c32a8cfda20c88c8522

```
# in your playwright script, assuming the preload.js file is in same directory
await page.add_init_script(path="./preload.js")

```

### example_6a181945f3bf3f5bd126224414d8684a11032608e044f9b9df6edc06824a6fb7

```
# in your playwright script, assuming the preload.js file is in same directory
page.add_init_script(path="./preload.js")

```

### example_800167b5b3eff041b4b22f84e8f1075914134cf5e05870d74105f91bc0ed013c

```
await page.dispatch_event("button#submit", "click")

```

### example_117a7994860d77d1683229c004539a6366f7fe1ad564147589a53c07198f3d6d

```
page.dispatch_event("button#submit", "click")

```

### example_8f98ab370bd573982e1bef068245008734eb75829df17f32513fc0d0b7a6289c

```
# note you can only create data_transfer in chromium and firefox
data_transfer = await page.evaluate_handle("new DataTransfer()")
await page.dispatch_event("#source", "dragstart", { "dataTransfer": data_transfer })

```

### example_00b26820746466c8788341e55d126d6fc4c3774a518f24f14c164fcfd7c9ee4a

```
# note you can only create data_transfer in chromium and firefox
data_transfer = page.evaluate_handle("new DataTransfer()")
page.dispatch_event("#source", "dragstart", { "dataTransfer": data_transfer })

```

### example_e41549078b5dbb47eb44b1391e7a8e63736bee165e9d4fcdbecf23f0764816cd

```
await page.drag_and_drop("#source", "#target")
# or specify exact positions relative to the top-left corners of the elements:
await page.drag_and_drop(
  "#source",
  "#target",
  source_position={"x": 34, "y": 7},
  target_position={"x": 10, "y": 20}
)

```

### example_941e96397e47965399015d883bb0f48a496fe3273f1257b4b2e2b4e2c81a6411

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

### example_520445be43679bcf5047860b3055330c1f72c3d5228fd67a38f945c643801b34

```
await page.evaluate("matchMedia('screen').matches")
# → True
await page.evaluate("matchMedia('print').matches")
# → False

await page.emulate_media(media="print")
await page.evaluate("matchMedia('screen').matches")
# → False
await page.evaluate("matchMedia('print').matches")
# → True

await page.emulate_media()
await page.evaluate("matchMedia('screen').matches")
# → True
await page.evaluate("matchMedia('print').matches")
# → False

```

### example_261f35f0113e44cd815c2edf55623655a1d26b80e7c5104511d4270915ad095b

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

### example_fab77eafbb95ba57301ed81b60bc3c848e97b78b7e4cc1744a15ed8aefc3a685

```
await page.emulate_media(color_scheme="dark")
await page.evaluate("matchMedia('(prefers-color-scheme: dark)').matches")
# → True
await page.evaluate("matchMedia('(prefers-color-scheme: light)').matches")
# → False
await page.evaluate("matchMedia('(prefers-color-scheme: no-preference)').matches")
# → False

```

### example_08016bbdc751dd39fabd0c352ebed4edf349ab03e3e54815982d5abbb2cb3bac

```
page.emulate_media(color_scheme="dark")
page.evaluate("matchMedia('(prefers-color-scheme: dark)').matches")
# → True
page.evaluate("matchMedia('(prefers-color-scheme: light)').matches")
# → False
page.evaluate("matchMedia('(prefers-color-scheme: no-preference)').matches")

```

### example_83439858a8cc6fee4df60a574e73b4066b6d182bc821ada96de1adafdf13b258

```
search_value = await page.eval_on_selector("#search", "el => el.value")
preload_href = await page.eval_on_selector("link[rel=preload]", "el => el.href")
html = await page.eval_on_selector(".main-container", "(e, suffix) => e.outer_html + suffix", "hello")

```

### example_fbbf648e7e6e584f69180087098ee02252e9d942bf9f177d48183a17e9e9ce50

```
search_value = page.eval_on_selector("#search", "el => el.value")
preload_href = page.eval_on_selector("link[rel=preload]", "el => el.href")
html = page.eval_on_selector(".main-container", "(e, suffix) => e.outer_html + suffix", "hello")

```

### example_c382b058144338f04edb37e8484f01021e47153b94654f942b8cf9d852dfb0ef

```
div_counts = await page.eval_on_selector_all("div", "(divs, min) => divs.length >= min", 10)

```

### example_49c241e7ef571e55412dc2041f8c16fcb5fdf22fb221236879d59bc61ae7ff50

```
div_counts = page.eval_on_selector_all("div", "(divs, min) => divs.length >= min", 10)

```

### example_c7949c54234b8c330309fd90133fb90b942d87779faf3d66fce1f48a0b61e399

```
result = await page.evaluate("([x, y]) => Promise.resolve(x * y)", [7, 8])
print(result) # prints "56"

```

### example_cab05223e2a430fb202831c3c3de2a9732056bd1477b2a8f5907987a4cc40f56

```
result = page.evaluate("([x, y]) => Promise.resolve(x * y)", [7, 8])
print(result) # prints "56"

```

### example_da6342e7a94c20ccda60c84cc81b5a9eb4b5238249842dc7e9f03e86537d8756

```
print(await page.evaluate("1 + 2")) # prints "3"
x = 10
print(await page.evaluate(f"1 + {x}")) # prints "11"

```

### example_04e5e4cfd8ee566fe467dac01f8ea7688bd05794d946966508b0a2433a036f13

```
print(page.evaluate("1 + 2")) # prints "3"
x = 10
print(page.evaluate(f"1 + {x}")) # prints "11"

```

### example_37a982e70895a2ec993769d8288618d91bc177cf72db4529ff0ba1b5549bdea0

```
body_handle = await page.evaluate("document.body")
html = await page.evaluate("([body, suffix]) => body.innerHTML + suffix", [body_handle, "hello"])
await body_handle.dispose()

```

### example_3e25ebf63419b39d81c30f3f867f7528e90c16297d2cd9b71b0f2628c7865519

```
body_handle = page.evaluate("document.body")
html = page.evaluate("([body, suffix]) => body.innerHTML + suffix", [body_handle, "hello"])
body_handle.dispose()

```

### example_cbe313321f4f565a3cca3bc8f4666f90edf78435630502f2122a8d221a17eb0b

```
a_window_handle = await page.evaluate_handle("Promise.resolve(window)")
a_window_handle # handle for the window object.

```

### example_b9136581ad3e344d77f3892b38d86a5eb3f8f60fb570bb33b2bcb6a2ed7540da

```
a_window_handle = page.evaluate_handle("Promise.resolve(window)")
a_window_handle # handle for the window object.

```

### example_0d1e28bbd652512a14515e3b7379654bd71222d90d9c1c575814dfb169329380

```
a_handle = await page.evaluate_handle("document") # handle for the "document"

```

### example_c681f8996c058c7f3f0720775a87f75611457b7e8b94b9d645b2f44ca0ffbd39

```
a_handle = page.evaluate_handle("document") # handle for the "document"

```

### example_0ae18f20ef6bf91a018b5362e56c867ddfccad677610a2b1dbc628e159b88d56

```
a_handle = await page.evaluate_handle("document.body")
result_handle = await page.evaluate_handle("body => body.innerHTML", a_handle)
print(await result_handle.json_value())
await result_handle.dispose()

```

### example_da79d92242e58e9a49140f09273411ee9318e357d07fbdb2a63956f6cef638fa

```
a_handle = page.evaluate_handle("document.body")
result_handle = page.evaluate_handle("body => body.innerHTML", a_handle)
print(result_handle.json_value())
result_handle.dispose()

```

### example_a71d2863897d0c8fd95d967314e2e6d6c4b92f954d6c39ec51295b176ed98639

```
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    webkit = playwright.webkit
    browser = await webkit.launch(headless=false)
    context = await browser.new_context()
    page = await context.new_page()
    await page.expose_binding("pageURL", lambda source: source["page"].url)
    await page.set_content("""
    <script>
      async function onClick() {
        document.querySelector('div').textContent = await window.pageURL();
      }
    </script>
    <button onclick="onClick()">Click me</button>
    <div></div>
    """)
    await page.click("button")

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

### example_27bd6ac97df3c18b4ef059be4cada4a7a7f0ff077e1dbaf7ee5d629d2e85ae78

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

### example_1d453e776770bb6c0125978e84f80960f9f0a7ea4855c926ff7b2c8d15518d0f

```
async def print(source, element):
    print(await element.text_content())

await page.expose_binding("clicked", print, handle=true)
await page.set_content("""
  <script>
    document.addEventListener('click', event => window.clicked(event.target));
  </script>
  <div>Click me</div>
  <div>Or click me</div>
""")

```

### example_4fbc6553706c0a670332f7b69b50824ea49bac67dade2e9122dbbd4dec7e349a

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

### example_38a76ce9aed523164d04767aeed307d2bc6cb0b07aad3c3d86f4d73a55838568

```
import asyncio
import hashlib
from playwright.async_api import async_playwright

def sha256(text):
    m = hashlib.sha256()
    m.update(bytes(text, "utf8"))
    return m.hexdigest()


async def run(playwright):
    webkit = playwright.webkit
    browser = await webkit.launch(headless=False)
    page = await browser.new_page()
    await page.expose_function("sha256", sha256)
    await page.set_content("""
        <script>
          async function onClick() {
            document.querySelector('div').textContent = await window.sha256('PLAYWRIGHT');
          }
        </script>
        <button onclick="onClick()">Click me</button>
        <div></div>
    """)
    await page.click("button")

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

### example_02100c4444e1336b004a04e56143c14cb217bd04357885cc7316180281914552

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
    page = browser.new_page()
    page.expose_function("sha256", sha256)
    page.set_content("""
        <script>
          async function onClick() {
            document.querySelector('div').textContent = await window.sha256('PLAYWRIGHT');
          }
        </script>
        <button onclick="onClick()">Click me</button>
        <div></div>
    """)
    page.click("button")

with sync_playwright() as playwright:
    run(playwright)

```

### example_ca8dce78d29c9529fc726a800a93462958b10af0fb06d9884420ca2f43ede7b9

```
locator = page.frame_locator("#my-iframe").get_by_text("Submit")
await locator.click()

```

### example_6452b981d4f346d634923ce043402c2e3d242570afd83b9d1532e51b861640af

```
locator = page.frame_locator("#my-iframe").get_by_text("Submit")
locator.click()

```

### example_c6955d996988d22b00dab15c3992b7961b9814c65a49cf0681728cd32653553c

```
# Matches <span>
page.get_by_text("world")

# Matches first <div>
page.get_by_text("Hello world")

# Matches second <div>
page.get_by_text("Hello", exact=True)

# Matches both <div>s
page.get_by_text(re.compile("Hello"))

# Matches second <div>
page.get_by_text(re.compile("^hello$", re.IGNORECASE))

```

### example_c6955d996988d22b00dab15c3992b7961b9814c65a49cf0681728cd32653553c

```
# Matches <span>
page.get_by_text("world")

# Matches first <div>
page.get_by_text("Hello world")

# Matches second <div>
page.get_by_text("Hello", exact=True)

# Matches both <div>s
page.get_by_text(re.compile("Hello"))

# Matches second <div>
page.get_by_text(re.compile("^hello$", re.IGNORECASE))

```

### example_85018ca43f1966cedc30fc02b200bed7d73f654e0446b95db3856f3ac9f9d4e1

```
# generates a pdf with "screen" media type.
await page.emulate_media(media="screen")
await page.pdf(path="page.pdf")

```

### example_6ae1b99aa3ea6cd7a571de12031a563e7fc02f1f0b17958c263e0ba8395618f1

```
# generates a pdf with "screen" media type.
page.emulate_media(media="screen")
page.pdf(path="page.pdf")

```

### example_a28964a09dac76b60d9e88cf889662252e621173047b38387f2cf510ac1e3f08

```
page = await browser.new_page()
await page.goto("https://keycode.info")
await page.press("body", "A")
await page.screenshot(path="a.png")
await page.press("body", "ArrowLeft")
await page.screenshot(path="arrow_left.png")
await page.press("body", "Shift+O")
await page.screenshot(path="o.png")
await browser.close()

```

### example_2b3f0072bb23e7cbd8198467010305a4b63809c1f432d956f25b8bb5d6095df2

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

### example_8e341b80d87b75d20d31761c5d81a29f4979d2dcc83920bed57743678d0b0a9e

```
page = await browser.new_page()
await page.route("**/*.{png,jpg,jpeg}", lambda route: route.abort())
await page.goto("https://example.com")
await browser.close()

```

### example_f263344629e850e1219ce3efdb9283eeb6c6c1c2f33d331c3be7fcf9dfe96e27

```
page = browser.new_page()
page.route("**/*.{png,jpg,jpeg}", lambda route: route.abort())
page.goto("https://example.com")
browser.close()

```

### example_dda8a7b535c1a028cde1f84913c993315b3e5bb39bc37f88443cab25de02fd40

```
page = await browser.new_page()
await page.route(re.compile(r"(\.png$)|(\.jpg$)"), lambda route: route.abort())
await page.goto("https://example.com")
await browser.close()

```

### example_c95c3c6b06f099684f6c8b086b6c423137baa31396447cbbb756e3ad86b98771

```
page = browser.new_page()
page.route(re.compile(r"(\.png$)|(\.jpg$)"), lambda route: route.abort())
page.goto("https://example.com")
browser.close()

```

### example_e5cf80876bd0a46a6227fe2a84b67c8c277725e0b5d2629d992d2dd79990eaa5

```
def handle_route(route):
  if ("my-string" in route.request.post_data)
    route.fulfill(body="mocked-data")
  else
    route.continue_()
await page.route("/api/**", handle_route)

```

### example_fefc682f8619031abbe6afa4f1cb3a509ce6bf4da689b1f05a7cdf264cf01291

```
def handle_route(route):
  if ("my-string" in route.request.post_data)
    route.fulfill(body="mocked-data")
  else
    route.continue_()
page.route("/api/**", handle_route)

```

### example_92fba1d2324c392678327ffe5950b822e9031535a9dfeb40ceff1929d6141a93

```
# single selection matching the value
await page.select_option("select#colors", "blue")
# single selection matching the label
await page.select_option("select#colors", label="blue")
# multiple selection
await page.select_option("select#colors", value=["red", "green", "blue"])

```

### example_317f52caef6dc0e027ce05a27eb9ab37a692f592b585690e32be86952ee739d3

```
# single selection matching the value
page.select_option("select#colors", "blue")
# single selection matching both the label
page.select_option("select#colors", label="blue")
# multiple selection
page.select_option("select#colors", value=["red", "green", "blue"])

```

### example_4851705152b52b1417caf468eb7d14955a06be627a7a99abb3abecddf922ce6e

```
page = await browser.new_page()
await page.set_viewport_size({"width": 640, "height": 480})
await page.goto("https://example.com")

```

### example_61594bc3b6911efe5257180bd4330905c5e85ac5160bef8065e974e65acb5979

```
page = browser.new_page()
page.set_viewport_size({"width": 640, "height": 480})
page.goto("https://example.com")

```

### example_2d2b9d7e2fe1efe8e98c87e3942b5735479932de0f5a1cf34bd6505081e90be5

```
await page.type("#mytextarea", "hello") # types instantly
await page.type("#mytextarea", "world", delay=100) # types slower, like a user

```

### example_cb8aacbfa50c3c7929d638e7441078bc52be0e160fdaaf9595bcbd0e2b648489

```
page.type("#mytextarea", "hello") # types instantly
page.type("#mytextarea", "world", delay=100) # types slower, like a user

```

### example_50a05313ff0c0420679df115704d9a2b05f3ac38ae1f60cc124cf8038424b731

```
async with page.expect_event("framenavigated") as event_info:
    await page.get_by_role("button")
frame = await event_info.value

```

### example_0e9bb2e54a2b9ac634ff47e184ecce125ed6c6116d544a270aabdaa7d07aa211

```
with page.expect_event("framenavigated") as event_info:
    page.get_by_role("button")
frame = event_info.value

```

### example_a05818cc1560da9e71a3a591e690bc1cf4149053124b05b5540ae9b052f0f03a

```
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    webkit = playwright.webkit
    browser = await webkit.launch()
    page = await browser.new_page()
    await page.evaluate("window.x = 0; setTimeout(() => { window.x = 100 }, 1000);")
    await page.wait_for_function("() => window.x > 0")
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

### example_32b5a7bc501489d14a0bc27d3416a01b7abb402733588a04a0728196e5140cb3

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

### example_0db1e8ea8710b9a57ea2298490d7cc2eaab38ace0b3163fbc37270f37676b124

```
selector = ".foo"
await page.wait_for_function("selector => !!document.querySelector(selector)", selector)

```

### example_d9cffcfc0a1939f612248a9c0ef8ee53ddc650e0d6c9e092f50e70e1137c015c

```
selector = ".foo"
page.wait_for_function("selector => !!document.querySelector(selector)", selector)

```

### example_87ff554a532c3ad21f7279e805ddc1ea1d6a5e83cd22f4bf2d6876eeb970667a

```
await page.get_by_role("button").click() # click triggers navigation.
await page.wait_for_load_state() # the promise resolves after "load" event.

```

### example_4a982464576c7e9c51248c9279e9446b18084e973268c8eb67595b050ccab590

```
page.get_by_role("button").click() # click triggers navigation.
page.wait_for_load_state() # the promise resolves after "load" event.

```

### example_7fea1144705fad201a055f1ceb261eb8e66050fb044e5897413e73fb3e4b0d7c

```
async with page.expect_popup() as page_info:
    await page.get_by_role("button").click() # click triggers a popup.
popup = await page_info.value
# Wait for the "DOMContentLoaded" event.
await popup.wait_for_load_state("domcontentloaded")
print(await popup.title()) # popup is ready to use.

```

### example_a7addfa268423d8a1c52aeba3919ae79614f18b93db457da1292242a56d6621b

```
with page.expect_popup() as page_info:
    page.get_by_role("button").click() # click triggers a popup.
popup = page_info.value
# Wait for the "DOMContentLoaded" event.
popup.wait_for_load_state("domcontentloaded")
print(popup.title()) # popup is ready to use.

```

### example_29e37d3de68e80846769402da0d36aaa688c8047cef3b1e718ed62fe0995e166

```
async with page.expect_navigation():
    # This action triggers the navigation after a timeout.
    await page.get_by_text("Navigate after timeout").click()
# Resolves after navigation has finished

```

### example_4e1ff20ee93eb61c5a68f3d9ec8c84cb449775356be2fc24dbd8859bac6b74fe

```
with page.expect_navigation():
    # This action triggers the navigation after a timeout.
    page.get_by_text("Navigate after timeout").click()
# Resolves after navigation has finished

```

### example_7d3637cf1b1c39f6e3dde152d7bebdfc090caa5344dcd68108d8e61274e2281e

```
async with page.expect_request("http://example.com/resource") as first:
    await page.get_by_text("trigger request").click()
first_request = await first.value

# or with a lambda
async with page.expect_request(lambda request: request.url == "http://example.com" and request.method == "get") as second:
    await page.get_by_text("trigger request").click()
second_request = await second.value

```

### example_35f9b67d8d9ff416241657b566fa338f5a3fd06ddb1b6c5818e6d34280aea5c0

```
with page.expect_request("http://example.com/resource") as first:
    page.get_by_text("trigger request").click()
first_request = first.value

# or with a lambda
with page.expect_request(lambda request: request.url == "http://example.com" and request.method == "get") as second:
    page.get_by_text("trigger request").click()
second_request = second.value

```

### example_0c3ed1aea41d8149cf939321073cbbcf1f59e84015b6268bcfcd35df74840a03

```
async with page.expect_response("https://example.com/resource") as response_info:
    await page.get_by_text("trigger response").click()
response = await response_info.value
return response.ok

# or with a lambda
async with page.expect_response(lambda response: response.url == "https://example.com" and response.status == 200) as response_info:
    await page.get_by_text("trigger response").click()
response = await response_info.value
return response.ok

```

### example_0efc7ae161fdbcafb9598f37908dc61876ec40160ef6deea1e35e6488420d507

```
with page.expect_response("https://example.com/resource") as response_info:
    page.get_by_text("trigger response").click()
response = response_info.value
return response.ok

# or with a lambda
with page.expect_response(lambda response: response.url == "https://example.com" and response.status == 200) as response_info:
    page.get_by_text("trigger response").click()
response = response_info.value
return response.ok

```

### example_8fe0259d09f568eac9ef96ea8c867f167ad03baa2479377b0d53eb36ea0053e3

```
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    chromium = playwright.chromium
    browser = await chromium.launch()
    page = await browser.new_page()
    for current_url in ["https://google.com", "https://bbc.com"]:
        await page.goto(current_url, wait_until="domcontentloaded")
        element = await page.wait_for_selector("img")
        print("Loaded image: " + str(await element.get_attribute("src")))
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

### example_ae4e484f9c5130216d5ae358ed7195475c5f29da39931209982feb30e776fc05

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

### example_6870202af66b6074403a9a41198465dec21c41c7305f87ef21276aaa174eb361

```
# wait for 1 second
await page.wait_for_timeout(1000)

```

### example_df6f29d6ce17fe75b8813a95960b372ec97dee83b22f35878336eec8057797fd

```
# wait for 1 second
page.wait_for_timeout(1000)

```

### example_141a6aba0f23a37e614e60dfd4fe42b6225df9733b21e5e8140e6c912da981ca

```
await page.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
await page.wait_for_url("**/target.html")

```

### example_eaf38540aa7ddfa4b650e2eaba8fd60a5479e583663f73a6c5a406a86761732d

```
page.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
page.wait_for_url("**/target.html")

```

### example_020322a50b8dc608fa33c235a671e48663aa81f496f5d5dd13f687a3862591d8

```
# create a new incognito browser context
context = await browser.new_context()
# create a new page inside context.
page = await context.new_page()
await page.goto("https://example.com")
# dispose context once it is no longer needed.
await context.close()

```

### example_b91bf8bde66c133e16f010d447991b1face05f1dbbd19a63078650f239798d0b

```
# create a new incognito browser context
context = browser.new_context()
# create a new page inside context.
page = context.new_page()
page.goto("https://example.com")
# dispose context once it is no longer needed.
context.close()

```

### example_78d28363130d1792dbc1001974cb8f9385c7fa40ef65b0d87dda916438fa1ca5

```
await browser_context.add_cookies([cookie_object1, cookie_object2])

```

### example_fe865e261a072562c57af0b35937fe2014578f75d60089990774521e5c56be7c

```
browser_context.add_cookies([cookie_object1, cookie_object2])

```

### example_12d70c83325be78806c334a8f3bd1b717a54ba64d4df5fb997b3b492b9bc0d4a

```
# in your playwright script, assuming the preload.js file is in same directory.
await browser_context.add_init_script(path="preload.js")

```

### example_aa62e83764cf619192d335f2da300d285f4c10d6546a136b2507af4663cfa53a

```
# in your playwright script, assuming the preload.js file is in same directory.
browser_context.add_init_script(path="preload.js")

```

### example_c961afa052ca580c7a859ceb2e42bed2e7421b4522f41b3e0ed109ea7b593ca1

```
context = await browser.new_context()
await context.grant_permissions(["clipboard-read"])
# do stuff ..
context.clear_permissions()

```

### example_bc598e39b92e30b5450b944e776329c5281c86a75a1c241d9095f8bae0ee0313

```
context = browser.new_context()
context.grant_permissions(["clipboard-read"])
# do stuff ..
context.clear_permissions()

```

### example_60539b6e03d9e600dab8d44fdb4f42de0aa65a41d2244948f4746bb0691b8a2b

```
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    webkit = playwright.webkit
    browser = await webkit.launch(headless=false)
    context = await browser.new_context()
    await context.expose_binding("pageURL", lambda source: source["page"].url)
    page = await context.new_page()
    await page.set_content("""
    <script>
      async function onClick() {
        document.querySelector('div').textContent = await window.pageURL();
      }
    </script>
    <button onclick="onClick()">Click me</button>
    <div></div>
    """)
    await page.get_by_role("button").click()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

### example_c3e57462d511be77380e7f4e3a842043c543994b58256ed79f598d0d427ef3e5

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

### example_9a5b46c08a2631a58b2fe92b360b8ca420fbe73999bc11232a2aa5f3cc6a2ca4

```
async def print(source, element):
    print(await element.text_content())

await context.expose_binding("clicked", print, handle=true)
await page.set_content("""
  <script>
    document.addEventListener('click', event => window.clicked(event.target));
  </script>
  <div>Click me</div>
  <div>Or click me</div>
""")

```

### example_667879293e0c7fae47ee11d7f9302e8209888b77db7c701c0e47ce59484e444d

```
def print(source, element):
    print(element.text_content())

context.expose_binding("clicked", print, handle=true)
page.set_content("""
  <script>
    document.addEventListener('click', event => window.clicked(event.target));
  </script>
  <div>Click me</div>
  <div>Or click me</div>
""")

```

### example_d68353678001695a91e66fe0a2bf04023922ef20369f542fadc1e1e73131b383

```
import asyncio
import hashlib
from playwright.async_api import async_playwright

def sha256(text):
    m = hashlib.sha256()
    m.update(bytes(text, "utf8"))
    return m.hexdigest()


async def run(playwright):
    webkit = playwright.webkit
    browser = await webkit.launch(headless=False)
    context = await browser.new_context()
    await context.expose_function("sha256", sha256)
    page = await context.new_page()
    await page.set_content("""
        <script>
          async function onClick() {
            document.querySelector('div').textContent = await window.sha256('PLAYWRIGHT');
          }
        </script>
        <button onclick="onClick()">Click me</button>
        <div></div>
    """)
    await page.get_by_role("button").click()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

### example_828382ffa200879421f711ad0038d51ff0d60a8ff1e437930d170428f765ec07

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

### example_7040d21702f3f08ac71d49c7df013d85c00cb20141ea248241e51a33aa32413f

```
context = await browser.new_context()
page = await context.new_page()
await context.route("**/*.{png,jpg,jpeg}", lambda route: route.abort())
await page.goto("https://example.com")
await browser.close()

```

### example_df7146a147a3f30db5f1191b8dc36a953ce63e68613de6646daf776461879a34

```
context = browser.new_context()
page = context.new_page()
context.route("**/*.{png,jpg,jpeg}", lambda route: route.abort())
page.goto("https://example.com")
browser.close()

```

### example_987f6f946d8bccb9b13a36a1a22be986ab70b78e63ef0cfddfd0f7d4757be0ba

```
context = await browser.new_context()
page = await context.new_page()
await context.route(re.compile(r"(\.png$)|(\.jpg$)"), lambda route: route.abort())
page = await context.new_page()
await page.goto("https://example.com")
await browser.close()

```

### example_8b9f1b968d7727a6bb5a90587e19d26f2f4e8db804ef8c8c07e18a3f91620f45

```
context = browser.new_context()
page = context.new_page()
context.route(re.compile(r"(\.png$)|(\.jpg$)"), lambda route: route.abort())
page = await context.new_page()
page = context.new_page()
page.goto("https://example.com")
browser.close()

```

### example_cfc07cb3774fdf0af1e558f523a8aa19211b24bb2fcdf507366ee39b8f3a5f8f

```
def handle_route(route):
  if ("my-string" in route.request.post_data)
    route.fulfill(body="mocked-data")
  else
    route.continue_()
await context.route("/api/**", handle_route)

```

### example_e75265767423dfd5097f05e0922cb03bfb21fa0b4f0ea26373c8fb4f520a1952

```
def handle_route(route):
  if ("my-string" in route.request.post_data)
    route.fulfill(body="mocked-data")
  else
    route.continue_()
context.route("/api/**", handle_route)

```

### example_cba077118aa07126ab350d068577d6e6e773f1ded7f667591695968f1766e45f

```
await browser_context.set_geolocation({"latitude": 59.95, "longitude": 30.31667})

```

### example_9c8c7e9a664b97b3a7eced35b593c24fb5c390e420d3a8ff2a01a19f81b1c385

```
browser_context.set_geolocation({"latitude": 59.95, "longitude": 30.31667})

```

### example_d3b3b841e07375654a1816e40c1c523d3142f1ede064ff9e98fd5f2f8564d85f

```
async with context.expect_event("page") as event_info:
    await page.get_by_role("button").click()
page = await event_info.value

```

### example_eb91c13e380381cbdd6b7348784862bb703ed3742c390d96a4384f70125b3223

```
with context.expect_event("page") as event_info:
    page.get_by_role("button").click()
page = event_info.value

```

### example_5a71b3279416804f1a19f525b52e755d10f0019943360d0ca6394f03e15f3a59

```
client = await page.context.new_cdp_session(page)
await client.send("Animation.enable")
client.on("Animation.animationCreated", lambda: print("animation created!"))
response = await client.send("Animation.getPlaybackRate")
print("playback rate is " + str(response["playbackRate"]))
await client.send("Animation.setPlaybackRate", {
    playbackRate: response["playbackRate"] / 2
})

```

### example_fc0ffd4be81e3c4dac4dc6965d540a5656d93969a14f864fa722f037252b2848

```
client = page.context.new_cdp_session(page)
client.send("Animation.enable")
client.on("Animation.animationCreated", lambda: print("animation created!"))
response = client.send("Animation.getPlaybackRate")
print("playback rate is " + str(response["playbackRate"]))
client.send("Animation.setPlaybackRate", {
    playbackRate: response["playbackRate"] / 2
})

```

### example_f5c9c6dc93c87c0b6ac6dbb692a189539f8252930a4966ebc3a1dd68dad75e3c

```
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    firefox = playwright.firefox
    browser = await firefox.launch()
    page = await browser.new_page()
    await page.goto("https://example.com")
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

### example_a094ff37f6218e68d45cf46f74756adaca14d796014d8aa483537204eac0c14c

```
from playwright.sync_api import sync_playwright

def run(playwright):
    firefox = playwright.firefox
    browser = firefox.launch()
    page = browser.new_page()
    page.goto("https://example.com")
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

### example_5dcbbaa56b46c70c697229942fb3cc61129d598550a123625d4f1ec5f9e844a9

```
browser = await pw.webkit.launch()
print(len(browser.contexts())) # prints `0`
context = await browser.new_context()
print(len(browser.contexts())) # prints `1`

```

### example_31ccf8b183cccf81e84df3d50e2872e4aa71e6dc1a13270da4ac0da8ed27f81f

```
browser = pw.webkit.launch()
print(len(browser.contexts())) # prints `0`
context = browser.new_context()
print(len(browser.contexts())) # prints `1`

```

### example_86f075e015bf0da085ea967315d9b43f9b3fa455bb5a5af877e8b1086eb11ed0

```
browser = await playwright.firefox.launch() # or "chromium" or "webkit".
# create a new incognito browser context.
context = await browser.new_context()
# create a new page in a pristine context.
page = await context.new_page()
await page.goto("https://example.com")

# gracefully close up everything
await context.close()
await browser.close()

```

### example_9f9d052b43e67f65a6176ab4e169e57e2a2de518e66711b8d268601139aa9fb8

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

### example_aa372513cba86d24a8c95babf42c8545f9df9894c1f4986d119fb517290e27d8

```
await browser.start_tracing(page, path="trace.json")
await page.goto("https://www.google.com")
await browser.stop_tracing()

```

### example_1498031e3bdf580457eac0cb8d2b803fe6bcd25029a6be0412d385954a0c5090

```
browser.start_tracing(page, path="trace.json")
page.goto("https://www.google.com")
browser.stop_tracing()

```

### example_b8af68101a9c3416ce98d4a9e7dc7dbffbf2942c9a3302a5c9de83949c4f415d

```
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    chromium = playwright.chromium
    browser = await chromium.launch()
    page = await browser.new_page()
    await page.goto("https://example.com")
    # other actions...
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

### example_3129411f9b39671407a5ef7b3166b79c9a276343aeb2cddcb32a66d0dfe98b6a

```
from playwright.sync_api import sync_playwright

def run(playwright):
    chromium = playwright.chromium
    browser = chromium.launch()
    page = browser.new_page()
    page.goto("https://example.com")
    # other actions...
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

### example_e3394274245ab8a4232580a495133b7c8ffe4ff115de15beed2c172d0c529d58

```
browser = await playwright.chromium.connect_over_cdp("http://localhost:9222")
default_context = browser.contexts[0]
page = default_context.pages[0]

```

### example_d4cd91a13c9c84ee6e9768c603751b6386f0b46a15be0526e206196423a4abe4

```
browser = playwright.chromium.connect_over_cdp("http://localhost:9222")
default_context = browser.contexts[0]
page = default_context.pages[0]

```

### example_711634d1fa2c081d640b6e7a900b05c693ce5561753cfb1c1987aeb22db1654a

```
browser = await playwright.chromium.launch( # or "firefox" or "webkit".
    ignore_default_args=["--mute-audio"]
)

```

### example_6556c029d76ac60be292651bed6372b0512d228b6681172d26d388fbe2700af2

```
browser = playwright.chromium.launch( # or "firefox" or "webkit".
    ignore_default_args=["--mute-audio"]
)

```

### example_f16b97a99916b8c3dd5d17be75f2456d2e24138ddcef9224be19be9217f06900

```
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    chromium = playwright.chromium # or "firefox" or "webkit".
    browser = await chromium.launch()
    page = await browser.new_page()
    await page.goto("http://example.com")
    # other actions...
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

### example_de51b112ac2f009edc92122d874f024ca41676465fdb51adf3a1666399f3b728

```
from playwright.sync_api import sync_playwright

def run(playwright):
    chromium = playwright.chromium # or "firefox" or "webkit".
    browser = chromium.launch()
    page = browser.new_page()
    page.goto("http://example.com")
    # other actions...
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

### example_424229226d9940733b1ba360b13a618963ab827cd0e4f6114f5fe958fbf5cb3f

```
import asyncio
from playwright.async_api import async_playwright

async def run(playwright):
    webkit = playwright.webkit
    iphone = playwright.devices["iPhone 6"]
    browser = await webkit.launch()
    context = await browser.new_context(**iphone)
    page = await context.new_page()
    await page.goto("http://example.com")
    # other actions...
    await browser.close()

async def main():
    async with async_playwright() as playwright:
        await run(playwright)
asyncio.run(main())

```

### example_cd66fb063d6e600458c958cafa8fdc8e6654f2b43750a4ce590e884553127c8a

```
from playwright.sync_api import sync_playwright

def run(playwright):
    webkit = playwright.webkit
    iphone = playwright.devices["iPhone 6"]
    browser = webkit.launch()
    context = browser.new_context(**iphone)
    page = context.new_page()
    page.goto("http://example.com")
    # other actions...
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

### example_e079b42d1407d0e26318e717f2fda15ccd828010b65008e0d178620e4fe10727

```
browser = await chromium.launch()
context = await browser.new_context()
await context.tracing.start(screenshots=True, snapshots=True)
page = await context.new_page()
await page.goto("https://playwright.dev")
await context.tracing.stop(path = "trace.zip")

```

### example_a0f4f36f022cef400c035f754ff8466c79dbf1bd8d8bdca88b77063d40c2bf85

```
browser = chromium.launch()
context = browser.new_context()
context.tracing.start(screenshots=True, snapshots=True)
page = context.new_page()
page.goto("https://playwright.dev")
context.tracing.stop(path = "trace.zip")

```

### example_e288d6b68bb4b852c030dea31d2335abb1037c66a80367bbfb2cb1aa612a0240

```
await context.tracing.start(name="trace", screenshots=True, snapshots=True)
page = await context.new_page()
await page.goto("https://playwright.dev")
await context.tracing.stop(path = "trace.zip")

```

### example_32bf6a345ec98579c9299b22e8dbd26f7b3942297fd5619795ec0a0f61cf5f93

```
context.tracing.start(name="trace", screenshots=True, snapshots=True)
page = context.new_page()
page.goto("https://playwright.dev")
context.tracing.stop(path = "trace.zip")

```

### example_fa8100d21b7ff7f779b33ac24d368e36185ecaf336415bb86a38793bbf776e79

```
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

### example_9f83220984d3bbe679a6b42862c99279121cbe9b9e68e2500d1d0f2a8e97705b

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

### example_cfa34b2c623b4a590ee9b26b6165f2b3670ee9cd07f1f8daa93588c526e32451

```
box = await element.bounding_box()
await page.mouse.click(box["x"] + box["width"] / 2, box["y"] + box["height"] / 2)

```

### example_2577a5295157414174128624e2c79ce3742ff5752bed161d11505270ba02610f

```
box = element.bounding_box()
page.mouse.click(box["x"] + box["width"] / 2, box["y"] + box["height"] / 2)

```

### example_d618dd30ac13828f36d2e0a1dce74c3f5389c9b6b6745d6c119b0a66af150df8

```
await element.dispatch_event("click")

```

### example_efd2bea7fb1affc05245e1f451d40fa6a44063b0a4a180a14be943aa851d9ab0

```
element.dispatch_event("click")

```

### example_98ee89787a8212e3f7ba60f97472514f1924802dd49e17759fb7535e00547259

```
# note you can only create data_transfer in chromium and firefox
data_transfer = await page.evaluate_handle("new DataTransfer()")
await element.dispatch_event("#source", "dragstart", {"dataTransfer": data_transfer})

```

### example_34a5c61a96f8ef906b285eb829620a43735c2f59f14ecc0744f6c25cfb355947

```
# note you can only create data_transfer in chromium and firefox
data_transfer = page.evaluate_handle("new DataTransfer()")
element.dispatch_event("#source", "dragstart", {"dataTransfer": data_transfer})

```

### example_ff875cdc9bcaeed7ecccb5c7b55aaa4ce21f95144c204ce8ad45dea51761f556

```
source = page.locator("#source")
target = page.locator("#target")

await source.drag_to(target)
# or specify exact positions relative to the top-left corners of the elements:
await source.drag_to(
  target,
  source_position={"x": 34, "y": 7},
  target_position={"x": 10, "y": 20}
)

```

### example_b10561ae981a153c470e22850cce7617b8ac17e36024d4df42f0289f03de6837

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

### example_3fde7298eff9c0f67528980134ab22504089b4ed40a1bff1fa9548c9eec25011

```
tweets = page.locator(".tweet .retweets")
assert await tweets.evaluate("node => node.innerText") == "10 retweets"

```

### example_895807bd9867986347453eca7220409c312135e4c3facfa2f8d83fe5fe6f3649

```
tweets = page.locator(".tweet .retweets")
assert tweets.evaluate("node => node.innerText") == "10 retweets"

```

### example_1433660e197c6631f0c5635ff2b18a4ab710834e947a9e9e4b6cf309c98aa7da

```
elements = page.locator("div")
div_counts = await elements.evaluate_all("(divs, min) => divs.length >= min", 10)

```

### example_70418147f96b27cb0fb48d8d3fe1e3af1e59d46029b6139cbe0e6d7e1361ad41

```
elements = page.locator("div")
div_counts = elements.evaluate_all("(divs, min) => divs.length >= min", 10)

```

### example_f4d244f05ae747f66f94b5a3161171ee807e917f757d075b0303e6fea51a30f7

```
row_locator = page.locator("tr")
# ...
await row_locator
    .filter(has_text="text in column 1")
    .filter(has=page.get_by_role("button", name="column 2 button"))
    .screenshot()

```

### example_0f12efd79a918f362304f4a5d7e7bb760254cee823919121fe639877f8df94a9

```
row_locator = page.locator("tr")
# ...
row_locator
    .filter(has_text="text in column 1")
    .filter(has=page.get_by_role("button", name="column 2 button"))
    .screenshot()

```

### example_a68ee6bb2135004c094807abc47c7355f9661d6cbc3d8bb5eac917756dfd6e6f

```
locator = page.frame_locator("iframe").get_by_text("Submit")
await locator.click()

```

### example_d6dcf2277e215dd96b37a5171313ed8dc7ed66cb0b0a4cdf48b80b51ee9b18f8

```
locator = page.frame_locator("iframe").get_by_text("Submit")
locator.click()

```

### example_c6955d996988d22b00dab15c3992b7961b9814c65a49cf0681728cd32653553c

```
# Matches <span>
page.get_by_text("world")

# Matches first <div>
page.get_by_text("Hello world")

# Matches second <div>
page.get_by_text("Hello", exact=True)

# Matches both <div>s
page.get_by_text(re.compile("Hello"))

# Matches second <div>
page.get_by_text(re.compile("^hello$", re.IGNORECASE))

```

### example_c6955d996988d22b00dab15c3992b7961b9814c65a49cf0681728cd32653553c

```
# Matches <span>
page.get_by_text("world")

# Matches first <div>
page.get_by_text("Hello world")

# Matches second <div>
page.get_by_text("Hello", exact=True)

# Matches both <div>s
page.get_by_text(re.compile("Hello"))

# Matches second <div>
page.get_by_text(re.compile("^hello$", re.IGNORECASE))

```

### example_fe5ed4db5dd1163c85ca463cad7b9ddbdad92ee18c1e0e2b3f6486a51b908de2

```
# single selection matching the value or label
await element.select_option("blue")
# single selection matching the label
await element.select_option(label="blue")
# multiple selection for blue, red and second option
await element.select_option(value=["red", "green", "blue"])

```

### example_1e192b67d701475d337aef6eef9a4d48fe2679b63810d5d7f7c9f7598fe4e43e

```
# single selection matching the value or label
element.select_option("blue")
# single selection matching the label
element.select_option(label="blue")
# multiple selection for blue, red and second option
element.select_option(value=["red", "green", "blue"])

```

### example_997f50bb1b869c17ebcea0484f7e6c173d52c554cb973bce61c47bae0700956c

```
await element.type("hello") # types instantly
await element.type("world", delay=100) # types slower, like a user

```

### example_9625efb170dd15a824259f363a8eb286ab03df35b93015fcf408ba1d44c18d8b

```
element.type("hello") # types instantly
element.type("world", delay=100) # types slower, like a user

```

### example_377406c5b83b0dfb0139c2ea63f828d3c944b8afc9efce95a632ccd92477845a

```
element = page.get_by_label("Password")
await element.type("my password")
await element.press("Enter")

```

### example_30af71a32179d7582eeffc07e15c87899ec06088cc6e1fd68c9b74608542302b

```
element = page.get_by_label("Password")
element.type("my password")
element.press("Enter")

```

### example_c9838fba05979f539519b1416778be185d105ea6be591feefcaaca79dff13eb4

```
order_sent = page.locator("#order-sent")
await order_sent.wait_for()

```

### example_2c6e3463aca5430cf8b7dc63f4e347596b22d8807bd9a6a37670512d9d14aed0

```
order_sent = page.locator("#order-sent")
order_sent.wait_for()

```

### example_7085c284c1726494e43688ac754f9dcdbd38bf93ee7128ba1134458327c05c2f

```
locator = page.frame_locator("#my-frame").get_by_text("Submit")
await locator.click()

```

### example_791cecc9e970e61b183e25aef1c21c7d50779ad7bbf4ce88373237c3d1d0600e

```
locator = page.frame_locator("my-frame").get_by_text("Submit")
locator.click()

```

### example_8935c3bfed74b0c267484faa26906377c7118db6a12dcad300ffd932b6a4662c

```
# Throws if there are several frames in DOM:
await page.frame_locator('.result-frame').get_by_role('button').click()

# Works because we explicitly tell locator to pick the first frame:
await page.frame_locator('.result-frame').first.get_by_role('button').click()

```

### example_dbf7936cee6e1ca1a2609de3b6929703f05249e6dee4c5c47eb41e7cc6aea6af

```
# Throws if there are several frames in DOM:
page.frame_locator('.result-frame').get_by_role('button').click()

# Works because we explicitly tell locator to pick the first frame:
page.frame_locator('.result-frame').first.get_by_role('button').click()

```

### example_dea11e67882ec5fb3ab3a1d1cce87136bc78b06fa49a32c0278a43e93278a9fd

```
frameLocator = locator.frame_locator(":scope")

```

### example_dea11e67882ec5fb3ab3a1d1cce87136bc78b06fa49a32c0278a43e93278a9fd

```
frameLocator = locator.frame_locator(":scope")

```

### example_c6955d996988d22b00dab15c3992b7961b9814c65a49cf0681728cd32653553c

```
# Matches <span>
page.get_by_text("world")

# Matches first <div>
page.get_by_text("Hello world")

# Matches second <div>
page.get_by_text("Hello", exact=True)

# Matches both <div>s
page.get_by_text(re.compile("Hello"))

# Matches second <div>
page.get_by_text(re.compile("^hello$", re.IGNORECASE))

```

### example_c6955d996988d22b00dab15c3992b7961b9814c65a49cf0681728cd32653553c

```
# Matches <span>
page.get_by_text("world")

# Matches first <div>
page.get_by_text("Hello world")

# Matches second <div>
page.get_by_text("Hello", exact=True)

# Matches both <div>s
page.get_by_text(re.compile("Hello"))

# Matches second <div>
page.get_by_text(re.compile("^hello$", re.IGNORECASE))

```

### example_4f0529be9a259a20e30c3048d99dfc039ddb85955b57f7d4537067cd202e110c

```
import asyncio
from playwright.async_api import async_playwright, Playwright

async def run(playwright: Playwright):
    context = await playwright.request.new_context()
    response = await context.get("https://example.com/user/repos")
    assert response.ok
    assert response.status == 200
    assert response.headers["content-type"] == "application/json; charset=utf-8"
    assert response.json()["name"] == "foobar"
    assert await response.body() == '{"status": "ok"}'


async def main():
    async with async_playwright() as playwright:
        await run(playwright)

asyncio.run(main())

```

### example_d3853ee82c5e37c48d2014a4a0044137503aaeebb1ecad637f435e289ca5314e

```
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    context = playwright.request.new_context()
    response = context.get("https://example.com/user/repos")
    assert response.ok
    assert response.status == 200
    assert response.headers["content-type"] == "application/json; charset=utf-8"
    assert response.json()["name"] == "foobar"
    assert response.body() == '{"status": "ok"}'

```

### example_a30f9eae2e25de037b24a4e9f9e581276f2c311c2b371bae45c674ce7725fcb3

```
import os
import asyncio
from playwright.async_api import async_playwright, Playwright

REPO = "test-repo-1"
USER = "github-username"
API_TOKEN = os.getenv("GITHUB_API_TOKEN")

async def run(playwright: Playwright):
    # This will launch a new browser, create a context and page. When making HTTP
    # requests with the internal APIRequestContext (e.g. `context.request` or `page.request`)
    # it will automatically set the cookies to the browser page and vice versa.
    browser = await playwright.chromium.launch()
    context = await browser.new_context(base_url="https://api.github.com")
    api_request_context = context.request
    page = await context.new_page()

    # Alternatively you can create a APIRequestContext manually without having a browser context attached:
    # api_request_context = await playwright.request.new_context(base_url="https://api.github.com")

    # Create a repository.
    response = await api_request_context.post(
        "/user/repos",
        headers={
            "Accept": "application/vnd.github.v3+json",
            # Add GitHub personal access token.
            "Authorization": f"token {API_TOKEN}",
        },
        data={"name": REPO},
    )
    assert response.ok
    assert response.json()["name"] == REPO

    # Delete a repository.
    response = await api_request_context.delete(
        f"/repos/{USER}/{REPO}",
        headers={
            "Accept": "application/vnd.github.v3+json",
            # Add GitHub personal access token.
            "Authorization": f"token {API_TOKEN}",
        },
    )
    assert response.ok
    assert await response.body() == '{"status": "ok"}'

async def main():
    async with async_playwright() as playwright:
        await run(playwright)

asyncio.run(main())

```

### example_f1a7733c566fc0cb7b623faae53f65ea39a74c73c92ef0d8b59448c183f3eee9

```
import os
from playwright.sync_api import sync_playwright

REPO = "test-repo-1"
USER = "github-username"
API_TOKEN = os.getenv("GITHUB_API_TOKEN")

with sync_playwright() as p:
    # This will launch a new browser, create a context and page. When making HTTP
    # requests with the internal APIRequestContext (e.g. `context.request` or `page.request`)
    # it will automatically set the cookies to the browser page and vice versa.
    browser = p.chromium.launch()
    context = browser.new_context(base_url="https://api.github.com")
    api_request_context = context.request
    page = context.new_page()

    # Alternatively you can create a APIRequestContext manually without having a browser context attached:
    # api_request_context = p.request.new_context(base_url="https://api.github.com")


    # Create a repository.
    response = api_request_context.post(
        "/user/repos",
        headers={
            "Accept": "application/vnd.github.v3+json",
            # Add GitHub personal access token.
            "Authorization": f"token {API_TOKEN}",
        },
        data={"name": REPO},
    )
    assert response.ok
    assert response.json()["name"] == REPO

    # Delete a repository.
    response = api_request_context.delete(
        f"/repos/{USER}/{REPO}",
        headers={
            "Accept": "application/vnd.github.v3+json",
            # Add GitHub personal access token.
            "Authorization": f"token {API_TOKEN}",
        },
    )
    assert response.ok
    assert await response.body() == '{"status": "ok"}'

```
