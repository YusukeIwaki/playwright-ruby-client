---
sidebar_position: 10
---

# Keyboard

Keyboard provides an api for managing a virtual keyboard. The high level api is [Keyboard#type](./keyboard#type), which
takes raw characters and generates proper `keydown`, `keypress`/`input`, and `keyup` events on your page.

For finer control, you can use [Keyboard#down](./keyboard#down), [Keyboard#up](./keyboard#up), and
[Keyboard#insert_text](./keyboard#insert_text) to manually fire events as if they were generated from a real keyboard.

An example of holding down `Shift` in order to select and delete some text:

```py title=example_26fdb75d3fe4e80f629487f25c35515d365860e505e0977afcb20dd5d78235c8.py
await page.keyboard.type("Hello World!")
await page.keyboard.press("ArrowLeft")
await page.keyboard.down("Shift")
for i in range(6):
    await page.keyboard.press("ArrowLeft")
await page.keyboard.up("Shift")
await page.keyboard.press("Backspace")
# result text will end up saying "Hello!"

```

```py title=example_19a77495692b3afbd629d289f1aadabc0fd088677467a575846b1feec3051458.py
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

```py title=example_87f353333929066f58d052e716ef214077a81be6bf1bc24c032ebe79a44163ca.py
await page.keyboard.press("Shift+KeyA")
# or
await page.keyboard.press("Shift+A")

```

```py title=example_18b2427ff9a00609db64c555409debfafdfdc9695c26b2a09ede974ae1f10786.py
page.keyboard.press("Shift+KeyA")
# or
page.keyboard.press("Shift+A")

```

An example to trigger select-all with the keyboard

```py title=example_a02bb1f3511c4cccffee3b291e4066418af6755e719fcccad4b798368b0d2a26.py
# on windows and linux
await page.keyboard.press("Control+A")
# on mac_os
await page.keyboard.press("Meta+A")

```

```py title=example_d8372cc5ab4f4a816e0ffec961c3802d82562db37ed49a2e8df7ec5a88d3603a.py
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

`key` can specify the intended
[keyboardEvent.key](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key) value or a single character
to generate the text for. A superset of the `key` values can be found
[here](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values). Examples of the keys are:

`F1` - `F12`, `Digit0`- `Digit9`, `KeyA`- `KeyZ`, `Backquote`, `Minus`, `Equal`, `Backslash`, `Backspace`, `Tab`,
`Delete`, `Escape`, `ArrowDown`, `End`, `Enter`, `Home`, `Insert`, `PageDown`, `PageUp`, `ArrowRight`, `ArrowUp`,
etc.

Following modification shortcuts are also supported: `Shift`, `Control`, `Alt`, `Meta`, `ShiftLeft`.

Holding down `Shift` will type the text that corresponds to the `key` in the upper case.

If `key` is a single character, it is case-sensitive, so the values `a` and `A` will generate different respective
texts.

If `key` is a modifier key, `Shift`, `Meta`, `Control`, or `Alt`, subsequent key presses will be sent with that
modifier active. To release the modifier key, use [Keyboard#up](./keyboard#up).

After the key is pressed once, subsequent calls to [Keyboard#down](./keyboard#down) will have
[repeat](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/repeat) set to true. To release the key,
use [Keyboard#up](./keyboard#up).

**NOTE** Modifier keys DO influence `keyboard.down`. Holding down `Shift` will type the text in upper case.

## insert_text

```
def insert_text(text)
```

Dispatches only `input` event, does not emit the `keydown`, `keyup` or `keypress` events.

**Usage**

```py title=example_fb0a4454fb1b47814df4a012361a55dd89935f9679f8d562fc28a0d6d09b681b.py
await page.keyboard.insert_text("嗨")

```

```py title=example_9c4592c489be2b1ddf0b5eed3e3bfecbdb001c4af918115d5011f3ff01d95ef6.py
page.keyboard.insert_text("嗨")

```

**NOTE** Modifier keys DO NOT effect `keyboard.insertText`. Holding down `Shift` will not type the text in upper
case.

## press

```
def press(key, delay: nil)
```

`key` can specify the intended
[keyboardEvent.key](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key) value or a single character
to generate the text for. A superset of the `key` values can be found
[here](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values). Examples of the keys are:

`F1` - `F12`, `Digit0`- `Digit9`, `KeyA`- `KeyZ`, `Backquote`, `Minus`, `Equal`, `Backslash`, `Backspace`, `Tab`,
`Delete`, `Escape`, `ArrowDown`, `End`, `Enter`, `Home`, `Insert`, `PageDown`, `PageUp`, `ArrowRight`, `ArrowUp`,
etc.

Following modification shortcuts are also supported: `Shift`, `Control`, `Alt`, `Meta`, `ShiftLeft`.

Holding down `Shift` will type the text that corresponds to the `key` in the upper case.

If `key` is a single character, it is case-sensitive, so the values `a` and `A` will generate different respective
texts.

Shortcuts such as `key: "Control+o"` or `key: "Control+Shift+T"` are supported as well. When specified with the
modifier, modifier is pressed and being held while the subsequent key is being pressed.

**Usage**

```py title=example_9cf34d1b8089c7c78b22be1e423a512a140c63aaa15df97acdd00f1ee6f899c6.py
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

```py title=example_e9c1ca558c39e9b93a6f51b294f4b157eff8285a28e4b80994d2b6fa0632dfad.py
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

**Usage**

```py title=example_c9d633f2ee63eb8ddcbe6cca7370621fe19b56d8b23faed55ad96584f7c358a8.py
await page.keyboard.type("Hello") # types instantly
await page.keyboard.type("World", delay=100) # types slower, like a user

```

```py title=example_b88ab9f788db040043a217be7557a2c809804cbd42f4988d47668c8dc792c1b3.py
page.keyboard.type("Hello") # types instantly
page.keyboard.type("World", delay=100) # types slower, like a user

```

**NOTE** Modifier keys DO NOT effect `keyboard.type`. Holding down `Shift` will not type the text in upper case.

**NOTE** For characters that are not on a US keyboard, only an `input` event will be sent.

## up

```
def up(key)
```

Dispatches a `keyup` event.
