module Playwright
  # The Accessibility class provides methods for inspecting Chromium's accessibility tree. The accessibility tree is used by
  # assistive technology such as [screen readers](https://en.wikipedia.org/wiki/Screen_reader) or
  # [switches](https://en.wikipedia.org/wiki/Switch_access).
  # 
  # Accessibility is a very platform-specific thing. On different platforms, there are different screen readers that might
  # have wildly different output.
  # 
  # Rendering engines of Chromium, Firefox and WebKit have a concept of "accessibility tree", which is then translated into
  # different platform-specific APIs. Accessibility namespace gives access to this Accessibility Tree.
  # 
  # Most of the accessibility tree gets filtered out when converting from internal browser AX Tree to Platform-specific
  # AX-Tree or by assistive technologies themselves. By default, Playwright tries to approximate this filtering, exposing
  # only the "interesting" nodes of the tree.
  class Accessibility < PlaywrightApi

    # Captures the current state of the accessibility tree. The returned object represents the root accessible node of the
    # page.
    # 
    # > NOTE: The Chromium accessibility tree contains nodes that go unused on most platforms and by most screen readers.
    # Playwright will discard them as well for an easier to process tree, unless `interestingOnly` is set to `false`.
    # 
    # An example of dumping the entire accessibility tree:
    # 
    #
    # ```js
    # const snapshot = await page.accessibility.snapshot();
    # console.log(snapshot);
    # ```
    # 
    # ```java
    # String snapshot = page.accessibility().snapshot();
    # System.out.println(snapshot);
    # ```
    # 
    # ```python async
    # snapshot = await page.accessibility.snapshot()
    # print(snapshot)
    # ```
    # 
    # ```python sync
    # snapshot = page.accessibility.snapshot()
    # print(snapshot)
    # ```
    # 
    # ```csharp
    # var accessibilitySnapshot = await Page.Accessibility.SnapshotAsync();
    # Console.WriteLine(accessibilitySnapshot);
    # ```
    # 
    # An example of logging the focused node's name:
    # 
    #
    # ```js
    # const snapshot = await page.accessibility.snapshot();
    # const node = findFocusedNode(snapshot);
    # console.log(node && node.name);
    # 
    # function findFocusedNode(node) {
    #   if (node.focused)
    #     return node;
    #   for (const child of node.children || []) {
    #     const foundNode = findFocusedNode(child);
    #     return foundNode;
    #   }
    #   return null;
    # }
    # ```
    # 
    # ```csharp
    # Func<AccessibilitySnapshotResult, AccessibilitySnapshotResult> findFocusedNode = root =>
    # {
    #     var nodes = new Stack<AccessibilitySnapshotResult>(new[] { root });
    #     while (nodes.Count > 0)
    #     {
    #         var node = nodes.Pop();
    #         if (node.Focused) return node;
    #         foreach (var innerNode in node.Children)
    #         {
    #             nodes.Push(innerNode);
    #         }
    #     }
    # 
    #     return null;
    # };
    # 
    # var accessibilitySnapshot = await Page.Accessibility.SnapshotAsync();
    # var focusedNode = findFocusedNode(accessibilitySnapshot);
    # if(focusedNode != null)
    #   Console.WriteLine(focusedNode.Name);
    # ```
    # 
    # ```java
    # // FIXME
    # String snapshot = page.accessibility().snapshot();
    # ```
    # 
    # ```python async
    # def find_focused_node(node):
    #     if (node.get("focused"))
    #         return node
    #     for child in (node.get("children") or []):
    #         found_node = find_focused_node(child)
    #         return found_node
    #     return None
    # 
    # snapshot = await page.accessibility.snapshot()
    # node = find_focused_node(snapshot)
    # if node:
    #     print(node["name"])
    # ```
    # 
    # ```python sync
    # def find_focused_node(node):
    #     if (node.get("focused"))
    #         return node
    #     for child in (node.get("children") or []):
    #         found_node = find_focused_node(child)
    #         return found_node
    #     return None
    # 
    # snapshot = page.accessibility.snapshot()
    # node = find_focused_node(snapshot)
    # if node:
    #     print(node["name"])
    # ```
    def snapshot(interestingOnly: nil, root: nil)
      raise NotImplementedError.new('snapshot is not implemented yet.')
    end
  end
end
