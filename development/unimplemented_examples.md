# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_e6bbc99e34c9f6ee73aa7d4265d34af456e6c67d185530f0a77f8064050a3ec4 (ElementHandle#select_option)

```
# Single selection matching the value or label
handle.select_option("blue")
# single selection matching both the label
handle.select_option(label="blue")
# multiple selection
handle.select_option(value=["red", "green", "blue"])

```

### example_2bc8a0187190738d8dc7b29c66ad5f9f2187fd1827455e9ceb1e9ace26aaf534 (Frame)

```
from playwright.sync_api import sync_playwright, Playwright

def run(playwright: Playwright):
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

### example_3f390f340c78c42dd0c88a09b2f56575b02b163786e8cdee33581217afced6b2 (Frame#select_option)

```
# Single selection matching the value or label
frame.select_option("select#colors", "blue")
# single selection matching both the label
frame.select_option("select#colors", label="blue")
# multiple selection
frame.select_option("select#colors", value=["red", "green", "blue"])

```

### example_e6a8c279eb09e58e3522cb6237f5d62165b164cad0c1916720af299ffcb8dc8a (Frame#wait_for_function)

```
from playwright.sync_api import sync_playwright, Playwright

def run(playwright: Playwright):
    webkit = playwright.webkit
    browser = webkit.launch()
    page = browser.new_page()
    page.evaluate("window.x = 0; setTimeout(() => { window.x = 100 }, 1000);")
    page.main_frame.wait_for_function("() => window.x > 0")
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

### example_6e2a71807566cf008382d4c163ff6e71e34d7f10ef6706ad7fcaa9b70c256a66 (Frame#wait_for_selector)

```
from playwright.sync_api import sync_playwright, Playwright

def run(playwright: Playwright):
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

### example_3e739d4f0e30e20a6a698e0e17605a841c35e65e75aa3c2642f8bfc368b33f9e (Selectors#register)

```
from playwright.sync_api import sync_playwright, Playwright

def run(playwright: Playwright):
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
    # Combine it with built-in locators.
    page.locator('tag=div').get_by_text('Click me').click()
    # Can use it in any methods supporting selectors.
    button_count = page.locator('tag=button').count()
    print(button_count)
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

### example_a7dcc75b7aa5544237ac3a964e9196d0445308864d3ce820f8cb8396f687b04a (Dialog)

```
from playwright.sync_api import sync_playwright, Playwright

def handle_dialog(dialog):
    print(dialog.message)
    dialog.dismiss()

def run(playwright: Playwright):
    chromium = playwright.chromium
    browser = chromium.launch()
    page = browser.new_page()
    page.on("dialog", handle_dialog)
    page.evaluate("alert('1')")
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

### example_c247767083cf193df26a39a61a3a8bc19d63ed5c24db91b88c50b7d37975005d (Download)

```
# Start waiting for the download
with page.expect_download() as download_info:
    # Perform the action that initiates download
    page.get_by_text("Download file").click()
download = download_info.value

# Wait for the download process to complete and save the downloaded file somewhere
download.save_as("/path/to/save/at/" + download.suggested_filename)

```

### example_66ffd4ef7286957e4294d84b8f660ff852c87af27a56b3e4dd9f84562b5ece02 (Download#save_as)

```
download.save_as("/path/to/save/at/" + download.suggested_filename)

```

### example_94e620cdbdfd41e2c9b14d561052ffa89535fc346038c4584ea4dd8520f5401c (Page)

```
from playwright.sync_api import sync_playwright, Playwright

def run(playwright: Playwright):
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

### example_4f7d99a72aaea957cc5678ed8728965338d78598d7772f47fbf23c28f0eba52d (Page#expose_binding)

```
from playwright.sync_api import sync_playwright, Playwright

def run(playwright: Playwright):
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

### example_0f68a39bdff02a3df161c74e81cabb8a2ff1f09f0d09f6ef9b799a6f2f19a280 (Page#expose_function)

```
import hashlib
from playwright.sync_api import sync_playwright, Playwright

