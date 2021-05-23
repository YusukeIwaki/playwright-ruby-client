module Playwright
  # - extends: [EventEmitter]
  # 
  # BrowserContexts provide a way to operate multiple independent browser sessions.
  # 
  # If a page opens another page, e.g. with a `window.open` call, the popup will belong to the parent page's browser
  # context.
  # 
  # Playwright allows creation of "incognito" browser contexts with `browser.newContext()` method. "Incognito" browser
  # contexts don't write any browsing data to disk.
  # 
  #
  # ```js
  # // Create a new incognito browser context
  # const context = await browser.newContext();
  # // Create a new page inside context.
  # const page = await context.newPage();
  # await page.goto('https://example.com');
  # // Dispose context once it's no longer needed.
  # await context.close();
  # ```
  # 
  # ```java
  # // Create a new incognito browser context
  # BrowserContext context = browser.newContext();
  # // Create a new page inside context.
  # Page page = context.newPage();
  # page.navigate("https://example.com");
  # // Dispose context once it"s no longer needed.
  # context.close();
  # ```
  # 
  # ```python async
  # # create a new incognito browser context
  # context = await browser.new_context()
  # # create a new page inside context.
  # page = await context.new_page()
  # await page.goto("https://example.com")
  # # dispose context once it"s no longer needed.
  # await context.close()
  # ```
  # 
  # ```python sync
  # # create a new incognito browser context
  # context = browser.new_context()
  # # create a new page inside context.
  # page = context.new_page()
  # page.goto("https://example.com")
  # # dispose context once it"s no longer needed.
  # context.close()
  # ```
  class BrowserContext < PlaywrightApi

    # Adds cookies into this browser context. All pages within this context will have these cookies installed. Cookies can be
    # obtained via [`method: BrowserContext.cookies`].
    # 
    #
    # ```js
    # await browserContext.addCookies([cookieObject1, cookieObject2]);
    # ```
    # 
    # ```java
    # browserContext.addCookies(Arrays.asList(cookieObject1, cookieObject2));
    # ```
    # 
    # ```python async
    # await browser_context.add_cookies([cookie_object1, cookie_object2])
    # ```
    # 
    # ```python sync
    # browser_context.add_cookies([cookie_object1, cookie_object2])
    # ```
    def add_cookies(cookies)
      wrap_impl(@impl.add_cookies(unwrap_impl(cookies)))
    end

    # Adds a script which would be evaluated in one of the following scenarios:
    # - Whenever a page is created in the browser context or is navigated.
    # - Whenever a child frame is attached or navigated in any page in the browser context. In this case, the script is
    #   evaluated in the context of the newly attached frame.
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
    # // In your playwright script, assuming the preload.js file is in same directory.
    # await browserContext.addInitScript({
    #   path: 'preload.js'
    # });
    # ```
    # 
    # ```java
    # // In your playwright script, assuming the preload.js file is in same directory.
    # browserContext.addInitScript(Paths.get("preload.js"));
    # ```
    # 
    # ```python async
    # # in your playwright script, assuming the preload.js file is in same directory.
    # await browser_context.add_init_script(path="preload.js")
    # ```
    # 
    # ```python sync
    # # in your playwright script, assuming the preload.js file is in same directory.
    # browser_context.add_init_script(path="preload.js")
    # ```
    # 
    # > NOTE: The order of evaluation of multiple scripts installed via [`method: BrowserContext.addInitScript`] and
    # [`method: Page.addInitScript`] is not defined.
    def add_init_script(path: nil, script: nil)
      wrap_impl(@impl.add_init_script(path: unwrap_impl(path), script: unwrap_impl(script)))
    end

    # > NOTE: Background pages are only supported on Chromium-based browsers.
    # 
    # All existing background pages in the context.
    def background_pages
      raise NotImplementedError.new('background_pages is not implemented yet.')
    end

    # Returns the browser instance of the context. If it was launched as a persistent context null gets returned.
    def browser
      wrap_impl(@impl.browser)
    end

    # Clears context cookies.
    def clear_cookies
      wrap_impl(@impl.clear_cookies)
    end

    # Clears all permission overrides for the browser context.
    # 
    #
    # ```js
    # const context = await browser.newContext();
    # await context.grantPermissions(['clipboard-read']);
    # // do stuff ..
    # context.clearPermissions();
    # ```
    # 
    # ```java
    # BrowserContext context = browser.newContext();
    # context.grantPermissions(Arrays.asList("clipboard-read"));
    # // do stuff ..
    # context.clearPermissions();
    # ```
    # 
    # ```python async
    # context = await browser.new_context()
    # await context.grant_permissions(["clipboard-read"])
    # # do stuff ..
    # context.clear_permissions()
    # ```
    # 
    # ```python sync
    # context = browser.new_context()
    # context.grant_permissions(["clipboard-read"])
    # # do stuff ..
    # context.clear_permissions()
    # ```
    def clear_permissions
      wrap_impl(@impl.clear_permissions)
    end

    # Closes the browser context. All the pages that belong to the browser context will be closed.
    # 
    # > NOTE: The default browser context cannot be closed.
    def close
      wrap_impl(@impl.close)
    end

    # If no URLs are specified, this method returns all cookies. If URLs are specified, only cookies that affect those URLs
    # are returned.
    def cookies(urls: nil)
      wrap_impl(@impl.cookies(urls: unwrap_impl(urls)))
    end

    # The method adds a function called `name` on the `window` object of every frame in every page in the context. When
    # called, the function executes `callback` and returns a [Promise] which resolves to the return value of `callback`. If
    # the `callback` returns a [Promise], it will be awaited.
    # 
    # The first argument of the `callback` function contains information about the caller: `{ browserContext: BrowserContext,
    # page: Page, frame: Frame }`.
    # 
    # See [`method: Page.exposeBinding`] for page-only version.
    # 
    # An example of exposing page URL to all frames in all pages in the context:
    # 
    #
    # ```js
    # const { webkit } = require('playwright');  // Or 'chromium' or 'firefox'.
    # 
    # (async () => {
    #   const browser = await webkit.launch({ headless: false });
    #   const context = await browser.newContext();
    #   await context.exposeBinding('pageURL', ({ page }) => page.url());
    #   const page = await context.newPage();
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
    #       BrowserType webkit = playwright.webkit()
    #       Browser browser = webkit.launch(new BrowserType.LaunchOptions().setHeadless(false));
    #       BrowserContext context = browser.newContext();
    #       context.exposeBinding("pageURL", (source, args) -> source.page().url());
    #       Page page = context.newPage();
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
    #     await context.expose_binding("pageURL", lambda source: source["page"].url)
    #     page = await context.new_page()
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
    #     context.expose_binding("pageURL", lambda source: source["page"].url)
    #     page = context.new_page()
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
    # An example of passing an element handle:
    # 
    #
    # ```js
    # await context.exposeBinding('clicked', async (source, element) => {
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
    # context.exposeBinding("clicked", (source, args) -> {
    #   ElementHandle element = (ElementHandle) args[0];
    #   System.out.println(element.textContent());
    #   return null;
    # }, new BrowserContext.ExposeBindingOptions().setHandle(true));
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
    # await context.expose_binding("clicked", print, handle=true)
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
    # context.expose_binding("clicked", print, handle=true)
    # page.set_content("""
    #   <script>
    #     document.addEventListener('click', event => window.clicked(event.target));
    #   </script>
    #   <div>Click me</div>
    #   <div>Or click me</div>
    # """)
    # ```
    def expose_binding(name, callback, handle: nil)
      wrap_impl(@impl.expose_binding(unwrap_impl(name), unwrap_impl(callback), handle: unwrap_impl(handle)))
    end

    # The method adds a function called `name` on the `window` object of every frame in every page in the context. When
    # called, the function executes `callback` and returns a [Promise] which resolves to the return value of `callback`.
    # 
    # If the `callback` returns a [Promise], it will be awaited.
    # 
    # See [`method: Page.exposeFunction`] for page-only version.
    # 
    # An example of adding an `md5` function to all pages in the context:
    # 
    #
    # ```js
    # const { webkit } = require('playwright');  // Or 'chromium' or 'firefox'.
    # const crypto = require('crypto');
    # 
    # (async () => {
    #   const browser = await webkit.launch({ headless: false });
    #   const context = await browser.newContext();
    #   await context.exposeFunction('md5', text => crypto.createHash('md5').update(text).digest('hex'));
    #   const page = await context.newPage();
    #   await page.setContent(`
    #     <script>
    #       async function onClick() {
    #         document.querySelector('div').textContent = await window.md5('PLAYWRIGHT');
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
    #       BrowserType webkit = playwright.webkit()
    #       Browser browser = webkit.launch(new BrowserType.LaunchOptions().setHeadless(false));
    #       context.exposeFunction("sha1", args -> {
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
    #       Page page = context.newPage();
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
    #     context = await browser.new_context()
    #     await context.expose_function("sha1", sha1)
    #     page = await context.new_page()
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
    #     context = browser.new_context()
    #     context.expose_function("sha1", sha1)
    #     page = context.new_page()
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
    def expose_function(name, callback)
      wrap_impl(@impl.expose_function(unwrap_impl(name), unwrap_impl(callback)))
    end

    # Grants specified permissions to the browser context. Only grants corresponding permissions to the given origin if
    # specified.
    def grant_permissions(permissions, origin: nil)
      wrap_impl(@impl.grant_permissions(unwrap_impl(permissions), origin: unwrap_impl(origin)))
    end

    # > NOTE: CDP sessions are only supported on Chromium-based browsers.
    # 
    # Returns the newly created session.
    def new_cdp_session(page)
      raise NotImplementedError.new('new_cdp_session is not implemented yet.')
    end

    # Creates a new page in the browser context.
    def new_page
      wrap_impl(@impl.new_page)
    end

    # Returns all open pages in the context.
    def pages
      wrap_impl(@impl.pages)
    end

    # Routing provides the capability to modify network requests that are made by any page in the browser context. Once route
    # is enabled, every request matching the url pattern will stall unless it's continued, fulfilled or aborted.
    # 
    # An example of a naive handler that aborts all image requests:
    # 
    #
    # ```js
    # const context = await browser.newContext();
    # await context.route('**/*.{png,jpg,jpeg}', route => route.abort());
    # const page = await context.newPage();
    # await page.goto('https://example.com');
    # await browser.close();
    # ```
    # 
    # ```java
    # BrowserContext context = browser.newContext();
    # context.route("**/*.{png,jpg,jpeg}", route -> route.abort());
    # Page page = context.newPage();
    # page.navigate("https://example.com");
    # browser.close();
    # ```
    # 
    # ```python async
    # context = await browser.new_context()
    # page = await context.new_page()
    # await context.route("**/*.{png,jpg,jpeg}", lambda route: route.abort())
    # await page.goto("https://example.com")
    # await browser.close()
    # ```
    # 
    # ```python sync
    # context = browser.new_context()
    # page = context.new_page()
    # context.route("**/*.{png,jpg,jpeg}", lambda route: route.abort())
    # page.goto("https://example.com")
    # browser.close()
    # ```
    # 
    # or the same snippet using a regex pattern instead:
    # 
    #
    # ```js
    # const context = await browser.newContext();
    # await context.route(/(\.png$)|(\.jpg$)/, route => route.abort());
    # const page = await context.newPage();
    # await page.goto('https://example.com');
    # await browser.close();
    # ```
    # 
    # ```java
    # BrowserContext context = browser.newContext();
    # context.route(Pattern.compile("(\\.png$)|(\\.jpg$)"), route -> route.abort());
    # Page page = context.newPage();
    # page.navigate("https://example.com");
    # browser.close();
    # ```
    # 
    # ```python async
    # context = await browser.new_context()
    # page = await context.new_page()
    # await context.route(re.compile(r"(\.png$)|(\.jpg$)"), lambda route: route.abort())
    # page = await context.new_page()
    # await page.goto("https://example.com")
    # await browser.close()
    # ```
    # 
    # ```python sync
    # context = browser.new_context()
    # page = context.new_page()
    # context.route(re.compile(r"(\.png$)|(\.jpg$)"), lambda route: route.abort())
    # page = await context.new_page()
    # page = context.new_page()
    # page.goto("https://example.com")
    # browser.close()
    # ```
    # 
    # Page routes (set up with [`method: Page.route`]) take precedence over browser context routes when request matches both
    # handlers.
    # 
    # To remove a route with its handler you can use [`method: BrowserContext.unroute`].
    # 
    # > NOTE: Enabling routing disables http cache.
    def route(url, handler)
      wrap_impl(@impl.route(unwrap_impl(url), unwrap_impl(handler)))
    end

    # > NOTE: Service workers are only supported on Chromium-based browsers.
    # 
    # All existing service workers in the context.
    def service_workers
      raise NotImplementedError.new('service_workers is not implemented yet.')
    end

    # This setting will change the default maximum navigation time for the following methods and related shortcuts:
    # - [`method: Page.goBack`]
    # - [`method: Page.goForward`]
    # - [`method: Page.goto`]
    # - [`method: Page.reload`]
    # - [`method: Page.setContent`]
    # - [`method: Page.waitForNavigation`]
    # 
    # > NOTE: [`method: Page.setDefaultNavigationTimeout`] and [`method: Page.setDefaultTimeout`] take priority over
    # [`method: BrowserContext.setDefaultNavigationTimeout`].
    def set_default_navigation_timeout(timeout)
      wrap_impl(@impl.set_default_navigation_timeout(unwrap_impl(timeout)))
    end
    alias_method :default_navigation_timeout=, :set_default_navigation_timeout

    # This setting will change the default maximum time for all the methods accepting `timeout` option.
    # 
    # > NOTE: [`method: Page.setDefaultNavigationTimeout`], [`method: Page.setDefaultTimeout`] and
    # [`method: BrowserContext.setDefaultNavigationTimeout`] take priority over [`method: BrowserContext.setDefaultTimeout`].
    def set_default_timeout(timeout)
      wrap_impl(@impl.set_default_timeout(unwrap_impl(timeout)))
    end
    alias_method :default_timeout=, :set_default_timeout

    # The extra HTTP headers will be sent with every request initiated by any page in the context. These headers are merged
    # with page-specific extra HTTP headers set with [`method: Page.setExtraHTTPHeaders`]. If page overrides a particular
    # header, page-specific header value will be used instead of the browser context header value.
    # 
    # > NOTE: [`method: BrowserContext.setExtraHTTPHeaders`] does not guarantee the order of headers in the outgoing requests.
    def set_extra_http_headers(headers)
      wrap_impl(@impl.set_extra_http_headers(unwrap_impl(headers)))
    end
    alias_method :extra_http_headers=, :set_extra_http_headers

    # Sets the context's geolocation. Passing `null` or `undefined` emulates position unavailable.
    # 
    #
    # ```js
    # await browserContext.setGeolocation({latitude: 59.95, longitude: 30.31667});
    # ```
    # 
    # ```java
    # browserContext.setGeolocation(new Geolocation(59.95, 30.31667));
    # ```
    # 
    # ```python async
    # await browser_context.set_geolocation({"latitude": 59.95, "longitude": 30.31667})
    # ```
    # 
    # ```python sync
    # browser_context.set_geolocation({"latitude": 59.95, "longitude": 30.31667})
    # ```
    # 
    # > NOTE: Consider using [`method: BrowserContext.grantPermissions`] to grant permissions for the browser context pages to
    # read its geolocation.
    def set_geolocation(geolocation)
      wrap_impl(@impl.set_geolocation(unwrap_impl(geolocation)))
    end
    alias_method :geolocation=, :set_geolocation

    def set_offline(offline)
      wrap_impl(@impl.set_offline(unwrap_impl(offline)))
    end
    alias_method :offline=, :set_offline

    # Returns storage state for this browser context, contains current cookies and local storage snapshot.
    def storage_state(path: nil)
      raise NotImplementedError.new('storage_state is not implemented yet.')
    end

    # Removes a route created with [`method: BrowserContext.route`]. When `handler` is not specified, removes all routes for
    # the `url`.
    def unroute(url, handler: nil)
      wrap_impl(@impl.unroute(unwrap_impl(url), handler: unwrap_impl(handler)))
    end

    # Waits for event to fire and passes its value into the predicate function. Returns when the predicate returns truthy
    # value. Will throw an error if the context closes before the event is fired. Returns the event data value.
    # 
    #
    # ```js
    # const [page, _] = await Promise.all([
    #   context.waitForEvent('page'),
    #   page.click('button')
    # ]);
    # ```
    # 
    # ```java
    # Page newPage = context.waitForPage(() -> page.click("button"));
    # ```
    # 
    # ```python async
    # async with context.expect_event("page") as event_info:
    #     await page.click("button")
    # page = await event_info.value
    # ```
    # 
    # ```python sync
    # with context.expect_event("page") as event_info:
    #     page.click("button")
    # page = event_info.value
    # ```
    def expect_event(event, predicate: nil, timeout: nil, &block)
      wrap_impl(@impl.expect_event(unwrap_impl(event), predicate: unwrap_impl(predicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    # Performs action and waits for a new `Page` to be created in the context. If predicate is provided, it passes `Page`
    # value into the `predicate` function and waits for `predicate(event)` to return a truthy value. Will throw an error if
    # the context closes before new `Page` is created.
    def expect_page(predicate: nil, timeout: nil)
      wrap_impl(@impl.expect_page(predicate: unwrap_impl(predicate), timeout: unwrap_impl(timeout)))
    end

    # > NOTE: In most cases, you should use [`method: BrowserContext.waitForEvent`].
    # 
    # Waits for given `event` to fire. If predicate is provided, it passes event's value into the `predicate` function and
    # waits for `predicate(event)` to return a truthy value. Will throw an error if the socket is closed before the `event` is
    # fired.
    def wait_for_event(event, predicate: nil, timeout: nil)
      raise NotImplementedError.new('wait_for_event is not implemented yet.')
    end

    # @nodoc
    def browser=(req)
      wrap_impl(@impl.browser=(unwrap_impl(req)))
    end

    # @nodoc
    def owner_page=(req)
      wrap_impl(@impl.owner_page=(unwrap_impl(req)))
    end

    # @nodoc
    def pause
      wrap_impl(@impl.pause)
    end

    # @nodoc
    def options=(req)
      wrap_impl(@impl.options=(unwrap_impl(req)))
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
