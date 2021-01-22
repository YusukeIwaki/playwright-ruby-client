require 'spec_helper'

RSpec.describe Playwright::Page do
  it 'should reject all promises when page is closed' do
    with_page do |page|
      never_resolved_promise = Concurrent::Promises.future { page.evaluate('() => new Promise(r => {})') }
      page.close
      expect { never_resolved_promise.value! }.to raise_error(/Protocol error/)
    end
  end

  it 'should not be visible in context.pages' do
    with_context do |context|
      page = context.new_page
      expect(context.pages).to include(page)
      expect { page.close }.to change { context.pages.count }.by(-1)
      expect(context.pages).not_to include(page)
    end
  end

  it 'should set the page close state' do
    with_page do |page|
      expect { page.close }.to change { page.closed? }.from(false).to(true)
    end
  end

  it 'should terminate network waiters' do
    with_page do |page|
      request_promise = Concurrent::Promises.future { page.wait_for_request('http://example.com/') }
      response_promise = Concurrent::Promises.future { page.wait_for_response('http://example.com/') }
      page.close
      expect { request_promise.value! }.to raise_error(/Page closed/)
      expect { response_promise.value! }.to raise_error(/Page closed/)
    end
  end

  it 'should be callable twice' do
    with_page do |page|
      expect {
        page.close
        page.close
        page.close
      }.not_to raise_error
    end
  end

  it 'should fire load when expected' do
    with_page do |page|
      promise = Concurrent::Promises.future { page.wait_for_event('load') }
      page.goto('about:blank')
      expect(promise).to be_fulfilled
    end
  end

#   it('async stacks should work', async ({page, server}) => {
#     server.setRoute('/empty.html', (req, res) => {
#       req.socket.end();
#     });
#     let error = null;
#     await page.goto(server.EMPTY_PAGE).catch(e => error = e);
#     expect(error).not.toBe(null);
#     expect(error.stack).toContain(__filename);
#   });

#   it('should provide access to the opener page', async ({page}) => {
#     const [popup] = await Promise.all([
#       page.waitForEvent('popup'),
#       page.evaluate(() => window.open('about:blank')),
#     ]);
#     const opener = await popup.opener();
#     expect(opener).toBe(page);
#   });

#   it('should return null if parent page has been closed', async ({page}) => {
#     const [popup] = await Promise.all([
#       page.waitForEvent('popup'),
#       page.evaluate(() => window.open('about:blank')),
#     ]);
#     await page.close();
#     const opener = await popup.opener();
#     expect(opener).toBe(null);
#   });

#   it('should fire domcontentloaded when expected', async ({page, server}) => {
#     const navigatedPromise = page.goto('about:blank');
#     await page.waitForEvent('domcontentloaded');
#     await navigatedPromise;
#   });

#   it('should fail with error upon disconnect', async ({page, server}) => {
#     let error;
#     const waitForPromise = page.waitForEvent('download').catch(e => error = e);
#     await page.close();
#     await waitForPromise;
#     expect(error.message).toContain('Page closed');
#   });

#   it('page.url should work', async ({page, server}) => {
#     expect(page.url()).toBe('about:blank');
#     await page.goto(server.EMPTY_PAGE);
#     expect(page.url()).toBe(server.EMPTY_PAGE);
#   });

#   it('page.url should include hashes', async ({page, server}) => {
#     await page.goto(server.EMPTY_PAGE + '#hash');
#     expect(page.url()).toBe(server.EMPTY_PAGE + '#hash');
#     await page.evaluate(() => {
#       window.location.hash = 'dynamic';
#     });
#     expect(page.url()).toBe(server.EMPTY_PAGE + '#dynamic');
#   });

#   it('page.title should return the page title', async ({page, server}) => {
#     await page.goto(server.PREFIX + '/title.html');
#     expect(await page.title()).toBe('Woof-Woof');
#   });