def sha256(text):
    m = hashlib.sha256()
    m.update(bytes(text, "utf8"))
    return m.hexdigest()


def run(playwright: Playwright):
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

### example_8260034c740933903e5a39d30a4f4e388bdffa9e82acd9a5fe1fb774752a505a (Page#select_option)

```
# Single selection matching the value or label
page.select_option("select#colors", "blue")
# single selection matching both the label
page.select_option("select#colors", label="blue")
# multiple selection
page.select_option("select#colors", value=["red", "green", "blue"])

```

### example_83eed1f1f00ad73f641bf4a49f672e81c4faf1ca098a4a5070afeeabb88312f5 (Page#wait_for_function)

```
from playwright.sync_api import sync_playwright, Playwright

def run(playwright: Playwright):
    webkit = playwright.webkit
    browser = webkit.launch()
    page = browser.new_page()
    page.evaluate("window.x = 0; setTimeout(() => { window.x = 100 }, 1000);")
    page.wait_for_function("() => window.x > 0")
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

### example_903c7325fd65fcdf6f22c77fc159922a568841abce60ae1b7c54ab5837401862 (Page#wait_for_selector)

```
from playwright.sync_api import sync_playwright, Playwright

def run(playwright: Playwright):
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

### example_a450852d36dda88564582371af8d87bb58b1a517aac4fa60b7a58a0e41c5ceff (BrowserContext#expose_binding)

```
from playwright.sync_api import sync_playwright, Playwright

def run(playwright: Playwright):
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

### example_714719de9c92e66678257180301c2512f8cd69185f53a5121b6c52194f61a871 (BrowserContext#expose_function)

```
import hashlib
from playwright.sync_api import sync_playwright

def sha256(text: str) -> str:
    m = hashlib.sha256()
    m.update(bytes(text, "utf8"))
    return m.hexdigest()


def run(playwright: Playwright):
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

### example_5d31815545511b1d8ce5dfce5b153cb5ea46a1868cee95eb211d77f33026788b (Browser)

```
from playwright.sync_api import sync_playwright, Playwright

def run(playwright: Playwright):
    firefox = playwright.firefox
    browser = firefox.launch()
    page = browser.new_page()
    page.goto("https://example.com")
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

### example_2f9fbff87f35af4b76a27f54efeca3201696bbfa94ce03fee5a3df2639cc27d3 (BrowserType)

```
from playwright.sync_api import sync_playwright, Playwright

def run(playwright: Playwright):
    chromium = playwright.chromium
    browser = chromium.launch()
    page = browser.new_page()
    page.goto("https://example.com")
    # other actions...
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

### example_6647e5a44b0440884026a6142606dfddad75ba1e643919b015457df4ed2e198f (Playwright)

```
from playwright.sync_api import sync_playwright, Playwright

def run(playwright: Playwright):
    chromium = playwright.chromium # or "firefox" or "webkit".
    browser = chromium.launch()
    page = browser.new_page()
    page.goto("http://example.com")
    # other actions...
    browser.close()

with sync_playwright() as playwright:
    run(playwright)

```

### example_14d627977a4ad16a605ec5472d768a3324812fa8e7c57685561408fa6601e352 (Playwright#devices)

```
from playwright.sync_api import sync_playwright, Playwright

def run(playwright: Playwright):
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

### example_1b7781d5527574a18d4b9812e3461203d2acc9ba7e09cbfd0ffbc4154e3f5971 (Locator#press_sequentially)

```
locator.press_sequentially("hello") # types instantly
locator.press_sequentially("world", delay=100) # types slower, like a user

```

### example_cc0a6b9aa95b97e5c17c4b114da10a29c7f6f793e99aee1ea2703636af6e24f9 (Locator#press_sequentially)

```
locator = page.get_by_label("Password")
locator.press_sequentially("my password")
locator.press("Enter")

```

### example_eff0600f575bf375d7372280ca8e6dfc51d927ced49fbcb75408c894b9e0564e (LocatorAssertions)

```
from playwright.sync_api import Page, expect

