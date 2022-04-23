---
sidebar_position: 10
---

# ConsoleMessage

[ConsoleMessage](./console_message) objects are dispatched by page via the [`event: Page.console`] event. For each console messages logged
in the page there will be corresponding event in the Playwright context.

```python sync title=example_585cbbd055f47a5d0d7a6197d90874436cd4a2d50a92956723fc69336f8ccee9.py
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



## args

```
def args
```

List of arguments passed to a `console` function call. See also [`event: Page.console`].

## location

```
def location
```



## text

```
def text
```

The text of the console message.

## type

```
def type
```

One of the following values: `'log'`, `'debug'`, `'info'`, `'error'`, `'warning'`, `'dir'`, `'dirxml'`, `'table'`,
`'trace'`, `'clear'`, `'startGroup'`, `'startGroupCollapsed'`, `'endGroup'`, `'assert'`, `'profile'`, `'profileEnd'`,
`'count'`, `'timeEnd'`.
