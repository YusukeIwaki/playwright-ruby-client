require 'spec_helper'
require 'tmpdir'

RSpec.describe 'BrowserContext.route_from_har' do
  let(:har_fulfill) { File.join('spec', 'assets', 'har-fulfill.har') }

  it 'should context.routeFromHAR, matching the method and following redirects' do
    with_context do |context|
      context.route_from_har(har_fulfill)

      page = context.new_page
      page.goto('http://no.playwright/')
      # HAR contains a redirect for the script that should be followed automatically.
      expect(page.evaluate('window.value')).to eq('foo')
      # HAR contains a POST for the css file that should not be used.
      style = page.locator('body').evaluate("e => window.getComputedStyle(e).getPropertyValue('background-color')")
      expect(style).to eq('rgb(255, 0, 0)')
    end
  end

  it 'should page.routeFromHAR, matching the method and following redirects' do
    with_page do |page|
      page.route_from_har(har_fulfill)
      page.goto('http://no.playwright/')
      # HAR contains a redirect for the script that should be followed automatically.
      expect(page.evaluate('window.value')).to eq('foo')
      # HAR contains a POST for the css file that should not be used.
      style = page.locator('body').evaluate("e => window.getComputedStyle(e).getPropertyValue('background-color')")
      expect(style).to eq('rgb(255, 0, 0)')
    end
  end

  it 'fallback:continue should continue when not found in har', sinatra: true do
    with_context do |context|
      context.route_from_har(har_fulfill, notFound: 'fallback')

      page = context.new_page
      page.goto("#{server_prefix}/one-style.html")
      style = page.locator('body').evaluate("e => window.getComputedStyle(e).getPropertyValue('background-color')")
      expect(style).to eq('rgb(255, 192, 203)')
    end
  end

  it 'by default should abort requests not found in har', sinatra: true do
    with_context do |context|
      context.route_from_har(har_fulfill)

      page = context.new_page
      expect { page.goto(server_empty_page) }.to raise_error(::Playwright::Error)
    end
  end

  # it('fallback:continue should continue requests on bad har', async ({ context, server, isAndroid }, testInfo) => {
  #   it.fixme(isAndroid);

  #   const path = testInfo.outputPath('test.har');
  #   fs.writeFileSync(path, JSON.stringify({ log: {} }), 'utf-8');
  #   await context.routeFromHAR(path, { notFound: 'fallback' });
  #   const page = await context.newPage();
  #   await page.goto(server.PREFIX + '/one-style.html');
  #   await expect(page.locator('body')).toHaveCSS('background-color', 'rgb(255, 192, 203)');
  # });

  # it('should only handle requests matching url filter', async ({ context, isAndroid, asset }) => {
  #   it.fixme(isAndroid);

  #   const path = asset('har-fulfill.har');
  #   await context.routeFromHAR(path, { notFound: 'fallback', url: '**/*.js' });
  #   const page = await context.newPage();
  #   await context.route('http://no.playwright/', async route => {
  #     expect(route.request().url()).toBe('http://no.playwright/');
  #     await route.fulfill({
  #       status: 200,
  #       contentType: 'text/html',
  #       body: '<script src="./script.js"></script><div>hello</div>',
  #     });
  #   });
  #   await page.goto('http://no.playwright/');
  #   // HAR contains a redirect for the script that should be followed automatically.
  #   expect(await page.evaluate('window.value')).toBe('foo');
  #   await expect(page.locator('body')).toHaveCSS('background-color', 'rgba(0, 0, 0, 0)');
  # });

  # it('should only context.routeFromHAR requests matching url filter', async ({ context, isAndroid, asset }) => {
  #   it.fixme(isAndroid);

  #   const path = asset('har-fulfill.har');
  #   await context.routeFromHAR(path, { url: '**/*.js' });
  #   const page = await context.newPage();
  #   await context.route('http://no.playwright/', async route => {
  #     expect(route.request().url()).toBe('http://no.playwright/');
  #     await route.fulfill({
  #       status: 200,
  #       contentType: 'text/html',
  #       body: '<script src="./script.js"></script><div>hello</div>',
  #     });
  #   });
  #   await page.goto('http://no.playwright/');
  #   // HAR contains a redirect for the script that should be followed automatically.
  #   expect(await page.evaluate('window.value')).toBe('foo');
  #   await expect(page.locator('body')).toHaveCSS('background-color', 'rgba(0, 0, 0, 0)');
  # });

  # it('should only page.routeFromHAR requests matching url filter', async ({ context, isAndroid, asset }) => {
  #   it.fixme(isAndroid);

  #   const path = asset('har-fulfill.har');
  #   const page = await context.newPage();
  #   await page.routeFromHAR(path, { url: '**/*.js' });
  #   await context.route('http://no.playwright/', async route => {
  #     expect(route.request().url()).toBe('http://no.playwright/');
  #     await route.fulfill({
  #       status: 200,
  #       contentType: 'text/html',
  #       body: '<script src="./script.js"></script><div>hello</div>',
  #     });
  #   });
  #   await page.goto('http://no.playwright/');
  #   // HAR contains a redirect for the script that should be followed automatically.
  #   expect(await page.evaluate('window.value')).toBe('foo');
  #   await expect(page.locator('body')).toHaveCSS('background-color', 'rgba(0, 0, 0, 0)');
  # });

  # it('should support regex filter', async ({ context, isAndroid, asset }) => {
  #   it.fixme(isAndroid);

  #   const path = asset('har-fulfill.har');
  #   await context.routeFromHAR(path, { url: /.*(\.js|.*\.css|no.playwright\/)$/ });
  #   const page = await context.newPage();
  #   await page.goto('http://no.playwright/');
  #   expect(await page.evaluate('window.value')).toBe('foo');
  #   await expect(page.locator('body')).toHaveCSS('background-color', 'rgb(255, 0, 0)');
  # });

  # it('newPage should fulfill from har, matching the method and following redirects', async ({ browser, isAndroid, asset }) => {
  #   it.fixme(isAndroid);

  #   const path = asset('har-fulfill.har');
  #   const page = await browser.newPage();
  #   await page.routeFromHAR(path);
  #   await page.goto('http://no.playwright/');
  #   // HAR contains a redirect for the script that should be followed automatically.
  #   expect(await page.evaluate('window.value')).toBe('foo');
  #   // HAR contains a POST for the css file that should not be used.
  #   await expect(page.locator('body')).toHaveCSS('background-color', 'rgb(255, 0, 0)');
  #   await page.close();
  # });

  # it('should change document URL after redirected navigation', async ({ context, isAndroid, asset }) => {
  #   it.fixme(isAndroid);

  #   const path = asset('har-redirect.har');
  #   await context.routeFromHAR(path);
  #   const page = await context.newPage();
  #   const [response] = await Promise.all([
  #     page.waitForNavigation(),
  #     page.waitForURL('https://www.theverge.com/'),
  #     page.goto('https://theverge.com/')
  #   ]);
  #   await expect(page).toHaveURL('https://www.theverge.com/');
  #   expect(response.request().url()).toBe('https://www.theverge.com/');
  #   expect(await page.evaluate(() => location.href)).toBe('https://www.theverge.com/');
  # });

  # it('should change document URL after redirected navigation on click', async ({ server, context, isAndroid, asset }) => {
  #   it.fixme(isAndroid);

  #   const path = asset('har-redirect.har');
  #   await context.routeFromHAR(path, { url: /.*theverge.*/ });
  #   const page = await context.newPage();
  #   await page.goto(server.EMPTY_PAGE);
  #   await page.setContent(`<a href="https://theverge.com/">click me</a>`);
  #   const [response] = await Promise.all([
  #     page.waitForNavigation(),
  #     page.click('text=click me'),
  #   ]);
  #   await expect(page).toHaveURL('https://www.theverge.com/');
  #   expect(response.request().url()).toBe('https://www.theverge.com/');
  #   expect(await page.evaluate(() => location.href)).toBe('https://www.theverge.com/');
  # });

  # it('should goBack to redirected navigation', async ({ context, isAndroid, asset, server }) => {
  #   it.fixme(isAndroid);

  #   const path = asset('har-redirect.har');
  #   await context.routeFromHAR(path, { url: /.*theverge.*/ });
  #   const page = await context.newPage();
  #   await page.goto('https://theverge.com/');
  #   await page.goto(server.EMPTY_PAGE);
  #   await expect(page).toHaveURL(server.EMPTY_PAGE);
  #   const response = await page.goBack();
  #   await expect(page).toHaveURL('https://www.theverge.com/');
  #   expect(response.request().url()).toBe('https://www.theverge.com/');
  #   expect(await page.evaluate(() => location.href)).toBe('https://www.theverge.com/');
  # });

  # it('should goForward to redirected navigation', async ({ context, isAndroid, asset, server, browserName }) => {
  #   it.fixme(isAndroid);
  #   it.fixme(browserName === 'firefox', 'Flaky in firefox');

  #   const path = asset('har-redirect.har');
  #   await context.routeFromHAR(path, { url: /.*theverge.*/ });
  #   const page = await context.newPage();
  #   await page.goto(server.EMPTY_PAGE);
  #   await expect(page).toHaveURL(server.EMPTY_PAGE);
  #   await page.goto('https://theverge.com/');
  #   await expect(page).toHaveURL('https://www.theverge.com/');
  #   await page.goBack();
  #   await expect(page).toHaveURL(server.EMPTY_PAGE);
  #   const response = await page.goForward();
  #   await expect(page).toHaveURL('https://www.theverge.com/');
  #   expect(response.request().url()).toBe('https://www.theverge.com/');
  #   expect(await page.evaluate(() => location.href)).toBe('https://www.theverge.com/');
  # });

  # it('should reload redirected navigation', async ({ context, isAndroid, asset, server }) => {
  #   it.fixme(isAndroid);

  #   const path = asset('har-redirect.har');
  #   await context.routeFromHAR(path, { url: /.*theverge.*/ });
  #   const page = await context.newPage();
  #   await page.goto('https://theverge.com/');
  #   await expect(page).toHaveURL('https://www.theverge.com/');
  #   const response = await page.reload();
  #   await expect(page).toHaveURL('https://www.theverge.com/');
  #   expect(response.request().url()).toBe('https://www.theverge.com/');
  #   expect(await page.evaluate(() => location.href)).toBe('https://www.theverge.com/');
  # });

  # it('should fulfill from har with content in a file', async ({ context, isAndroid, asset }) => {
  #   it.fixme(isAndroid);

  #   const path = asset('har-sha1.har');
  #   await context.routeFromHAR(path);
  #   const page = await context.newPage();
  #   await page.goto('http://no.playwright/');
  #   expect(await page.content()).toBe('<html><head></head><body>Hello, world</body></html>');
  # });

  # it('should round-trip har.zip', async ({ contextFactory, isAndroid, server }, testInfo) => {
  #   it.fixme(isAndroid);

  #   const harPath = testInfo.outputPath('har.zip');
  #   const context1 = await contextFactory({ recordHar: { mode: 'minimal', path: harPath } });
  #   const page1 = await context1.newPage();
  #   await page1.goto(server.PREFIX + '/one-style.html');
  #   await context1.close();

  #   const context2 = await contextFactory();
  #   await context2.routeFromHAR(harPath, { notFound: 'abort' });
  #   const page2 = await context2.newPage();
  #   await page2.goto(server.PREFIX + '/one-style.html');
  #   expect(await page2.content()).toContain('hello, world!');
  #   await expect(page2.locator('body')).toHaveCSS('background-color', 'rgb(255, 192, 203)');
  # });

  it 'should produce extracted zip', sinatra: true do
    Dir.mktmpdir do |dir|
      har_path = File.join(dir, 'one-style.har')

      options = {
        record_har_mode: 'minimal',
        record_har_path: har_path,
        record_har_content: 'attach',
      }
      with_context(**options) do |context|
        context.route_from_har(har_path, update: true)
        page = context.new_page
        page.goto("#{server_prefix}/one-style.html")
      end

      with_context do |context|
        context.route_from_har(har_path, notFound: 'abort')
        page = context.new_page
        page.goto("#{server_prefix}/one-style.html")

        style = page.locator('body').evaluate("e => window.getComputedStyle(e).getPropertyValue('background-color')")
        expect(style).to eq('rgb(255, 192, 203)')
      end
    end
  end

  # it('should round-trip extracted har.zip', async ({ contextFactory, isAndroid, server }, testInfo) => {
  #   it.fixme(isAndroid);

  #   const harPath = testInfo.outputPath('har.zip');
  #   const context1 = await contextFactory({ recordHar: { mode: 'minimal', path: harPath } });
  #   const page1 = await context1.newPage();
  #   await page1.goto(server.PREFIX + '/one-style.html');
  #   await context1.close();

  #   const harDir = testInfo.outputPath('hardir');
  #   await extractZip(harPath, { dir: harDir });

  #   const context2 = await contextFactory();
  #   await context2.routeFromHAR(path.join(harDir, 'har.har'));
  #   const page2 = await context2.newPage();
  #   await page2.goto(server.PREFIX + '/one-style.html');
  #   expect(await page2.content()).toContain('hello, world!');
  #   await expect(page2.locator('body')).toHaveCSS('background-color', 'rgb(255, 192, 203)');
  # });

  # it('should round-trip har with postData', async ({ contextFactory, isAndroid, server }, testInfo) => {
  #   it.fixme(isAndroid);
  #   server.setRoute('/echo', async (req, res) => {
  #     const body = await req.postBody;
  #     res.end(body.toString());
  #   });

  #   const harPath = testInfo.outputPath('har.zip');
  #   const context1 = await contextFactory({ recordHar: { mode: 'minimal', path: harPath } });
  #   const page1 = await context1.newPage();
  #   await page1.goto(server.EMPTY_PAGE);
  #   const fetchFunction = async (body: string) => {
  #     const response = await fetch('/echo', { method: 'POST', body });
  #     return await response.text();
  #   };

  #   expect(await page1.evaluate(fetchFunction, '1')).toBe('1');
  #   expect(await page1.evaluate(fetchFunction, '2')).toBe('2');
  #   expect(await page1.evaluate(fetchFunction, '3')).toBe('3');
  #   await context1.close();

  #   const context2 = await contextFactory();
  #   await context2.routeFromHAR(harPath);
  #   const page2 = await context2.newPage();
  #   await page2.goto(server.EMPTY_PAGE);
  #   expect(await page2.evaluate(fetchFunction, '1')).toBe('1');
  #   expect(await page2.evaluate(fetchFunction, '2')).toBe('2');
  #   expect(await page2.evaluate(fetchFunction, '3')).toBe('3');
  #   expect(await page2.evaluate(fetchFunction, '4').catch(e => e)).toBeTruthy();
  # });

  # it('should disambiguate by header', async ({ contextFactory, isAndroid, server }, testInfo) => {
  #   it.fixme(isAndroid);

  #   server.setRoute('/echo', async (req, res) => {
  #     res.end(req.headers['baz']);
  #   });

  #   const harPath = testInfo.outputPath('har.zip');
  #   const context1 = await contextFactory({ recordHar: { mode: 'minimal', path: harPath } });
  #   const page1 = await context1.newPage();
  #   await page1.goto(server.EMPTY_PAGE);

  #   const fetchFunction = async (bazValue: string) => {
  #     const response = await fetch('/echo', {
  #       method: 'POST',
  #       body: '',
  #       headers: {
  #         foo: 'foo-value',
  #         bar: 'bar-value',
  #         baz: bazValue,
  #       }
  #     });
  #     return await response.text();
  #   };

  #   expect(await page1.evaluate(fetchFunction, 'baz1')).toBe('baz1');
  #   expect(await page1.evaluate(fetchFunction, 'baz2')).toBe('baz2');
  #   expect(await page1.evaluate(fetchFunction, 'baz3')).toBe('baz3');
  #   await context1.close();

  #   const context2 = await contextFactory();
  #   await context2.routeFromHAR(harPath);
  #   const page2 = await context2.newPage();
  #   await page2.goto(server.EMPTY_PAGE);
  #   expect(await page2.evaluate(fetchFunction, 'baz1')).toBe('baz1');
  #   expect(await page2.evaluate(fetchFunction, 'baz2')).toBe('baz2');
  #   expect(await page2.evaluate(fetchFunction, 'baz3')).toBe('baz3');
  #   expect(await page2.evaluate(fetchFunction, 'baz4')).toBe('baz1');
  # });

  it 'should update har.zip for context', sinatra: true do
    Dir.mktmpdir do |dir|
      har_path = File.join(dir, 'one-style.zip')

      with_context do |context|
        context.route_from_har(har_path, update: true)
        page = context.new_page
        page.goto("#{server_prefix}/one-style.html")
      end

      with_context do |context|
        context.route_from_har(har_path, notFound: 'abort')
        page = context.new_page
        page.goto("#{server_prefix}/one-style.html")

        style = page.locator('body').evaluate("e => window.getComputedStyle(e).getPropertyValue('background-color')")
        expect(style).to eq('rgb(255, 192, 203)')
      end
    end
  end

  it 'should update har.zip for page', sinatra: true do
    Dir.mktmpdir do |dir|
      har_path = File.join(dir, 'one-style.zip')

      with_page do |page|
        page.route_from_har(har_path, update: true)
        page.goto("#{server_prefix}/one-style.html")
      end

      with_page do |page|
        page.route_from_har(har_path, notFound: 'abort')
        page.goto("#{server_prefix}/one-style.html")

        expect(page.content).to include('hello, world!')
        style = page.locator('body').evaluate("e => window.getComputedStyle(e).getPropertyValue('background-color')")
        expect(style).to eq('rgb(255, 192, 203)')
      end
    end
  end

  it 'should update har.zip for page with different options', sinatra: true do
    Dir.mktmpdir do |dir|
      har_path = File.join(dir, 'one-style.zip')

      with_page do |page|
        page.route_from_har(har_path, update: true, updateContent: 'embed', updateMode: 'full')
        page.goto("#{server_prefix}/one-style.html")
      end

      with_page do |page|
        page.route_from_har(har_path, notFound: 'abort')
        page.goto("#{server_prefix}/one-style.html")

        expect(page.content).to include('hello, world!')
        style = page.locator('body').evaluate("e => window.getComputedStyle(e).getPropertyValue('background-color')")
        expect(style).to eq('rgb(255, 192, 203)')
      end
    end
  end

  it 'should update extracted har.zip for page', sinatra: true do
    Dir.mktmpdir do |dir|
      har_path = File.join(dir, 'one-style.har')

      with_page do |page|
        page.route_from_har(har_path, update: true)
        page.goto("#{server_prefix}/one-style.html")
      end

      with_page do |page|
        page.route_from_har(har_path, notFound: 'abort')
        page.goto("#{server_prefix}/one-style.html")

        expect(page.content).to include('hello, world!')
        style = page.locator('body').evaluate("e => window.getComputedStyle(e).getPropertyValue('background-color')")
        expect(style).to eq('rgb(255, 192, 203)')
      end
    end
  end
end
