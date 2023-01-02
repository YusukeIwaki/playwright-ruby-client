---
sidebar_position: 10
---

# ConsoleMessage

[ConsoleMessage](./console_message) objects are dispatched by page via the [`event: Page.console`] event. For each console messages
logged in the page there will be corresponding event in the Playwright context.

```py title=example_b90d8e782c1c573e6f11d8ece3fe3ad06c7ebd6eda60859a4f0544ad5131652d.py
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

```py title=example_9d404329108c69b16e9e327a86f38e44c10d28762278b5d7a3e5339f3d12cf1f.py
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
`'trace'`, `'clear'`, `'startGroup'`, `'startGroupCollapsed'`, `'endGroup'`, `'assert'`, `'profile'`,
`'profileEnd'`, `'count'`, `'timeEnd'`.
