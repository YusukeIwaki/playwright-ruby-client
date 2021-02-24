require 'spec_helper'

RSpec.describe Playwright::BrowserContext do
  it 'should create new context' do
    expect(browser.contexts).to be_empty
    with_context do |context|
      expect(browser.contexts.count).to eq(1)
      expect(browser.contexts.first).to eq(context)
      expect(browser).to eq(context.browser)
    end
    expect(browser.contexts).to be_empty
  end

  it 'window.open should use parent tab context', sinatra: true do
    with_context do |context|
      page = context.new_page
      page.goto(server_empty_page)
      popup = page.expect_popup do
        page.evaluate('url => window.open(url)', arg: server_empty_page)
      end
      expect(popup.context).to eq(context)
    end
  end

  # it('should isolate localStorage and cookies', async function({browser, server}) {
  #   // Create two incognito contexts.
  #   const context1 = await browser.newContext();
  #   const context2 = await browser.newContext();
  #   expect(context1.pages().length).toBe(0);
  #   expect(context2.pages().length).toBe(0);

  #   // Create a page in first incognito context.
  #   const page1 = await context1.newPage();
  #   await page1.goto(server.EMPTY_PAGE);
  #   await page1.evaluate(() => {
  #     localStorage.setItem('name', 'page1');
  #     document.cookie = 'name=page1';
  #   });

  #   expect(context1.pages().length).toBe(1);
  #   expect(context2.pages().length).toBe(0);

  #   // Create a page in second incognito context.
  #   const page2 = await context2.newPage();
  #   await page2.goto(server.EMPTY_PAGE);
  #   await page2.evaluate(() => {
  #     localStorage.setItem('name', 'page2');
  #     document.cookie = 'name=page2';
  #   });

  #   expect(context1.pages().length).toBe(1);
  #   expect(context2.pages().length).toBe(1);
  #   expect(context1.pages()[0]).toBe(page1);
  #   expect(context2.pages()[0]).toBe(page2);

  #   // Make sure pages don't share localstorage or cookies.
  #   expect(await page1.evaluate(() => localStorage.getItem('name'))).toBe('page1');
  #   expect(await page1.evaluate(() => document.cookie)).toBe('name=page1');
  #   expect(await page2.evaluate(() => localStorage.getItem('name'))).toBe('page2');
  #   expect(await page2.evaluate(() => document.cookie)).toBe('name=page2');

  #   // Cleanup contexts.
  #   await Promise.all([
  #     context1.close(),
  #     context2.close()
  #   ]);
  #   expect(browser.contexts().length).toBe(0);
  # });

  it 'should propagate default viewport to the page' do
    with_context(viewport: { width: 456, height: 789 }) do |context|
      page = context.new_page
      expect(page.viewport_size).to eq({ width: 456, height: 789 })
    end
  end

  it 'should make a copy of default viewport' do
    viewport = { width: 456, height: 789 }
    with_context(viewport: viewport) do |context|
      viewport[:width] = 567
      page = context.new_page
      expect(page.viewport_size).to eq({ width: 456, height: 789 })
    end
  end

  # it('should respect deviceScaleFactor', async ({ browser }) => {
  #   const context = await browser.newContext({ deviceScaleFactor: 3 });
  #   const page = await context.newPage();
  #   expect(await page.evaluate('window.devicePixelRatio')).toBe(3);
  #   await context.close();
  # });

  # it('should not allow deviceScaleFactor with null viewport', async ({ browser }) => {
  #   const error = await browser.newContext({ viewport: null, deviceScaleFactor: 1 }).catch(e => e);
  #   expect(error.message).toContain('"deviceScaleFactor" option is not supported with null "viewport"');
  # });

  # it('should not allow isMobile with null viewport', async ({ browser }) => {
  #   const error = await browser.newContext({ viewport: null, isMobile: true }).catch(e => e);
  #   expect(error.message).toContain('"isMobile" option is not supported with null "viewport"');
  # });

  # it('close() should work for empty context', async ({ browser }) => {
  #   const context = await browser.newContext();
  #   await context.close();
  # });

  # it('close() should abort waitForEvent', async ({ browser }) => {
  #   const context = await browser.newContext();
  #   const promise = context.waitForEvent('page').catch(e => e);
  #   await context.close();
  #   const error = await promise;
  #   expect(error.message).toContain('Context closed');
  # });

  # it('close() should be callable twice', async ({browser}) => {
  #   const context = await browser.newContext();
  #   await Promise.all([
  #     context.close(),
  #     context.close(),
  #   ]);
  #   await context.close();
  # });

  # it('should pass self to close event', async ({browser}) => {
  #   const newContext = await browser.newContext();
  #   const [closedContext] = await Promise.all([
  #     newContext.waitForEvent('close'),
  #     newContext.close()
  #   ]);
  #   expect(closedContext).toBe(newContext);
  # });

  # it('should not report frameless pages on error', async ({browser, server}) => {
  #   const context = await browser.newContext();
  #   const page = await context.newPage();
  #   server.setRoute('/empty.html', (req, res) => {
  #     res.end(`<a href="${server.EMPTY_PAGE}" target="_blank">Click me</a>`);
  #   });
  #   let popup;
  #   context.on('page', p => popup = p);
  #   await page.goto(server.EMPTY_PAGE);
  #   await page.click('"Click me"');
  #   await context.close();
  #   if (popup) {
  #     // This races on Firefox :/
  #     expect(popup.isClosed()).toBeTruthy();
  #     expect(popup.mainFrame()).toBeTruthy();
  #   }
  # });

  # it('should return all of the pages', async ({browser, server}) => {
  #   const context = await browser.newContext();
  #   const page = await context.newPage();
  #   const second = await context.newPage();
  #   const allPages = context.pages();
  #   expect(allPages.length).toBe(2);
  #   expect(allPages).toContain(page);
  #   expect(allPages).toContain(second);
  #   await context.close();
  # });

  # it('should close all belonging pages once closing context', async function({browser}) {
  #   const context = await browser.newContext();
  #   await context.newPage();
  #   expect(context.pages().length).toBe(1);

  #   await context.close();
  #   expect(context.pages().length).toBe(0);
  # });

  # it('should disable javascript', async ({browser, isWebKit}) => {
  #   {
  #     const context = await browser.newContext({ javaScriptEnabled: false });
  #     const page = await context.newPage();
  #     await page.goto('data:text/html, <script>var something = "forbidden"</script>');
  #     let error = null;
  #     await page.evaluate('something').catch(e => error = e);
  #     if (isWebKit)
  #       expect(error.message).toContain('Can\'t find variable: something');
  #     else
  #       expect(error.message).toContain('something is not defined');
  #     await context.close();
  #   }

  #   {
  #     const context = await browser.newContext();
  #     const page = await context.newPage();
  #     await page.goto('data:text/html, <script>var something = "forbidden"</script>');
  #     expect(await page.evaluate('something')).toBe('forbidden');
  #     await context.close();
  #   }
  # });

  # it('should be able to navigate after disabling javascript', async ({browser, server}) => {
  #   const context = await browser.newContext({ javaScriptEnabled: false });
  #   const page = await context.newPage();
  #   await page.goto(server.EMPTY_PAGE);
  #   await context.close();
  # });

  # it('should work with offline option', async ({browser, server}) => {
  #   const context = await browser.newContext({offline: true});
  #   const page = await context.newPage();
  #   let error = null;
  #   await page.goto(server.EMPTY_PAGE).catch(e => error = e);
  #   expect(error).toBeTruthy();
  #   await context.setOffline(false);
  #   const response = await page.goto(server.EMPTY_PAGE);
  #   expect(response.status()).toBe(200);
  #   await context.close();
  # });

  it 'should emulate navigator.onLine' do
    with_context do |context|
      page = context.new_page
      expect(page.evaluate('() => window.navigator.onLine')).to eq(true)
      context.offline = true
      expect(page.evaluate('() => window.navigator.onLine')).to eq(false)
      context.offline = false
      expect(page.evaluate('() => window.navigator.onLine')).to eq(true)
    end
  end
end
