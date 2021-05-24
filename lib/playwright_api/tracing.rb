module Playwright
  # API for collecting and saving Playwright traces. Playwright traces can be opened using the Playwright CLI after
  # Playwright script runs.
  #
  # Start with specifying the folder traces will be stored in:
  #
  #
  # ```js
  # const browser = await chromium.launch({ traceDir: 'traces' });
  # const context = await browser.newContext();
  # await context.tracing.start({ name: 'trace', screenshots: true, snapshots: true });
  # const page = await context.newPage();
  # await page.goto('https://playwright.dev');
  # await context.tracing.stop();
  # await context.tracing.export('trace.zip');
  # ```
  #
  # ```java
  # Browser browser = chromium.launch(new BrowserType.LaunchOptions().setTraceDir("trace"));
  # BrowserContext context = browser.newContext();
  # context.tracing.start(page, new Tracing.StartOptions()
  #   .setName("trace")
  #   .setScreenshots(true)
  #   .setSnapshots(true);
  # Page page = context.newPage();
  # page.goto("https://playwright.dev");
  # context.tracing.stop();
  # context.tracing.export(Paths.get("trace.zip")))
  # ```
  #
  # ```python async
  # browser = await chromium.launch(traceDir='traces')
  # context = await browser.new_context()
  # await context.tracing.start(name="trace", screenshots=True, snapshots=True)
  # await page.goto("https://playwright.dev")
  # await context.tracing.stop()
  # await context.tracing.export("trace.zip")
  # ```
  #
  # ```python sync
  # browser = chromium.launch(traceDir='traces')
  # context = browser.new_context()
  # context.tracing.start(name="trace", screenshots=True, snapshots=True)
  # page.goto("https://playwright.dev")
  # context.tracing.stop()
  # context.tracing.export("trace.zip")
  # ```
  class Tracing < PlaywrightApi

    # Export trace into the file with the given name. Should be called after the tracing has stopped.
    def export(path)
      wrap_impl(@impl.export(unwrap_impl(path)))
    end

    # Start tracing.
    #
    #
    # ```js
    # await context.tracing.start({ name: 'trace', screenshots: true, snapshots: true });
    # const page = await context.newPage();
    # await page.goto('https://playwright.dev');
    # await context.tracing.stop();
    # await context.tracing.export('trace.zip');
    # ```
    #
    # ```java
    # context.tracing.start(page, new Tracing.StartOptions()
    #   .setName("trace")
    #   .setScreenshots(true)
    #   .setSnapshots(true);
    # Page page = context.newPage();
    # page.goto('https://playwright.dev');
    # context.tracing.stop();
    # context.tracing.export(Paths.get("trace.zip")))
    # ```
    #
    # ```python async
    # await context.tracing.start(name="trace", screenshots=True, snapshots=True)
    # await page.goto("https://playwright.dev")
    # await context.tracing.stop()
    # await context.tracing.export("trace.zip")
    # ```
    #
    # ```python sync
    # context.tracing.start(name="trace", screenshots=True, snapshots=True)
    # page.goto("https://playwright.dev")
    # context.tracing.stop()
    # context.tracing.export("trace.zip")
    # ```
    def start(name: nil, screenshots: nil, snapshots: nil)
      wrap_impl(@impl.start(name: unwrap_impl(name), screenshots: unwrap_impl(screenshots), snapshots: unwrap_impl(snapshots)))
    end

    # Stop tracing.
    def stop
      wrap_impl(@impl.stop)
    end
  end
end