def test_status_becomes_submitted(page: Page) -> None:
    # ..
    page.get_by_role("button").click()
    expect(page.locator(".status")).to_have_text("Submitted")

```

### example_781b6f44dd462fc3753b3e48d6888f2ef4d0794253bf6ffb4c42c76f5ec3b454 (LocatorAssertions#to_be_attached)

```
expect(page.get_by_text("Hidden text")).to_be_attached()

```

### example_00a58b66eec12973ab87c0ce5004126aa1f1af5a971a9e89638669f729bbb1b6 (LocatorAssertions#to_be_checked)

```
from playwright.sync_api import expect

locator = page.get_by_label("Subscribe to newsletter")
expect(locator).to_be_checked()

```

### example_fc3052bc38e6c1968f23f9185bda7f06478af4719ce96f6a49878ea7e72c9a82 (LocatorAssertions#to_be_disabled)

```
from playwright.sync_api import expect

locator = page.locator("button.submit")
expect(locator).to_be_disabled()

```

### example_a42b1e97cd0899ccd72bc4b74ab8f57c549814ca5b6d1bb912c870153d6d3f8d (LocatorAssertions#to_be_editable)

```
from playwright.sync_api import expect

locator = page.get_by_role("textbox")
expect(locator).to_be_editable()

```

### example_1fb5a7ee389401cf5a6fb3ba90c5b58c42c93d43aa5e4e34d99a5c6265ce0b35 (LocatorAssertions#to_be_empty)

```
from playwright.sync_api import expect

locator = page.locator("div.warning")
expect(locator).to_be_empty()

```

### example_0389b23d34a430ee418fd2138f9b8269df20fb6595f2618400e3d53b4f344a75 (LocatorAssertions#to_be_enabled)

```
from playwright.sync_api import expect

locator = page.locator("button.submit")
expect(locator).to_be_enabled()

```

### example_9fc7c2560e0a8117bc4ba14d6133a3d9c66cf6461c29c5a74fe132dea8bd8d63 (LocatorAssertions#to_be_focused)

```
from playwright.sync_api import expect

locator = page.get_by_role("textbox")
expect(locator).to_be_focused()

```

### example_55b9181de8eb71936b5e5289631fca33d2100f47f4c4e832d92c23f923779c62 (LocatorAssertions#to_be_hidden)

```
from playwright.sync_api import expect

locator = page.locator('.my-element')
expect(locator).to_be_hidden()

```

### example_7d5d5657528a32a8fb24cbf30e7bb3154cdf4c426e84e40131445a38fe8df2ee (LocatorAssertions#to_be_in_viewport)

```
from playwright.sync_api import expect

locator = page.get_by_role("button")
# Make sure at least some part of element intersects viewport.
expect(locator).to_be_in_viewport()
# Make sure element is fully outside of viewport.
expect(locator).not_to_be_in_viewport()
# Make sure that at least half of the element intersects viewport.
expect(locator).to_be_in_viewport(ratio=0.5)

```

### example_84ccd2ec31f9f00136a2931e9abb9c766eab967a6e892d3dcf90c02f14e5117f (LocatorAssertions#to_be_visible)

```
expect(page.get_by_text("Welcome")).to_be_visible()

```

### example_3553a48e2a15853f4869604ef20dae14952c16abfa0570b8f02e9b74e3d84faa (LocatorAssertions#to_contain_text)

```
import re
from playwright.sync_api import expect

locator = page.locator('.title')
expect(locator).to_contain_text("substring")
expect(locator).to_contain_text(re.compile(r"\d messages"))

```

### example_fb3cde55b658aefe2e54f93e5b78d26f25cd376eaa469434631af079bb8d8a62 (LocatorAssertions#to_contain_text)

```
from playwright.sync_api import expect

# ✓ Contains the right items in the right order
expect(page.locator("ul > li")).to_contain_text(["Text 1", "Text 3", "Text 4"])

# ✖ Wrong order
expect(page.locator("ul > li")).to_contain_text(["Text 3", "Text 2"])

# ✖ No item contains this text
expect(page.locator("ul > li")).to_contain_text(["Some 33"])

