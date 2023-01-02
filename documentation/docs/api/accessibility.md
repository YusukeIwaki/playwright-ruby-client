---
sidebar_position: 10
---

# Accessibility

The Accessibility class provides methods for inspecting Chromium's accessibility tree. The accessibility tree is
used by assistive technology such as [screen readers](https://en.wikipedia.org/wiki/Screen_reader) or
[switches](https://en.wikipedia.org/wiki/Switch_access).

Accessibility is a very platform-specific thing. On different platforms, there are different screen readers that
might have wildly different output.

Rendering engines of Chromium, Firefox and WebKit have a concept of "accessibility tree", which is then translated
into different platform-specific APIs. Accessibility namespace gives access to this Accessibility Tree.

Most of the accessibility tree gets filtered out when converting from internal browser AX Tree to Platform-specific
AX-Tree or by assistive technologies themselves. By default, Playwright tries to approximate this filtering,
exposing only the "interesting" nodes of the tree.

## snapshot

```
def snapshot(interestingOnly: nil, root: nil)
```

Captures the current state of the accessibility tree. The returned object represents the root accessible node of
the page.

**NOTE** The Chromium accessibility tree contains nodes that go unused on most platforms and by most screen
readers. Playwright will discard them as well for an easier to process tree, unless `interestingOnly` is set to
`false`.

**Usage**

An example of dumping the entire accessibility tree:

```py title=example_d2caa2d871e91e70d303b96634b06cf6a7ab99de947c8510794204827f0f8a83.py
snapshot = await page.accessibility.snapshot()
print(snapshot)

```

```py title=example_321883625cabef121ccada23e807b2759d691bb929ba34843cc78a2219a71b10.py
snapshot = page.accessibility.snapshot()
print(snapshot)

```

An example of logging the focused node's name:

```py title=example_b21345cac0c9e7f5abb1ba36c1093be03c489d8fcdf4f018aecc07f062dee563.py
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

```py title=example_3f5026589176f924fc99775945d7919c977e8c88f9fd94771bbcf7156853b9a4.py
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

