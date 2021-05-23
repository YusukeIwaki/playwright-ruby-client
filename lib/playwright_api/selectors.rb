module Playwright
  # Selectors can be used to install custom selector engines. See [Working with selectors](./selectors.md) for more
  # information.
  class Selectors < PlaywrightApi

    # An example of registering selector engine that queries elements based on a tag name:
    # 
    #
    # ```js
    # const { selectors, firefox } = require('playwright');  // Or 'chromium' or 'webkit'.
    # 
    # (async () => {
    #   // Must be a function that evaluates to a selector engine instance.
    #   const createTagNameEngine = () => ({
    #     // Returns the first element matching given selector in the root's subtree.
    #     query(root, selector) {
    #       return root.querySelector(selector);
    #     },
    # 
    #     // Returns all elements matching given selector in the root's subtree.
    #     queryAll(root, selector) {
    #       return Array.from(root.querySelectorAll(selector));
    #     }
    #   });
    # 
    #   // Register the engine. Selectors will be prefixed with "tag=".
    #   await selectors.register('tag', createTagNameEngine);
    # 
    #   const browser = await firefox.launch();
    #   const page = await browser.newPage();
    #   await page.setContent(`<div><button>Click me</button></div>`);
    # 
    #   // Use the selector prefixed with its name.
    #   const button = await page.$('tag=button');
    #   // Combine it with other selector engines.
    #   await page.click('tag=div >> text="Click me"');
    #   // Can use it in any methods supporting selectors.
    #   const buttonCount = await page.$$eval('tag=button', buttons => buttons.length);
    # 
    #   await browser.close();
    # })();
    # ```
    # 
    # ```java
    # // Script that evaluates to a selector engine instance.
    # String createTagNameEngine = "{\n" +
    #   "  // Returns the first element matching given selector in the root's subtree.\n" +
    #   "  query(root, selector) {\n" +
    #   "    return root.querySelector(selector);\n" +
    #   "  },\n" +
    #   "  // Returns all elements matching given selector in the root's subtree.\n" +
    #   "  queryAll(root, selector) {\n" +
    #   "    return Array.from(root.querySelectorAll(selector));\n" +
    #   "  }\n" +
    #   "}";
    # // Register the engine. Selectors will be prefixed with "tag=".
    # playwright.selectors().register("tag", createTagNameEngine);
    # Browser browser = playwright.firefox().launch();
    # Page page = browser.newPage();
    # page.setContent("<div><button>Click me</button></div>");
    # // Use the selector prefixed with its name.
    # ElementHandle button = page.querySelector("tag=button");
    # // Combine it with other selector engines.
    # page.click("tag=div >> text=\"Click me\"");
    # // Can use it in any methods supporting selectors.
    # int buttonCount = (int) page.evalOnSelectorAll("tag=button", "buttons => buttons.length");
    # browser.close();
    # ```
    # 
    # ```python async
    # # FIXME: add snippet
    # ```
    # 
    # ```python sync
    # # FIXME: add snippet
    # ```
    def register(name, contentScript: nil, path: nil, script: nil)
      wrap_impl(@impl.register(unwrap_impl(name), contentScript: unwrap_impl(contentScript), path: unwrap_impl(path), script: unwrap_impl(script)))
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
