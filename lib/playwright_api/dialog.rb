module Playwright
  # `Dialog` objects are dispatched by page via the [`event: Page.dialog`] event.
  # 
  # An example of using `Dialog` class:
  # 
  #
  # ```js
  # const { chromium } = require('playwright');  // Or 'firefox' or 'webkit'.
  # 
  # (async () => {
  #   const browser = await chromium.launch();
  #   const page = await browser.newPage();
  #   page.on('dialog', async dialog => {
  #     console.log(dialog.message());
  #     await dialog.dismiss();
  #   });
  #   await page.evaluate(() => alert('1'));
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
  #       page.onDialog(dialog -> {
  #         System.out.println(dialog.message());
  #         dialog.dismiss();
  #       });
  #       page.evaluate("alert('1')");
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
  # async def handle_dialog(dialog):
  #     print(dialog.message)
  #     await dialog.dismiss()
  # 
  # async def run(playwright):
  #     chromium = playwright.chromium
  #     browser = await chromium.launch()
  #     page = await browser.new_page()
  #     page.on("dialog", handle_dialog)
  #     page.evaluate("alert('1')")
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
  # def handle_dialog(dialog):
  #     print(dialog.message)
  #     dialog.dismiss()
  # 
  # def run(playwright):
  #     chromium = playwright.chromium
  #     browser = chromium.launch()
  #     page = browser.new_page()
  #     page.on("dialog", handle_dialog)
  #     page.evaluate("alert('1')")
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
  # class DialogExample
  # {
  #     public static async Task Run()
  #     {
  #         using var playwright = await Playwright.CreateAsync();
  #         await using var browser = await playwright.Chromium.LaunchAsync();
  #         var page = await browser.NewPageAsync();
  # 
  #         page.Dialog += async (_, dialog) =>
  #         {
  #             System.Console.WriteLine(dialog.Message);
  #             await dialog.DismissAsync();
  #         };
  # 
  #         await page.EvaluateAsync("alert('1');");
  #     }
  # }
  # ```
  # 
  # > NOTE: Dialogs are dismissed automatically, unless there is a [`event: Page.dialog`] listener. When listener is
  # present, it **must** either [`method: Dialog.accept`] or [`method: Dialog.dismiss`] the dialog - otherwise the page will
  # [freeze](https://developer.mozilla.org/en-US/docs/Web/JavaScript/EventLoop#never_blocking) waiting for the dialog, and
  # actions like click will never finish.
  class Dialog < PlaywrightApi

    # Returns when the dialog has been accepted.
    def accept(promptText: nil)
      wrap_impl(@impl.accept(promptText: unwrap_impl(promptText)))
    end

    # If dialog is prompt, returns default prompt value. Otherwise, returns empty string.
    def default_value
      wrap_impl(@impl.default_value)
    end

    # Returns when the dialog has been dismissed.
    def dismiss
      wrap_impl(@impl.dismiss)
    end

    # A message displayed in the dialog.
    def message
      wrap_impl(@impl.message)
    end

    # Returns dialog's type, can be one of `alert`, `beforeunload`, `confirm` or `prompt`.
    def type
      wrap_impl(@impl.type)
    end

    # @nodoc
    def accept_async(promptText: nil)
      wrap_impl(@impl.accept_async(promptText: unwrap_impl(promptText)))
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
