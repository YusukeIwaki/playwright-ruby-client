module Playwright
  # BrowserType provides methods to launch a specific browser instance or connect to an existing one. The following is a
  # typical example of using Playwright to drive automation:
  # 
  #
  # ```js
  # const { chromium } = require('playwright');  // Or 'firefox' or 'webkit'.
  # 
  # (async () => {
  #   const browser = await chromium.launch();
  #   const page = await browser.newPage();
  #   await page.goto('https://example.com');
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
  #       page.navigate("https://example.com");
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
  #     chromium = playwright.chromium
  #     browser = await chromium.launch()
  #     page = await browser.new_page()
  #     await page.goto("https://example.com")
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
  #     chromium = playwright.chromium
  #     browser = chromium.launch()
  #     page = browser.new_page()
  #     page.goto("https://example.com")
  #     # other actions...
  #     browser.close()
  # 
  # with sync_playwright() as playwright:
  #     run(playwright)
  # ```
  class BrowserType < PlaywrightApi

    # A path where Playwright expects to find a bundled browser executable.
    def executable_path
      wrap_impl(@impl.executable_path)
    end

    # Returns the browser instance.
    # 
    # You can use `ignoreDefaultArgs` to filter out `--mute-audio` from default arguments:
    # 
    #
    # ```js
    # const browser = await chromium.launch({  // Or 'firefox' or 'webkit'.
    #   ignoreDefaultArgs: ['--mute-audio']
    # });
    # ```
    # 
    # ```java
    # // Or "firefox" or "webkit".
    # Browser browser = chromium.launch(new BrowserType.LaunchOptions()
    #   .setIgnoreDefaultArgs(Arrays.asList("--mute-audio")));
    # ```
    # 
    # ```python async
    # browser = await playwright.chromium.launch( # or "firefox" or "webkit".
    #     ignore_default_args=["--mute-audio"]
    # )
    # ```
    # 
    # ```python sync
    # browser = playwright.chromium.launch( # or "firefox" or "webkit".
    #     ignore_default_args=["--mute-audio"]
    # )
    # ```
    # 
    # > **Chromium-only** Playwright can also be used to control the Google Chrome or Microsoft Edge browsers, but it works
    # best with the version of Chromium it is bundled with. There is no guarantee it will work with any other version. Use
    # `executablePath` option with extreme caution.
    # >
    # > If Google Chrome (rather than Chromium) is preferred, a
    # [Chrome Canary](https://www.google.com/chrome/browser/canary.html) or
    # [Dev Channel](https://www.chromium.org/getting-involved/dev-channel) build is suggested.
    # >
    # > Stock browsers like Google Chrome and Microsoft Edge are suitable for tests that require proprietary media codecs for
    # video playback. See
    # [this article](https://www.howtogeek.com/202825/what%E2%80%99s-the-difference-between-chromium-and-chrome/) for other
    # differences between Chromium and Chrome.
    # [This article](https://chromium.googlesource.com/chromium/src/+/lkgr/docs/chromium_browser_vs_google_chrome.md)
    # describes some differences for Linux users.
    def launch(
          args: nil,
          channel: nil,
          chromiumSandbox: nil,
          devtools: nil,
          downloadsPath: nil,
          env: nil,
          executablePath: nil,
          firefoxUserPrefs: nil,
          handleSIGHUP: nil,
          handleSIGINT: nil,
          handleSIGTERM: nil,
          headless: nil,
          ignoreDefaultArgs: nil,
          proxy: nil,
          slowMo: nil,
          timeout: nil,
          &block)
      wrap_impl(@impl.launch(args: unwrap_impl(args), channel: unwrap_impl(channel), chromiumSandbox: unwrap_impl(chromiumSandbox), devtools: unwrap_impl(devtools), downloadsPath: unwrap_impl(downloadsPath), env: unwrap_impl(env), executablePath: unwrap_impl(executablePath), firefoxUserPrefs: unwrap_impl(firefoxUserPrefs), handleSIGHUP: unwrap_impl(handleSIGHUP), handleSIGINT: unwrap_impl(handleSIGINT), handleSIGTERM: unwrap_impl(handleSIGTERM), headless: unwrap_impl(headless), ignoreDefaultArgs: unwrap_impl(ignoreDefaultArgs), proxy: unwrap_impl(proxy), slowMo: unwrap_impl(slowMo), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    # Returns the persistent browser context instance.
    # 
    # Launches browser that uses persistent storage located at `userDataDir` and returns the only context. Closing this
    # context will automatically close the browser.
    def launch_persistent_context(
          userDataDir,
          acceptDownloads: nil,
          args: nil,
          bypassCSP: nil,
          channel: nil,
          chromiumSandbox: nil,
          colorScheme: nil,
          deviceScaleFactor: nil,
          devtools: nil,
          downloadsPath: nil,
          env: nil,
          executablePath: nil,
          extraHTTPHeaders: nil,
          geolocation: nil,
          handleSIGHUP: nil,
          handleSIGINT: nil,
          handleSIGTERM: nil,
          hasTouch: nil,
          headless: nil,
          httpCredentials: nil,
          ignoreDefaultArgs: nil,
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
          slowMo: nil,
          timeout: nil,
          timezoneId: nil,
          userAgent: nil,
          viewport: nil)
      raise NotImplementedError.new('launch_persistent_context is not implemented yet.')
    end

    # Returns browser name. For example: `'chromium'`, `'webkit'` or `'firefox'`.
    def name
      wrap_impl(@impl.name)
    end

    # @nodoc
    def connect_over_cdp(endpointURL, slowMo: nil, timeout: nil, &block)
      wrap_impl(@impl.connect_over_cdp(unwrap_impl(endpointURL), slowMo: unwrap_impl(slowMo), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
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
