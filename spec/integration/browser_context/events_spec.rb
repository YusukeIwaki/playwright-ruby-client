require 'spec_helper'

RSpec.describe 'BrowserContext events' do
  before { skip unless chromium? }

  it 'console event should work @smoke' do
    with_page do |page|
      message = page.context.expect_event('console') do
        page.evaluate('() => console.log("hello")')
      end

      expect(message.text).to eq('hello')
      expect(message.page).to eq(page)
    end
  end

  # test('console event should work in popup', async ({ page }) => {
  #   const [, message, popup] = await Promise.all([
  #     page.evaluate(() => {
  #       const win = window.open('');
  #       (win as any).console.log('hello');
  #     }),
  #     page.context().waitForEvent('console'),
  #     page.waitForEvent('popup'),
  #   ]);

  #   expect(message.text()).toBe('hello');
  #   expect(message.page()).toBe(popup);
  # });

  # test('console event should work in popup 2', async ({ page, browserName }) => {
  #   test.fixme(browserName === 'firefox', 'console message from javascript: url is not reported at all');

  #   const [, message, popup] = await Promise.all([
  #     page.evaluate(async () => {
  #       const win = window.open('javascript:console.log("hello")');
  #       await new Promise(f => setTimeout(f, 0));
  #       win.close();
  #     }),
  #     page.context().waitForEvent('console', msg => msg.type() === 'log'),
  #     page.context().waitForEvent('page'),
  #   ]);

  #   expect(message.text()).toBe('hello');
  #   expect(message.page()).toBe(popup);
  # });

  # test('console event should work in immediately closed popup', async ({ page, browserName }) => {
  #   test.fixme(browserName === 'firefox', 'console message is not reported at all');

  #   const [, message, popup] = await Promise.all([
  #     page.evaluate(async () => {
  #       const win = window.open();
  #       (win as any).console.log('hello');
  #       win.close();
  #     }),
  #     page.context().waitForEvent('console'),
  #     page.waitForEvent('popup'),
  #   ]);

  #   expect(message.text()).toBe('hello');
  #   expect(message.page()).toBe(popup);
  # });

  it 'dialog event should work @smoke' do
    with_page do |page|
      promise = Concurrent::Promises.resolvable_future
      dialog = page.context.expect_event('dialog') do
        Concurrent::Promises.future {
          promise.fulfill(page.evaluate('() => prompt("hey?")'))
        }
      end

      expect(dialog.message).to eq('hey?')
      expect(dialog.page).to eq(page)
      dialog.accept(promptText: 'hello')
      expect(promise.value!).to eq('hello')
    end
  end

  # test('dialog event should work in popup', async ({ page }) => {
  #   const promise = page.evaluate(() => {
  #     const win = window.open('');
  #     return (win as any).prompt('hey?');
  #   });

  #   const [dialog, popup] = await Promise.all([
  #     page.context().waitForEvent('dialog'),
  #     page.waitForEvent('popup'),
  #   ]);

  #   expect(dialog.message()).toBe('hey?');
  #   expect(dialog.page()).toBe(popup);
  #   await dialog.accept('hello');
  #   expect(await promise).toBe('hello');
  # });

  # test('dialog event should work in popup 2', async ({ page, browserName }) => {
  #   test.fixme(browserName === 'firefox', 'dialog from javascript: url is not reported at all');

  #   const promise = page.evaluate(async () => {
  #     window.open('javascript:prompt("hey?")');
  #   });

  #   const dialog = await page.context().waitForEvent('dialog');

  #   expect(dialog.message()).toBe('hey?');
  #   expect(dialog.page()).toBe(null);
  #   await dialog.accept('hello');
  #   await promise;
  # });

  # test('dialog event should work in immdiately closed popup', async ({ page }) => {
  #   const promise = page.evaluate(async () => {
  #     const win = window.open();
  #     const result = (win as any).prompt('hey?');
  #     win.close();
  #     return result;
  #   });

  #   const [dialog, popup] = await Promise.all([
  #     page.context().waitForEvent('dialog'),
  #     page.waitForEvent('popup'),
  #   ]);

  #   expect(dialog.message()).toBe('hey?');
  #   expect(dialog.page()).toBe(popup);
  #   await dialog.accept('hello');
  #   expect(await promise).toBe('hello');
  # });

  # test('dialog event should work with inline script tag', async ({ page, server }) => {
  #   server.setRoute('/popup.html', (req, res) => {
  #     res.setHeader('content-type', 'text/html');
  #     res.end(`<script>window.result = prompt('hey?')</script>`);
  #   });

  #   await page.goto(server.EMPTY_PAGE);
  #   await page.setContent(`<a href='popup.html' target=_blank>Click me</a>`);

  #   const promise = page.click('a');
  #   const [dialog, popup] = await Promise.all([
  #     page.context().waitForEvent('dialog'),
  #     page.context().waitForEvent('page'),
  #   ]);

  #   expect(dialog.message()).toBe('hey?');
  #   expect(dialog.page()).toBe(popup);
  #   await dialog.accept('hello');
  #   await promise;
  #   await expect.poll(() => popup.evaluate('window.result')).toBe('hello');
  # });

  it 'weberror event should work' do
    with_page do |page|
      error = page.context.expect_event('weberror') do
        page.content = '<script>throw new Error("boom")</script>'
      end

      expect(error.page).to eq(page)
      expect(error.error).to be_a(Playwright::Error)
      expect(error.error.stack).to include('boom')
    end
  end
end
