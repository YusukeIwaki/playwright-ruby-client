require 'spec_helper'

# https://github.com/microsoft/playwright/blob/release-1.60/tests/library/route-web-socket.spec.ts
RSpec.describe 'routeWebSocket', sinatra: true, web_socket: true do
  def wait_for_value(timeout: 5)
    Timeout.timeout(timeout) do
      loop do
        value = yield
        return value if value
        sleep 0.05
      end
    end
  end

  it 'should expose protocols to the route handler' do
    with_page do |page|
      routes = []
      page.route_web_socket(/.*/, ->(ws) { routes << ws })

      page.goto(server_empty_page)
      page.evaluate(<<~JAVASCRIPT, arg: { host: "localhost:#{server_port}" })
        ({ host }) => {
          window.wsNone = new WebSocket('ws://' + host + '/ws-none');
          window.wsString = new WebSocket('ws://' + host + '/ws-string', 'chat.v1');
          window.wsArray = new WebSocket('ws://' + host + '/ws-array', ['chat.v2', 'chat.v1']);
        }
      JAVASCRIPT

      wait_for_value { routes.length == 3 }

      by_path = routes.to_h { |route| [URI(route.url).path, route] }
      expect(by_path.fetch('/ws-none').protocols).to eq([])
      expect(by_path.fetch('/ws-string').protocols).to eq(['chat.v1'])
      expect(by_path.fetch('/ws-array').protocols).to eq(['chat.v2', 'chat.v1'])
    end
  end

  it 'should expose protocols on server-side route' do
    with_page do |page|
      route_future = Concurrent::Promises.resolvable_future
      page.route_web_socket(/.*/, ->(ws) {
        server_route = ws.connect_to_server
        route_future.fulfill(page: ws, server: server_route)
      })

      page.goto(server_empty_page)
      page.evaluate(<<~JAVASCRIPT, arg: { wsUrl: "ws://localhost:#{server_port}/ws" })
        ({ wsUrl }) => {
          window.ws = new WebSocket(wsUrl, ['chat.v2', 'chat.v1']);
        }
      JAVASCRIPT

      routes = route_future.value!(5)
      expect(routes[:page].protocols).to eq(['chat.v2', 'chat.v1'])
      expect(routes[:server].protocols).to eq(['chat.v2', 'chat.v1'])
    end
  end
end
