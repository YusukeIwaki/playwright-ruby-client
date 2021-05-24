module Playwright
  # At every point of time, page exposes its current frame tree via the [`method: Page.mainFrame`] and
  # [`method: Frame.childFrames`] methods.
  #
  # `Frame` object's lifecycle is controlled by three events, dispatched on the page object:
  # - [`event: Page.frameAttached`] - fired when the frame gets attached to the page. A Frame can be attached to the page
  #   only once.
  # - [`event: Page.frameNavigated`] - fired when the frame commits navigation to a different URL.
  # - [`event: Page.frameDetached`] - fired when the frame gets detached from the page.  A Frame can be detached from the
  #   page only once.
  #
  # An example of dumping frame tree:
  #
  #
  # ```js
  # const { firefox } = require('playwright');  // Or 'chromium' or 'webkit'.
  #
  # (async () => {
  #   const browser = await firefox.launch();
  #   const page = await browser.newPage();
  #   await page.goto('https://www.google.com/chrome/browser/canary.html');
  #   dumpFrameTree(page.mainFrame(), '');
  #   await browser.close();
  #
  #   function dumpFrameTree(frame, indent) {
  #     console.log(indent + frame.url());
  #     for (const child of frame.childFrames()) {
  #       dumpFrameTree(child, indent + '  ');
  #     }
  #   }
  # })();
  # ```
  #
  # ```java
  # import com.microsoft.playwright.*;
  #
  # public class Example {
  #   public static void main(String[] args) {
  #     try (Playwright playwright = Playwright.create()) {
  #       BrowserType firefox = playwright.firefox();
  #       Browser browser = firefox.launch();
  #       Page page = browser.newPage();
  #       page.navigate("https://www.google.com/chrome/browser/canary.html");
  #       dumpFrameTree(page.mainFrame(), "");
  #       browser.close();
  #     }
  #   }
  #   static void dumpFrameTree(Frame frame, String indent) {
  #     System.out.println(indent + frame.url());
  #     for (Frame child : frame.childFrames()) {
  #       dumpFrameTree(child, indent + "  ");
  #     }
  #   }
  # }
  # ```
  #
  # ```python async
  # import asyncio
  # from playwright.async_api import async_playwright
  #
  # async def run(playwright):
  #     firefox = playwright.firefox
  #     browser = await firefox.launch()
  #     page = await browser.new_page()
  #     await page.goto("https://www.theverge.com")
  #     dump_frame_tree(page.main_frame, "")
  #     await browser.close()
  #
  # def dump_frame_tree(frame, indent):
  #     print(indent + frame.name + '@' + frame.url)
  #     for child in frame.child_frames:
  #         dump_frame_tree(child, indent + "    ")
  #
  # async def main():
  #     async with async_playwright() as playwright:
  #         await run(playwright)
  # asyncio.run(main())
  # ```
  #
  # ```python sync
  # from playwright.sync_api import sync_playwright
  #
  # def run(playwright):
  #     firefox = playwright.firefox
  #     browser = firefox.launch()
  #     page = browser.new_page()
  #     page.goto("https://www.theverge.com")
  #     dump_frame_tree(page.main_frame, "")
  #     browser.close()
  #
  # def dump_frame_tree(frame, indent):
  #     print(indent + frame.name + '@' + frame.url)
  #     for child in frame.child_frames:
  #         dump_frame_tree(child, indent + "    ")
  #
  # with sync_playwright() as playwright:
  #     run(playwright)
  # ```
  #
  # ```csharp
  # using Microsoft.Playwright;
  # using System;
  # using System.Threading.Tasks;
  #
  # class FrameExamples
  # {
  #     public static async Task Main()
  #     {
  #         using var playwright = await Playwright.CreateAsync();
  #         await using var browser = await playwright.Firefox.LaunchAsync();
  #         var page = await browser.NewPageAsync();
  #
  #         await page.GotoAsync("https://www.bing.com");
  #         DumpFrameTree(page.MainFrame, string.Empty);
  #     }
  #
  #     private static void DumpFrameTree(IFrame frame, string indent)
  #     {
  #         Console.WriteLine($"{indent}{frame.Url}");
  #         foreach (var child in frame.ChildFrames)
  #             DumpFrameTree(child, indent + " ");
  #     }
  # }
  # ```
  class Frame < PlaywrightApi

    # Returns the added tag when the script's onload fires or when the script content was injected into frame.
    #
    # Adds a `<script>` tag into the page with the desired url or content.
    def add_script_tag(content: nil, path: nil, type: nil, url: nil)
      wrap_impl(@impl.add_script_tag(content: unwrap_impl(content), path: unwrap_impl(path), type: unwrap_impl(type), url: unwrap_impl(url)))
    end

    # Returns the added tag when the stylesheet's onload fires or when the CSS content was injected into frame.
    #
    # Adds a `<link rel="stylesheet">` tag into the page with the desired url or a `<style type="text/css">` tag with the
    # content.
    def add_style_tag(content: nil, path: nil, url: nil)
      wrap_impl(@impl.add_style_tag(content: unwrap_impl(content), path: unwrap_impl(path), url: unwrap_impl(url)))
    end

    # This method checks an element matching `selector` by performing the following steps:
    # 1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
    # 1. Ensure that matched element is a checkbox or a radio input. If not, this method throws. If the element is already
    #    checked, this method returns immediately.
    # 1. Wait for [actionability](./actionability.md) checks on the matched element, unless `force` option is set. If the
    #    element is detached during the checks, the whole action is retried.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.mouse`] to click in the center of the element.
    # 1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.
    # 1. Ensure that the element is now checked. If not, this method throws.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`. Passing
    # zero timeout disables this.
    def check(
          selector,
          force: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.check(unwrap_impl(selector), force: unwrap_impl(force), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    def child_frames
      wrap_impl(@impl.child_frames)
    end

    # This method clicks an element matching `selector` by performing the following steps:
    # 1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
    # 1. Wait for [actionability](./actionability.md) checks on the matched element, unless `force` option is set. If the
    #    element is detached during the checks, the whole action is retried.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.mouse`] to click in the center of the element, or the specified `position`.
    # 1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`. Passing
    # zero timeout disables this.
    def click(
          selector,
          button: nil,
          clickCount: nil,
          delay: nil,
          force: nil,
          modifiers: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.click(unwrap_impl(selector), button: unwrap_impl(button), clickCount: unwrap_impl(clickCount), delay: unwrap_impl(delay), force: unwrap_impl(force), modifiers: unwrap_impl(modifiers), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    # Gets the full HTML contents of the frame, including the doctype.
    def content
      wrap_impl(@impl.content)
    end

    # This method double clicks an element matching `selector` by performing the following steps:
    # 1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
    # 1. Wait for [actionability](./actionability.md) checks on the matched element, unless `force` option is set. If the
    #    element is detached during the checks, the whole action is retried.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.mouse`] to double click in the center of the element, or the specified `position`.
    # 1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set. Note that if the
    #    first click of the `dblclick()` triggers a navigation event, this method will throw.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`. Passing
    # zero timeout disables this.
    #
    # > NOTE: `frame.dblclick()` dispatches two `click` events and a single `dblclick` event.
    def dblclick(
          selector,
          button: nil,
          delay: nil,
          force: nil,
          modifiers: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.dblclick(unwrap_impl(selector), button: unwrap_impl(button), delay: unwrap_impl(delay), force: unwrap_impl(force), modifiers: unwrap_impl(modifiers), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    # The snippet below dispatches the `click` event on the element. Regardless of the visibility state of the element,
    # `click` is dispatched. This is equivalent to calling
    # [element.click()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/click).
    #
    #
    # ```js
    # await frame.dispatchEvent('button#submit', 'click');
    # ```
    #
    # ```java
    # frame.dispatchEvent("button#submit", "click");
    # ```
    #
    # ```python async
    # await frame.dispatch_event("button#submit", "click")
    # ```
    #
    # ```python sync
    # frame.dispatch_event("button#submit", "click")
    # ```
    #
    # ```csharp
    # await frame.DispatchEventAsync("button#submit", "click");
    # ```
    #
    # Under the hood, it creates an instance of an event based on the given `type`, initializes it with `eventInit` properties
    # and dispatches it on the element. Events are `composed`, `cancelable` and bubble by default.
    #
    # Since `eventInit` is event-specific, please refer to the events documentation for the lists of initial properties:
    # - [DragEvent](https://developer.mozilla.org/en-US/docs/Web/API/DragEvent/DragEvent)
    # - [FocusEvent](https://developer.mozilla.org/en-US/docs/Web/API/FocusEvent/FocusEvent)
    # - [KeyboardEvent](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/KeyboardEvent)
    # - [MouseEvent](https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent/MouseEvent)
    # - [PointerEvent](https://developer.mozilla.org/en-US/docs/Web/API/PointerEvent/PointerEvent)
    # - [TouchEvent](https://developer.mozilla.org/en-US/docs/Web/API/TouchEvent/TouchEvent)
    # - [Event](https://developer.mozilla.org/en-US/docs/Web/API/Event/Event)
    #
    # You can also specify `JSHandle` as the property value if you want live objects to be passed into the event:
    #
    #
    # ```js
    # // Note you can only create DataTransfer in Chromium and Firefox
    # const dataTransfer = await frame.evaluateHandle(() => new DataTransfer());
    # await frame.dispatchEvent('#source', 'dragstart', { dataTransfer });
    # ```
    #
    # ```java
    # // Note you can only create DataTransfer in Chromium and Firefox
    # JSHandle dataTransfer = frame.evaluateHandle("() => new DataTransfer()");
    # Map<String, Object> arg = new HashMap<>();
    # arg.put("dataTransfer", dataTransfer);
    # frame.dispatchEvent("#source", "dragstart", arg);
    # ```
    #
    # ```python async
    # # note you can only create data_transfer in chromium and firefox
    # data_transfer = await frame.evaluate_handle("new DataTransfer()")
    # await frame.dispatch_event("#source", "dragstart", { "dataTransfer": data_transfer })
    # ```
    #
    # ```python sync
    # # note you can only create data_transfer in chromium and firefox
    # data_transfer = frame.evaluate_handle("new DataTransfer()")
    # frame.dispatch_event("#source", "dragstart", { "dataTransfer": data_transfer })
    # ```
    #
    # ```csharp
    # // Note you can only create DataTransfer in Chromium and Firefox
    # var dataTransfer = await frame.EvaluateHandleAsync("() => new DataTransfer()");
    # await frame.DispatchEventAsync("#source", "dragstart", new { dataTransfer });
    # ```
    def dispatch_event(selector, type, eventInit: nil, timeout: nil)
      wrap_impl(@impl.dispatch_event(unwrap_impl(selector), unwrap_impl(type), eventInit: unwrap_impl(eventInit), timeout: unwrap_impl(timeout)))
    end

    # Returns the return value of `expression`.
    #
    # The method finds an element matching the specified selector within the frame and passes it as a first argument to
    # `expression`. See [Working with selectors](./selectors.md) for more details. If no elements match the selector, the
    # method throws an error.
    #
    # If `expression` returns a [Promise], then [`method: Frame.evalOnSelector`] would wait for the promise to resolve and
    # return its value.
    #
    # Examples:
    #
    #
    # ```js
    # const searchValue = await frame.$eval('#search', el => el.value);
    # const preloadHref = await frame.$eval('link[rel=preload]', el => el.href);
    # const html = await frame.$eval('.main-container', (e, suffix) => e.outerHTML + suffix, 'hello');
    # ```
    #
    # ```java
    # String searchValue = (String) frame.evalOnSelector("#search", "el => el.value");
    # String preloadHref = (String) frame.evalOnSelector("link[rel=preload]", "el => el.href");
    # String html = (String) frame.evalOnSelector(".main-container", "(e, suffix) => e.outerHTML + suffix", "hello");
    # ```
    #
    # ```python async
    # search_value = await frame.eval_on_selector("#search", "el => el.value")
    # preload_href = await frame.eval_on_selector("link[rel=preload]", "el => el.href")
    # html = await frame.eval_on_selector(".main-container", "(e, suffix) => e.outerHTML + suffix", "hello")
    # ```
    #
    # ```python sync
    # search_value = frame.eval_on_selector("#search", "el => el.value")
    # preload_href = frame.eval_on_selector("link[rel=preload]", "el => el.href")
    # html = frame.eval_on_selector(".main-container", "(e, suffix) => e.outerHTML + suffix", "hello")
    # ```
    #
    # ```csharp
    # var searchValue = await frame.EvalOnSelectorAsync<string>("#search", "el => el.value");
    # var preloadHref = await frame.EvalOnSelectorAsync<string>("link[rel=preload]", "el => el.href");
    # var html = await frame.EvalOnSelectorAsync(".main-container", "(e, suffix) => e.outerHTML + suffix", "hello");
    # ```
    def eval_on_selector(selector, expression, arg: nil)
      wrap_impl(@impl.eval_on_selector(unwrap_impl(selector), unwrap_impl(expression), arg: unwrap_impl(arg)))
    end

    # Returns the return value of `expression`.
    #
    # The method finds all elements matching the specified selector within the frame and passes an array of matched elements
    # as a first argument to `expression`. See [Working with selectors](./selectors.md) for more details.
    #
    # If `expression` returns a [Promise], then [`method: Frame.evalOnSelectorAll`] would wait for the promise to resolve and
    # return its value.
    #
    # Examples:
    #
    #
    # ```js
    # const divsCounts = await frame.$$eval('div', (divs, min) => divs.length >= min, 10);
    # ```
    #
    # ```java
    # boolean divsCounts = (boolean) page.evalOnSelectorAll("div", "(divs, min) => divs.length >= min", 10);
    # ```
    #
    # ```python async
    # divs_counts = await frame.eval_on_selector_all("div", "(divs, min) => divs.length >= min", 10)
    # ```
    #
    # ```python sync
    # divs_counts = frame.eval_on_selector_all("div", "(divs, min) => divs.length >= min", 10)
    # ```
    #
    # ```csharp
    # var divsCount = await frame.EvalOnSelectorAllAsync<bool>("div", "(divs, min) => divs.length >= min", 10);
    # ```
    def eval_on_selector_all(selector, expression, arg: nil)
      wrap_impl(@impl.eval_on_selector_all(unwrap_impl(selector), unwrap_impl(expression), arg: unwrap_impl(arg)))
    end

    # Returns the return value of `expression`.
    #
    # If the function passed to the [`method: Frame.evaluate`] returns a [Promise], then [`method: Frame.evaluate`] would wait
    # for the promise to resolve and return its value.
    #
    # If the function passed to the [`method: Frame.evaluate`] returns a non-[Serializable] value, then
    # [`method: Frame.evaluate`] returns `undefined`. Playwright also supports transferring some additional values that are
    # not serializable by `JSON`: `-0`, `NaN`, `Infinity`, `-Infinity`.
    #
    #
    # ```js
    # const result = await frame.evaluate(([x, y]) => {
    #   return Promise.resolve(x * y);
    # }, [7, 8]);
    # console.log(result); // prints "56"
    # ```
    #
    # ```java
    # Object result = frame.evaluate("([x, y]) => {\n" +
    #   "  return Promise.resolve(x * y);\n" +
    #   "}", Arrays.asList(7, 8));
    # System.out.println(result); // prints "56"
    # ```
    #
    # ```python async
    # result = await frame.evaluate("([x, y]) => Promise.resolve(x * y)", [7, 8])
    # print(result) # prints "56"
    # ```
    #
    # ```python sync
    # result = frame.evaluate("([x, y]) => Promise.resolve(x * y)", [7, 8])
    # print(result) # prints "56"
    # ```
    #
    # ```csharp
    # var result = await frame.EvaluateAsync<int>("([x, y]) => Promise.resolve(x * y)", new[] { 7, 8 });
    # Console.WriteLine(result);
    # ```
    #
    # A string can also be passed in instead of a function.
    #
    #
    # ```js
    # console.log(await frame.evaluate('1 + 2')); // prints "3"
    # ```
    #
    # ```java
    # System.out.println(frame.evaluate("1 + 2")); // prints "3"
    # ```
    #
    # ```python async
    # print(await frame.evaluate("1 + 2")) # prints "3"
    # x = 10
    # print(await frame.evaluate(f"1 + {x}")) # prints "11"
    # ```
    #
    # ```python sync
    # print(frame.evaluate("1 + 2")) # prints "3"
    # x = 10
    # print(frame.evaluate(f"1 + {x}")) # prints "11"
    # ```
    #
    # ```csharp
    # Console.WriteLine(await frame.EvaluateAsync<int>("1 + 2")); // prints "3"
    # ```
    #
    # `ElementHandle` instances can be passed as an argument to the [`method: Frame.evaluate`]:
    #
    #
    # ```js
    # const bodyHandle = await frame.$('body');
    # const html = await frame.evaluate(([body, suffix]) => body.innerHTML + suffix, [bodyHandle, 'hello']);
    # await bodyHandle.dispose();
    # ```
    #
    # ```java
    # ElementHandle bodyHandle = frame.querySelector("body");
    # String html = (String) frame.evaluate("([body, suffix]) => body.innerHTML + suffix", Arrays.asList(bodyHandle, "hello"));
    # bodyHandle.dispose();
    # ```
    #
    # ```python async
    # body_handle = await frame.query_selector("body")
    # html = await frame.evaluate("([body, suffix]) => body.innerHTML + suffix", [body_handle, "hello"])
    # await body_handle.dispose()
    # ```
    #
    # ```python sync
    # body_handle = frame.query_selector("body")
    # html = frame.evaluate("([body, suffix]) => body.innerHTML + suffix", [body_handle, "hello"])
    # body_handle.dispose()
    # ```
    #
    # ```csharp
    # var bodyHandle = await frame.QuerySelectorAsync("body");
    # var html = await frame.EvaluateAsync<string>("([body, suffix]) => body.innerHTML + suffix", new object [] { bodyHandle, "hello" });
    # await bodyHandle.DisposeAsync();
    # ```
    def evaluate(expression, arg: nil)
      wrap_impl(@impl.evaluate(unwrap_impl(expression), arg: unwrap_impl(arg)))
    end

    # Returns the return value of `expression` as a `JSHandle`.
    #
    # The only difference between [`method: Frame.evaluate`] and [`method: Frame.evaluateHandle`] is that
    # [`method: Frame.evaluateHandle`] returns `JSHandle`.
    #
    # If the function, passed to the [`method: Frame.evaluateHandle`], returns a [Promise], then
    # [`method: Frame.evaluateHandle`] would wait for the promise to resolve and return its value.
    #
    #
    # ```js
    # const aWindowHandle = await frame.evaluateHandle(() => Promise.resolve(window));
    # aWindowHandle; // Handle for the window object.
    # ```
    #
    # ```java
    # // Handle for the window object.
    # JSHandle aWindowHandle = frame.evaluateHandle("() => Promise.resolve(window)");
    # ```
    #
    # ```python async
    # a_window_handle = await frame.evaluate_handle("Promise.resolve(window)")
    # a_window_handle # handle for the window object.
    # ```
    #
    # ```python sync
    # a_window_handle = frame.evaluate_handle("Promise.resolve(window)")
    # a_window_handle # handle for the window object.
    # ```
    #
    # ```csharp
    # // Handle for the window object.
    # var aWindowHandle = await frame.EvaluateHandleAsync("() => Promise.resolve(window)");
    # ```
    #
    # A string can also be passed in instead of a function.
    #
    #
    # ```js
    # const aHandle = await frame.evaluateHandle('document'); // Handle for the 'document'.
    # ```
    #
    # ```java
    # JSHandle aHandle = frame.evaluateHandle("document"); // Handle for the "document".
    # ```
    #
    # ```python async
    # a_handle = await page.evaluate_handle("document") # handle for the "document"
    # ```
    #
    # ```python sync
    # a_handle = page.evaluate_handle("document") # handle for the "document"
    # ```
    #
    # ```csharp
    # var docHandle = await frame.EvalueHandleAsync("document"); // Handle for the `document`
    # ```
    #
    # `JSHandle` instances can be passed as an argument to the [`method: Frame.evaluateHandle`]:
    #
    #
    # ```js
    # const aHandle = await frame.evaluateHandle(() => document.body);
    # const resultHandle = await frame.evaluateHandle(([body, suffix]) => body.innerHTML + suffix, [aHandle, 'hello']);
    # console.log(await resultHandle.jsonValue());
    # await resultHandle.dispose();
    # ```
    #
    # ```java
    # JSHandle aHandle = frame.evaluateHandle("() => document.body");
    # JSHandle resultHandle = frame.evaluateHandle("([body, suffix]) => body.innerHTML + suffix", Arrays.asList(aHandle, "hello"));
    # System.out.println(resultHandle.jsonValue());
    # resultHandle.dispose();
    # ```
    #
    # ```python async
    # a_handle = await page.evaluate_handle("document.body")
    # result_handle = await page.evaluate_handle("body => body.innerHTML", a_handle)
    # print(await result_handle.json_value())
    # await result_handle.dispose()
    # ```
    #
    # ```python sync
    # a_handle = page.evaluate_handle("document.body")
    # result_handle = page.evaluate_handle("body => body.innerHTML", a_handle)
    # print(result_handle.json_value())
    # result_handle.dispose()
    # ```
    #
    # ```csharp
    # var handle = await frame.EvaluateHandleAsync("() => document.body");
    # var resultHandle = await frame.EvaluateHandleAsync("([body, suffix]) => body.innerHTML + suffix", new object[] { handle, "hello" });
    # Console.WriteLine(await resultHandle.JsonValueAsync<string>());
    # await resultHandle.DisposeAsync();
    # ```
    def evaluate_handle(expression, arg: nil)
      wrap_impl(@impl.evaluate_handle(unwrap_impl(expression), arg: unwrap_impl(arg)))
    end

    # This method waits for an element matching `selector`, waits for [actionability](./actionability.md) checks, focuses the
    # element, fills it and triggers an `input` event after filling. Note that you can pass an empty string to clear the input
    # field.
    #
    # If the target element is not an `<input>`, `<textarea>` or `[contenteditable]` element, this method throws an error.
    # However, if the element is inside the `<label>` element that has an associated
    # [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be filled
    # instead.
    #
    # To send fine-grained keyboard events, use [`method: Frame.type`].
    def fill(selector, value, noWaitAfter: nil, timeout: nil)
      wrap_impl(@impl.fill(unwrap_impl(selector), unwrap_impl(value), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end

    # This method fetches an element with `selector` and focuses it. If there's no element matching `selector`, the method
    # waits until a matching element appears in the DOM.
    def focus(selector, timeout: nil)
      wrap_impl(@impl.focus(unwrap_impl(selector), timeout: unwrap_impl(timeout)))
    end

    # Returns the `frame` or `iframe` element handle which corresponds to this frame.
    #
    # This is an inverse of [`method: ElementHandle.contentFrame`]. Note that returned handle actually belongs to the parent
    # frame.
    #
    # This method throws an error if the frame has been detached before `frameElement()` returns.
    #
    #
    # ```js
    # const frameElement = await frame.frameElement();
    # const contentFrame = await frameElement.contentFrame();
    # console.log(frame === contentFrame);  // -> true
    # ```
    #
    # ```java
    # ElementHandle frameElement = frame.frameElement();
    # Frame contentFrame = frameElement.contentFrame();
    # System.out.println(frame == contentFrame);  // -> true
    # ```
    #
    # ```python async
    # frame_element = await frame.frame_element()
    # content_frame = await frame_element.content_frame()
    # assert frame == content_frame
    # ```
    #
    # ```python sync
    # frame_element = frame.frame_element()
    # content_frame = frame_element.content_frame()
    # assert frame == content_frame
    # ```
    #
    # ```csharp
    # var frameElement = await frame.FrameElementAsync();
    # var contentFrame = await frameElement.ContentFrameAsync();
    # Console.WriteLine(frame == contentFrame); // -> True
    # ```
    def frame_element
      wrap_impl(@impl.frame_element)
    end

    # Returns element attribute value.
    def get_attribute(selector, name, timeout: nil)
      wrap_impl(@impl.get_attribute(unwrap_impl(selector), unwrap_impl(name), timeout: unwrap_impl(timeout)))
    end

    # Returns the main resource response. In case of multiple redirects, the navigation will resolve with the response of the
    # last redirect.
    #
    # `frame.goto` will throw an error if:
    # - there's an SSL error (e.g. in case of self-signed certificates).
    # - target URL is invalid.
    # - the `timeout` is exceeded during navigation.
    # - the remote server does not respond or is unreachable.
    # - the main resource failed to load.
    #
    # `frame.goto` will not throw an error when any valid HTTP status code is returned by the remote server, including 404
    # "Not Found" and 500 "Internal Server Error".  The status code for such responses can be retrieved by calling
    # [`method: Response.status`].
    #
    # > NOTE: `frame.goto` either throws an error or returns a main resource response. The only exceptions are navigation to
    # `about:blank` or navigation to the same URL with a different hash, which would succeed and return `null`.
    # > NOTE: Headless mode doesn't support navigation to a PDF document. See the
    # [upstream issue](https://bugs.chromium.org/p/chromium/issues/detail?id=761295).
    def goto(url, referer: nil, timeout: nil, waitUntil: nil)
      wrap_impl(@impl.goto(unwrap_impl(url), referer: unwrap_impl(referer), timeout: unwrap_impl(timeout), waitUntil: unwrap_impl(waitUntil)))
    end

    # This method hovers over an element matching `selector` by performing the following steps:
    # 1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
    # 1. Wait for [actionability](./actionability.md) checks on the matched element, unless `force` option is set. If the
    #    element is detached during the checks, the whole action is retried.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.mouse`] to hover over the center of the element, or the specified `position`.
    # 1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`. Passing
    # zero timeout disables this.
    def hover(
          selector,
          force: nil,
          modifiers: nil,
          position: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.hover(unwrap_impl(selector), force: unwrap_impl(force), modifiers: unwrap_impl(modifiers), position: unwrap_impl(position), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    # Returns `element.innerHTML`.
    def inner_html(selector, timeout: nil)
      wrap_impl(@impl.inner_html(unwrap_impl(selector), timeout: unwrap_impl(timeout)))
    end

    # Returns `element.innerText`.
    def inner_text(selector, timeout: nil)
      wrap_impl(@impl.inner_text(unwrap_impl(selector), timeout: unwrap_impl(timeout)))
    end

    # Returns whether the element is checked. Throws if the element is not a checkbox or radio input.
    def checked?(selector, timeout: nil)
      wrap_impl(@impl.checked?(unwrap_impl(selector), timeout: unwrap_impl(timeout)))
    end

    # Returns `true` if the frame has been detached, or `false` otherwise.
    def detached?
      wrap_impl(@impl.detached?)
    end

    # Returns whether the element is disabled, the opposite of [enabled](./actionability.md#enabled).
    def disabled?(selector, timeout: nil)
      wrap_impl(@impl.disabled?(unwrap_impl(selector), timeout: unwrap_impl(timeout)))
    end

    # Returns whether the element is [editable](./actionability.md#editable).
    def editable?(selector, timeout: nil)
      wrap_impl(@impl.editable?(unwrap_impl(selector), timeout: unwrap_impl(timeout)))
    end

    # Returns whether the element is [enabled](./actionability.md#enabled).
    def enabled?(selector, timeout: nil)
      wrap_impl(@impl.enabled?(unwrap_impl(selector), timeout: unwrap_impl(timeout)))
    end

    # Returns whether the element is hidden, the opposite of [visible](./actionability.md#visible).  `selector` that does not
    # match any elements is considered hidden.
    def hidden?(selector, timeout: nil)
      wrap_impl(@impl.hidden?(unwrap_impl(selector), timeout: unwrap_impl(timeout)))
    end

    # Returns whether the element is [visible](./actionability.md#visible). `selector` that does not match any elements is
    # considered not visible.
    def visible?(selector, timeout: nil)
      wrap_impl(@impl.visible?(unwrap_impl(selector), timeout: unwrap_impl(timeout)))
    end

    # Returns frame's name attribute as specified in the tag.
    #
    # If the name is empty, returns the id attribute instead.
    #
    # > NOTE: This value is calculated once when the frame is created, and will not update if the attribute is changed later.
    def name
      wrap_impl(@impl.name)
    end

    # Returns the page containing this frame.
    def page
      wrap_impl(@impl.page)
    end

    # Parent frame, if any. Detached frames and main frames return `null`.
    def parent_frame
      wrap_impl(@impl.parent_frame)
    end

    # `key` can specify the intended [keyboardEvent.key](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key)
    # value or a single character to generate the text for. A superset of the `key` values can be found
    # [here](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values). Examples of the keys are:
    #
    # `F1` - `F12`, `Digit0`- `Digit9`, `KeyA`- `KeyZ`, `Backquote`, `Minus`, `Equal`, `Backslash`, `Backspace`, `Tab`,
    # `Delete`, `Escape`, `ArrowDown`, `End`, `Enter`, `Home`, `Insert`, `PageDown`, `PageUp`, `ArrowRight`, `ArrowUp`, etc.
    #
    # Following modification shortcuts are also supported: `Shift`, `Control`, `Alt`, `Meta`, `ShiftLeft`.
    #
    # Holding down `Shift` will type the text that corresponds to the `key` in the upper case.
    #
    # If `key` is a single character, it is case-sensitive, so the values `a` and `A` will generate different respective
    # texts.
    #
    # Shortcuts such as `key: "Control+o"` or `key: "Control+Shift+T"` are supported as well. When specified with the
    # modifier, modifier is pressed and being held while the subsequent key is being pressed.
    def press(
          selector,
          key,
          delay: nil,
          noWaitAfter: nil,
          timeout: nil)
      wrap_impl(@impl.press(unwrap_impl(selector), unwrap_impl(key), delay: unwrap_impl(delay), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end

    # Returns the ElementHandle pointing to the frame element.
    #
    # The method finds an element matching the specified selector within the frame. See
    # [Working with selectors](./selectors.md) for more details. If no elements match the selector, returns `null`.
    def query_selector(selector)
      wrap_impl(@impl.query_selector(unwrap_impl(selector)))
    end

    # Returns the ElementHandles pointing to the frame elements.
    #
    # The method finds all elements matching the specified selector within the frame. See
    # [Working with selectors](./selectors.md) for more details. If no elements match the selector, returns empty array.
    def query_selector_all(selector)
      wrap_impl(@impl.query_selector_all(unwrap_impl(selector)))
    end

    # This method waits for an element matching `selector`, waits for [actionability](./actionability.md) checks, waits until
    # all specified options are present in the `<select>` element and selects these options.
    #
    # If the target element is not a `<select>` element, this method throws an error. However, if the element is inside the
    # `<label>` element that has an associated
    # [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be used instead.
    #
    # Returns the array of option values that have been successfully selected.
    #
    # Triggers a `change` and `input` event once all the provided options have been selected.
    #
    #
    # ```js
    # // single selection matching the value
    # frame.selectOption('select#colors', 'blue');
    #
    # // single selection matching both the value and the label
    # frame.selectOption('select#colors', { label: 'Blue' });
    #
    # // multiple selection
    # frame.selectOption('select#colors', 'red', 'green', 'blue');
    # ```
    #
    # ```java
    # // single selection matching the value
    # frame.selectOption("select#colors", "blue");
    # // single selection matching both the value and the label
    # frame.selectOption("select#colors", new SelectOption().setLabel("Blue"));
    # // multiple selection
    # frame.selectOption("select#colors", new String[] {"red", "green", "blue"});
    # ```
    #
    # ```python async
    # # single selection matching the value
    # await frame.select_option("select#colors", "blue")
    # # single selection matching the label
    # await frame.select_option("select#colors", label="blue")
    # # multiple selection
    # await frame.select_option("select#colors", value=["red", "green", "blue"])
    # ```
    #
    # ```python sync
    # # single selection matching the value
    # frame.select_option("select#colors", "blue")
    # # single selection matching both the label
    # frame.select_option("select#colors", label="blue")
    # # multiple selection
    # frame.select_option("select#colors", value=["red", "green", "blue"])
    # ```
    #
    # ```csharp
    # // single selection matching the value
    # await frame.SelectOptionAsync("select#colors", new[] { "blue" });
    # // single selection matching both the value and the label
    # await frame.SelectOptionAsync("select#colors", new[] { new SelectOptionValue() { Label = "blue" } });
    # // multiple selection
    # await frame.SelectOptionAsync("select#colors", new[] { "red", "green", "blue" });
    # ```
    def select_option(
          selector,
          element: nil,
          index: nil,
          value: nil,
          label: nil,
          noWaitAfter: nil,
          timeout: nil)
      wrap_impl(@impl.select_option(unwrap_impl(selector), element: unwrap_impl(element), index: unwrap_impl(index), value: unwrap_impl(value), label: unwrap_impl(label), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end

    def set_content(html, timeout: nil, waitUntil: nil)
      wrap_impl(@impl.set_content(unwrap_impl(html), timeout: unwrap_impl(timeout), waitUntil: unwrap_impl(waitUntil)))
    end
    alias_method :content=, :set_content

    # This method expects `selector` to point to an
    # [input element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input).
    #
    # Sets the value of the file input to these file paths or files. If some of the `filePaths` are relative paths, then they
    # are resolved relative to the the current working directory. For empty array, clears the selected files.
    def set_input_files(selector, files, noWaitAfter: nil, timeout: nil)
      wrap_impl(@impl.set_input_files(unwrap_impl(selector), unwrap_impl(files), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end

    # This method taps an element matching `selector` by performing the following steps:
    # 1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
    # 1. Wait for [actionability](./actionability.md) checks on the matched element, unless `force` option is set. If the
    #    element is detached during the checks, the whole action is retried.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.touchscreen`] to tap the center of the element, or the specified `position`.
    # 1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`. Passing
    # zero timeout disables this.
    #
    # > NOTE: `frame.tap()` requires that the `hasTouch` option of the browser context be set to true.
    def tap_point(
          selector,
          force: nil,
          modifiers: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.tap_point(unwrap_impl(selector), force: unwrap_impl(force), modifiers: unwrap_impl(modifiers), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    # Returns `element.textContent`.
    def text_content(selector, timeout: nil)
      wrap_impl(@impl.text_content(unwrap_impl(selector), timeout: unwrap_impl(timeout)))
    end

    # Returns the page title.
    def title
      wrap_impl(@impl.title)
    end

    # Sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text. `frame.type` can be used to
    # send fine-grained keyboard events. To fill values in form fields, use [`method: Frame.fill`].
    #
    # To press a special key, like `Control` or `ArrowDown`, use [`method: Keyboard.press`].
    #
    #
    # ```js
    # await frame.type('#mytextarea', 'Hello'); // Types instantly
    # await frame.type('#mytextarea', 'World', {delay: 100}); // Types slower, like a user
    # ```
    #
    # ```java
    # // Types instantly
    # frame.type("#mytextarea", "Hello");
    # // Types slower, like a user
    # frame.type("#mytextarea", "World", new Frame.TypeOptions().setDelay(100));
    # ```
    #
    # ```python async
    # await frame.type("#mytextarea", "hello") # types instantly
    # await frame.type("#mytextarea", "world", delay=100) # types slower, like a user
    # ```
    #
    # ```python sync
    # frame.type("#mytextarea", "hello") # types instantly
    # frame.type("#mytextarea", "world", delay=100) # types slower, like a user
    # ```
    #
    # ```csharp
    # await frame.TypeAsync("#mytextarea", "hello"); // types instantly
    # await frame.TypeAsync("#mytextarea", "world", delay: 100); // types slower, like a user
    # ```
    def type(
          selector,
          text,
          delay: nil,
          noWaitAfter: nil,
          timeout: nil)
      wrap_impl(@impl.type(unwrap_impl(selector), unwrap_impl(text), delay: unwrap_impl(delay), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end

    # This method checks an element matching `selector` by performing the following steps:
    # 1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
    # 1. Ensure that matched element is a checkbox or a radio input. If not, this method throws. If the element is already
    #    unchecked, this method returns immediately.
    # 1. Wait for [actionability](./actionability.md) checks on the matched element, unless `force` option is set. If the
    #    element is detached during the checks, the whole action is retried.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.mouse`] to click in the center of the element.
    # 1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.
    # 1. Ensure that the element is now unchecked. If not, this method throws.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a `TimeoutError`. Passing
    # zero timeout disables this.
    def uncheck(
          selector,
          force: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.uncheck(unwrap_impl(selector), force: unwrap_impl(force), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    # Returns frame's url.
    def url
      wrap_impl(@impl.url)
    end

    # Returns when the `expression` returns a truthy value, returns that value.
    #
    # The [`method: Frame.waitForFunction`] can be used to observe viewport size change:
    #
    #
    # ```js
    # const { firefox } = require('playwright');  // Or 'chromium' or 'webkit'.
    #
    # (async () => {
    #   const browser = await firefox.launch();
    #   const page = await browser.newPage();
    #   const watchDog = page.mainFrame().waitForFunction('window.innerWidth < 100');
    #   page.setViewportSize({width: 50, height: 50});
    #   await watchDog;
    #   await browser.close();
    # })();
    # ```
    #
    # ```java
    # import com.microsoft.playwright.*;
    #
    # public class Example {
    #   public static void main(String[] args) {
    #     try (Playwright playwright = Playwright.create()) {
    #       BrowserType firefox = playwright.firefox();
    #       Browser browser = firefox.launch();
    #       Page page = browser.newPage();
    #       page.setViewportSize(50, 50);
    #       page.mainFrame().waitForFunction("window.innerWidth < 100");
    #       browser.close();
    #     }
    #   }
    # }
    # ```
    #
    # ```python async
    # import asyncio
    # from playwright.async_api import async_playwright
    #
    # async def run(playwright):
    #     webkit = playwright.webkit
    #     browser = await webkit.launch()
    #     page = await browser.new_page()
    #     await page.evaluate("window.x = 0; setTimeout(() => { window.x = 100 }, 1000);")
    #     await page.main_frame.wait_for_function("() => window.x > 0")
    #     await browser.close()
    #
    # async def main():
    #     async with async_playwright() as playwright:
    #         await run(playwright)
    # asyncio.run(main())
    # ```
    #
    # ```python sync
    # from playwright.sync_api import sync_playwright
    #
    # def run(playwright):
    #     webkit = playwright.webkit
    #     browser = webkit.launch()
    #     page = browser.new_page()
    #     page.evaluate("window.x = 0; setTimeout(() => { window.x = 100 }, 1000);")
    #     page.main_frame.wait_for_function("() => window.x > 0")
    #     browser.close()
    #
    # with sync_playwright() as playwright:
    #     run(playwright)
    # ```
    #
    # ```csharp
    # using Microsoft.Playwright;
    # using System.Threading.Tasks;
    #
    # class FrameExamples
    # {
    #     public static async Task Main()
    #     {
    #         using var playwright = await Playwright.CreateAsync();
    #         await using var browser = await playwright.Firefox.LaunchAsync();
    #         var page = await browser.NewPageAsync();
    #         await page.SetViewportSizeAsync(50, 50);
    #         await page.MainFrame.WaitForFunctionAsync("window.innerWidth < 100");
    #     }
    # }
    # ```
    #
    # To pass an argument to the predicate of `frame.waitForFunction` function:
    #
    #
    # ```js
    # const selector = '.foo';
    # await frame.waitForFunction(selector => !!document.querySelector(selector), selector);
    # ```
    #
    # ```java
    # String selector = ".foo";
    # frame.waitForFunction("selector => !!document.querySelector(selector)", selector);
    # ```
    #
    # ```python async
    # selector = ".foo"
    # await frame.wait_for_function("selector => !!document.querySelector(selector)", selector)
    # ```
    #
    # ```python sync
    # selector = ".foo"
    # frame.wait_for_function("selector => !!document.querySelector(selector)", selector)
    # ```
    #
    # ```csharp
    # var selector = ".foo";
    # await page.MainFrame.WaitForFunctionAsync("selector => !!document.querySelector(selector)", selector);
    # ```
    def wait_for_function(expression, arg: nil, polling: nil, timeout: nil)
      wrap_impl(@impl.wait_for_function(unwrap_impl(expression), arg: unwrap_impl(arg), polling: unwrap_impl(polling), timeout: unwrap_impl(timeout)))
    end

    # Waits for the required load state to be reached.
    #
    # This returns when the frame reaches a required load state, `load` by default. The navigation must have been committed
    # when this method is called. If current document has already reached the required state, resolves immediately.
    #
    #
    # ```js
    # await frame.click('button'); // Click triggers navigation.
    # await frame.waitForLoadState(); // Waits for 'load' state by default.
    # ```
    #
    # ```java
    # frame.click("button"); // Click triggers navigation.
    # frame.waitForLoadState(); // Waits for "load" state by default.
    # ```
    #
    # ```python async
    # await frame.click("button") # click triggers navigation.
    # await frame.wait_for_load_state() # the promise resolves after "load" event.
    # ```
    #
    # ```python sync
    # frame.click("button") # click triggers navigation.
    # frame.wait_for_load_state() # the promise resolves after "load" event.
    # ```
    #
    # ```csharp
    # await frame.ClickAsync("button");
    # await frame.WaitForLoadStateAsync(); // Defaults to LoadState.Load
    # ```
    def wait_for_load_state(state: nil, timeout: nil)
      wrap_impl(@impl.wait_for_load_state(state: unwrap_impl(state), timeout: unwrap_impl(timeout)))
    end

    # Waits for the frame navigation and returns the main resource response. In case of multiple redirects, the navigation
    # will resolve with the response of the last redirect. In case of navigation to a different anchor or navigation due to
    # History API usage, the navigation will resolve with `null`.
    #
    # This method waits for the frame to navigate to a new URL. It is useful for when you run code which will indirectly cause
    # the frame to navigate. Consider this example:
    #
    #
    # ```js
    # const [response] = await Promise.all([
    #   frame.waitForNavigation(), // The promise resolves after navigation has finished
    #   frame.click('a.delayed-navigation'), // Clicking the link will indirectly cause a navigation
    # ]);
    # ```
    #
    # ```java
    # // The method returns after navigation has finished
    # Response response = frame.waitForNavigation(() -> {
    #   // Clicking the link will indirectly cause a navigation
    #   frame.click("a.delayed-navigation");
    # });
    # ```
    #
    # ```python async
    # async with frame.expect_navigation():
    #     await frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
    # # Resolves after navigation has finished
    # ```
    #
    # ```python sync
    # with frame.expect_navigation():
    #     frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
    # # Resolves after navigation has finished
    # ```
    #
    # ```csharp
    # await Task.WhenAll(
    #     frame.WaitForNavigationAsync(),
    #     // clicking the link will indirectly cause a navigation
    #     frame.ClickAsync("a.delayed-navigation"));
    # // Resolves after navigation has finished
    # ```
    #
    # > NOTE: Usage of the [History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API) to change the URL is
    # considered a navigation.
    def expect_navigation(timeout: nil, url: nil, waitUntil: nil, &block)
      wrap_impl(@impl.expect_navigation(timeout: unwrap_impl(timeout), url: unwrap_impl(url), waitUntil: unwrap_impl(waitUntil), &wrap_block_call(block)))
    end

    # Returns when element specified by selector satisfies `state` option. Returns `null` if waiting for `hidden` or
    # `detached`.
    #
    # Wait for the `selector` to satisfy `state` option (either appear/disappear from dom, or become visible/hidden). If at
    # the moment of calling the method `selector` already satisfies the condition, the method will return immediately. If the
    # selector doesn't satisfy the condition for the `timeout` milliseconds, the function will throw.
    #
    # This method works across navigations:
    #
    #
    # ```js
    # const { chromium } = require('playwright');  // Or 'firefox' or 'webkit'.
    #
    # (async () => {
    #   const browser = await chromium.launch();
    #   const page = await browser.newPage();
    #   for (let currentURL of ['https://google.com', 'https://bbc.com']) {
    #     await page.goto(currentURL);
    #     const element = await page.mainFrame().waitForSelector('img');
    #     console.log('Loaded image: ' + await element.getAttribute('src'));
    #   }
    #   await browser.close();
    # })();
    # ```
    #
    # ```java
    # import com.microsoft.playwright.*;
    #
    # public class Example {
    #   public static void main(String[] args) {
    #     try (Playwright playwright = Playwright.create()) {
    #       BrowserType chromium = playwright.chromium();
    #       Browser browser = chromium.launch();
    #       Page page = browser.newPage();
    #       for (String currentURL : Arrays.asList("https://google.com", "https://bbc.com")) {
    #         page.navigate(currentURL);
    #         ElementHandle element = page.mainFrame().waitForSelector("img");
    #         System.out.println("Loaded image: " + element.getAttribute("src"));
    #       }
    #       browser.close();
    #     }
    #   }
    # }
    # ```
    #
    # ```python async
    # import asyncio
    # from playwright.async_api import async_playwright
    #
    # async def run(playwright):
    #     chromium = playwright.chromium
    #     browser = await chromium.launch()
    #     page = await browser.new_page()
    #     for current_url in ["https://google.com", "https://bbc.com"]:
    #         await page.goto(current_url, wait_until="domcontentloaded")
    #         element = await page.main_frame.wait_for_selector("img")
    #         print("Loaded image: " + str(await element.get_attribute("src")))
    #     await browser.close()
    #
    # async def main():
    #     async with async_playwright() as playwright:
    #         await run(playwright)
    # asyncio.run(main())
    # ```
    #
    # ```python sync
    # from playwright.sync_api import sync_playwright
    #
    # def run(playwright):
    #     chromium = playwright.chromium
    #     browser = chromium.launch()
    #     page = browser.new_page()
    #     for current_url in ["https://google.com", "https://bbc.com"]:
    #         page.goto(current_url, wait_until="domcontentloaded")
    #         element = page.main_frame.wait_for_selector("img")
    #         print("Loaded image: " + str(element.get_attribute("src")))
    #     browser.close()
    #
    # with sync_playwright() as playwright:
    #     run(playwright)
    # ```
    #
    # ```csharp
    # using Microsoft.Playwright;
    # using System;
    # using System.Threading.Tasks;
    #
    # class FrameExamples
    # {
    #   public static async Task Main()
    #   {
    #     using var playwright = await Playwright.CreateAsync();
    #     await using var browser = await playwright.Chromium.LaunchAsync();
    #     var page = await browser.NewPageAsync();
    #
    #     foreach (var currentUrl in new[] { "https://www.google.com", "https://bbc.com" })
    #     {
    #       await page.GotoAsync(currentUrl);
    #       element = await page.MainFrame.WaitForSelectorAsync("img");
    #       Console.WriteLine($"Loaded image: {await element.GetAttributeAsync("src")}");
    #     }
    #   }
    # }
    # ```
    def wait_for_selector(selector, state: nil, timeout: nil)
      wrap_impl(@impl.wait_for_selector(unwrap_impl(selector), state: unwrap_impl(state), timeout: unwrap_impl(timeout)))
    end

    # Waits for the given `timeout` in milliseconds.
    #
    # Note that `frame.waitForTimeout()` should only be used for debugging. Tests using the timer in production are going to
    # be flaky. Use signals such as network events, selectors becoming visible and others instead.
    def wait_for_timeout(timeout)
      raise NotImplementedError.new('wait_for_timeout is not implemented yet.')
    end

    # Waits for the frame to navigate to the given URL.
    #
    #
    # ```js
    # await frame.click('a.delayed-navigation'); // Clicking the link will indirectly cause a navigation
    # await frame.waitForURL('**/target.html');
    # ```
    #
    # ```java
    # frame.click("a.delayed-navigation"); // Clicking the link will indirectly cause a navigation
    # frame.waitForURL("**/target.html");
    # ```
    #
    # ```python async
    # await frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
    # await frame.wait_for_url("**/target.html")
    # ```
    #
    # ```python sync
    # frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
    # frame.wait_for_url("**/target.html")
    # ```
    #
    # ```csharp
    # await frame.ClickAsync("a.delayed-navigation"); // clicking the link will indirectly cause a navigation
    # await frame.WaitForURLAsync("**/target.html");
    # ```
    def wait_for_url(url, timeout: nil, waitUntil: nil)
      wrap_impl(@impl.wait_for_url(unwrap_impl(url), timeout: unwrap_impl(timeout), waitUntil: unwrap_impl(waitUntil)))
    end

    # @nodoc
    def detached=(req)
      wrap_impl(@impl.detached=(unwrap_impl(req)))
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def on(event, callback)
      event_emitter_proxy.on(event, callback)
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def off(event, callback)
      event_emitter_proxy.off(event, callback)
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def once(event, callback)
      event_emitter_proxy.once(event, callback)
    end

    private def event_emitter_proxy
      @event_emitter_proxy ||= EventEmitterProxy.new(self, @impl)
    end
  end
end