#   it('page.close should work with window.close', async function({ page, context, server }) {
#     const newPagePromise = page.waitForEvent('popup');
#     await page.evaluate(() => window['newPage'] = window.open('about:blank'));
#     const newPage = await newPagePromise;
#     const closedPromise = new Promise(x => newPage.on('close', x));
#     await page.evaluate(() => window['newPage'].close());
#     await closedPromise;
#   });

#   it('page.close should work with page.close', async function({ page, context, server }) {
#     const newPage = await context.newPage();
#     const closedPromise = new Promise(x => newPage.on('close', x));
#     await newPage.close();
#     await closedPromise;
#   });

#   it('page.context should return the correct instance', async function({page, context}) {
#     expect(page.context()).toBe(context);
#   });

#   it('page.frame should respect name', async function({page, server}) {
#     await page.setContent(`<iframe name=target></iframe>`);
#     expect(page.frame({ name: 'bogus' })).toBe(null);
#     const frame = page.frame({ name: 'target' });
#     expect(frame).toBeTruthy();
#     expect(frame === page.mainFrame().childFrames()[0]).toBeTruthy();
#   });

#   it('page.frame should respect url', async function({page, server}) {
#     await page.setContent(`<iframe src="${server.EMPTY_PAGE}"></iframe>`);
#     expect(page.frame({ url: /bogus/ })).toBe(null);
#     expect(page.frame({ url: /empty/ }).url()).toBe(server.EMPTY_PAGE);
#   });

#   it('should have sane user agent', async ({page, isChromium, isFirefox}) => {
#     const userAgent = await page.evaluate(() => navigator.userAgent);
#     const [
#       part1,
#       /* part2 */,
#       part3,
#       part4,
#       part5,
#     ] = userAgent.split(/[()]/).map(part => part.trim());
#     // First part is always "Mozilla/5.0"
#     expect(part1).toBe('Mozilla/5.0');
#     // Second part in parenthesis is platform - ignore it.

#     // Third part for Firefox is the last one and encodes engine and browser versions.
#     if (isFirefox) {
#       const [engine, browser] = part3.split(' ');
#       expect(engine.startsWith('Gecko')).toBe(true);
#       expect(browser.startsWith('Firefox')).toBe(true);
#       expect(part4).toBe(undefined);
#       expect(part5).toBe(undefined);
#       return;
#     }
#     // For both options.CHROMIUM and options.WEBKIT, third part is the AppleWebKit version.
#     expect(part3.startsWith('AppleWebKit/')).toBe(true);
#     expect(part4).toBe('KHTML, like Gecko');
#     // 5th part encodes real browser name and engine version.
#     const [engine, browser] = part5.split(' ');
#     expect(browser.startsWith('Safari/')).toBe(true);
#     if (isChromium)
#       expect(engine.includes('Chrome/')).toBe(true);
#     else
#       expect(engine.startsWith('Version/')).toBe(true);
#   });

  it 'page.press should work', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/textarea.html")
      page.press('textarea', 'a')
      expect(page.evaluate("() => document.querySelector('textarea').value")).to eq('a')
    end
  end

  it 'page.press should work for Enter' do
    with_page do |page|
      page.content = <<~HTML
      <input onkeypress="console.log('press')"></input>
      HTML
      messages = []
      page.on('console', ->(message) { messages << message })
      page.press('input', 'Enter')
      expect(messages.count).to eq(1)
      expect(messages.first.text).to eq('press')
    end
  end

  it 'frame.press should work', sinatra: true do
    with_page do |page|
      page.content = <<~HTML
      <iframe name=inner src="#{server_prefix}/input/textarea.html"></iframe>
      HTML
      frame = page.frame('inner')
      frame.press('textarea', 'a')
      expect(frame.evaluate("() => document.querySelector('textarea').value")).to eq('a')
    end
  end

  it 'frame.focus should work multiple times' do
    with_context do |context|
      pages = [context.new_page, context.new_page]
      pages.each do |page|
        page.content = '<button id="foo" onfocus="window.gotFocus=true"></button>'
        page.focus('#foo')
        expect(page.evaluate("() => !!window['gotFocus']")).to eq(true)
      end
    end
  end
end
