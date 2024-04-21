require 'spec_helper'

RSpec.describe 'Request' do
  it 'should return headers', sinatra: true do
    with_page do |page|
      response = page.goto(server_empty_page)
      expect(response.request.headers['user-agent']).to start_with('Mozilla/5.0')
    end
  end

  it 'should return postData', sinatra: true do
    with_page do |page|
      sinatra.post('/post') { '' }

      page.goto(server_empty_page)
      request = Concurrent::Promises.resolvable_future
      page.on('request', ->(req) {
        request.fulfill(req)
      })
      page.evaluate(<<~JAVASCRIPT)
      () => fetch('./post', { method: 'POST', body: JSON.stringify({ foo: 'bar' }) })
      JAVASCRIPT
      req = request.value!
      expect(req.post_data).to eq('{"foo":"bar"}')
    end
  end

  it 'should work with binary post data', sinatra: true do
    with_page do |page|
      sinatra.post('/post') { '' }

      page.goto(server_empty_page)
      request = Concurrent::Promises.resolvable_future
      page.on('request', ->(req) {
        request.fulfill(req)
      })
      page.evaluate(<<~JAVASCRIPT)
      () => fetch('./post', { method: 'POST', body: new Uint8Array(Array.from(Array(256).keys())) })
      JAVASCRIPT
      req = request.value!
      expect(req.post_data_buffer.size).to eq(256)
      expect(req.post_data_buffer).to eq((0..255).to_a.pack('C*'))
    end
  end

  it 'should work with binary post data and interception', sinatra: true do
    with_page do |page|
      sinatra.post('/post') { '' }

      page.goto(server_empty_page)
      request = Concurrent::Promises.resolvable_future
      page.route('/post', -> (req, _) { req.continue })
      page.on('request', ->(req) {
        request.fulfill(req)
      })
      page.evaluate(<<~JAVASCRIPT)
      () => fetch('./post', { method: 'POST', body: new Uint8Array(Array.from(Array(256).keys())) })
      JAVASCRIPT
      req = request.value!
      expect(req.post_data_buffer.size).to eq(256)
      expect(req.post_data_buffer).to eq((0..255).to_a.pack('C*'))
    end
  end

  it 'should return parsed json post data', sinatra: true do
    with_page do |page|
      env = Concurrent::Promises.resolvable_future
      sinatra.post('/post') {
        env.fulfill(request.env)
        ''
      }

      request = Concurrent::Promises.resolvable_future
      page.goto(server_empty_page)
      page.route('**/post', -> (route, request) {
        headers = request.headers
        headers['content-type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
        route.continue(headers: headers, postData: request.post_data)
      })
      page.on('request', ->(req) {
        request.fulfill(req)
      })
      page.evaluate(<<~JAVASCRIPT)
      () => fetch('./post', { method: 'POST', body: "foo=bar" })
      JAVASCRIPT
      request_env = env.value!
      expect(request_env['CONTENT_TYPE']).to eq('application/x-www-form-urlencoded; charset=UTF-8')
      req = request.value!
      expect(req.post_data_json).to eq({ 'foo' => 'bar' })
    end
  end

  it 'should return navigation bit when navigating to image', sinatra: true do
    with_page do |page|
      requests = []
      page.on('request', ->(req) { requests << req })
      page.goto("#{server_prefix}/pprt.png")

      expect(requests.first.navigation_request?).to eq(true)
    end
  end

  it 'should report raw headers', sinatra: true do
    sinatra.get('/headers') { 'OK' }

    with_page do |page|
      page.goto(server_empty_page)
      request = page.expect_request('**/*') do
        page.evaluate(<<~JAVASCRIPT)
        () => fetch('/headers', {
          headers: [
            ['header-a', 'value-a'],
            ['header-b', 'value-b'],
            ['header-a', 'value-a-1'],
            ['header-a', 'value-a-2'],
          ]
        })
        JAVASCRIPT
      end
      headers = request.headers_array
      expect(request.header_value('header-a')).to eq('value-a, value-a-1, value-a-2')
      expect(request.header_value('header-b')).to eq('value-b')
      expect(request.header_value('not-there')).to be_nil
      expect(request.header_values('not-there')).to eq([])
    end
  end

  it 'should report all cookies in one header', sinatra: true do
    pending 'cookies cannot be set in latest chromium' if chromium?
    sinatra.get('/headers') { 'OK' }

    with_page do |page|
      page.goto(server_empty_page)
      page.evaluate(<<~JAVASCRIPT)
      () => {
        document.cookie = 'myCookie=myValue';
        document.cookie = 'myOtherCookie=myOtherValue';
      }
      JAVASCRIPT
      response = page.goto(server_empty_page)
      headers = response.request.all_headers
      expect(headers['cookie']).to eq('myCookie=myValue; myOtherCookie=myOtherValue')
    end
  end

  it 'should not allow to access frame on popup main request', sinatra: true do
    with_page do |page|
      page.content = "<a target=_blank href='#{server_empty_page}'>click me</a>"
      request = page.context.expect_event('request') do
        page.get_by_text('click me').click
      end

      expect(request.navigation_request?).to eq(true)

      expect { request.frame }.to raise_error(/Frame for this navigation request is not available/)
    end
  end
  # it('should not allow to access frame on popup main request', async ({ page, server }) => {
  #   await page.setContent(`<a target=_blank href="${server.EMPTY_PAGE}">click me</a>`);
  #   const requestPromise = page.context().waitForEvent('request');
  #   const popupPromise = page.context().waitForEvent('page');
  #   const clicked = page.getByText('click me').click();
  #   const request = await requestPromise;

  #   expect(request.isNavigationRequest()).toBe(true);

  #   let error;
  #   try {
  #     request.frame();
  #   } catch (e) {
  #     error = e;
  #   }
  #   expect(error.message).toContain('Frame for this navigation request is not available');

  #   const response = await request.response();
  #   await response.finished();
  #   await popupPromise;
  #   await clicked;
  # });
end
