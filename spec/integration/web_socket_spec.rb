require 'spec_helper'

# https://github.com/microsoft/playwright-python/blob/master/tests/async/test_websocket.py
RSpec.describe 'WebSocket', web_socket: true do
  let(:js) {
    <<~JAVASCRIPT
    (wsUrl) => {
      let cb;
      const result = new Promise(f => cb = f);
      const ws = new WebSocket(wsUrl);
      ws.addEventListener('message', data => { ws.close(); cb(data.data); });
      return result;
    }
    JAVASCRIPT
  }

  it 'should work', sinatra: true do
    with_page do |page|
      value = page.evaluate(js, arg: ws_url)
      expect(value).to eq('incoming')
    end
  end

  it 'should emit close events', sinatra: true do
    with_page do |page|
      ws = page.expect_websocket do
        page.evaluate(js, arg: ws_url)
      end
      expect(ws.url).to eq(ws_url)
      ws.wait_for_event('close') unless ws.closed?
      expect(ws.closed?).to eq(true)
    end
  end
end
