module Playwright
  # - extends: [EventEmitter]
  # 
  # A Browser is created via [`method: BrowserType.launch`]. An example of using a `Browser` to create a `Page`:
  # 
  #
  # ```js
  # const { firefox } = require('playwright');  // Or 'chromium' or 'webkit'.
  # 
  # (async () => {
  #   const browser = await firefox.launch();
  #   const page = await browser.newPage();
  #   await page.goto('https://example.com');
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
  #       BrowserType firefox = playwright.firefox()
  #       Browser browser = firefox.launch();
  #       Page page = browser.newPage();
  #       page.navigate('https://example.com');
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
  #     firefox = playwright.firefox
  #     browser = await firefox.launch()
  #     page = await browser.new_page()
  #     await page.goto("https://example.com")
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
  #     firefox = playwright.firefox
  #     browser = firefox.launch()
  #     page = browser.new_page()
  #     page.goto("https://example.com")
  #     browser.close()
  # 
  # with sync_playwright() as playwright:
  #     run(playwright)
  # ```
  class Browser < PlaywrightApi

    # In case this browser is obtained using [`method: BrowserType.launch`], closes the browser and all of its pages (if any
    # were opened).
    # 
    # In case this browser is connected to, clears all created contexts belonging to this browser and disconnects from the
    # browser server.
    # 
    # The `Browser` object itself is considered to be disposed and cannot be used anymore.
    def close
      wrap_impl(@impl.close)
    end

    # Returns an array of all open browser contexts. In a newly created browser, this will return zero browser contexts.
    # 
    #
    # ```js
    # const browser = await pw.webkit.launch();
    # console.log(browser.contexts().length); // prints `0`
    # 
    # const context = await browser.newContext();
    # console.log(browser.contexts().length); // prints `1`
    # ```
    # 
    # ```java
    # Browser browser = pw.webkit().launch();
    # System.out.println(browser.contexts().size()); // prints "0"
    # BrowserContext context = browser.newContext();
    # System.out.println(browser.contexts().size()); // prints "1"
    # ```
    # 
    # ```python async
    # browser = await pw.webkit.launch()
    # print(len(browser.contexts())) # prints `0`
    # context = await browser.new_context()
    # print(len(browser.contexts())) # prints `1`
    # ```
    # 
    # ```python sync
    # browser = pw.webkit.launch()
    # print(len(browser.contexts())) # prints `0`
    # context = browser.new_context()
    # print(len(browser.contexts())) # prints `1`
    # ```
    def contexts
      wrap_impl(@impl.contexts)
    end

    # Indicates that the browser is connected.
    def connected?
      wrap_impl(@impl.connected?)
    end

    # > NOTE: CDP Sessions are only supported on Chromium-based browsers.
    # 
    # Returns the newly created browser session.
    def new_browser_cdp_session
      raise NotImplementedError.new('new_browser_cdp_session is not implemented yet.')
    end

    # Creates a new browser context. It won't share cookies/cache with other browser contexts.
    # 
    #
    # ```js
    # (async () => {
    #   const browser = await playwright.firefox.launch();  // Or 'chromium' or 'webkit'.
    #   // Create a new incognito browser context.
    #   const context = await browser.newContext();
    #   // Create a new page in a pristine context.
    #   const page = await context.newPage();
    #   await page.goto('https://example.com');
    # })();
    # ```
    # 
    # ```java
    # Browser browser = playwright.firefox().launch();  // Or 'chromium' or 'webkit'.
    # // Create a new incognito browser context.
    # BrowserContext context = browser.newContext();
    # // Create a new page in a pristine context.
    # Page page = context.newPage();
    # page.navigate('https://example.com');
    # ```
    # 
    # ```python async
    # browser = await playwright.firefox.launch() # or "chromium" or "webkit".
    # # create a new incognito browser context.
    # context = await browser.new_context()
    # # create a new page in a pristine context.
    # page = await context.new_page()
    # await page.goto("https://example.com")
    # ```
    # 
    # ```python sync
    # browser = playwright.firefox.launch() # or "chromium" or "webkit".
    # # create a new incognito browser context.
    # context = browser.new_context()
    # # create a new page in a pristine context.
    # page = context.new_page()
    # page.goto("https://example.com")
    # ```
    def new_context(
          acceptDownloads: nil,
          bypassCSP: nil,
          colorScheme: nil,
          deviceScaleFactor: nil,
          extraHTTPHeaders: nil,
          geolocation: nil,
          hasTouch: nil,
          httpCredentials: nil,
          ignoreHTTPSErrors: nil,
          isMobile: nil,
          javaScriptEnabled: nil,
          locale: nil,
          noViewport: nil,
          offline: nil,
          permissions: nil,
          proxy: nil,
          record_har_omit_content: nil,
          record_har_path: nil,
          record_video_dir: nil,
          record_video_size: nil,
          screen: nil,
          storageState: nil,
          timezoneId: nil,
          userAgent: nil,
          viewport: nil,
          &block)
      wrap_impl(@impl.new_context(acceptDownloads: unwrap_impl(acceptDownloads), bypassCSP: unwrap_impl(bypassCSP), colorScheme: unwrap_impl(colorScheme), deviceScaleFactor: unwrap_impl(deviceScaleFactor), extraHTTPHeaders: unwrap_impl(extraHTTPHeaders), geolocation: unwrap_impl(geolocation), hasTouch: unwrap_impl(hasTouch), httpCredentials: unwrap_impl(httpCredentials), ignoreHTTPSErrors: unwrap_impl(ignoreHTTPSErrors), isMobile: unwrap_impl(isMobile), javaScriptEnabled: unwrap_impl(javaScriptEnabled), locale: unwrap_impl(locale), noViewport: unwrap_impl(noViewport), offline: unwrap_impl(offline), permissions: unwrap_impl(permissions), proxy: unwrap_impl(proxy), record_har_omit_content: unwrap_impl(record_har_omit_content), record_har_path: unwrap_impl(record_har_path), record_video_dir: unwrap_impl(record_video_dir), record_video_size: unwrap_impl(record_video_size), screen: unwrap_impl(screen), storageState: unwrap_impl(storageState), timezoneId: unwrap_impl(timezoneId), userAgent: unwrap_impl(userAgent), viewport: unwrap_impl(viewport), &wrap_block_call(block)))
    end

    # Creates a new page in a new browser context. Closing this page will close the context as well.
    # 
    # This is a convenience API that should only be used for the single-page scenarios and short snippets. Production code and
    # testing frameworks should explicitly create [`method: Browser.newContext`] followed by the
    # [`method: BrowserContext.newPage`] to control their exact life times.
    def new_page(
          acceptDownloads: nil,
          bypassCSP: nil,
          colorScheme: nil,
          deviceScaleFactor: nil,
          extraHTTPHeaders: nil,
          geolocation: nil,
          hasTouch: nil,
          httpCredentials: nil,
          ignoreHTTPSErrors: nil,
          isMobile: nil,
          javaScriptEnabled: nil,
          locale: nil,
          noViewport: nil,
          offline: nil,
          permissions: nil,
          proxy: nil,
          record_har_omit_content: nil,
          record_har_path: nil,
          record_video_dir: nil,
          record_video_size: nil,
          screen: nil,
          storageState: nil,
          timezoneId: nil,
          userAgent: nil,
          viewport: nil)
      wrap_impl(@impl.new_page(acceptDownloads: unwrap_impl(acceptDownloads), bypassCSP: unwrap_impl(bypassCSP), colorScheme: unwrap_impl(colorScheme), deviceScaleFactor: unwrap_impl(deviceScaleFactor), extraHTTPHeaders: unwrap_impl(extraHTTPHeaders), geolocation: unwrap_impl(geolocation), hasTouch: unwrap_impl(hasTouch), httpCredentials: unwrap_impl(httpCredentials), ignoreHTTPSErrors: unwrap_impl(ignoreHTTPSErrors), isMobile: unwrap_impl(isMobile), javaScriptEnabled: unwrap_impl(javaScriptEnabled), locale: unwrap_impl(locale), noViewport: unwrap_impl(noViewport), offline: unwrap_impl(offline), permissions: unwrap_impl(permissions), proxy: unwrap_impl(proxy), record_har_omit_content: unwrap_impl(record_har_omit_content), record_har_path: unwrap_impl(record_har_path), record_video_dir: unwrap_impl(record_video_dir), record_video_size: unwrap_impl(record_video_size), screen: unwrap_impl(screen), storageState: unwrap_impl(storageState), timezoneId: unwrap_impl(timezoneId), userAgent: unwrap_impl(userAgent), viewport: unwrap_impl(viewport)))
    end

    # > NOTE: Tracing is only supported on Chromium-based browsers.
    # 
    # You can use [`method: Browser.startTracing`] and [`method: Browser.stopTracing`] to create a trace file that can be
    # opened in Chrome DevTools performance panel.
    # 
    #
    # ```js
    # await browser.startTracing(page, {path: 'trace.json'});
    # await page.goto('https://www.google.com');
    # await browser.stopTracing();
    # ```
    # 
    # ```python async
    # await browser.start_tracing(page, path="trace.json")
    # await page.goto("https://www.google.com")
    # await browser.stop_tracing()
    # ```
    # 
    # ```python sync
    # browser.start_tracing(page, path="trace.json")
    # page.goto("https://www.google.com")
    # browser.stop_tracing()
    # ```
    def start_tracing(page: nil, categories: nil, path: nil, screenshots: nil)
      wrap_impl(@impl.start_tracing(page: unwrap_impl(page), categories: unwrap_impl(categories), path: unwrap_impl(path), screenshots: unwrap_impl(screenshots)))
    end

    # > NOTE: Tracing is only supported on Chromium-based browsers.
    # 
    # Returns the buffer with trace data.
    def stop_tracing
      wrap_impl(@impl.stop_tracing)
    end

    # Returns the browser version.
    def version
      wrap_impl(@impl.version)
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
