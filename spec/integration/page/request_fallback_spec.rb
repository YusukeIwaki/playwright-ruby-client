require 'spec_helper'

RSpec.describe 'request#fallback', sinatra: true do
  it 'should work' do
    with_page do |page|
      page.route('**/*', -> (route, _) { route.fallback })
      page.goto(server_empty_page)
    end
  end

  it 'should fall back' do
    intercepted = []
    with_context do |context|
      context.route('**/empty.html', ->(route, _) {
        intercepted << 1
        route.fallback
      })
      context.route('**/empty.html', ->(route, _) {
        intercepted << 2
        route.fallback
      })
      context.route('**/empty.html', ->(route, _) {
        intercepted << 3
        route.fallback
      })
      page = context.new_page
      page.goto(server_empty_page)
    end
    expect(intercepted).to eq([3, 2, 1])
  end

  it 'should not chain fulfill' do
    failed = false
    with_context do |context|
      context.route('**/empty.html', ->(route, _) {
        failed = true
      })
      context.route('**/empty.html', ->(route, _) {
        route.fulfill(status: 200, body: 'fulfilled')
      })
      context.route('**/empty.html', ->(route, _) {
        route.fallback
      })
      page = context.new_page
      response = page.goto(server_empty_page)
      expect(response.body).to eq('fulfilled')
      expect(failed).to eq(false)
    end
  end

  it 'should not chain abort' do
    failed = false
    with_context do |context|
      context.route('**/empty.html', ->(route, _) {
        failed = true
      })
      context.route('**/empty.html', ->(route, _) {
        route.abort
      })
      context.route('**/empty.html', ->(route, _) {
        route.fallback
      })
      page = context.new_page
      expect { page.goto(server_empty_page) }.to raise_error(/net::ERR_FAILED|Request intercepted|Blocked by Web Inspector/)
      expect(failed).to eq(false)
    end
  end

  # it('should fall back after exception', async ({ page, server, isAndroid, isElectron }) => {
  #   it.fixme(isAndroid);
  #   it.fixme(isElectron);

  #   await page.route('**/empty.html', route => {
  #     route.continue();
  #   });
  #   await page.route('**/empty.html', async route => {
  #     try {
  #       await route.fulfill({ response: {} as any });
  #     } catch (e) {
  #       route.fallback();
  #     }
  #   });
  #   await page.goto(server.EMPTY_PAGE);
  # });

  it 'should chain once' do
    with_context do |context|
      context.route('**/empty.html', ->(route, _) {
        route.fulfill(status: 200, body: 'fulfilled one')
      }, times: 1)
      context.route('**/empty.html', ->(route, _) {
        route.fallback
      }, times: 1)
      page = context.new_page
      response = page.goto(server_empty_page)
      expect(response.body).to eq('fulfilled one')
    end
  end

  # it('should amend HTTP headers', async ({ page, server }) => {
  #   const values = [];
  #   await page.route('**/sleep.zzz', async route => {
  #     values.push(route.request().headers().foo);
  #     values.push(await route.request().headerValue('FOO'));
  #     route.continue();
  #   });
  #   await page.route('**/*', route => {
  #     route.fallback({ headers: { ...route.request().headers(), FOO: 'bar' } });
  #   });
  #   await page.goto(server.EMPTY_PAGE);
  #   const [request] = await Promise.all([
  #     server.waitForRequest('/sleep.zzz'),
  #     page.evaluate(() => fetch('/sleep.zzz'))
  #   ]);
  #   values.push(request.headers['foo']);
  #   expect(values).toEqual(['bar', 'bar', 'bar']);
  # });

  # it('should delete header with undefined value', async ({ page, server, browserName }) => {
  #   await page.goto(server.PREFIX + '/empty.html');
  #   server.setRoute('/something', (request, response) => {
  #     response.writeHead(200, { 'Access-Control-Allow-Origin': '*' });
  #     response.end('done');
  #   });
  #   let interceptedRequest;
  #   await page.route('**/*', (route, request) => {
  #     interceptedRequest = request;
  #     route.continue();
  #   });
  #   await page.route(server.PREFIX + '/something', async (route, request) => {
  #     const headers = await request.allHeaders();
  #     route.fallback({
  #       headers: {
  #         ...headers,
  #         foo: undefined
  #       }
  #     });
  #   });
  #   const [text, serverRequest] = await Promise.all([
  #     page.evaluate(async url => {
  #       const data = await fetch(url, {
  #         headers: {
  #           foo: 'a',
  #           bar: 'b',
  #         }
  #       });
  #       return data.text();
  #     }, server.PREFIX + '/something'),
  #     server.waitForRequest('/something')
  #   ]);
  #   expect(text).toBe('done');
  #   expect(interceptedRequest.headers()['foo']).toEqual(undefined);
  #   expect(interceptedRequest.headers()['bar']).toEqual('b');
  #   expect(serverRequest.headers.foo).toBeFalsy();
  #   expect(serverRequest.headers.bar).toBe('b');
  # });

  it 'should amend method' do
    sinatra.post('/sleep.zzz') do
      sleep 1
      'sleep'
    end
    with_page do |page|
      page.goto(server_empty_page)

      _method = []
      page.route('**/*', -> (route, _) {
        _method = route.request.method
        route.continue
      })
      page.route('**/*', -> (route, _) {
        route.fallback(method: 'POST')
      })

      request = page.expect_request(-> (_) { true }) do
        page.evaluate('() => fetch("/sleep.zzz")')
      end
      expect(_method).to eq('POST')
      expect(request.method).to eq('POST')
    end
  end

  it 'should override request url' do
    with_page do |page|
      url = nil
      page.route('**/global-var.html', ->(route, _) {
        url = route.request.url
        route.continue
      })
      page.route('**/foo', ->(route, _) {
        route.fallback(url: "#{server_prefix}/global-var.html")
      })
      response = page.expect_response(-> (_) { true }) do
        page.goto("#{server_prefix}/foo")
      end

      expect(url).to eq("#{server_prefix}/global-var.html")
      expect(response.url).to eq("#{server_prefix}/foo")
      expect(page.evaluate("() => window['globalVar']")).to eq(123)
    end
  end

  it 'should amend post data' do
    post_data = nil

    with_page do |page|
      page.goto(server_empty_page)
      page.route('**/*', ->(route, request) {
        post_data = request.post_data
        route.continue
      })
      page.route('**/*', ->(route, _) {
        route.fallback(postData: 'doggo')
      })
      page.evaluate("() => fetch('/empty.html', { method: 'POST', body: 'birdy' })")
      expect(post_data).to eq('doggo')
    end
  end

  # it.describe('post data', () => {
  #   it.fixme(({ isAndroid }) => isAndroid, 'Post data does not work');

  #   it('should amend post data', async ({ page, server }) => {
  #     await page.goto(server.EMPTY_PAGE);
  #     let postData: string;
  #     await page.route('**/*', route => {
  #       postData = route.request().postData();
  #       route.continue();
  #     });
  #     await page.route('**/*', route => {
  #       route.fallback({ postData: 'doggo' });
  #     });
  #     const [serverRequest] = await Promise.all([
  #       server.waitForRequest('/sleep.zzz'),
  #       page.evaluate(() => fetch('/sleep.zzz', { method: 'POST', body: 'birdy' }))
  #     ]);
  #     expect(postData).toBe('doggo');
  #     expect((await serverRequest.postBody).toString('utf8')).toBe('doggo');
  #   });

  #   it('should amend binary post data', async ({ page, server }) => {
  #     await page.goto(server.EMPTY_PAGE);
  #     const arr = Array.from(Array(256).keys());
  #     let postDataBuffer: Buffer;
  #     await page.route('**/*', route => {
  #       postDataBuffer = route.request().postDataBuffer();
  #       route.continue();
  #     });
  #     await page.route('**/*', route => {
  #       route.fallback({ postData: Buffer.from(arr) });
  #     });
  #     const [serverRequest] = await Promise.all([
  #       server.waitForRequest('/sleep.zzz'),
  #       page.evaluate(() => fetch('/sleep.zzz', { method: 'POST', body: 'birdy' }))
  #     ]);
  #     const buffer = await serverRequest.postBody;
  #     expect(postDataBuffer.length).toBe(arr.length);
  #     expect(buffer.length).toBe(arr.length);
  #     for (let i = 0; i < arr.length; ++i) {
  #       expect(buffer[i]).toBe(arr[i]);
  #       expect(postDataBuffer[i]).toBe(arr[i]);
  #     }
  #   });
  # });
end
