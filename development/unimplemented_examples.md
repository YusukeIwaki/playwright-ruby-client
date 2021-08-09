# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_3b0f6c6573db513b7b707a39d6c5bbf5ce5896b4785466d80f525968cfbd0be7

```
page.set_content("<div><span></span></div>")
div = page.query_selector("div")
# waiting for the "span" selector relative to the div.
span = div.wait_for_selector("span", state="attached")

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
