module Playwright
  # - extends: [EventEmitter]
  # 
  # Page provides methods to interact with a single tab in a `Browser`, or an
  # [extension background page](https://developer.chrome.com/extensions/background_pages) in Chromium. One `Browser`
  # instance might have multiple `Page` instances.
  # 
  # This example creates a page, navigates it to a URL, and then saves a screenshot:
  # 
  #
  # ```js
  # const { webkit } = require('playwright');  // Or 'chromium' or 'firefox'.
  # 
  # (async () => {
  #   const browser = await webkit.launch();
  #   const context = await browser.newContext();
  #   const page = await context.newPage();
  #   await page.goto('https://example.com');
  #   await page.screenshot({path: 'screenshot.png'});
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
  #       BrowserType webkit = playwright.webkit();
  #       Browser browser = webkit.launch();
  #       BrowserContext context = browser.newContext();
  #       Page page = context.newPage();
  #       page.navigate("https://example.com");
  #       page.screenshot(new Page.ScreenshotOptions().setPath(Paths.get("screenshot.png")));
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
  #     context = await browser.new_context()
  #     page = await context.new_page()
  #     await page.goto("https://example.com")
  #     await page.screenshot(path="screenshot.png")
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
  #     context = browser.new_context()
  #     page = context.new_page()
  #     page.goto("https://example.com")
  #     page.screenshot(path="screenshot.png")
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
  # class PageExamples
  # {
  #     public static async Task Run()
  #     {
  #         using var playwright = await Playwright.CreateAsync();
  #         await using var browser = await playwright.Webkit.LaunchAsync();
  #         var page = await browser.NewPageAsync();
  #         await page.GotoAsync("https://www.theverge.com");
  #         await page.ScreenshotAsync("theverge.png");
  #     }
  # }
  # ```
  # 
  # The Page class emits various events (described below) which can be handled using any of Node's native
  # [`EventEmitter`](https://nodejs.org/api/events.html#events_class_eventemitter) methods, such as `on`, `once` or
  # `removeListener`.
  # 
  # This example logs a message for a single page `load` event:
  # 
  #
  # ```js
  # page.once('load', () => console.log('Page loaded!'));
  # ```
  # 
  # ```java
  # page.onLoad(p -> System.out.println("Page loaded!"));
  # ```
  # 
  # ```py
  # page.once("load", lambda: print("page loaded!"))
  # ```
  # 
  # ```csharp
  # page.Load += (_, _) => Console.WriteLine("Page loaded!");
  # ```
  # 
  # To unsubscribe from events use the `removeListener` method:
  # 
  #
  # ```js
  # function logRequest(interceptedRequest) {
  #   console.log('A request was made:', interceptedRequest.url());
  # }
  # page.on('request', logRequest);
  # // Sometime later...
  # page.removeListener('request', logRequest);
  # ```
  # 
  # ```java
  # Consumer<Request> logRequest = interceptedRequest -> {
  #   System.out.println("A request was made: " + interceptedRequest.url());
  # };
  # page.onRequest(logRequest);
  # // Sometime later...
  # page.offRequest(logRequest);
  # ```
  # 
  # ```py
  # def log_request(intercepted_request):
  #     print("a request was made:", intercepted_request.url)
  # page.on("request", log_request)
  # # sometime later...
  # page.remove_listener("request", log_request)
  # ```
  # 
  # ```csharp
  # void PageLoadHandler(object _, IPage p) {
  #     Console.WriteLine("Page loaded!");
  # };
  # 
  # page.Load += PageLoadHandler;
  # // Do some work...
  # page.Load -= PageLoadHandler;
  # ```
  class Page < PlaywrightApi

    def accessibility # property
      wrap_impl(@impl.accessibility)
    end

    def keyboard # property
      wrap_impl(@impl.keyboard)
    end

    def mouse # property
      wrap_impl(@impl.mouse)
    end

    def touchscreen # property
      wrap_impl(@impl.touchscreen)
    end

    # Adds a script which would be evaluated in one of the following scenarios:
    # - Whenever the page is navigated.
    # - Whenever the child frame is attached or navigated. In this case, the script is evaluated in the context of the newly
    #   attached frame.
    # 
    # The script is evaluated after the document was created but before any of its scripts were run. This is useful to amend
    # the JavaScript environment, e.g. to seed `Math.random`.
    # 
    # An example of overriding `Math.random` before the page loads:
    # 
    #
    # ```js browser
    # // preload.js
    # Math.random = () => 42;
    # ```
    # 
    #
    # ```js
    # // In your playwright script, assuming the preload.js file is in same directory
    # await page.addInitScript({ path: './preload.js' });
    # ```
    # 
    # ```java
    # // In your playwright script, assuming the preload.js file is in same directory
    # page.addInitScript(Paths.get("./preload.js"));
    # ```
    # 
    # ```python async
    # # in your playwright script, assuming the preload.js file is in same directory
    # await page.add_init_script(path="./preload.js")
    # ```
    # 
    # ```python sync
    # # in your playwright script, assuming the preload.js file is in same directory
    # page.add_init_script(path="./preload.js")
    # ```
    # 
    # ```csharp
    # await page.AddInitScriptAsync(scriptPath: "./preload.js");
    # ```
    # 
    # > NOTE: The order of evaluation of multiple scripts installed via [`method: BrowserContext.addInitScript`] and
    # [`method: Page.addInitScript`] is not defined.
    def add_init_script(path: nil, script: nil)
      wrap_impl(@impl.add_init_script(path: unwrap_impl(path), script: unwrap_impl(script)))
    end

    # Adds a `<script>` tag into the page with the desired url or content. Returns the added tag when the script's onload
    # fires or when the script content was injected into frame.
    # 
    # Shortcut for main frame's [`method: Frame.addScriptTag`].
    def add_script_tag(content: nil, path: nil, type: nil, url: nil)
      wrap_impl(@impl.add_script_tag(content: unwrap_impl(content), path: unwrap_impl(path), type: unwrap_impl(type), url: unwrap_impl(url)))
    end

    # Adds a `<link rel="stylesheet">` tag into the page with the desired url or a `<style type="text/css">` tag with the
    # content. Returns the added tag when the stylesheet's onload fires or when the CSS content was injected into frame.
    # 
    # Shortcut for main frame's [`method: Frame.addStyleTag`].
    def add_style_tag(content: nil, path: nil, url: nil)
      wrap_impl(@impl.add_style_tag(content: unwrap_impl(content), path: unwrap_impl(path), url: unwrap_impl(url)))
    end

    # Brings page to front (activates tab).
    def bring_to_front
      wrap_impl(@impl.bring_to_front)
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
    # 
    # Shortcut for main frame's [`method: Frame.check`].
    def check(
          selector,
          force: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.check(unwrap_impl(selector), force: unwrap_impl(force), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
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
    # 
    # Shortcut for main frame's [`method: Frame.click`].
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

    # If `runBeforeUnload` is `false`, does not run any unload handlers and waits for the page to be closed. If
    # `runBeforeUnload` is `true` the method will run unload handlers, but will **not** wait for the page to close.
    # 
    # By default, `page.close()` **does not** run `beforeunload` handlers.
    # 
    # > NOTE: if `runBeforeUnload` is passed as true, a `beforeunload` dialog might be summoned and should be handled manually
    # via [`event: Page.dialog`] event.
    def close(runBeforeUnload: nil)
      wrap_impl(@impl.close(runBeforeUnload: unwrap_impl(runBeforeUnload)))
    end

    # Gets the full HTML contents of the page, including the doctype.
    def content
      wrap_impl(@impl.content)
    end

    # Get the browser context that the page belongs to.
    def context
      wrap_impl(@impl.context)
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
    # > NOTE: `page.dblclick()` dispatches two `click` events and a single `dblclick` event.
    # 
    # Shortcut for main frame's [`method: Frame.dblclick`].
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
    # await page.dispatchEvent('button#submit', 'click');
    # ```
    # 
    # ```java
    # page.dispatchEvent("button#submit", "click");
    # ```
    # 
    # ```python async
    # await page.dispatch_event("button#submit", "click")
    # ```
    # 
    # ```python sync
    # page.dispatch_event("button#submit", "click")
    # ```
    # 
    # ```csharp
    # await page.DispatchEventAsync("button#submit", "click");
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
    # const dataTransfer = await page.evaluateHandle(() => new DataTransfer());
    # await page.dispatchEvent('#source', 'dragstart', { dataTransfer });
    # ```
    # 
    # ```java
    # // Note you can only create DataTransfer in Chromium and Firefox
    # JSHandle dataTransfer = page.evaluateHandle("() => new DataTransfer()");
    # Map<String, Object> arg = new HashMap<>();
    # arg.put("dataTransfer", dataTransfer);
    # page.dispatchEvent("#source", "dragstart", arg);
    # ```
    # 
    # ```python async
    # # note you can only create data_transfer in chromium and firefox
    # data_transfer = await page.evaluate_handle("new DataTransfer()")
    # await page.dispatch_event("#source", "dragstart", { "dataTransfer": data_transfer })
    # ```
    # 
    # ```python sync
    # # note you can only create data_transfer in chromium and firefox
    # data_transfer = page.evaluate_handle("new DataTransfer()")
    # page.dispatch_event("#source", "dragstart", { "dataTransfer": data_transfer })
    # ```
    # 
    # ```csharp
    # var dataTransfer = await page.EvaluateHandleAsync("() => new DataTransfer()");
    # await page.DispatchEventAsync("#source", "dragstart", new { dataTransfer });
    # ```
    def dispatch_event(selector, type, eventInit: nil, timeout: nil)
      wrap_impl(@impl.dispatch_event(unwrap_impl(selector), unwrap_impl(type), eventInit: unwrap_impl(eventInit), timeout: unwrap_impl(timeout)))
    end

    # This method changes the `CSS media type` through the `media` argument, and/or the `'prefers-colors-scheme'` media
    # feature, using the `colorScheme` argument.
    # 
    #
    # ```js
    # await page.evaluate(() => matchMedia('screen').matches);
    # // → true
    # await page.evaluate(() => matchMedia('print').matches);
    # // → false
    # 
    # await page.emulateMedia({ media: 'print' });
    # await page.evaluate(() => matchMedia('screen').matches);
    # // → false
    # await page.evaluate(() => matchMedia('print').matches);
    # // → true
    # 
    # await page.emulateMedia({});
    # await page.evaluate(() => matchMedia('screen').matches);
    # // → true
    # await page.evaluate(() => matchMedia('print').matches);
    # // → false
    # ```
    # 
    # ```java
    # page.evaluate("() => matchMedia('screen').matches");
    # // → true
    # page.evaluate("() => matchMedia('print').matches");
    # // → false
    # 
    # page.emulateMedia(new Page.EmulateMediaOptions().setMedia(Media.PRINT));
    # page.evaluate("() => matchMedia('screen').matches");
    # // → false
    # page.evaluate("() => matchMedia('print').matches");
    # // → true
    # 
    # page.emulateMedia(new Page.EmulateMediaOptions());
    # page.evaluate("() => matchMedia('screen').matches");
    # // → true
    # page.evaluate("() => matchMedia('print').matches");
    # // → false
    # ```
    # 
    # ```python async
    # await page.evaluate("matchMedia('screen').matches")
    # # → True
    # await page.evaluate("matchMedia('print').matches")
    # # → False
    # 
    # await page.emulate_media(media="print")
    # await page.evaluate("matchMedia('screen').matches")
    # # → False
    # await page.evaluate("matchMedia('print').matches")
    # # → True
    # 
    # await page.emulate_media()
    # await page.evaluate("matchMedia('screen').matches")
    # # → True
    # await page.evaluate("matchMedia('print').matches")
    # # → False
    # ```
    # 
    # ```python sync
    # page.evaluate("matchMedia('screen').matches")
    # # → True
    # page.evaluate("matchMedia('print').matches")
    # # → False
    # 
    # page.emulate_media(media="print")
    # page.evaluate("matchMedia('screen').matches")
    # # → False
    # page.evaluate("matchMedia('print').matches")
    # # → True
    # 
    # page.emulate_media()
    # page.evaluate("matchMedia('screen').matches")
    # # → True
    # page.evaluate("matchMedia('print').matches")
    # # → False
    # ```
    # 
    # ```csharp
    # await page.EvaluateAsync("() => matchMedia('screen').matches");
    # // → true
    # await page.EvaluateAsync("() => matchMedia('print').matches");
    # // → false
    # 
    # await page.EmulateMediaAsync(Media.Print);
    # await page.EvaluateAsync("() => matchMedia('screen').matches");
    # // → false
    # await page.EvaluateAsync("() => matchMedia('print').matches");
    # // → true
    # 
    # await page.EmulateMediaAsync(Media.Screen);
    # await page.EvaluateAsync("() => matchMedia('screen').matches");
    # // → true
    # await page.EvaluateAsync("() => matchMedia('print').matches");
    # // → false
    # ```
    # 
    #
    # ```js
    # await page.emulateMedia({ colorScheme: 'dark' });
    # await page.evaluate(() => matchMedia('(prefers-color-scheme: dark)').matches);
    # // → true
    # await page.evaluate(() => matchMedia('(prefers-color-scheme: light)').matches);
    # // → false
    # await page.evaluate(() => matchMedia('(prefers-color-scheme: no-preference)').matches);
    # // → false
    # ```
    # 
    # ```java
    # page.emulateMedia(new Page.EmulateMediaOptions().setColorScheme(ColorScheme.DARK));
    # page.evaluate("() => matchMedia('(prefers-color-scheme: dark)').matches");
    # // → true
    # page.evaluate("() => matchMedia('(prefers-color-scheme: light)').matches");
    # // → false
    # page.evaluate("() => matchMedia('(prefers-color-scheme: no-preference)').matches");
    # // → false
    # ```
    # 
    # ```python async
    # await page.emulate_media(color_scheme="dark")
    # await page.evaluate("matchMedia('(prefers-color-scheme: dark)').matches")
    # # → True
    # await page.evaluate("matchMedia('(prefers-color-scheme: light)').matches")
    # # → False
    # await page.evaluate("matchMedia('(prefers-color-scheme: no-preference)').matches")
    # # → False
    # ```
    # 
    # ```python sync
    # page.emulate_media(color_scheme="dark")
    # page.evaluate("matchMedia('(prefers-color-scheme: dark)').matches")
    # # → True
    # page.evaluate("matchMedia('(prefers-color-scheme: light)').matches")
    # # → False
    # page.evaluate("matchMedia('(prefers-color-scheme: no-preference)').matches")
    # ```
    # 
    # ```csharp
    # await page.EmulateMediaAsync(colorScheme: ColorScheme.Dark);
    # await page.EvaluateAsync("matchMedia('(prefers-color-scheme: dark)').matches");
    # // → true
    # await page.EvaluateAsync("matchMedia('(prefers-color-scheme: light)').matches");
    # // → false
    # await page.EvaluateAsync("matchMedia('(prefers-color-scheme: no-preference)').matches");
    # // → false
    # ```
    def emulate_media(colorScheme: nil, media: nil)
      wrap_impl(@impl.emulate_media(colorScheme: unwrap_impl(colorScheme), media: unwrap_impl(media)))
    end

    # The method finds an element matching the specified selector within the page and passes it as a first argument to
    # `expression`. If no elements match the selector, the method throws an error. Returns the value of `expression`.
    # 
    # If `expression` returns a [Promise], then [`method: Page.evalOnSelector`] would wait for the promise to resolve and
    # return its value.
    # 
    # Examples:
    # 
    #
    # ```js
    # const searchValue = await page.$eval('#search', el => el.value);
    # const preloadHref = await page.$eval('link[rel=preload]', el => el.href);
    # const html = await page.$eval('.main-container', (e, suffix) => e.outerHTML + suffix, 'hello');
    # ```
    # 
    # ```java
    # String searchValue = (String) page.evalOnSelector("#search", "el => el.value");
    # String preloadHref = (String) page.evalOnSelector("link[rel=preload]", "el => el.href");
    # String html = (String) page.evalOnSelector(".main-container", "(e, suffix) => e.outerHTML + suffix", "hello");
    # ```
    # 
    # ```python async
    # search_value = await page.eval_on_selector("#search", "el => el.value")
    # preload_href = await page.eval_on_selector("link[rel=preload]", "el => el.href")
    # html = await page.eval_on_selector(".main-container", "(e, suffix) => e.outer_html + suffix", "hello")
    # ```
    # 
    # ```python sync
    # search_value = page.eval_on_selector("#search", "el => el.value")
    # preload_href = page.eval_on_selector("link[rel=preload]", "el => el.href")
    # html = page.eval_on_selector(".main-container", "(e, suffix) => e.outer_html + suffix", "hello")
    # ```
    # 
    # ```csharp
    # var searchValue = await page.EvalOnSelectorAsync<string>("#search", "el => el.value");
    # var preloadHref = await page.EvalOnSelectorAsync<string>("link[rel=preload]", "el => el.href");
    # var html = await page.EvalOnSelectorAsync(".main-container", "(e, suffix) => e.outerHTML + suffix", "hello");
    # ```
    # 
    # Shortcut for main frame's [`method: Frame.evalOnSelector`].
    def eval_on_selector(selector, expression, arg: nil)
      wrap_impl(@impl.eval_on_selector(unwrap_impl(selector), unwrap_impl(expression), arg: unwrap_impl(arg)))
    end

    # The method finds all elements matching the specified selector within the page and passes an array of matched elements as
    # a first argument to `expression`. Returns the result of `expression` invocation.
    # 
    # If `expression` returns a [Promise], then [`method: Page.evalOnSelectorAll`] would wait for the promise to resolve and
    # return its value.
    # 
    # Examples:
    # 
    #
    # ```js
    # const divCounts = await page.$$eval('div', (divs, min) => divs.length >= min, 10);
    # ```
    # 
    # ```java
    # boolean divCounts = (boolean) page.evalOnSelectorAll("div", "(divs, min) => divs.length >= min", 10);
    # ```
    # 
    # ```python async
    # div_counts = await page.eval_on_selector_all("div", "(divs, min) => divs.length >= min", 10)
    # ```
    # 
    # ```python sync
    # div_counts = page.eval_on_selector_all("div", "(divs, min) => divs.length >= min", 10)
    # ```
    # 
    # ```csharp
    # var divsCount = await page.EvalOnSelectorAllAsync<bool>("div", "(divs, min) => divs.length >= min", 10);
    # ```
    def eval_on_selector_all(selector, expression, arg: nil)
      wrap_impl(@impl.eval_on_selector_all(unwrap_impl(selector), unwrap_impl(expression), arg: unwrap_impl(arg)))
    end

    # Returns the value of the `expression` invocation.
    # 
    # If the function passed to the [`method: Page.evaluate`] returns a [Promise], then [`method: Page.evaluate`] would wait
    # for the promise to resolve and return its value.
    # 
    # If the function passed to the [`method: Page.evaluate`] returns a non-[Serializable] value, then
    # [`method: Page.evaluate`] resolves to `undefined`. Playwright also supports transferring some additional values that are
    # not serializable by `JSON`: `-0`, `NaN`, `Infinity`, `-Infinity`.
    # 
    # Passing argument to `expression`:
    # 
    #
    # ```js
    # const result = await page.evaluate(([x, y]) => {
    #   return Promise.resolve(x * y);
    # }, [7, 8]);
    # console.log(result); // prints "56"
    # ```
    # 
    # ```java
    # Object result = page.evaluate("([x, y]) => {\n" +
    #   "  return Promise.resolve(x * y);\n" +
    #   "}", Arrays.asList(7, 8));
    # System.out.println(result); // prints "56"
    # ```
    # 
    # ```python async
    # result = await page.evaluate("([x, y]) => Promise.resolve(x * y)", [7, 8])
    # print(result) # prints "56"
    # ```
    # 
    # ```python sync
    # result = page.evaluate("([x, y]) => Promise.resolve(x * y)", [7, 8])
    # print(result) # prints "56"
    # ```
    # 
    # ```csharp
    # var result = await page.EvaluateAsync<int>("([x, y]) => Promise.resolve(x * y)", new[] { 7, 8 });
    # Console.WriteLine(result);
    # ```
    # 
    # A string can also be passed in instead of a function:
    # 
    #
    # ```js
    # console.log(await page.evaluate('1 + 2')); // prints "3"
    # const x = 10;
    # console.log(await page.evaluate(`1 + ${x}`)); // prints "11"
    # ```
    # 
    # ```java
    # System.out.println(page.evaluate("1 + 2")); // prints "3"
    # ```
    # 
    # ```python async
    # print(await page.evaluate("1 + 2")) # prints "3"
    # x = 10
    # print(await page.evaluate(f"1 + {x}")) # prints "11"
    # ```
    # 
    # ```python sync
    # print(page.evaluate("1 + 2")) # prints "3"
    # x = 10
    # print(page.evaluate(f"1 + {x}")) # prints "11"
    # ```
    # 
    # ```csharp
    # Console.WriteLine(await page.EvaluateAsync<int>("1 + 2")); // prints "3"
    # ```
    # 
    # `ElementHandle` instances can be passed as an argument to the [`method: Page.evaluate`]:
    # 
    #
    # ```js
    # const bodyHandle = await page.$('body');
    # const html = await page.evaluate(([body, suffix]) => body.innerHTML + suffix, [bodyHandle, 'hello']);
    # await bodyHandle.dispose();
    # ```
    # 
    # ```java
    # ElementHandle bodyHandle = page.querySelector("body");
    # String html = (String) page.evaluate("([body, suffix]) => body.innerHTML + suffix", Arrays.asList(bodyHandle, "hello"));
    # bodyHandle.dispose();
    # ```
    # 
    # ```python async
    # body_handle = await page.query_selector("body")
    # html = await page.evaluate("([body, suffix]) => body.innerHTML + suffix", [body_handle, "hello"])
    # await body_handle.dispose()
    # ```
    # 
    # ```python sync
    # body_handle = page.query_selector("body")
    # html = page.evaluate("([body, suffix]) => body.innerHTML + suffix", [body_handle, "hello"])
    # body_handle.dispose()
    # ```
    # 
    # ```csharp
    # var bodyHandle = await page.QuerySelectorAsync("body");
    # var html = await page.EvaluateAsync<string>("([body, suffix]) => body.innerHTML + suffix", new object [] { bodyHandle, "hello" });
    # await bodyHandle.DisposeAsync();
    # ```
    # 
    # Shortcut for main frame's [`method: Frame.evaluate`].
    def evaluate(expression, arg: nil)
      wrap_impl(@impl.evaluate(unwrap_impl(expression), arg: unwrap_impl(arg)))
    end

    # Returns the value of the `expression` invocation as a `JSHandle`.
    # 
    # The only difference between [`method: Page.evaluate`] and [`method: Page.evaluateHandle`] is that
    # [`method: Page.evaluateHandle`] returns `JSHandle`.
    # 
    # If the function passed to the [`method: Page.evaluateHandle`] returns a [Promise], then [`method: Page.evaluateHandle`]
    # would wait for the promise to resolve and return its value.
    # 
    #
    # ```js
    # const aWindowHandle = await page.evaluateHandle(() => Promise.resolve(window));
    # aWindowHandle; // Handle for the window object.
    # ```
    # 
    # ```java
    # // Handle for the window object.
    # JSHandle aWindowHandle = page.evaluateHandle("() => Promise.resolve(window)");
    # ```
    # 
    # ```python async
    # a_window_handle = await page.evaluate_handle("Promise.resolve(window)")
    # a_window_handle # handle for the window object.
    # ```
    # 
    # ```python sync
    # a_window_handle = page.evaluate_handle("Promise.resolve(window)")
    # a_window_handle # handle for the window object.
    # ```
    # 
    # ```csharp
    # // Handle for the window object.
    # var aWindowHandle = await page.EvaluateHandleAsync("() => Promise.resolve(window)");
    # ```
    # 
    # A string can also be passed in instead of a function:
    # 
    #
    # ```js
    # const aHandle = await page.evaluateHandle('document'); // Handle for the 'document'
    # ```
    # 
    # ```java
    # JSHandle aHandle = page.evaluateHandle("document"); // Handle for the "document".
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
    # var docHandle = await page.EvalueHandleAsync("document"); // Handle for the `document`
    # ```
    # 
    # `JSHandle` instances can be passed as an argument to the [`method: Page.evaluateHandle`]:
    # 
    #
    # ```js
    # const aHandle = await page.evaluateHandle(() => document.body);
    # const resultHandle = await page.evaluateHandle(body => body.innerHTML, aHandle);
    # console.log(await resultHandle.jsonValue());
    # await resultHandle.dispose();
    # ```
    # 
    # ```java
    # JSHandle aHandle = page.evaluateHandle("() => document.body");
    # JSHandle resultHandle = page.evaluateHandle("([body, suffix]) => body.innerHTML + suffix", Arrays.asList(aHandle, "hello"));
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
    # var handle = await page.EvaluateHandleAsync("() => document.body");
    # var resultHandle = await page.EvaluateHandleAsync("([body, suffix]) => body.innerHTML + suffix", new object[] { handle, "hello" });
    # Console.WriteLine(await resultHandle.JsonValueAsync<string>());
    # await resultHandle.DisposeAsync();
    # ```
    def evaluate_handle(expression, arg: nil)
      wrap_impl(@impl.evaluate_handle(unwrap_impl(expression), arg: unwrap_impl(arg)))
    end

    # The method adds a function called `name` on the `window` object of every frame in this page. When called, the function
    # executes `callback` and returns a [Promise] which resolves to the return value of `callback`. If the `callback` returns
    # a [Promise], it will be awaited.
    # 
    # The first argument of the `callback` function contains information about the caller: `{ browserContext: BrowserContext,
    # page: Page, frame: Frame }`.
    # 
    # See [`method: BrowserContext.exposeBinding`] for the context-wide version.
    # 
    # > NOTE: Functions installed via [`method: Page.exposeBinding`] survive navigations.
    # 
    # An example of exposing page URL to all frames in a page:
    # 
    #
    # ```js
    # const { webkit } = require('playwright');  // Or 'chromium' or 'firefox'.
    # 
    # (async () => {
    #   const browser = await webkit.launch({ headless: false });
    #   const context = await browser.newContext();
    #   const page = await context.newPage();
    #   await page.exposeBinding('pageURL', ({ page }) => page.url());
    #   await page.setContent(`
    #     <script>
    #       async function onClick() {
    #         document.querySelector('div').textContent = await window.pageURL();
    #       }
    #     </script>
    #     <button onclick="onClick()">Click me</button>
    #     <div></div>
    #   `);
    #   await page.click('button');
    # })();
    # ```
    # 
    # ```java
    # import com.microsoft.playwright.*;
    # 
    # public class Example {
    #   public static void main(String[] args) {
    #     try (Playwright playwright = Playwright.create()) {
    #       BrowserType webkit = playwright.webkit();
    #       Browser browser = webkit.launch({ headless: false });
    #       BrowserContext context = browser.newContext();
    #       Page page = context.newPage();
    #       page.exposeBinding("pageURL", (source, args) -> source.page().url());
    #       page.setContent("<script>\n" +
    #         "  async function onClick() {\n" +
    #         "    document.querySelector('div').textContent = await window.pageURL();\n" +
    #         "  }\n" +
    #         "</script>\n" +
    #         "<button onclick=\"onClick()\">Click me</button>\n" +
    #         "<div></div>");
    #       page.click("button");
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
    #     browser = await webkit.launch(headless=false)
    #     context = await browser.new_context()
    #     page = await context.new_page()
    #     await page.expose_binding("pageURL", lambda source: source["page"].url)
    #     await page.set_content("""
    #     <script>
    #       async function onClick() {
    #         document.querySelector('div').textContent = await window.pageURL();
    #       }
    #     </script>
    #     <button onclick="onClick()">Click me</button>
    #     <div></div>
    #     """)
    #     await page.click("button")
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
    #     browser = webkit.launch(headless=false)
    #     context = browser.new_context()
    #     page = context.new_page()
    #     page.expose_binding("pageURL", lambda source: source["page"].url)
    #     page.set_content("""
    #     <script>
    #       async function onClick() {
    #         document.querySelector('div').textContent = await window.pageURL();
    #       }
    #     </script>
    #     <button onclick="onClick()">Click me</button>
    #     <div></div>
    #     """)
    #     page.click("button")
    # 
    # with sync_playwright() as playwright:
    #     run(playwright)
    # ```
    # 
    # ```csharp
    # using Microsoft.Playwright;
    # using System.Threading.Tasks;
    # 
    # class PageExamples
    # {
    #   public static async Task Main()
    #   {
    #       using var playwright = await Playwright.CreateAsync();
    #       await using var browser = await playwright.Webkit.LaunchAsync(headless: false);
    #       var page = await browser.NewPageAsync();
    # 
    #       await page.ExposeBindingAsync("pageUrl", (source) => source.Page.Url);
    #       await page.SetContentAsync("<script>\n" +
    #       "  async function onClick() {\n" +
    #       "    document.querySelector('div').textContent = await window.pageURL();\n" +
    #       "  }\n" +
    #       "</script>\n" +
    #       "<button onclick=\"onClick()\">Click me</button>\n" +
    #       "<div></div>");
    # 
    #       await page.ClickAsync("button");
    #   }
    # }
    # ```
    # 
    # An example of passing an element handle:
    # 
    #
    # ```js
    # await page.exposeBinding('clicked', async (source, element) => {
    #   console.log(await element.textContent());
    # }, { handle: true });
    # await page.setContent(`
    #   <script>
    #     document.addEventListener('click', event => window.clicked(event.target));
    #   </script>
    #   <div>Click me</div>
    #   <div>Or click me</div>
    # `);
    # ```
    # 
    # ```java
    # page.exposeBinding("clicked", (source, args) -> {
    #   ElementHandle element = (ElementHandle) args[0];
    #   System.out.println(element.textContent());
    #   return null;
    # }, new Page.ExposeBindingOptions().setHandle(true));
    # page.setContent("" +
    #   "<script>\n" +
    #   "  document.addEventListener('click', event => window.clicked(event.target));\n" +
    #   "</script>\n" +
    #   "<div>Click me</div>\n" +
    #   "<div>Or click me</div>\n");
    # ```
    # 
    # ```python async
    # async def print(source, element):
    #     print(await element.text_content())
    # 
    # await page.expose_binding("clicked", print, handle=true)
    # await page.set_content("""
    #   <script>
    #     document.addEventListener('click', event => window.clicked(event.target));
    #   </script>
    #   <div>Click me</div>
    #   <div>Or click me</div>
    # """)
    # ```
    # 
    # ```python sync
    # def print(source, element):
    #     print(element.text_content())
    # 
    # page.expose_binding("clicked", print, handle=true)
    # page.set_content("""
    #   <script>
    #     document.addEventListener('click', event => window.clicked(event.target));
    #   </script>
    #   <div>Click me</div>
    #   <div>Or click me</div>
    # """)
    # ```
    # 
    # ```csharp
    # var result = new TaskCompletionSource<string>();
    # await page.ExposeBindingAsync("clicked", async (BindingSource _, IJSHandle t) =>
    # {
    #     return result.TrySetResult(await t.AsElement.TextContentAsync());
    # });
    # 
    # await page.SetContentAsync("<script>\n" +
    #   "  document.addEventListener('click', event => window.clicked(event.target));\n" +
    #   "</script>\n" +
    #   "<div>Click me</div>\n" +
    #   "<div>Or click me</div>\n");
    # 
    # await page.ClickAsync("div");
    # Console.WriteLine(await result.Task);
    # ```
    def expose_binding(name, callback, handle: nil)
      wrap_impl(@impl.expose_binding(unwrap_impl(name), unwrap_impl(callback), handle: unwrap_impl(handle)))
    end

    # The method adds a function called `name` on the `window` object of every frame in the page. When called, the function
    # executes `callback` and returns a [Promise] which resolves to the return value of `callback`.
    # 
    # If the `callback` returns a [Promise], it will be awaited.
    # 
    # See [`method: BrowserContext.exposeFunction`] for context-wide exposed function.
    # 
    # > NOTE: Functions installed via [`method: Page.exposeFunction`] survive navigations.
    # 
    # An example of adding an `sha1` function to the page:
    # 
    #
    # ```js
    # const { webkit } = require('playwright');  // Or 'chromium' or 'firefox'.
    # const crypto = require('crypto');
    # 
    # (async () => {
    #   const browser = await webkit.launch({ headless: false });
    #   const page = await browser.newPage();
    #   await page.exposeFunction('sha1', text => crypto.createHash('sha1').update(text).digest('hex'));
    #   await page.setContent(`
    #     <script>
    #       async function onClick() {
    #         document.querySelector('div').textContent = await window.sha1('PLAYWRIGHT');
    #       }
    #     </script>
    #     <button onclick="onClick()">Click me</button>
    #     <div></div>
    #   `);
    #   await page.click('button');
    # })();
    # ```
    # 
    # ```java
    # import com.microsoft.playwright.*;
    # 
    # import java.nio.charset.StandardCharsets;
    # import java.security.MessageDigest;
    # import java.security.NoSuchAlgorithmException;
    # import java.util.Base64;
    # 
    # public class Example {
    #   public static void main(String[] args) {
    #     try (Playwright playwright = Playwright.create()) {
    #       BrowserType webkit = playwright.webkit();
    #       Browser browser = webkit.launch({ headless: false });
    #       Page page = browser.newPage();
    #       page.exposeFunction("sha1", args -> {
    #         String text = (String) args[0];
    #         MessageDigest crypto;
    #         try {
    #           crypto = MessageDigest.getInstance("SHA-1");
    #         } catch (NoSuchAlgorithmException e) {
    #           return null;
    #         }
    #         byte[] token = crypto.digest(text.getBytes(StandardCharsets.UTF_8));
    #         return Base64.getEncoder().encodeToString(token);
    #       });
    #       page.setContent("<script>\n" +
    #         "  async function onClick() {\n" +
    #         "    document.querySelector('div').textContent = await window.sha1('PLAYWRIGHT');\n" +
    #         "  }\n" +
    #         "</script>\n" +
    #         "<button onclick=\"onClick()\">Click me</button>\n" +
    #         "<div></div>\n");
    #       page.click("button");
    #     }
    #   }
    # }
    # ```
    # 
    # ```python async
    # import asyncio
    # import hashlib
    # from playwright.async_api import async_playwright
    # 
    # async def sha1(text):
    #     m = hashlib.sha1()
    #     m.update(bytes(text, "utf8"))
    #     return m.hexdigest()
    # 
    # 
    # async def run(playwright):
    #     webkit = playwright.webkit
    #     browser = await webkit.launch(headless=False)
    #     page = await browser.new_page()
    #     await page.expose_function("sha1", sha1)
    #     await page.set_content("""
    #         <script>
    #           async function onClick() {
    #             document.querySelector('div').textContent = await window.sha1('PLAYWRIGHT');
    #           }
    #         </script>
    #         <button onclick="onClick()">Click me</button>
    #         <div></div>
    #     """)
    #     await page.click("button")
    # 
    # async def main():
    #     async with async_playwright() as playwright:
    #         await run(playwright)
    # asyncio.run(main())
    # ```
    # 
    # ```python sync
    # import hashlib
    # from playwright.sync_api import sync_playwright
    # 
    # def sha1(text):
    #     m = hashlib.sha1()
    #     m.update(bytes(text, "utf8"))
    #     return m.hexdigest()
    # 
    # 
    # def run(playwright):
    #     webkit = playwright.webkit
    #     browser = webkit.launch(headless=False)
    #     page = browser.new_page()
    #     page.expose_function("sha1", sha1)
    #     page.set_content("""
    #         <script>
    #           async function onClick() {
    #             document.querySelector('div').textContent = await window.sha1('PLAYWRIGHT');
    #           }
    #         </script>
    #         <button onclick="onClick()">Click me</button>
    #         <div></div>
    #     """)
    #     page.click("button")
    # 
    # with sync_playwright() as playwright:
    #     run(playwright)
    # ```
    # 
    # ```csharp
    # using Microsoft.Playwright;
    # using System;
    # using System.Security.Cryptography;
    # using System.Threading.Tasks;
    # 
    # class PageExamples
    # {
    #   public static async Task Main()
    #   {
    #       using var playwright = await Playwright.CreateAsync();
    #       await using var browser = await playwright.Webkit.LaunchAsync(headless: false); 
    #       var page = await browser.NewPageAsync();
    # 
    #       // NOTE: md5 is inherently insecure, and we strongly discourage using
    #       // this in production in any shape or form
    #       await page.ExposeFunctionAsync("sha1", (string input) =>
    #       {
    #           return Convert.ToBase64String(
    #               MD5.Create().ComputeHash(System.Text.Encoding.UTF8.GetBytes(input)));
    #       });
    # 
    #       await page.SetContentAsync("<script>\n" +
    #       "  async function onClick() {\n" +
    #       "    document.querySelector('div').textContent = await window.sha1('PLAYWRIGHT');\n" +
    #       "  }\n" +
    #       "</script>\n" +
    #       "<button onclick=\"onClick()\">Click me</button>\n" +
    #       "<div></div>");
    # 
    #       await page.ClickAsync("button");
    #       Console.WriteLine(await page.TextContentAsync("div"));
    #   }
    # }
    # ```
    def expose_function(name, callback)
      wrap_impl(@impl.expose_function(unwrap_impl(name), unwrap_impl(callback)))
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
    # To send fine-grained keyboard events, use [`method: Page.type`].
    # 
    # Shortcut for main frame's [`method: Frame.fill`].
    def fill(selector, value, noWaitAfter: nil, timeout: nil)
      wrap_impl(@impl.fill(unwrap_impl(selector), unwrap_impl(value), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end

    # This method fetches an element with `selector` and focuses it. If there's no element matching `selector`, the method
    # waits until a matching element appears in the DOM.
    # 
    # Shortcut for main frame's [`method: Frame.focus`].
    def focus(selector, timeout: nil)
      wrap_impl(@impl.focus(unwrap_impl(selector), timeout: unwrap_impl(timeout)))
    end

    # Returns frame matching the specified criteria. Either `name` or `url` must be specified.
    # 
    #
    # ```js
    # const frame = page.frame('frame-name');
    # ```
    # 
    # ```java
    # Frame frame = page.frame("frame-name");
    # ```
    # 
    # ```py
    # frame = page.frame(name="frame-name")
    # ```
    # 
    # ```csharp
    # var frame = page.Frame("frame-name");
    # ```
    # 
    #
    # ```js
    # const frame = page.frame({ url: /.*domain.*/ });
    # ```
    # 
    # ```java
    # Frame frame = page.frameByUrl(Pattern.compile(".*domain.*");
    # ```
    # 
    # ```py
    # frame = page.frame(url=r".*domain.*")
    # ```
    # 
    # ```csharp
    # var frame = page.FrameByUrl(".*domain.*");
    # ```
    def frame(name: nil, url: nil)
      wrap_impl(@impl.frame(name: unwrap_impl(name), url: unwrap_impl(url)))
    end

    # An array of all frames attached to the page.
    def frames
      wrap_impl(@impl.frames)
    end

    # Returns element attribute value.
    def get_attribute(selector, name, timeout: nil)
      wrap_impl(@impl.get_attribute(unwrap_impl(selector), unwrap_impl(name), timeout: unwrap_impl(timeout)))
    end

    # Returns the main resource response. In case of multiple redirects, the navigation will resolve with the response of the
    # last redirect. If can not go back, returns `null`.
    # 
    # Navigate to the previous page in history.
    def go_back(timeout: nil, waitUntil: nil)
      wrap_impl(@impl.go_back(timeout: unwrap_impl(timeout), waitUntil: unwrap_impl(waitUntil)))
    end

    # Returns the main resource response. In case of multiple redirects, the navigation will resolve with the response of the
    # last redirect. If can not go forward, returns `null`.
    # 
    # Navigate to the next page in history.
    def go_forward(timeout: nil, waitUntil: nil)
      wrap_impl(@impl.go_forward(timeout: unwrap_impl(timeout), waitUntil: unwrap_impl(waitUntil)))
    end

    # Returns the main resource response. In case of multiple redirects, the navigation will resolve with the response of the
    # last redirect.
    # 
    # `page.goto` will throw an error if:
    # - there's an SSL error (e.g. in case of self-signed certificates).
    # - target URL is invalid.
    # - the `timeout` is exceeded during navigation.
    # - the remote server does not respond or is unreachable.
    # - the main resource failed to load.
    # 
    # `page.goto` will not throw an error when any valid HTTP status code is returned by the remote server, including 404 "Not
    # Found" and 500 "Internal Server Error".  The status code for such responses can be retrieved by calling
    # [`method: Response.status`].
    # 
    # > NOTE: `page.goto` either throws an error or returns a main resource response. The only exceptions are navigation to
    # `about:blank` or navigation to the same URL with a different hash, which would succeed and return `null`.
    # > NOTE: Headless mode doesn't support navigation to a PDF document. See the
    # [upstream issue](https://bugs.chromium.org/p/chromium/issues/detail?id=761295).
    # 
    # Shortcut for main frame's [`method: Frame.goto`]
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
    # 
    # Shortcut for main frame's [`method: Frame.hover`].
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

    # Indicates that the page has been closed.
    def closed?
      wrap_impl(@impl.closed?)
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

    # The page's main frame. Page is guaranteed to have a main frame which persists during navigations.
    def main_frame
      wrap_impl(@impl.main_frame)
    end

    # Returns the opener for popup pages and `null` for others. If the opener has been closed already the returns `null`.
    def opener
      wrap_impl(@impl.opener)
    end

    # Pauses script execution. Playwright will stop executing the script and wait for the user to either press 'Resume' button
    # in the page overlay or to call `playwright.resume()` in the DevTools console.
    # 
    # User can inspect selectors or perform manual steps while paused. Resume will continue running the original script from
    # the place it was paused.
    # 
    # > NOTE: This method requires Playwright to be started in a headed mode, with a falsy `headless` value in the
    # [`method: BrowserType.launch`].
    def pause
      raise NotImplementedError.new('pause is not implemented yet.')
    end

    # Returns the PDF buffer.
    # 
    # > NOTE: Generating a pdf is currently only supported in Chromium headless.
    # 
    # `page.pdf()` generates a pdf of the page with `print` css media. To generate a pdf with `screen` media, call
    # [`method: Page.emulateMedia`] before calling `page.pdf()`:
    # 
    # > NOTE: By default, `page.pdf()` generates a pdf with modified colors for printing. Use the
    # [`-webkit-print-color-adjust`](https://developer.mozilla.org/en-US/docs/Web/CSS/-webkit-print-color-adjust) property to
    # force rendering of exact colors.
    # 
    #
    # ```js
    # // Generates a PDF with 'screen' media type.
    # await page.emulateMedia({media: 'screen'});
    # await page.pdf({path: 'page.pdf'});
    # ```
    # 
    # ```java
    # // Generates a PDF with "screen" media type.
    # page.emulateMedia(new Page.EmulateMediaOptions().setMedia(Media.SCREEN));
    # page.pdf(new Page.PdfOptions().setPath(Paths.get("page.pdf")));
    # ```
    # 
    # ```python async
    # # generates a pdf with "screen" media type.
    # await page.emulate_media(media="screen")
    # await page.pdf(path="page.pdf")
    # ```
    # 
    # ```python sync
    # # generates a pdf with "screen" media type.
    # page.emulate_media(media="screen")
    # page.pdf(path="page.pdf")
    # ```
    # 
    # ```csharp
    # // Generates a PDF with 'screen' media type
    # await page.EmulateMediaAsync(Media.Screen);
    # await page.PdfAsync("page.pdf");
    # ```
    # 
    # The `width`, `height`, and `margin` options accept values labeled with units. Unlabeled values are treated as pixels.
    # 
    # A few examples:
    # - `page.pdf({width: 100})` - prints with width set to 100 pixels
    # - `page.pdf({width: '100px'})` - prints with width set to 100 pixels
    # - `page.pdf({width: '10cm'})` - prints with width set to 10 centimeters.
    # 
    # All possible units are:
    # - `px` - pixel
    # - `in` - inch
    # - `cm` - centimeter
    # - `mm` - millimeter
    # 
    # The `format` options are:
    # - `Letter`: 8.5in x 11in
    # - `Legal`: 8.5in x 14in
    # - `Tabloid`: 11in x 17in
    # - `Ledger`: 17in x 11in
    # - `A0`: 33.1in x 46.8in
    # - `A1`: 23.4in x 33.1in
    # - `A2`: 16.54in x 23.4in
    # - `A3`: 11.7in x 16.54in
    # - `A4`: 8.27in x 11.7in
    # - `A5`: 5.83in x 8.27in
    # - `A6`: 4.13in x 5.83in
    # 
    # > NOTE: `headerTemplate` and `footerTemplate` markup have the following limitations: > 1. Script tags inside templates
    # are not evaluated. > 2. Page styles are not visible inside templates.
    def pdf(
          displayHeaderFooter: nil,
          footerTemplate: nil,
          format: nil,
          headerTemplate: nil,
          height: nil,
          landscape: nil,
          margin: nil,
          pageRanges: nil,
          path: nil,
          preferCSSPageSize: nil,
          printBackground: nil,
          scale: nil,
          width: nil)
      wrap_impl(@impl.pdf(displayHeaderFooter: unwrap_impl(displayHeaderFooter), footerTemplate: unwrap_impl(footerTemplate), format: unwrap_impl(format), headerTemplate: unwrap_impl(headerTemplate), height: unwrap_impl(height), landscape: unwrap_impl(landscape), margin: unwrap_impl(margin), pageRanges: unwrap_impl(pageRanges), path: unwrap_impl(path), preferCSSPageSize: unwrap_impl(preferCSSPageSize), printBackground: unwrap_impl(printBackground), scale: unwrap_impl(scale), width: unwrap_impl(width)))
    end

    # Focuses the element, and then uses [`method: Keyboard.down`] and [`method: Keyboard.up`].
    # 
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
    # 
    #
    # ```js
    # const page = await browser.newPage();
    # await page.goto('https://keycode.info');
    # await page.press('body', 'A');
    # await page.screenshot({ path: 'A.png' });
    # await page.press('body', 'ArrowLeft');
    # await page.screenshot({ path: 'ArrowLeft.png' });
    # await page.press('body', 'Shift+O');
    # await page.screenshot({ path: 'O.png' });
    # await browser.close();
    # ```
    # 
    # ```java
    # Page page = browser.newPage();
    # page.navigate("https://keycode.info");
    # page.press("body", "A");
    # page.screenshot(new Page.ScreenshotOptions().setPath(Paths.get("A.png")));
    # page.press("body", "ArrowLeft");
    # page.screenshot(new Page.ScreenshotOptions().setPath(Paths.get("ArrowLeft.png" )));
    # page.press("body", "Shift+O");
    # page.screenshot(new Page.ScreenshotOptions().setPath(Paths.get("O.png" )));
    # ```
    # 
    # ```python async
    # page = await browser.new_page()
    # await page.goto("https://keycode.info")
    # await page.press("body", "A")
    # await page.screenshot(path="a.png")
    # await page.press("body", "ArrowLeft")
    # await page.screenshot(path="arrow_left.png")
    # await page.press("body", "Shift+O")
    # await page.screenshot(path="o.png")
    # await browser.close()
    # ```
    # 
    # ```python sync
    # page = browser.new_page()
    # page.goto("https://keycode.info")
    # page.press("body", "A")
    # page.screenshot(path="a.png")
    # page.press("body", "ArrowLeft")
    # page.screenshot(path="arrow_left.png")
    # page.press("body", "Shift+O")
    # page.screenshot(path="o.png")
    # browser.close()
    # ```
    # 
    # ```csharp
    # await using var browser = await playwright.Webkit.LaunchAsync(headless: false);
    # var page = await browser.NewPageAsync();
    # await page.GotoAsync("https://keycode.info");
    # await page.PressAsync("body", "A");
    # await page.ScreenshotAsync("A.png");
    # await page.PressAsync("body", "ArrowLeft");
    # await page.ScreenshotAsync("ArrowLeft.png");
    # await page.PressAsync("body", "Shift+O");
    # await page.ScreenshotAsync("O.png");
    # ```
    def press(
          selector,
          key,
          delay: nil,
          noWaitAfter: nil,
          timeout: nil)
      wrap_impl(@impl.press(unwrap_impl(selector), unwrap_impl(key), delay: unwrap_impl(delay), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end

    # The method finds an element matching the specified selector within the page. If no elements match the selector, the
    # return value resolves to `null`. To wait for an element on the page, use [`method: Page.waitForSelector`].
    # 
    # Shortcut for main frame's [`method: Frame.querySelector`].
    def query_selector(selector)
      wrap_impl(@impl.query_selector(unwrap_impl(selector)))
    end

    # The method finds all elements matching the specified selector within the page. If no elements match the selector, the
    # return value resolves to `[]`.
    # 
    # Shortcut for main frame's [`method: Frame.querySelectorAll`].
    def query_selector_all(selector)
      wrap_impl(@impl.query_selector_all(unwrap_impl(selector)))
    end

    # Returns the main resource response. In case of multiple redirects, the navigation will resolve with the response of the
    # last redirect.
    def reload(timeout: nil, waitUntil: nil)
      wrap_impl(@impl.reload(timeout: unwrap_impl(timeout), waitUntil: unwrap_impl(waitUntil)))
    end

    # Routing provides the capability to modify network requests that are made by a page.
    # 
    # Once routing is enabled, every request matching the url pattern will stall unless it's continued, fulfilled or aborted.
    # 
    # > NOTE: The handler will only be called for the first url if the response is a redirect.
    # 
    # An example of a naive handler that aborts all image requests:
    # 
    #
    # ```js
    # const page = await browser.newPage();
    # await page.route('**/*.{png,jpg,jpeg}', route => route.abort());
    # await page.goto('https://example.com');
    # await browser.close();
    # ```
    # 
    # ```java
    # Page page = browser.newPage();
    # page.route("**/*.{png,jpg,jpeg}", route -> route.abort());
    # page.navigate("https://example.com");
    # browser.close();
    # ```
    # 
    # ```python async
    # page = await browser.new_page()
    # await page.route("**/*.{png,jpg,jpeg}", lambda route: route.abort())
    # await page.goto("https://example.com")
    # await browser.close()
    # ```
    # 
    # ```python sync
    # page = browser.new_page()
    # page.route("**/*.{png,jpg,jpeg}", lambda route: route.abort())
    # page.goto("https://example.com")
    # browser.close()
    # ```
    # 
    # ```csharp
    # await using var browser = await playwright.Webkit.LaunchAsync();
    # var page = await browser.NewPageAsync();
    # await page.RouteAsync("**/*.{png,jpg,jpeg}", async r => await r.AbortAsync());
    # await page.GotoAsync("https://www.microsoft.com");
    # ```
    # 
    # or the same snippet using a regex pattern instead:
    # 
    #
    # ```js
    # const page = await browser.newPage();
    # await page.route(/(\.png$)|(\.jpg$)/, route => route.abort());
    # await page.goto('https://example.com');
    # await browser.close();
    # ```
    # 
    # ```java
    # Page page = browser.newPage();
    # page.route(Pattern.compile("(\\.png$)|(\\.jpg$)"),route -> route.abort());
    # page.navigate("https://example.com");
    # browser.close();
    # ```
    # 
    # ```python async
    # page = await browser.new_page()
    # await page.route(re.compile(r"(\.png$)|(\.jpg$)"), lambda route: route.abort())
    # await page.goto("https://example.com")
    # await browser.close()
    # ```
    # 
    # ```python sync
    # page = browser.new_page()
    # page.route(re.compile(r"(\.png$)|(\.jpg$)"), lambda route: route.abort())
    # page.goto("https://example.com")
    # browser.close()
    # ```
    # 
    # ```csharp
    # await using var browser = await playwright.Webkit.LaunchAsync();
    # var page = await browser.NewPageAsync();
    # await page.RouteAsync(new Regex("(\\.png$)|(\\.jpg$)"), async r => await r.AbortAsync());
    # await page.GotoAsync("https://www.microsoft.com");
    # ```
    # 
    # It is possible to examine the request to decide the route action. For example, mocking all requests that contain some
    # post data, and leaving all other requests as is:
    # 
    #
    # ```js
    # await page.route('/api/**', route => {
    #   if (route.request().postData().includes('my-string'))
    #     route.fulfill({ body: 'mocked-data' });
    #   else
    #     route.continue();
    # });
    # ```
    # 
    # ```java
    # page.route("/api/**", route -> {
    #   if (route.request().postData().contains("my-string"))
    #     route.fulfill(new Route.FulfillOptions().setBody("mocked-data"));
    #   else
    #     route.resume();
    # });
    # ```
    # 
    # ```python async
    # def handle_route(route):
    #   if ("my-string" in route.request.post_data)
    #     route.fulfill(body="mocked-data")
    #   else
    #     route.continue_()
    # await page.route("/api/**", handle_route)
    # ```
    # 
    # ```python sync
    # def handle_route(route):
    #   if ("my-string" in route.request.post_data)
    #     route.fulfill(body="mocked-data")
    #   else
    #     route.continue_()
    # page.route("/api/**", handle_route)
    # ```
    # 
    # ```csharp
    # await page.RouteAsync("/api/**", async r =>
    # {
    #   if (r.Request.PostData.Contains("my-string"))
    #       await r.FulfillAsync(body: "mocked-data");
    #   else
    #       await r.ContinueAsync();
    # });
    # ```
    # 
    # Page routes take precedence over browser context routes (set up with [`method: BrowserContext.route`]) when request
    # matches both handlers.
    # 
    # To remove a route with its handler you can use [`method: Page.unroute`].
    # 
    # > NOTE: Enabling routing disables http cache.
    def route(url, handler)
      wrap_impl(@impl.route(unwrap_impl(url), unwrap_impl(handler)))
    end

    # Returns the buffer with the captured screenshot.
    def screenshot(
          clip: nil,
          fullPage: nil,
          omitBackground: nil,
          path: nil,
          quality: nil,
          timeout: nil,
          type: nil)
      wrap_impl(@impl.screenshot(clip: unwrap_impl(clip), fullPage: unwrap_impl(fullPage), omitBackground: unwrap_impl(omitBackground), path: unwrap_impl(path), quality: unwrap_impl(quality), timeout: unwrap_impl(timeout), type: unwrap_impl(type)))
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
    # page.selectOption('select#colors', 'blue');
    # 
    # // single selection matching the label
    # page.selectOption('select#colors', { label: 'Blue' });
    # 
    # // multiple selection
    # page.selectOption('select#colors', ['red', 'green', 'blue']);
    # 
    # ```
    # 
    # ```java
    # // single selection matching the value
    # page.selectOption("select#colors", "blue");
    # // single selection matching both the value and the label
    # page.selectOption("select#colors", new SelectOption().setLabel("Blue"));
    # // multiple selection
    # page.selectOption("select#colors", new String[] {"red", "green", "blue"});
    # ```
    # 
    # ```python async
    # # single selection matching the value
    # await page.select_option("select#colors", "blue")
    # # single selection matching the label
    # await page.select_option("select#colors", label="blue")
    # # multiple selection
    # await page.select_option("select#colors", value=["red", "green", "blue"])
    # ```
    # 
    # ```python sync
    # # single selection matching the value
    # page.select_option("select#colors", "blue")
    # # single selection matching both the label
    # page.select_option("select#colors", label="blue")
    # # multiple selection
    # page.select_option("select#colors", value=["red", "green", "blue"])
    # ```
    # 
    # ```csharp
    # // single selection matching the value
    # await page.SelectOptionAsync("select#colors", new[] { "blue" });
    # // single selection matching both the value and the label
    # await page.SelectOptionAsync("select#colors", new[] { new SelectOptionValue() { Label = "blue" } });
    # // multiple 
    # await page.SelectOptionAsync("select#colors", new[] { "red", "green", "blue" });
    # ```
    # 
    # Shortcut for main frame's [`method: Frame.selectOption`].
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

    # This setting will change the default maximum navigation time for the following methods and related shortcuts:
    # - [`method: Page.goBack`]
    # - [`method: Page.goForward`]
    # - [`method: Page.goto`]
    # - [`method: Page.reload`]
    # - [`method: Page.setContent`]
    # - [`method: Page.waitForNavigation`]
    # - [`method: Page.waitForURL`]
    # 
    # > NOTE: [`method: Page.setDefaultNavigationTimeout`] takes priority over [`method: Page.setDefaultTimeout`],
    # [`method: BrowserContext.setDefaultTimeout`] and [`method: BrowserContext.setDefaultNavigationTimeout`].
    def set_default_navigation_timeout(timeout)
      wrap_impl(@impl.set_default_navigation_timeout(unwrap_impl(timeout)))
    end
    alias_method :default_navigation_timeout=, :set_default_navigation_timeout

    # This setting will change the default maximum time for all the methods accepting `timeout` option.
    # 
    # > NOTE: [`method: Page.setDefaultNavigationTimeout`] takes priority over [`method: Page.setDefaultTimeout`].
    def set_default_timeout(timeout)
      wrap_impl(@impl.set_default_timeout(unwrap_impl(timeout)))
    end
    alias_method :default_timeout=, :set_default_timeout

    # The extra HTTP headers will be sent with every request the page initiates.
    # 
    # > NOTE: [`method: Page.setExtraHTTPHeaders`] does not guarantee the order of headers in the outgoing requests.
    def set_extra_http_headers(headers)
      wrap_impl(@impl.set_extra_http_headers(unwrap_impl(headers)))
    end
    alias_method :extra_http_headers=, :set_extra_http_headers

    # This method expects `selector` to point to an
    # [input element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input).
    # 
    # Sets the value of the file input to these file paths or files. If some of the `filePaths` are relative paths, then they
    # are resolved relative to the the current working directory. For empty array, clears the selected files.
    def set_input_files(selector, files, noWaitAfter: nil, timeout: nil)
      wrap_impl(@impl.set_input_files(unwrap_impl(selector), unwrap_impl(files), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end

    # In the case of multiple pages in a single browser, each page can have its own viewport size. However,
    # [`method: Browser.newContext`] allows to set viewport size (and more) for all pages in the context at once.
    # 
    # `page.setViewportSize` will resize the page. A lot of websites don't expect phones to change size, so you should set the
    # viewport size before navigating to the page.
    # 
    #
    # ```js
    # const page = await browser.newPage();
    # await page.setViewportSize({
    #   width: 640,
    #   height: 480,
    # });
    # await page.goto('https://example.com');
    # ```
    # 
    # ```java
    # Page page = browser.newPage();
    # page.setViewportSize(640, 480);
    # page.navigate("https://example.com");
    # ```
    # 
    # ```python async
    # page = await browser.new_page()
    # await page.set_viewport_size({"width": 640, "height": 480})
    # await page.goto("https://example.com")
    # ```
    # 
    # ```python sync
    # page = browser.new_page()
    # page.set_viewport_size({"width": 640, "height": 480})
    # page.goto("https://example.com")
    # ```
    # 
    # ```csharp
    # var page = await browser.NewPageAsync();
    # await page.SetViewportSizeAsync(640, 480);
    # await page.GotoAsync("https://www.microsoft.com");
    # ```
    def set_viewport_size(viewportSize)
      wrap_impl(@impl.set_viewport_size(unwrap_impl(viewportSize)))
    end
    alias_method :viewport_size=, :set_viewport_size

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
    # > NOTE: [`method: Page.tap`] requires that the `hasTouch` option of the browser context be set to true.
    # 
    # Shortcut for main frame's [`method: Frame.tap`].
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

    # Returns the page's title. Shortcut for main frame's [`method: Frame.title`].
    def title
      wrap_impl(@impl.title)
    end

    # Sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text. `page.type` can be used to send
    # fine-grained keyboard events. To fill values in form fields, use [`method: Page.fill`].
    # 
    # To press a special key, like `Control` or `ArrowDown`, use [`method: Keyboard.press`].
    # 
    #
    # ```js
    # await page.type('#mytextarea', 'Hello'); // Types instantly
    # await page.type('#mytextarea', 'World', {delay: 100}); // Types slower, like a user
    # ```
    # 
    # ```java
    # // Types instantly
    # page.type("#mytextarea", "Hello");
    # // Types slower, like a user
    # page.type("#mytextarea", "World", new Page.TypeOptions().setDelay(100));
    # ```
    # 
    # ```python async
    # await page.type("#mytextarea", "hello") # types instantly
    # await page.type("#mytextarea", "world", delay=100) # types slower, like a user
    # ```
    # 
    # ```python sync
    # page.type("#mytextarea", "hello") # types instantly
    # page.type("#mytextarea", "world", delay=100) # types slower, like a user
    # ```
    # 
    # ```csharp
    # await page.TypeAsync("#mytextarea", "hello"); // types instantly
    # await page.TypeAsync("#mytextarea", "world"); // types slower, like a user
    # ```
    # 
    # Shortcut for main frame's [`method: Frame.type`].
    def type(
          selector,
          text,
          delay: nil,
          noWaitAfter: nil,
          timeout: nil)
      wrap_impl(@impl.type(unwrap_impl(selector), unwrap_impl(text), delay: unwrap_impl(delay), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end

    # This method unchecks an element matching `selector` by performing the following steps:
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
    # 
    # Shortcut for main frame's [`method: Frame.uncheck`].
    def uncheck(
          selector,
          force: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.uncheck(unwrap_impl(selector), force: unwrap_impl(force), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    # Removes a route created with [`method: Page.route`]. When `handler` is not specified, removes all routes for the `url`.
    def unroute(url, handler: nil)
      wrap_impl(@impl.unroute(unwrap_impl(url), handler: unwrap_impl(handler)))
    end

    # Shortcut for main frame's [`method: Frame.url`].
    def url
      wrap_impl(@impl.url)
    end

    # Video object associated with this page.
    def video
      wrap_impl(@impl.video)
    end

    def viewport_size
      wrap_impl(@impl.viewport_size)
    end

    # Performs action and waits for a `ConsoleMessage` to be logged by in the page. If predicate is provided, it passes
    # `ConsoleMessage` value into the `predicate` function and waits for `predicate(message)` to return a truthy value. Will
    # throw an error if the page is closed before the console event is fired.
    def expect_console_message(predicate: nil, timeout: nil, &block)
      wrap_impl(@impl.expect_console_message(predicate: unwrap_impl(predicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    # Performs action and waits for a new `Download`. If predicate is provided, it passes `Download` value into the
    # `predicate` function and waits for `predicate(download)` to return a truthy value. Will throw an error if the page is
    # closed before the download event is fired.
    def expect_download(predicate: nil, timeout: nil, &block)
      wrap_impl(@impl.expect_download(predicate: unwrap_impl(predicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    # Waits for event to fire and passes its value into the predicate function. Returns when the predicate returns truthy
    # value. Will throw an error if the page is closed before the event is fired. Returns the event data value.
    # 
    #
    # ```js
    # const [frame, _] = await Promise.all([
    #   page.waitForEvent('framenavigated'),
    #   page.click('button')
    # ]);
    # ```
    # 
    # ```python async
    # async with page.expect_event("framenavigated") as event_info:
    #     await page.click("button")
    # frame = await event_info.value
    # ```
    # 
    # ```python sync
    # with page.expect_event("framenavigated") as event_info:
    #     page.click("button")
    # frame = event_info.value
    # ```
    # 
    # ```csharp
    # var waitTask = page.WaitForEventAsync(PageEvent.FrameNavigated);
    # await page.ClickAsync("button");
    # var frame = await waitTask;
    # ```
    def expect_event(event, predicate: nil, timeout: nil, &block)
      wrap_impl(@impl.expect_event(unwrap_impl(event), predicate: unwrap_impl(predicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    # Performs action and waits for a new `FileChooser` to be created. If predicate is provided, it passes `FileChooser` value
    # into the `predicate` function and waits for `predicate(fileChooser)` to return a truthy value. Will throw an error if
    # the page is closed before the file chooser is opened.
    def expect_file_chooser(predicate: nil, timeout: nil, &block)
      wrap_impl(@impl.expect_file_chooser(predicate: unwrap_impl(predicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    # Returns when the `expression` returns a truthy value. It resolves to a JSHandle of the truthy value.
    # 
    # The [`method: Page.waitForFunction`] can be used to observe viewport size change:
    # 
    #
    # ```js
    # const { webkit } = require('playwright');  // Or 'chromium' or 'firefox'.
    # 
    # (async () => {
    #   const browser = await webkit.launch();
    #   const page = await browser.newPage();
    #   const watchDog = page.waitForFunction(() => window.innerWidth < 100);
    #   await page.setViewportSize({width: 50, height: 50});
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
    #       BrowserType webkit = playwright.webkit();
    #       Browser browser = webkit.launch();
    #       Page page = browser.newPage();
    #       page.setViewportSize(50,  50);
    #       page.waitForFunction("() => window.innerWidth < 100");
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
    #     await page.wait_for_function("() => window.x > 0")
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
    #     page.wait_for_function("() => window.x > 0")
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
    #   public static async Task WaitForFunction()
    #   {
    #     using var playwright = await Playwright.CreateAsync();
    #     await using var browser = await playwright.Webkit.LaunchAsync();
    #     var page = await browser.NewPageAsync();
    #     await page.SetViewportSizeAsync(50, 50);
    #     await page.MainFrame.WaitForFunctionAsync("window.innerWidth < 100");
    #   }
    # }
    # ```
    # 
    # To pass an argument to the predicate of [`method: Page.waitForFunction`] function:
    # 
    #
    # ```js
    # const selector = '.foo';
    # await page.waitForFunction(selector => !!document.querySelector(selector), selector);
    # ```
    # 
    # ```java
    # String selector = ".foo";
    # page.waitForFunction("selector => !!document.querySelector(selector)", selector);
    # ```
    # 
    # ```python async
    # selector = ".foo"
    # await page.wait_for_function("selector => !!document.querySelector(selector)", selector)
    # ```
    # 
    # ```python sync
    # selector = ".foo"
    # page.wait_for_function("selector => !!document.querySelector(selector)", selector)
    # ```
    # 
    # ```csharp
    # var selector = ".foo";
    # await page.WaitForFunctionAsync("selector => !!document.querySelector(selector)", selector);
    # ```
    # 
    # Shortcut for main frame's [`method: Frame.waitForFunction`].
    def wait_for_function(expression, arg: nil, polling: nil, timeout: nil)
      wrap_impl(@impl.wait_for_function(unwrap_impl(expression), arg: unwrap_impl(arg), polling: unwrap_impl(polling), timeout: unwrap_impl(timeout)))
    end

    # Returns when the required load state has been reached.
    # 
    # This resolves when the page reaches a required load state, `load` by default. The navigation must have been committed
    # when this method is called. If current document has already reached the required state, resolves immediately.
    # 
    #
    # ```js
    # await page.click('button'); // Click triggers navigation.
    # await page.waitForLoadState(); // The promise resolves after 'load' event.
    # ```
    # 
    # ```java
    # page.click("button"); // Click triggers navigation.
    # page.waitForLoadState(); // The promise resolves after "load" event.
    # ```
    # 
    # ```python async
    # await page.click("button") # click triggers navigation.
    # await page.wait_for_load_state() # the promise resolves after "load" event.
    # ```
    # 
    # ```python sync
    # page.click("button") # click triggers navigation.
    # page.wait_for_load_state() # the promise resolves after "load" event.
    # ```
    # 
    # ```csharp
    # await page.ClickAsync("button"); // Click triggers navigation.
    # await page.WaitForLoadStateAsync(); // The promise resolves after 'load' event.
    # ```
    # 
    #
    # ```js
    # const [popup] = await Promise.all([
    #   page.waitForEvent('popup'),
    #   page.click('button'), // Click triggers a popup.
    # ])
    # await popup.waitForLoadState('domcontentloaded'); // The promise resolves after 'domcontentloaded' event.
    # console.log(await popup.title()); // Popup is ready to use.
    # ```
    # 
    # ```java
    # Page popup = page.waitForPopup(() -> {
    #   page.click("button"); // Click triggers a popup.
    # });
    # popup.waitForLoadState(LoadState.DOMCONTENTLOADED);
    # System.out.println(popup.title()); // Popup is ready to use.
    # ```
    # 
    # ```python async
    # async with page.expect_popup() as page_info:
    #     await page.click("button") # click triggers a popup.
    # popup = await page_info.value
    #  # Following resolves after "domcontentloaded" event.
    # await popup.wait_for_load_state("domcontentloaded")
    # print(await popup.title()) # popup is ready to use.
    # ```
    # 
    # ```python sync
    # with page.expect_popup() as page_info:
    #     page.click("button") # click triggers a popup.
    # popup = page_info.value
    #  # Following resolves after "domcontentloaded" event.
    # popup.wait_for_load_state("domcontentloaded")
    # print(popup.title()) # popup is ready to use.
    # ```
    # 
    # ```csharp
    # var popupTask = page.WaitForPopupAsync();
    # await page.ClickAsync("button"); // click triggers the popup/
    # var popup = await popupTask;
    # await popup.WaitForLoadStateAsync(LoadState.DOMContentLoaded);
    # Console.WriteLine(await popup.TitleAsync()); // popup is ready to use.
    # ```
    # 
    # Shortcut for main frame's [`method: Frame.waitForLoadState`].
    def wait_for_load_state(state: nil, timeout: nil)
      wrap_impl(@impl.wait_for_load_state(state: unwrap_impl(state), timeout: unwrap_impl(timeout)))
    end

    # Waits for the main frame navigation and returns the main resource response. In case of multiple redirects, the
    # navigation will resolve with the response of the last redirect. In case of navigation to a different anchor or
    # navigation due to History API usage, the navigation will resolve with `null`.
    # 
    # This resolves when the page navigates to a new URL or reloads. It is useful for when you run code which will indirectly
    # cause the page to navigate. e.g. The click target has an `onclick` handler that triggers navigation from a `setTimeout`.
    # Consider this example:
    # 
    #
    # ```js
    # const [response] = await Promise.all([
    #   page.waitForNavigation(), // The promise resolves after navigation has finished
    #   page.click('a.delayed-navigation'), // Clicking the link will indirectly cause a navigation
    # ]);
    # ```
    # 
    # ```java
    # // The method returns after navigation has finished
    # Response response = page.waitForNavigation(() -> {
    #   page.click("a.delayed-navigation"); // Clicking the link will indirectly cause a navigation
    # });
    # ```
    # 
    # ```python async
    # async with page.expect_navigation():
    #     await page.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
    # # Resolves after navigation has finished
    # ```
    # 
    # ```python sync
    # with page.expect_navigation():
    #     page.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
    # # Resolves after navigation has finished
    # ```
    # 
    # ```csharp
    # await Task.WhenAll(page.WaitForNavigationAsync(),
    #     frame.ClickAsync("a.delayed-navigation")); // clicking the link will indirectly cause a navigation
    # // The method continues after navigation has finished
    # ```
    # 
    # > NOTE: Usage of the [History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API) to change the URL is
    # considered a navigation.
    # 
    # Shortcut for main frame's [`method: Frame.waitForNavigation`].
    def expect_navigation(timeout: nil, url: nil, waitUntil: nil, &block)
      wrap_impl(@impl.expect_navigation(timeout: unwrap_impl(timeout), url: unwrap_impl(url), waitUntil: unwrap_impl(waitUntil), &wrap_block_call(block)))
    end

    # Performs action and waits for a popup `Page`. If predicate is provided, it passes [Popup] value into the `predicate`
    # function and waits for `predicate(page)` to return a truthy value. Will throw an error if the page is closed before the
    # popup event is fired.
    def expect_popup(predicate: nil, timeout: nil, &block)
      wrap_impl(@impl.expect_popup(predicate: unwrap_impl(predicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    # Waits for the matching request and returns it.  See [waiting for event](./events.md#waiting-for-event) for more details
    # about events.
    # 
    #
    # ```js
    # // Note that Promise.all prevents a race condition
    # // between clicking and waiting for the request.
    # const [request] = await Promise.all([
    #   // Waits for the next request with the specified url
    #   page.waitForRequest('https://example.com/resource'),
    #   // Triggers the request
    #   page.click('button.triggers-request'),
    # ]);
    # 
    # // Alternative way with a predicate.
    # const [request] = await Promise.all([
    #   // Waits for the next request matching some conditions
    #   page.waitForRequest(request => request.url() === 'https://example.com' && request.method() === 'GET'),
    #   // Triggers the request
    #   page.click('button.triggers-request'),
    # ]);
    # ```
    # 
    # ```java
    # // Waits for the next response with the specified url
    # Request request = page.waitForRequest("https://example.com/resource", () -> {
    #   // Triggers the request
    #   page.click("button.triggers-request");
    # });
    # 
    # // Waits for the next request matching some conditions
    # Request request = page.waitForRequest(request -> "https://example.com".equals(request.url()) && "GET".equals(request.method()), () -> {
    #   // Triggers the request
    #   page.click("button.triggers-request");
    # });
    # ```
    # 
    # ```python async
    # async with page.expect_request("http://example.com/resource") as first:
    #     await page.click('button')
    # first_request = await first.value
    # 
    # # or with a lambda
    # async with page.expect_request(lambda request: request.url == "http://example.com" and request.method == "get") as second:
    #     await page.click('img')
    # second_request = await second.value
    # ```
    # 
    # ```python sync
    # with page.expect_request("http://example.com/resource") as first:
    #     page.click('button')
    # first_request = first.value
    # 
    # # or with a lambda
    # with page.expect_request(lambda request: request.url == "http://example.com" and request.method == "get") as second:
    #     page.click('img')
    # second_request = second.value
    # ```
    # 
    # ```csharp
    # // Waits for the next response with the specified url
    # await Task.WhenAll(page.WaitForRequestAsync("https://example.com/resource"),
    #     page.ClickAsync("button.triggers-request"));
    # 
    # // Waits for the next request matching some conditions
    # await Task.WhenAll(page.WaitForRequestAsync(r => "https://example.com".Equals(r.Url) && "GET" == r.Method),
    #     page.ClickAsync("button.triggers-request"));
    # ```
    # 
    #
    # ```js
    # await page.waitForRequest(request => request.url().searchParams.get('foo') === 'bar' && request.url().searchParams.get('foo2') === 'bar2');
    # ```
    def expect_request(urlOrPredicate, timeout: nil)
      wrap_impl(@impl.expect_request(unwrap_impl(urlOrPredicate), timeout: unwrap_impl(timeout)))
    end

    # Returns the matched response. See [waiting for event](./events.md#waiting-for-event) for more details about events.
    # 
    #
    # ```js
    # // Note that Promise.all prevents a race condition
    # // between clicking and waiting for the response.
    # const [response] = await Promise.all([
    #   // Waits for the next response with the specified url
    #   page.waitForResponse('https://example.com/resource'),
    #   // Triggers the response
    #   page.click('button.triggers-response'),
    # ]);
    # 
    # // Alternative way with a predicate.
    # const [response] = await Promise.all([
    #   // Waits for the next response matching some conditions
    #   page.waitForResponse(response => response.url() === 'https://example.com' && response.status() === 200),
    #   // Triggers the response
    #   page.click('button.triggers-response'),
    # ]);
    # ```
    # 
    # ```java
    # // Waits for the next response with the specified url
    # Response response = page.waitForResponse("https://example.com/resource", () -> {
    #   // Triggers the response
    #   page.click("button.triggers-response");
    # });
    # 
    # // Waits for the next response matching some conditions
    # Response response = page.waitForResponse(response -> "https://example.com".equals(response.url()) && response.status() == 200, () -> {
    #   // Triggers the response
    #   page.click("button.triggers-response");
    # });
    # ```
    # 
    # ```python async
    # async with page.expect_response("https://example.com/resource") as response_info:
    #     await page.click("input")
    # response = response_info.value
    # return response.ok
    # 
    # # or with a lambda
    # async with page.expect_response(lambda response: response.url == "https://example.com" and response.status === 200) as response_info:
    #     await page.click("input")
    # response = response_info.value
    # return response.ok
    # ```
    # 
    # ```python sync
    # with page.expect_response("https://example.com/resource") as response_info:
    #     page.click("input")
    # response = response_info.value
    # return response.ok
    # 
    # # or with a lambda
    # with page.expect_response(lambda response: response.url == "https://example.com" and response.status === 200) as response_info:
    #     page.click("input")
    # response = response_info.value
    # return response.ok
    # ```
    # 
    # ```csharp
    # // Waits for the next response with the specified url
    # await Task.WhenAll(page.WaitForResponseAsync("https://example.com/resource"),
    #     page.ClickAsync("button.triggers-response"));
    # 
    # // Waits for the next response matching some conditions
    # await Task.WhenAll(page.WaitForResponseAsync(r => "https://example.com".Equals(r.Url) && r.Status == 200),
    #     page.ClickAsync("button.triggers-response"));
    # ```
    def expect_response(urlOrPredicate, timeout: nil)
      wrap_impl(@impl.expect_response(unwrap_impl(urlOrPredicate), timeout: unwrap_impl(timeout)))
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
    #     const element = await page.waitForSelector('img');
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
    #         ElementHandle element = page.waitForSelector("img");
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
    #         element = await page.wait_for_selector("img")
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
    #         element = page.wait_for_selector("img")
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
    #   public static async Task Images()
    #   {
    #       using var playwright = await Playwright.CreateAsync();
    #       await using var browser = await playwright.Chromium.LaunchAsync();
    #       var page = await browser.NewPageAsync();
    # 
    #       foreach (var currentUrl in new[] { "https://www.google.com", "https://bbc.com" })
    #       {
    #           await page.GotoAsync(currentUrl);
    #           var element = await page.WaitForSelectorAsync("img");
    #           Console.WriteLine($"Loaded image: {await element.GetAttributeAsync("src")}");
    #       }
    # 
    #       await browser.CloseAsync();
    #   }
    # }
    # ```
    def wait_for_selector(selector, state: nil, timeout: nil)
      wrap_impl(@impl.wait_for_selector(unwrap_impl(selector), state: unwrap_impl(state), timeout: unwrap_impl(timeout)))
    end

    # Waits for the given `timeout` in milliseconds.
    # 
    # Note that `page.waitForTimeout()` should only be used for debugging. Tests using the timer in production are going to be
    # flaky. Use signals such as network events, selectors becoming visible and others instead.
    # 
    #
    # ```js
    # // wait for 1 second
    # await page.waitForTimeout(1000);
    # ```
    # 
    # ```java
    # // wait for 1 second
    # page.waitForTimeout(1000);
    # ```
    # 
    # ```python async
    # # wait for 1 second
    # await page.wait_for_timeout(1000)
    # ```
    # 
    # ```python sync
    # # wait for 1 second
    # page.wait_for_timeout(1000)
    # ```
    # 
    # ```csharp
    # // Wait for 1 second
    # await page.WaitForTimeoutAsync(1000);
    # ```
    # 
    # Shortcut for main frame's [`method: Frame.waitForTimeout`].
    def wait_for_timeout(timeout)
      raise NotImplementedError.new('wait_for_timeout is not implemented yet.')
    end

    # Waits for the main frame to navigate to the given URL.
    # 
    #
    # ```js
    # await page.click('a.delayed-navigation'); // Clicking the link will indirectly cause a navigation
    # await page.waitForURL('**/target.html');
    # ```
    # 
    # ```java
    # page.click("a.delayed-navigation"); // Clicking the link will indirectly cause a navigation
    # page.waitForURL("**/target.html");
    # ```
    # 
    # ```python async
    # await page.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
    # await page.wait_for_url("**/target.html")
    # ```
    # 
    # ```python sync
    # page.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
    # page.wait_for_url("**/target.html")
    # ```
    # 
    # ```csharp
    # await page.ClickAsync("a.delayed-navigation"); // clicking the link will indirectly cause a navigation
    # await page.WaitForURLAsync("**/target.html");
    # ```
    # 
    # Shortcut for main frame's [`method: Frame.waitForURL`].
    def wait_for_url(url, timeout: nil, waitUntil: nil)
      wrap_impl(@impl.wait_for_url(unwrap_impl(url), timeout: unwrap_impl(timeout), waitUntil: unwrap_impl(waitUntil)))
    end

    # Performs action and waits for a new `Worker`. If predicate is provided, it passes `Worker` value into the `predicate`
    # function and waits for `predicate(worker)` to return a truthy value. Will throw an error if the page is closed before
    # the worker event is fired.
    def expect_worker(predicate: nil, timeout: nil)
      raise NotImplementedError.new('expect_worker is not implemented yet.')
    end

    # This method returns all of the dedicated [WebWorkers](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API)
    # associated with the page.
    # 
    # > NOTE: This does not contain ServiceWorkers
    def workers
      raise NotImplementedError.new('workers is not implemented yet.')
    end

    # > NOTE: In most cases, you should use [`method: Page.waitForEvent`].
    # 
    # Waits for given `event` to fire. If predicate is provided, it passes event's value into the `predicate` function and
    # waits for `predicate(event)` to return a truthy value. Will throw an error if the socket is closed before the `event` is
    # fired.
    def wait_for_event(event, predicate: nil, timeout: nil)
      raise NotImplementedError.new('wait_for_event is not implemented yet.')
    end

    # @nodoc
    def owned_context=(req)
      wrap_impl(@impl.owned_context=(unwrap_impl(req)))
    end

    # @nodoc
    def guid
      wrap_impl(@impl.guid)
    end

    # @nodoc
    def start_js_coverage(resetOnNavigation: nil, reportAnonymousScripts: nil)
      wrap_impl(@impl.start_js_coverage(resetOnNavigation: unwrap_impl(resetOnNavigation), reportAnonymousScripts: unwrap_impl(reportAnonymousScripts)))
    end

    # @nodoc
    def stop_js_coverage
      wrap_impl(@impl.stop_js_coverage)
    end

    # @nodoc
    def start_css_coverage(resetOnNavigation: nil, reportAnonymousScripts: nil)
      wrap_impl(@impl.start_css_coverage(resetOnNavigation: unwrap_impl(resetOnNavigation), reportAnonymousScripts: unwrap_impl(reportAnonymousScripts)))
    end

    # @nodoc
    def stop_css_coverage
      wrap_impl(@impl.stop_css_coverage)
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

    # -- inherited from EventEmitter --
    # @nodoc
    def on(event, callback)
      event_emitter_proxy.on(event, callback)
    end

    private def event_emitter_proxy
      @event_emitter_proxy ||= EventEmitterProxy.new(self, @impl)
    end
  end
end
