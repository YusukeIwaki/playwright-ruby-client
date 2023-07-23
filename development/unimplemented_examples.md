# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_49eec7966dd7a081de100e4563b110174e5e2dc4b89959cd14894097080346dc (JSHandle#get_properties)

```
handle = page.evaluate_handle("({ window, document })")
properties = handle.get_properties()
window_handle = properties.get("window")
document_handle = properties.get("document")
handle.dispose()

```

### example_64bcac14fcbd1a2e6d6f32164d92124a90dddbfa9277f7503be7b0a401c9cf85 (ElementHandle#eval_on_selector)

```
tweet_handle = page.query_selector(".tweet")
assert tweet_handle.eval_on_selector(".like", "node => node.innerText") == "100"
assert tweet_handle.eval_on_selector(".retweets", "node => node.innerText") == "10"

```

### example_3d67a99411b5f924d573427b6f54aff63f7241f2b810959b79948bd3b522404a (Accessibility#snapshot)

```
def find_focused_node(node):
    if node.get("focused"):
        return node
    for child in (node.get("children") or []):
        found_node = find_focused_node(child)
        if found_node:
            return found_node
    return None

snapshot = page.accessibility.snapshot()
node = find_focused_node(snapshot)
if node:
    print(node["name"])

```

### example_a0ba081a92628cce9358e983826ad7143d6757dc2780f1b53f0d2e073000409e (Page#route)

```
def handle_route(route):
  if ("my-string" in route.request.post_data):
    route.fulfill(body="mocked-data")
  else:
    route.continue_()
page.route("/api/**", handle_route)

```

### example_ef709e5ad2c021453ff9ed1c2faedc7f9f07043c4fa503929ba2020a557ccbdf (BrowserContext#route)

```
def handle_route(route):
  if ("my-string" in route.request.post_data):
    route.fulfill(body="mocked-data")
  else:
    route.continue_()
context.route("/api/**", handle_route)

```

### example_981a978542d75734983c5b8d6fc19f2b2e94d93d3ecce2349a55fff99918b412 (Locator#filter)

```
row_locator = page.locator("tr")
# ...
row_locator.filter(has_text="text in column 1").filter(
    has=page.get_by_role("button", name="column 2 button")
).screenshot()

```

### example_180e47ad1dc80f352ad9ffc8519b25c65c17b7413febe4912e66acc198de69e7 (Locator#or)

```
new_email = page.get_by_role("button", name="New")
dialog = page.get_by_text("Confirm security settings")
expect(new_email.or_(dialog)).to_be_visible()
if (dialog.is_visible()):
  page.get_by_role("button", name="Dismiss").click()
new_email.click()

```