# ✖ Locator points to the outer list element, not to the list items
expect(page.locator("ul")).to_contain_text(["Text 3"])

```

### example_709faaa456b4775109b1fbaca74a86ac5107af5e4801ea07cb690942f1d37f88 (LocatorAssertions#to_have_attribute)

```
from playwright.sync_api import expect

locator = page.locator("input")
expect(locator).to_have_attribute("type", "text")

```

### example_c16c6c567ee66b6d60de634c8a8a7c7c2b26f0e9ea8556e50a47d0c151935aa1 (LocatorAssertions#to_have_class)

```
from playwright.sync_api import expect

locator = page.locator("#component")
expect(locator).to_have_class(re.compile(r"selected"))
expect(locator).to_have_class("selected row")

```

### example_96b9affd86317eeafe4a419f6ec484d33cea4ee947297f44b7b4ebb373261f1d (LocatorAssertions#to_have_class)

```
from playwright.sync_api import expect

locator = page.locator("list > .component")
expect(locator).to_have_class(["component", "component selected", "component"])

```

### example_b3e3d5c7f2ff3a225541e57968953a77e32048daddaabe29ba84e93a1fcee84f (LocatorAssertions#to_have_count)

```
from playwright.sync_api import expect

locator = page.locator("list > .component")
expect(locator).to_have_count(3)

```

### example_12c52b928c1fac117b68573a914ce0ef9595becead95a0ee7c1f487ba1ad9010 (LocatorAssertions#to_have_css)

```
from playwright.sync_api import expect

locator = page.get_by_role("button")
expect(locator).to_have_css("display", "flex")

```

### example_5a4c0b1802f0751c2e1068d831ecd499b36a7860605050ba976c2290452bbd89 (LocatorAssertions#to_have_id)

```
from playwright.sync_api import expect

locator = page.get_by_role("textbox")
expect(locator).to_have_id("lastname")

```

### example_01cad4288f995d4b6253003eb0f4acb227e80553410cea0a8db0ab6927247d92 (LocatorAssertions#to_have_js_property)

```
from playwright.sync_api import expect

locator = page.locator(".component")
expect(locator).to_have_js_property("loaded", True)

```

### example_4ece81163bcb1edeccd7cea8f8c6158cf794c8ef88a673e8c5350a10eaa81542 (LocatorAssertions#to_have_text)

```
import re
from playwright.sync_api import expect

locator = page.locator(".title")
expect(locator).to_have_text(re.compile(r"Welcome, Test User"))
expect(locator).to_have_text(re.compile(r"Welcome, .*"))

```

### example_2caa32069462b536399b1e7e9ade6388ab8b83912ae46ba293cf8ed241c48e85 (LocatorAssertions#to_have_text)

```
from playwright.sync_api import expect

# ✓ Has the right items in the right order
expect(page.locator("ul > li")).to_have_text(["Text 1", "Text 2", "Text 3"])

# ✖ Wrong order
expect(page.locator("ul > li")).to_have_text(["Text 3", "Text 2", "Text 1"])

# ✖ Last item does not match
expect(page.locator("ul > li")).to_have_text(["Text 1", "Text 2", "Text"])

# ✖ Locator points to the outer list element, not to the list items
expect(page.locator("ul")).to_have_text(["Text 1", "Text 2", "Text 3"])

```

### example_84f23ac0426bebae60693613034771d70a26808dff53d1d476c3f5856346521a (LocatorAssertions#to_have_value)

```
import re
from playwright.sync_api import expect

locator = page.locator("input[type=number]")
expect(locator).to_have_value(re.compile(r"[0-9]"))

```

### example_e5cce4bcdea914bbae14a3645b77f19c322038b0ef81d6ad2a1c9f5b0e21b1e9 (LocatorAssertions#to_have_values)

```
import re
from playwright.sync_api import expect

locator = page.locator("id=favorite-colors")
locator.select_option(["R", "G"])
expect(locator).to_have_values([re.compile(r"R"), re.compile(r"G")])

```
