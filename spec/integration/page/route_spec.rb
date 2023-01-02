require 'spec_helper'

RSpec.describe 'Page#route', sinatra: true do
  it 'should intercept' do
    with_page do |page|
      intercepted = false
      promise = Concurrent::Promises.resolvable_future
      request_frame_url = nil
      page.route('**/empty.html', ->(route, request) {
        promise.fulfill(request)
        request_frame_url = request.frame.url
        route.continue
      })

      response = page.goto(server_empty_page)
      expect(response.ok?).to eq(true)

      req = promise.value!
      expect(req.url).to include('empty.html')
      expect(req.headers['user-agent']).to be_a(String)
      expect(req.method).to eq('GET')
      expect(req.post_data).to be_nil
      expect(req.navigation_request?).to eq(true)
      expect(req.resource_type).to eq('document')
      expect(req.frame).to eq(page.main_frame)
      expect(request_frame_url).to eq('about:blank')
      expect(req.frame.url).to include('empty.html')
    end
  end

  it 'should unroute' do
    with_page do |page|
      intercepted = Set.new
      page.route('**/*', -> (route, _) {
        intercepted << 1
        route.continue
      })
      page.route('**/empty.html', -> (route, _) {
        intercepted << 2
        route.continue
      })
      page.route('**/empty.html', -> (route, _) {
        intercepted << 3
        route.continue
      })
      handler4 = -> (route, _) {
        intercepted << 4
        route.continue
      }
      page.route('**/empty.html', handler4)

      page.goto(server_empty_page)
      expect(intercepted).to contain_exactly(4)

      intercepted.clear
      page.unroute('**/empty.html', handler: handler4)
      page.goto(server_empty_page)
      expect(intercepted).to contain_exactly(3)

      intercepted.clear
      page.unroute('**/empty.html')
      page.goto(server_empty_page)
      expect(intercepted).to contain_exactly(1)
    end
  end

  it 'should work when POST is redirected with 302' do
    with_page do |page|
      sinatra.post('/rredirect') do
        redirect to('/empty.html'), 302
      end

      page.goto(server_empty_page)
      page.route('**/*', -> (route, _) { route.continue })
      page.content = [
        "<form action='/rredirect' method='post'>",
        '<input type="hidden" id="foo" name="foo" value="FOOBAR">',
        "</form>",
      ].join("\n")
      page.expect_navigation do
        page.eval_on_selector('form', 'form => form.submit()')
      end
    end
  end

  # // @see https://github.com/GoogleChrome/puppeteer/issues/3973
  # it('should work when header manipulation headers with redirect', async ({page, server}) => {
  #   server.setRedirect('/rrredirect', '/empty.html');
  #   await page.route('**/*', route => {
  #     const headers = Object.assign({}, route.request().headers(), {
  #       foo: 'bar'
  #     });
  #     route.continue({ headers });
  #   });
  #   await page.goto(server.PREFIX + '/rrredirect');
  # });
  # // @see https://github.com/GoogleChrome/puppeteer/issues/4743
  # it('should be able to remove headers', async ({page, server}) => {
  #   await page.goto(server.EMPTY_PAGE);
  #   await page.route('**/*', route => {
  #     const headers = Object.assign({}, route.request().headers(), {
  #       foo: undefined, // remove "foo" header
  #     });
  #     route.continue({ headers });
  #   });

  #   const [serverRequest] = await Promise.all([
  #     server.waitForRequest('/title.html'),
  #     page.evaluate(url => fetch(url, { headers: {foo: 'bar'} }), server.PREFIX + '/title.html')
  #   ]);
  #   expect(serverRequest.headers.foo).toBe(undefined);
  # });

  # it('should contain referer header', async ({page, server}) => {
  #   const requests = [];
  #   await page.route('**/*', route => {
  #     requests.push(route.request());
  #     route.continue();
  #   });
  #   await page.goto(server.PREFIX + '/one-style.html');
  #   expect(requests[1].url()).toContain('/one-style.css');
  #   expect(requests[1].headers().referer).toContain('/one-style.html');
  # });

  # it('should properly return navigation response when URL has cookies', async ({context, page, server}) => {
  #   // Setup cookie.
  #   await page.goto(server.EMPTY_PAGE);
  #   await context.addCookies([{ url: server.EMPTY_PAGE, name: 'foo', value: 'bar'}]);

  #   // Setup request interception.
  #   await page.route('**/*', route => route.continue());
  #   const response = await page.reload();
  #   expect(response.status()).toBe(200);
  # });

  # it('should show custom HTTP headers', async ({page, server}) => {
  #   await page.setExtraHTTPHeaders({
  #     foo: 'bar'
  #   });
  #   await page.route('**/*', route => {
  #     expect(route.request().headers()['foo']).toBe('bar');
  #     route.continue();
  #   });
  #   const response = await page.goto(server.EMPTY_PAGE);
  #   expect(response.ok()).toBe(true);
  # });
  # // @see https://github.com/GoogleChrome/puppeteer/issues/4337
  # it('should work with redirect inside sync XHR', async ({page, server}) => {
  #   await page.goto(server.EMPTY_PAGE);
  #   server.setRedirect('/logo.png', '/pptr.png');
  #   await page.route('**/*', route => route.continue());
  #   const status = await page.evaluate(async () => {
  #     const request = new XMLHttpRequest();
  #     request.open('GET', '/logo.png', false);  // `false` makes the request synchronous
  #     request.send(null);
  #     return request.status;
  #   });
  #   expect(status).toBe(200);
  # });

  # it('should pause intercepted XHR until continue', (test, { browserName}) => {
  #   test.fixme(browserName === 'webkit', 'Redirected request is not paused in WebKit');
  # }, async ({page, server}) => {
  #   await page.goto(server.EMPTY_PAGE);
  #   let resolveRoute;
  #   const routePromise = new Promise(r => resolveRoute = r);
  #   await page.route('**/global-var.html', async route => resolveRoute(route));
  #   let xhrFinished = false;
  #   const statusPromise = page.evaluate(async () => {
  #     const request = new XMLHttpRequest();
  #     request.open('GET', '/global-var.html', false);  // `false` makes the request synchronous
  #     request.send(null);
  #     return request.status;
  #   }).then(r => {
  #     xhrFinished = true;
  #     return r;
  #   });
  #   const route = await routePromise;
  #   // Check that intercepted request is actually paused.
  #   await new Promise(r => setTimeout(r, 500));
  #   expect(xhrFinished).toBe(false);
  #   const [status] = await Promise.all([
  #     statusPromise,
  #     (route as any).continue()
  #   ]);
  #   expect(status).toBe(200);
  # });

  # it('should pause intercepted fetch request until continue', async ({page, server}) => {
  #   await page.goto(server.EMPTY_PAGE);
  #   let resolveRoute;
  #   const routePromise = new Promise(r => resolveRoute = r);
  #   await page.route('**/global-var.html', async route => resolveRoute(route));
  #   let fetchFinished = false;
  #   const statusPromise = page.evaluate(async () => {
  #     const response = await fetch('/global-var.html');
  #     return response.status;
  #   }).then(r => {
  #     fetchFinished = true;
  #     return r;
  #   });
  #   const route = await routePromise;
  #   // Check that intercepted request is actually paused.
  #   await new Promise(r => setTimeout(r, 500));
  #   expect(fetchFinished).toBe(false);
  #   const [status] = await Promise.all([
  #     statusPromise,
  #     (route as any).continue()
  #   ]);
  #   expect(status).toBe(200);
  # });

  # it('should work with custom referer headers', async ({page, server}) => {
  #   await page.setExtraHTTPHeaders({ 'referer': server.EMPTY_PAGE });
  #   await page.route('**/*', route => {
  #     expect(route.request().headers()['referer']).toBe(server.EMPTY_PAGE);
  #     route.continue();
  #   });
  #   const response = await page.goto(server.EMPTY_PAGE);
  #   expect(response.ok()).toBe(true);
  # });

  it 'should be abortable' do
    with_page do |page|
      page.route(/\.css$/, ->(route, _) { route.abort })
      failed = false
      page.on('requestfailed', ->(req) {
        if req.url.include?('.css')
          failed = true
        end
      })
      response = page.goto("#{server_prefix}/one-style.html")
      expect(response).to be_ok
      expect(response.request.failure).to be_nil
      expect(failed).to eq(true)
    end
  end

  # it('should be abortable with custom error codes', async ({page, server, isWebKit, isFirefox}) => {
  #   await page.route('**/*', route => route.abort('internetdisconnected'));
  #   let failedRequest = null;
  #   page.on('requestfailed', request => failedRequest = request);
  #   await page.goto(server.EMPTY_PAGE).catch(e => {});
  #   expect(failedRequest).toBeTruthy();
  #   if (isWebKit)
  #     expect(failedRequest.failure().errorText).toBe('Request intercepted');
  #   else if (isFirefox)
  #     expect(failedRequest.failure().errorText).toBe('NS_ERROR_OFFLINE');
  #   else
  #     expect(failedRequest.failure().errorText).toBe('net::ERR_INTERNET_DISCONNECTED');
  # });

  # it('should send referer', async ({page, server}) => {
  #   await page.setExtraHTTPHeaders({
  #     referer: 'http://google.com/'
  #   });
  #   await page.route('**/*', route => route.continue());
  #   const [request] = await Promise.all([
  #     server.waitForRequest('/grid.html'),
  #     page.goto(server.PREFIX + '/grid.html'),
  #   ]);
  #   expect(request.headers['referer']).toBe('http://google.com/');
  # });

  # it('should fail navigation when aborting main resource', async ({page, server, isWebKit, isFirefox}) => {
  #   await page.route('**/*', route => route.abort());
  #   let error = null;
  #   await page.goto(server.EMPTY_PAGE).catch(e => error = e);
  #   expect(error).toBeTruthy();
  #   if (isWebKit)
  #     expect(error.message).toContain('Request intercepted');
  #   else if (isFirefox)
  #     expect(error.message).toContain('NS_ERROR_FAILURE');
  #   else
  #     expect(error.message).toContain('net::ERR_FAILED');
  # });

  # it('should not work with redirects', async ({page, server}) => {
  #   const intercepted = [];
  #   await page.route('**/*', route => {
  #     route.continue();
  #     intercepted.push(route.request());
  #   });
  #   server.setRedirect('/non-existing-page.html', '/non-existing-page-2.html');
  #   server.setRedirect('/non-existing-page-2.html', '/non-existing-page-3.html');
  #   server.setRedirect('/non-existing-page-3.html', '/non-existing-page-4.html');
  #   server.setRedirect('/non-existing-page-4.html', '/empty.html');

  #   const response = await page.goto(server.PREFIX + '/non-existing-page.html');
  #   expect(response.status()).toBe(200);
  #   expect(response.url()).toContain('empty.html');

  #   expect(intercepted.length).toBe(1);
  #   expect(intercepted[0].resourceType()).toBe('document');
  #   expect(intercepted[0].isNavigationRequest()).toBe(true);
  #   expect(intercepted[0].url()).toContain('/non-existing-page.html');

  #   const chain = [];
  #   for (let r = response.request(); r; r = r.redirectedFrom()) {
  #     chain.push(r);
  #     expect(r.isNavigationRequest()).toBe(true);
  #   }
  #   expect(chain.length).toBe(5);
  #   expect(chain[0].url()).toContain('/empty.html');
  #   expect(chain[1].url()).toContain('/non-existing-page-4.html');
  #   expect(chain[2].url()).toContain('/non-existing-page-3.html');
  #   expect(chain[3].url()).toContain('/non-existing-page-2.html');
  #   expect(chain[4].url()).toContain('/non-existing-page.html');
  #   for (let i = 0; i < chain.length; i++)
  #     expect(chain[i].redirectedTo()).toBe(i ? chain[i - 1] : null);
  # });

  it 'should chain fallback w/ dynamic URL' do
    with_page do |page|
      intercepted = []
      page.route('**/bar', -> (route, _) {
        intercepted << 1
        route.fallback(url: server_empty_page)
      })
      page.route('**/foo', -> (route, _) {
        intercepted << 2
        route.fallback(url: 'http://localhost/bar')
      })
      page.route('**/empty.html', -> (route, _) {
        intercepted << 3
        route.fallback(url: 'http://localhost/foo')
      })
      page.goto(server_empty_page)
      expect(intercepted).to eq([3, 2, 1])
    end
  end

  # it('should work with redirects for subresources', async ({page, server}) => {
  #   const intercepted = [];
  #   await page.route('**/*', route => {
  #     route.continue();
  #     intercepted.push(route.request());
  #   });
  #   server.setRedirect('/one-style.css', '/two-style.css');
  #   server.setRedirect('/two-style.css', '/three-style.css');
  #   server.setRedirect('/three-style.css', '/four-style.css');
  #   server.setRoute('/four-style.css', (req, res) => res.end('body {box-sizing: border-box; }'));

  #   const response = await page.goto(server.PREFIX + '/one-style.html');
  #   expect(response.status()).toBe(200);
  #   expect(response.url()).toContain('one-style.html');

  #   expect(intercepted.length).toBe(2);
  #   expect(intercepted[0].resourceType()).toBe('document');
  #   expect(intercepted[0].url()).toContain('one-style.html');

  #   let r = intercepted[1];
  #   for (const url of ['/one-style.css', '/two-style.css', '/three-style.css', '/four-style.css']) {
  #     expect(r.resourceType()).toBe('stylesheet');
  #     expect(r.url()).toContain(url);
  #     r = r.redirectedTo();
  #   }
  #   expect(r).toBe(null);
  # });

  # it('should work with equal requests', async ({page, server}) => {
  #   await page.goto(server.EMPTY_PAGE);
  #   let responseCount = 1;
  #   server.setRoute('/zzz', (req, res) => res.end((responseCount++) * 11 + ''));

  #   let spinner = false;
  #   // Cancel 2nd request.
  #   await page.route('**/*', route => {
  #     spinner ? route.abort() : route.continue();
  #     spinner = !spinner;
  #   });
  #   const results = [];
  #   for (let i = 0; i < 3; i++)
  #     results.push(await page.evaluate(() => fetch('/zzz').then(response => response.text()).catch(e => 'FAILED')));
  #   expect(results).toEqual(['11', 'FAILED', '22']);
  # });

  # it('should navigate to dataURL and not fire dataURL requests', async ({page, server}) => {
  #   const requests = [];
  #   await page.route('**/*', route => {
  #     requests.push(route.request());
  #     route.continue();
  #   });
  #   const dataURL = 'data:text/html,<div>yo</div>';
  #   const response = await page.goto(dataURL);
  #   expect(response).toBe(null);
  #   expect(requests.length).toBe(0);
  # });

  # it('should be able to fetch dataURL and not fire dataURL requests', async ({page, server}) => {
  #   await page.goto(server.EMPTY_PAGE);
  #   const requests = [];
  #   await page.route('**/*', route => {
  #     requests.push(route.request());
  #     route.continue();
  #   });
  #   const dataURL = 'data:text/html,<div>yo</div>';
  #   const text = await page.evaluate(url => fetch(url).then(r => r.text()), dataURL);
  #   expect(text).toBe('<div>yo</div>');
  #   expect(requests.length).toBe(0);
  # });

  # it('should navigate to URL with hash and and fire requests without hash', async ({page, server}) => {
  #   const requests = [];
  #   await page.route('**/*', route => {
  #     requests.push(route.request());
  #     route.continue();
  #   });
  #   const response = await page.goto(server.EMPTY_PAGE + '#hash');
  #   expect(response.status()).toBe(200);
  #   expect(response.url()).toBe(server.EMPTY_PAGE);
  #   expect(requests.length).toBe(1);
  #   expect(requests[0].url()).toBe(server.EMPTY_PAGE);
  # });

  # it('should work with encoded server', async ({page, server}) => {
  #   // The requestWillBeSent will report encoded URL, whereas interception will
  #   // report URL as-is. @see crbug.com/759388
  #   await page.route('**/*', route => route.continue());
  #   const response = await page.goto(server.PREFIX + '/some nonexisting page');
  #   expect(response.status()).toBe(404);
  # });

  # it('should work with badly encoded server', async ({page, server}) => {
  #   server.setRoute('/malformed?rnd=%911', (req, res) => res.end());
  #   await page.route('**/*', route => route.continue());
  #   const response = await page.goto(server.PREFIX + '/malformed?rnd=%911');
  #   expect(response.status()).toBe(200);
  # });

  # it('should work with encoded server - 2', async ({page, server}) => {
  #   // The requestWillBeSent will report URL as-is, whereas interception will
  #   // report encoded URL for stylesheet. @see crbug.com/759388
  #   const requests = [];
  #   await page.route('**/*', route => {
  #     route.continue();
  #     requests.push(route.request());
  #   });
  #   const response = await page.goto(`data:text/html,<link rel="stylesheet" href="${server.PREFIX}/fonts?helvetica|arial"/>`);
  #   expect(response).toBe(null);
  #   expect(requests.length).toBe(1);
  #   expect((await requests[0].response()).status()).toBe(404);
  # });

  # it('should not throw "Invalid Interception Id" if the request was cancelled', async ({page, server}) => {
  #   await page.setContent('<iframe></iframe>');
  #   let route = null;
  #   await page.route('**/*', async r => route = r);
  #   page.$eval('iframe', (frame, url) => frame.src = url, server.EMPTY_PAGE);
  #   // Wait for request interception.
  #   await page.waitForEvent('request');
  #   // Delete frame to cause request to be canceled.
  #   await page.$eval('iframe', frame => frame.remove());
  #   let error = null;
  #   await route.continue().catch(e => error = e);
  #   expect(error).toBe(null);
  # });

  # it('should intercept main resource during cross-process navigation', async ({page, server}) => {
  #   await page.goto(server.EMPTY_PAGE);
  #   let intercepted = false;
  #   await page.route(server.CROSS_PROCESS_PREFIX + '/empty.html', route => {
  #     intercepted = true;
  #     route.continue();
  #   });
  #   const response = await page.goto(server.CROSS_PROCESS_PREFIX + '/empty.html');
  #   expect(response.ok()).toBe(true);
  #   expect(intercepted).toBe(true);
  # });

  # it('should fulfill with redirect status', (test, { browserName, headful}) => {
  #   test.fixme(browserName === 'webkit', 'in WebKit the redirects are handled by the network stack and we intercept before');
  # }, async ({page, server}) => {
  #   await page.goto(server.PREFIX + '/title.html');
  #   server.setRoute('/final', (req, res) => res.end('foo'));
  #   await page.route('**/*', async (route, request) => {
  #     if (request.url() !== server.PREFIX + '/redirect_this')
  #       return route.continue();
  #     await route.fulfill({
  #       status: 301,
  #       headers: {
  #         'location': '/final',
  #       }
  #     });
  #   });

  #   const text = await page.evaluate(async url => {
  #     const data = await fetch(url);
  #     return data.text();
  #   }, server.PREFIX + '/redirect_this');
  #   expect(text).toBe('foo');
  # });

  # it('should not fulfill with redirect status', (test, { browserName, headful}) => {
  #   test.skip(browserName !== 'webkit', 'we should support fulfill with redirect in webkit and delete this test');
  # }, async ({page, server}) => {
  #   await page.goto(server.PREFIX + '/empty.html');

  #   let status;
  #   let fulfill;
  #   let reject;
  #   await page.route('**/*', async (route, request) => {
  #     if (request.url() !== server.PREFIX + '/redirect_this')
  #       return route.continue();
  #     try {
  #       await route.fulfill({
  #         status,
  #         headers: {
  #           'location': '/empty.html',
  #         }
  #       });
  #       reject('fullfill didn\'t throw');
  #     } catch (e) {
  #       fulfill(e);
  #     }
  #   });

  #   for (status = 300; status < 310; status++) {
  #     const exception = await Promise.race([
  #       page.evaluate(url => location.href = url, server.PREFIX + '/redirect_this'),
  #       new Promise((f, r) => {fulfill = f; reject = r;})
  #     ]) as any;
  #     expect(exception).toBeTruthy();
  #     expect(exception.message.includes('Cannot fulfill with redirect status')).toBe(true);
  #   }
  # });

  # it('should support cors with GET', async ({page, server}) => {
  #   await page.goto(server.EMPTY_PAGE);
  #   await page.route('**/cars*', async (route, request) => {
  #     const headers = request.url().endsWith('allow') ? { 'access-control-allow-origin': '*' } : {};
  #     await route.fulfill({
  #       contentType: 'application/json',
  #       headers,
  #       status: 200,
  #       body: JSON.stringify(['electric', 'gas']),
  #     });
  #   });
  #   {
  #     // Should succeed
  #     const resp = await page.evaluate(async () => {
  #       const response = await fetch('https://example.com/cars?allow', { mode: 'cors' });
  #       return response.json();
  #     });
  #     expect(resp).toEqual(['electric', 'gas']);
  #   }
  #   {
  #     // Should be rejected
  #     const error = await page.evaluate(async () => {
  #       const response = await fetch('https://example.com/cars?reject', { mode: 'cors' });
  #       return response.json();
  #     }).catch(e => e);
  #     expect(error.message).toContain('failed');
  #   }
  # });

  # it('should support cors with POST', async ({page, server}) => {
  #   await page.goto(server.EMPTY_PAGE);
  #   await page.route('**/cars', async route => {
  #     await route.fulfill({
  #       contentType: 'application/json',
  #       headers: { 'Access-Control-Allow-Origin': '*' },
  #       status: 200,
  #       body: JSON.stringify(['electric', 'gas']),
  #     });
  #   });
  #   const resp = await page.evaluate(async () => {
  #     const response = await fetch('https://example.com/cars', {
  #       method: 'POST',
  #       headers: { 'Content-Type': 'application/json' },
  #       mode: 'cors',
  #       body: JSON.stringify({ 'number': 1 })
  #     });
  #     return response.json();
  #   });
  #   expect(resp).toEqual(['electric', 'gas']);
  # });

  # it('should support cors with credentials', async ({page, server}) => {
  #   await page.goto(server.EMPTY_PAGE);
  #   await page.route('**/cars', async route => {
  #     await route.fulfill({
  #       contentType: 'application/json',
  #       headers: {
  #         'Access-Control-Allow-Origin': server.PREFIX,
  #         'Access-Control-Allow-Credentials': 'true'
  #       },
  #       status: 200,
  #       body: JSON.stringify(['electric', 'gas']),
  #     });
  #   });
  #   const resp = await page.evaluate(async () => {
  #     const response = await fetch('https://example.com/cars', {
  #       method: 'POST',
  #       headers: { 'Content-Type': 'application/json' },
  #       mode: 'cors',
  #       body: JSON.stringify({ 'number': 1 }),
  #       credentials: 'include'
  #     });
  #     return response.json();
  #   });
  #   expect(resp).toEqual(['electric', 'gas']);
  # });

  # it('should reject cors with disallowed credentials', async ({page, server}) => {
  #   await page.goto(server.EMPTY_PAGE);
  #   await page.route('**/cars', async route => {
  #     await route.fulfill({
  #       contentType: 'application/json',
  #       headers: {
  #         'Access-Control-Allow-Origin': server.PREFIX,
  #         // Should fail without this line below!
  #         // 'Access-Control-Allow-Credentials': 'true'
  #       },
  #       status: 200,
  #       body: JSON.stringify(['electric', 'gas']),
  #     });
  #   });
  #   let error = '';
  #   try {
  #     await page.evaluate(async () => {
  #       const response = await fetch('https://example.com/cars', {
  #         method: 'POST',
  #         headers: { 'Content-Type': 'application/json' },
  #         mode: 'cors',
  #         body: JSON.stringify({ 'number': 1 }),
  #         credentials: 'include'
  #       });
  #       return response.json();
  #     });
  #   } catch (e) {
  #     error = e;
  #   }
  #   expect(error).toBeTruthy();
  # });

  # it('should support cors for different methods', async ({page, server}) => {
  #   await page.goto(server.EMPTY_PAGE);
  #   await page.route('**/cars', async (route, request) => {
  #     await route.fulfill({
  #       contentType: 'application/json',
  #       headers: { 'Access-Control-Allow-Origin': '*' },
  #       status: 200,
  #       body: JSON.stringify([request.method(), 'electric', 'gas']),
  #     });
  #   });
  #   // First POST
  #   {
  #     const resp = await page.evaluate(async () => {
  #       const response = await fetch('https://example.com/cars', {
  #         method: 'POST',
  #         headers: { 'Content-Type': 'application/json' },
  #         mode: 'cors',
  #         body: JSON.stringify({ 'number': 1 })
  #       });
  #       return response.json();
  #     });
  #     expect(resp).toEqual(['POST', 'electric', 'gas']);
  #   }
  #   // Then DELETE
  #   {
  #     const resp = await page.evaluate(async () => {
  #       const response = await fetch('https://example.com/cars', {
  #         method: 'DELETE',
  #         headers: {},
  #         mode: 'cors',
  #         body: ''
  #       });
  #       return response.json();
  #     });
  #     expect(resp).toEqual(['DELETE', 'electric', 'gas']);
  #   }
  # });

  it 'should support the times parameter with route matching' do
    intercepted = []
    handler = ->(route, _) {
      intercepted << 'intercepted'
      route.continue
    }

    with_page do |page|
      page.route(
        '**/empty.html',
        handler,
        times: 2,
      )

      4.times { page.goto(server_empty_page) }

      routes = page.instance_variable_get(:@impl).instance_variable_get(:@routes)
      expect(routes).to be_empty

      page.unroute('**/empty.html', handler: handler)
    end

    expect(intercepted).to eq(%w[intercepted intercepted])
  end

  it 'should support async handler w/ times' do
    with_page do |page|
      page.route('**/empty.html', ->(route, _) {
        sleep 0.1
        route.fulfill(body: '<html>intercepted</html>', contentType: 'text/html')
      }, times: 1)

      page.goto(server_empty_page)
      expect(page.locator('body').text_content).to eq('intercepted')
      page.goto(server_empty_page)
      expect(page.locator('body').text_content).not_to include('intercepted')
    end
  end

  it 'should contain raw request header' do
    with_page do |page|
      headers_promise = Concurrent::Promises.resolvable_future
      page.route(
        '**/*',
        ->(route, req) {
          headers_promise.fulfill(req.all_headers)
          route.continue
        },
      )
      page.goto(server_empty_page)
      #expect(headers_promise.value!).to include()
      puts headers_promise.value!
    end
  end

  it 'should contain raw response header' do
    with_page do |page|
      headers_promise = Concurrent::Promises.resolvable_future
      page.route(
        '**/*',
        ->(route, req) {
          Concurrent::Promises.future(req) do |_req|
            headers_promise.fulfill(_req.response.all_headers)
          end
          route.continue
        },
      )
      page.goto(server_empty_page)
      #expect(headers_promise.value!).to include()
      puts headers_promise.value!
    end
  end

  it 'should contain raw response header after fulfill' do
    with_page do |page|
      headers_promise = Concurrent::Promises.resolvable_future
      page.route(
        '**/*',
        ->(route, req) {
          Concurrent::Promises.future(req) do |_req|
            headers_promise.fulfill(_req.response.all_headers)
          end
          route.fulfill(
            status: 200,
            body: 'Hello',
            contentType: 'text/html',
          )
        },
      )
      page.goto(server_empty_page)
      expect(headers_promise.value!['content-type']).to eq('text/html')
    end
  end
end
