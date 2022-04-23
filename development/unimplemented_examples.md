# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_388652162f4e169aab346af9ea657dd96de9217cd390a4cae2090af952b7aebe

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

### example_585cbbd055f47a5d0d7a6197d90874436cd4a2d50a92956723fc69336f8ccee9

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
