require 'spec_helper'

RSpec.describe 'request' do
  def attach_frame(page, frame_id, url)
    handle = page.evaluate_handle(<<~JAVASCRIPT, arg: { frameId: frame_id, url: url })
      async ({ frameId, url }) => {
        const frame = document.createElement('iframe');
        frame.src = url;
        frame.id = frameId;
        document.body.appendChild(frame);
        await new Promise(x => frame.onload = x);
        return frame;
      }
    JAVASCRIPT
    handle.as_element.content_frame
  end

  it 'should fire for navigation requests', sinatra: true do
    with_page do |page|
      requests = []
      page.on('request', -> (request) { requests << request })

      page.goto(server_empty_page)
      expect(requests.length).to eq(1)
    end
  end

  it 'should fire for iframes', sinatra: true do
    with_page do |page|
      requests = []
      page.on('request', -> (request) { requests << request })
      page.goto(server_empty_page)
      attach_frame(page, 'frame1', server_empty_page)
      expect(requests.length).to eq(2)
    end
  end

  it 'should fire for fetches', sinatra: true do
    with_page do |page|
      requests = []
      page.on('request', -> (request) { requests << request })
      page.goto(server_empty_page)
      page.evaluate("() => fetch('/empty.html')")
      expect(requests.length).to eq(2)
    end
  end

  # Replaces the accidentally re-added TypeScript test block.
  it 'should return last requests', sinatra: true do
    with_page do |page|
      # Simulate server.setRoute for /fetch?N
      page.route(%r{/fetch\?\d+}, -> (route, request) {
        route.fulfill(status: 200, body: "url:#{request.url}")
      })

      page.goto("#{server_prefix}/title.html")

      # Issue first 99 fetches (0..98)
      (0...99).each do |i|
        page.evaluate("url => fetch(url)", arg: "#{server_prefix}/fetch?#{i}")
      end
      first99_requests = page.requests.dup
      first99_requests.shift # drop navigation request

      # Issue remaining fetches (99..198)
      (99...199).each do |i|
        page.evaluate("url => fetch(url)", arg: "#{server_prefix}/fetch?#{i}")
      end
      last100_requests = page.requests

      all_requests = first99_requests + last100_requests

      received = all_requests.map do |req|
        resp = req.response
        { url: req.url, text: resp.text }
      end

      expected = (0...199).map do |i|
        url = "#{server_prefix}/fetch?#{i}"
        { url: url, text: "url:#{url}" }
      end

      expect(received).to eq(expected)
    end
  end
end
