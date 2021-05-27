---
sidebar_position: 10
---

# Keyboard

Keyboard provides an api for managing a virtual keyboard. The high level api is [Keyboard#type](./keyboard#type), which takes
raw characters and generates proper keydown, keypress/input, and keyup events on your page.

For finer control, you can use [Keyboard#down](./keyboard#down), [Keyboard#up](./keyboard#up), and [Keyboard#insert_text](./keyboard#insert_text)
to manually fire events as if they were generated from a real keyboard.

An example of holding down `Shift` in order to select and delete some text:

```python sync title=example_575870a45e4fe08d3e06be3420e8a11be03f85791cd8174f27198c016031ae72.py
page.keyboard.type("Hello World!")
page.keyboard.press("ArrowLeft")
page.keyboard.down("Shift")
for i in range(6):
    page.keyboard.press("ArrowLeft")
page.keyboard.up("Shift")
page.keyboard.press("Backspace")
# result text will end up saying "Hello!"

```

An example of pressing uppercase `A`

```python sync title=example_a4f00f0cd486431b7eca785304f4e9715522da45b66dda7f3a5f6899b889b9fd.py
page.keyboard.press("Shift+KeyA")
# or
page.keyboard.press("Shift+A")

```

An example to trigger select-all with the keyboard

```python sync title=example_2deda0786a20a28cec9e8b438078a5fc567f7c7e5cf369419ab3c4d80a319ff6.py
# on windows and linux
page.keyboard.press("Control+A")
# on mac_os
page.keyboard.press("Meta+A")

```



## down

```
def down(key)
```

Dispatches a `keydown` event.

`key` can specify the intended [keyboardEvent.key](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key)
value or a single character to generate the text for. A superset of the `key` values can be found
[here](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values). Examples of the keys are:

`F1` - `F12`, `Digit0`- `Digit9`, `KeyA`- `KeyZ`, `Backquote`, `Minus`, `Equal`, `Backslash`, `Backspace`, `Tab`,
`Delete`, `Escape`, `ArrowDown`, `End`, `Enter`, `Home`, `Insert`, `PageDown`, `PageUp`, `ArrowRight`, `ArrowUp`, etc.

Following modification shortcuts are also supported: `Shift`, `Control`, `Alt`, `Meta`, `ShiftLeft`.

Holding down `Shift` will type the text that corresponds to the `key` in the upper case.

If `key` is a single character, it is case-sensitive, so the values `a` and `A` will generate different respective
texts.

If `key` is a modifier key, `Shift`, `Meta`, `Control`, or `Alt`, subsequent key presses will be sent with that modifier
active. To release the modifier key, use [Keyboard#up](./keyboard#up).

After the key is pressed once, subsequent calls to [Keyboard#down](./keyboard#down) will have
[repeat](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/repeat) set to true. To release the key, use
[Keyboard#up](./keyboard#up).

> NOTE: Modifier keys DO influence `keyboard.down`. Holding down `Shift` will type the text in upper case.

## insert_text

```
def insert_text(text)
```

Dispatches only `input` event, does not emit the `keydown`, `keyup` or `keypress` events.

```python sync title=example_a9cc2667e9f3e3b8c619649d7e4a7f5db9463e0b76d67a5e588158093a9e9124.py
page.keyboard.insert_text("嗨")

```

> NOTE: Modifier keys DO NOT effect `keyboard.insertText`. Holding down `Shift` will not type the text in upper case.

## press

```
def press(key, delay: nil)
```

`key` can specify the intended [keyboardEvent.key](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key)
value or a single character to generate the text for. A superset of the `key` values can be found
[here](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values). Examples of the keys are:

`F1` - `F12`, `Digit0`- `Digit9`, `KeyA`- `KeyZ`, `Backquote`, `Minus`, `Equal`, `Backslash`, `Backspace`, `Tab`,
`Delete`, `Escape`, `ArrowDown`, `End`, `Enter`, `Home`, `Insert`, `PageDown`, `PageUp`, `ArrowRight`, `ArrowUp`, etc.

Following modification shortcuts are also supported: `Shift`, `Control`, `Alt`, `Meta`, `ShiftLeft`.

Holding down `Shift` will type the text that corresponds to the `key` in the upper case.

If `key` is a single character, it is case-sensitive, so the values `a` and `A` will generate different respective
texts.

Shortcuts such as `key: "Control+o"` or `key: "Control+Shift+T"` are supported as well. When specified with the
modifier, modifier is pressed and being held while the subsequent key is being pressed.

```python sync title=example_88943eb85c1ac7c261601e6edbdead07a31c2784326c496e10667ede1a853bab.py
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

Shortcut for [Keyboard#down](./keyboard#down) and [Keyboard#up](./keyboard#up).

## type

```
def type(text, delay: nil)
```

Sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text.

To press a special key, like `Control` or `ArrowDown`, use [Keyboard#press](./keyboard#press).

```python sync title=example_d9ced919f139961fd2b795c71375ca96f788a19c1f8e1479c5ec905fb5c02d43.py
page.keyboard.type("Hello") # types instantly
page.keyboard.type("World", delay=100) # types slower, like a user

```

> NOTE: Modifier keys DO NOT effect `keyboard.type`. Holding down `Shift` will not type the text in upper case.
> NOTE: For characters that are not on a US keyboard, only an `input` event will be sent.

## up

```
def up(key)
```

Dispatches a `keyup` event.
