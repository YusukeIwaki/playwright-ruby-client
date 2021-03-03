require 'spec_helper'

RSpec.describe 'BrowserContext#route' do
  it 'should intercept', sinatra: true do
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

  it 'should unroute', sinatra: true do
    with_context do |context|
      intercepted = Set.new
      handler1 = -> (route, _) {
        intercepted << 1
        route.continue
      }
      context.route('**/empty.html', handler1)
      context.route('**/empty.html', -> (route, _) {
        intercepted << 2
        route.continue
      })
      context.route('**/empty.html', -> (route, _) {
        intercepted << 3
        route.continue
      })
      context.route('**/*', -> (route, _) {
        intercepted << 4
        route.continue
      })

      page = context.new_page
      page.goto(server_empty_page)
      expect(intercepted).to contain_exactly(1)

      intercepted.clear
      context.unroute('**/empty.html', handler: handler1)
      page.goto(server_empty_page)
      expect(intercepted).to contain_exactly(2)

      intercepted.clear
      context.unroute('**/empty.html')
      page.goto(server_empty_page)
      expect(intercepted).to contain_exactly(4)
    end
  end
end
