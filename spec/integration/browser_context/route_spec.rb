require 'spec_helper'

RSpec.describe 'BrowserContext#route', sinatra: true do
  it 'should intercept' do
    with_context do |context|
      intercepted = false
      promise = Concurrent::Promises.resolvable_future
      request_frame_url = nil
      context.route('**/empty.html', ->(route, request) {
        promise.fulfill(request)
        request_frame_url = request.frame.url
        route.continue
      })

      page = context.new_page
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
    with_context do |context|
      intercepted = Set.new
      context.route('**/*', -> (route, _) {
        intercepted << 1
        route.continue
      })
      context.route('**/empty.html', -> (route, _) {
        intercepted << 2
        route.continue
      })
      context.route('**/empty.html', -> (route, _) {
        intercepted << 3
        route.continue
      })
      handler4 =  -> (route, _) {
        intercepted << 4
        route.continue
      }
      context.route('**/empty.html', handler4)

      page = context.new_page
      page.goto(server_empty_page)
      expect(intercepted).to contain_exactly(4)

      intercepted.clear
      context.unroute('**/empty.html', handler: handler4)
      page.goto(server_empty_page)
      expect(intercepted).to contain_exactly(3)

      intercepted.clear
      context.unroute('**/empty.html')
      page.goto(server_empty_page)
      expect(intercepted).to contain_exactly(1)
    end
  end

  it 'should yield to page.route' do
    with_context do |context|
      context.route('**/empty.html', ->(route, _) {
        route.fulfill(status: 200, body: 'context')
      })
      page = context.new_page
      page.route('**/empty.html', ->(route, _) {
        route.fulfill(status: 200, body: 'page')
      })
      response = page.goto(server_empty_page)
      expect(response).to be_ok
      expect(response.text).to eq('page')
    end
  end

  it 'should fall back to context.route' do
    with_context do |context|
      context.route('**/empty.html', ->(route, _) {
        route.fulfill(status: 200, body: 'context')
      })
      page = context.new_page
      page.route('**/non-empty.html', ->(route, _) {
        route.fulfill(status: 200, body: 'page')
      })
      response = page.goto(server_empty_page)
      expect(response).to be_ok
      expect(response.text).to eq('context')
    end
  end

  it 'should support the times parameter with route matching' do
    intercepted = []
    handler = ->(route, _) {
      intercepted << 'intercepted'
      route.continue
    }

    with_context do |context|
      context.route(
        '**/empty.html',
        handler,
        times: 2,
      )

      4.times { context.new_page.goto(server_empty_page) }

      routes = context.instance_variable_get(:@impl).instance_variable_get(:@routes)
      expect(routes).to be_empty

      context.unroute('**/empty.html', handler: handler)
    end

    expect(intercepted).to eq(%w[intercepted intercepted])
  end

  it 'should support async handler w/ times' do
    with_context do |context|
      page = context.new_page
      context.route('**/empty.html', ->(route, _) {
        sleep 0.1
        route.fulfill(body: '<html>intercepted</html>', contentType: 'text/html')
      }, times: 1)

      page.goto(server_empty_page)
      expect(page.locator('body').text_content).to eq('intercepted')
      page.goto(server_empty_page)
      expect(page.locator('body').text_content).not_to include('intercepted')
    end
  end

  xit 'should handle even if raise error' do
    with_context do |context|
      context.route('**/empty.html', ->(route, _) {
        route.fulfill(status: 200, body: 'context')
      })
      page = context.new_page
      page.route('**/empty.html', ->(route, _) {
        raise "Boom"
      }, times: 1)

      page.goto(server_empty_page)
      response = page.goto(server_empty_page)
      expect(response).to be_ok
      expect(response.text).to eq('context')
    end
  end

  it 'should chain continue' do
    intercepted = []
    with_context do |context|
      context.route('**/empty.html', ->(route, _) {
        intercepted << 1
        route.continue
      })
      context.route('**/empty.html', ->(route, _) {
        intercepted << 2
        route.continue
      })
      context.route('**/empty.html', ->(route, _) {
        intercepted << 3
        route.continue
      })
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
      route.continue
    })
    response = page.goto(server_empty_page)
    expect(response.body.to_s).to eq('fulfilled')
    expect(failed).to eq(false)
  end

  # it('should not chain abort', async ({ context, page, server }) => {
  #   let failed = false;
  #   await context.route('**/empty.html', route => {
  #     failed = true;
  #   });
  #   await context.route('**/empty.html', route => {
  #     route.abort();
  #   });
  #   await context.route('**/empty.html', route => {
  #     route.continue();
  #   });
  #   const e = await page.goto(server.EMPTY_PAGE).catch(e => e);
  #   expect(e).toBeTruthy();
  #   expect(failed).toBeFalsy();
  # });

  # it('should chain continue into page', async ({ context, page, server }) => {
  #   const intercepted = [];
  #   await context.route('**/empty.html', route => {
  #     intercepted.push(1);
  #     route.continue();
  #   });
  #   await context.route('**/empty.html', route => {
  #     intercepted.push(2);
  #     route.continue();
  #   });
  #   await context.route('**/empty.html', route => {
  #     intercepted.push(3);
  #     route.continue();
  #   });
  #   await page.route('**/empty.html', route => {
  #     intercepted.push(4);
  #     route.continue();
  #   });
  #   await page.route('**/empty.html', route => {
  #     intercepted.push(5);
  #     route.continue();
  #   });
  #   await page.route('**/empty.html', route => {
  #     intercepted.push(6);
  #     route.continue();
  #   });
  #   await page.goto(server.EMPTY_PAGE);
  #   expect(intercepted).toEqual([6, 5, 4, 3, 2, 1]);
  # });
end
