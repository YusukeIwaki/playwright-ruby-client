require 'spec_helper'

# https://github.com/microsoft/playwright-python/blob/master/tests/async/test_websocket.py
RSpec.describe 'WebSocket', web_socket: true do
  it 'should work', sinatra: true do
    js = <<~JAVASCRIPT
    (wsUrl) => {
      let cb;
      const result = new Promise(f => cb = f);
      const ws = new WebSocket(wsUrl);
      ws.addEventListener('message', data => { ws.close(); cb(data.data); });
      return result;
    }
    JAVASCRIPT

    with_page do |page|
      value = page.evaluate(js, arg: ws_url)
      expect(value).to eq('incoming')
    end
  end

  it 'should emit close events', sinatra: true do
    js = <<~JAVASCRIPT
    (wsUrl) => {
      let cb;
      const result = new Promise(f => cb = f);
      const ws = new WebSocket(wsUrl);
      ws.addEventListener('message', data => { ws.close(); cb(data.data); });
      return result;
    }
    JAVASCRIPT

    with_page do |page|
      ws = page.expect_websocket do
        page.evaluate(js, arg: ws_url)
      end
      expect(ws.url).to eq(ws_url)
      ws.wait_for_event('close') unless ws.closed?
      expect(ws.closed?).to eq(true)
    end
  end

  it 'should emit frame events', sinatra: true do
    js = <<~JAVASCRIPT
    (wsUrl) => {
      let cb;
      const ws = new WebSocket(wsUrl);
      ws.addEventListener('open', () => {
        ws.send('echo-text');
      });
    }
    JAVASCRIPT

    with_page do |page|
      sent = []
      received = []
      page.on('websocket', ->(ws) {
        ws.on('framesent', ->(payload) { sent << payload })
        ws.on('framereceived', ->(payload) { received << payload })
      })
      ws = page.expect_websocket do
        page.evaluate(js, arg: ws_url)
      end
      ws.wait_for_event('close') unless ws.closed?
      expect(sent).to eq(['echo-text'])
      expect(received).to eq(['incoming', 'text'])
    end
  end

  it 'should emit binary frame events', sinatra: true do
    js = <<~JAVASCRIPT
    (wsUrl) => {
      const ws = new WebSocket(wsUrl);
      ws.addEventListener('open', () => {
          const binary = new Uint8Array(5);
          for (let i = 0; i < 5; ++i)
              binary[i] = i;
          ws.send(binary);
          ws.send('echo-bin');
      });
    }
    JAVASCRIPT

    with_page do |page|
      sent = []
      received = []
      page.on('websocket', ->(ws) {
        ws.on('framesent', ->(payload) { sent << payload })
        ws.on('framereceived', ->(payload) { received << payload })
      })
      ws = page.expect_websocket do
        page.evaluate(js, arg: ws_url)
      end
      ws.wait_for_event('close') unless ws.closed?
      expect(sent).to eq(["\x00\x01\x02\x03\x04", "echo-bin"])
      expect(received).to eq(["incoming", "\x04\x02"])
    end
  end

  it 'should emit error', sinatra: true do
    with_page do |page|
      callback = Concurrent::Promises.resolvable_future

      page.on('websocket', ->(ws) {
        ws.on('socketerror', ->(error) { callback.fulfill(error) })
      })
      ws = page.expect_websocket do
        page.evaluate("new WebSocket('#{ws_url}-not-valid-url')")
      end

      error_message = callback.value!
      expect(error_message).to match(/: 404/)
    end
  end

  it 'should reject waitForEvent on socket close', sinatra: true do
    with_page do |page|
      ws = page.expect_websocket do
        page.evaluate("window.ws = new WebSocket('#{ws_url}')")
      end
      ws.wait_for_event('framereceived')
      expect {
        ws.expect_event('framesent') do
          page.evaluate('window.ws.close()')
        end
      }.to raise_error(/Socket closed/)
    end
  end

  it 'should reject waitForEvent on page close', sinatra: true do
    with_page do |page|
      ws = page.expect_websocket do
        page.evaluate("window.ws = new WebSocket('#{ws_url}')")
      end
      ws.wait_for_event('framereceived')
      expect {
        ws.expect_event('framesent') do
          page.close
        end
      }.to raise_error(/Target page, context or browser has been closed/)
    end
  end
end
