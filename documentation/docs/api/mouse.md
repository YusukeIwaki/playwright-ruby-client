---
sidebar_position: 10
---

# Mouse

The Mouse class operates in main-frame CSS pixels relative to the top-left corner of the viewport.

Every `page` object has its own Mouse, accessible with [Page#mouse](./page#mouse).

```python sync title=example_ba01da1f358cafb4c22b792488ff2f3de4dbd82d4ee1cc4050e3f0c24a2bd7dd.py
# using ‘page.mouse’ to trace a 100x100 square.
page.mouse.move(0, 0)
page.mouse.down()
page.mouse.move(0, 100)
page.mouse.move(100, 100)
page.mouse.move(100, 0)
page.mouse.move(0, 0)
page.mouse.up()

```



## click

```
def click(
      x,
      y,
      button: nil,
      clickCount: nil,
      delay: nil)
```

Shortcut for [Mouse#move](./mouse#move), [Mouse#down](./mouse#down), [Mouse#up](./mouse#up).

## dblclick

```
def dblclick(x, y, button: nil, delay: nil)
```

Shortcut for [Mouse#move](./mouse#move), [Mouse#down](./mouse#down), [Mouse#up](./mouse#up), [Mouse#down](./mouse#down) and
[Mouse#up](./mouse#up).

## down

```
def down(button: nil, clickCount: nil)
```

Dispatches a `mousedown` event.

## move

```
def move(x, y, steps: nil)
```

Dispatches a `mousemove` event.

## up

```
def up(button: nil, clickCount: nil)
```

Dispatches a `mouseup` event.
