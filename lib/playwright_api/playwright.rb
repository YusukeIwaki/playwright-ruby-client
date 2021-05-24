module Playwright
  # Playwright module provides a method to launch a browser instance. The following is a typical example of using Playwright
  # to drive automation:
  #
  #
  # ```js
  # const { chromium, firefox, webkit } = require('playwright');
  #
  # (async () => {
  #   const browser = await chromium.launch();  // Or 'firefox' or 'webkit'.
  #   const page = await browser.newPage();
  #   await page.goto('http://example.com');
  #   // other actions...
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
  #       page.navigate("http://example.com");
  #       // other actions...
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
  #     chromium = playwright.chromium # or "firefox" or "webkit".
  #     browser = await chromium.launch()
  #     page = await browser.new_page()
  #     await page.goto("http://example.com")
  #     # other actions...
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
  #     chromium = playwright.chromium # or "firefox" or "webkit".
  #     browser = chromium.launch()
  #     page = browser.new_page()
  #     page.goto("http://example.com")
  #     # other actions...
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
  # class PlaywrightExample
  # {
  #     public static async Task Main()
  #     {
  #         using var playwright = await Playwright.CreateAsync();
  #         await using var browser = await playwright.Chromium.LaunchAsync();
  #         var page = await browser.NewPageAsync();
  #
  #         await page.GotoAsync("https://www.microsoft.com");
  #         // other actions...
  #     }
  # }
  # ```
  class Playwright < PlaywrightApi

    # This object can be used to launch or connect to Chromium, returning instances of `Browser`.
    def chromium # property
      wrap_impl(@impl.chromium)
    end

    # Returns a dictionary of devices to be used with [`method: Browser.newContext`] or [`method: Browser.newPage`].
    #
    #
    # ```js
    # const { webkit, devices } = require('playwright');
    # const iPhone = devices['iPhone 6'];
    #
    # (async () => {
    #   const browser = await webkit.launch();
    #   const context = await browser.newContext({
    #     ...iPhone
    #   });
    #   const page = await context.newPage();
    #   await page.goto('http://example.com');
    #   // other actions...
    #   await browser.close();
    # })();
    # ```
    #
    # ```python async
    # import asyncio
    # from playwright.async_api import async_playwright
    #
    # async def run(playwright):
    #     webkit = playwright.webkit
    #     iphone = playwright.devices["iPhone 6"]
    #     browser = await webkit.launch()
    #     context = await browser.new_context(**iphone)
    #     page = await context.new_page()
    #     await page.goto("http://example.com")
    #     # other actions...
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
    #     iphone = playwright.devices["iPhone 6"]
    #     browser = webkit.launch()
    #     context = browser.new_context(**iphone)
    #     page = context.new_page()
    #     page.goto("http://example.com")
    #     # other actions...
    #     browser.close()
    #
    # with sync_playwright() as playwright:
    #     run(playwright)
    # ```
    def devices # property
      wrap_impl(@impl.devices)
    end

    # This object can be used to launch or connect to Firefox, returning instances of `Browser`.
    def firefox # property
      wrap_impl(@impl.firefox)
    end

    # Selectors can be used to install custom selector engines. See [Working with selectors](./selectors.md) for more
    # information.
    def selectors # property
      wrap_impl(@impl.selectors)
    end

    # This object can be used to launch or connect to WebKit, returning instances of `Browser`.
    def webkit # property
      wrap_impl(@impl.webkit)
    end

    # Terminates this instance of Playwright in case it was created bypassing the Python context manager. This is useful in
    # REPL applications.
    #
    # ```py
    # >>> from playwright.sync_api import sync_playwright
    #
    # >>> playwright = sync_playwright().start()
    #
    # >>> browser = playwright.chromium.launch()
    # >>> page = browser.new_page()
    # >>> page.goto("http://whatsmyuseragent.org/")
    # >>> page.screenshot(path="example.png")
    # >>> browser.close()
    #
    # >>> playwright.stop()
    # ```
    def stop
      raise NotImplementedError.new('stop is not implemented yet.')
    end

    # @nodoc
    def android
      wrap_impl(@impl.android)
    end

    # @nodoc
    def electron
      wrap_impl(@impl.electron)
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
