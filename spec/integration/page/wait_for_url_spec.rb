require 'spec_helper'

# https://github.com/microsoft/playwright/blob/master/tests/page-wait-for-url.spec.ts
RSpec.describe 'Page#wait_for_url' do
  it 'should work', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      page.evaluate('url => window.location.href = url', arg: "#{server_prefix}/grid.html")
      page.wait_for_url('**/grid.html')
    end
  end

  it 'should respect timeout', sinatra: true do
    with_page do |page|
      promise = Playwright::AsyncEvaluation.new {
        page.wait_for_url('**/frame.html',  timeout: 2500)
      }
      page.goto(server_empty_page)
      expect { promise.value! }.to raise_error(/Timeout 2500ms exceeded./)
    end
  end

  it 'should work with both domcontentloaded and load', sinatra: true do
    css_request_queue = Queue.new
    css_response_queue = Queue.new
    sinatra.get('/one-style.css') do
      css_request_queue << 'done'
      css_response_queue.pop
    end

    with_page do |page|
      domcontentloaded_promise = Playwright::AsyncEvaluation.new do
        page.wait_for_url('**/one-style.html', waitUntil: 'domcontentloaded')
      end
      navigation_promise = Playwright::AsyncEvaluation.new do
        page.goto("#{server_prefix}/one-style.html")
      end
      load_promise = Playwright::AsyncEvaluation.new do
        page.wait_for_url('**/one-style.html', waitUntil: 'load')
      end

      # wait for CSS request
      css_request_queue.pop

      Timeout.timeout(2) { domcontentloaded_promise.value! }
      expect(load_promise).not_to be_resolved

      css_response_queue << 'done'
      Timeout.timeout(2) { load_promise.value! }
      Timeout.timeout(2) { navigation_promise.value! }
    end
  end

  it 'should work with clicking on anchor links', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      page.content = "<a href='#foobar'>foobar</a>"
      page.click('a')
      Timeout.timeout(1) { page.wait_for_url('**/*#foobar') }
    end
  end

  it 'should work with history.pushState()', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      page.content = <<~HTML
      <a onclick='javascript:pushState()'>SPA</a>
      <script>
        function pushState() { history.pushState({}, '', 'wow.html') }
      </script>
      HTML
      page.click('a')
      Timeout.timeout(1) { page.wait_for_url('**/wow.html') }
      expect(page.url).to eq("#{server_prefix}/wow.html")
    end
  end

  it 'should work with history.replaceState()', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      page.content = <<~HTML
      <a onclick='javascript:replaceState()'>SPA</a>
      <script>
        function replaceState() { history.replaceState({}, '', '/replaced.html') }
      </script>
      HTML
      page.click('a')
      Timeout.timeout(1) { page.wait_for_url('**/replaced.html') }
      expect(page.url).to eq("#{server_prefix}/replaced.html")
    end
  end

  it 'should work with DOM history.back()/history.forward()', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      page.content = <<~HTML
      <a id=back onclick='javascript:goBack()'>back</a>
      <a id=forward onclick='javascript:goForward()'>forward</a>
      <script>
        function goBack() { history.back(); }
        function goForward() { history.forward(); }
        history.pushState({}, '', '/first.html');
        history.pushState({}, '', '/second.html');
      </script>
      HTML
      expect(page.url).to eq("#{server_prefix}/second.html")

      page.click('a#back')
      Timeout.timeout(1) { page.wait_for_url('**/first.html') }
      expect(page.url).to eq("#{server_prefix}/first.html")

      page.click('a#forward')
      Timeout.timeout(1) { page.wait_for_url('**/second.html') }
      expect(page.url).to eq("#{server_prefix}/second.html")
    end
  end

  it 'should work with url match for same document navigations', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      wait_promise = Playwright::AsyncEvaluation.new do
        page.wait_for_url(/third.html/)
      end
      expect(wait_promise).not_to be_resolved
      page.evaluate("() => history.pushState({}, '', '/first.html')")
      sleep 1
      expect(wait_promise).not_to be_resolved
      page.evaluate("() => history.pushState({}, '', '/second.html')")
      sleep 1
      expect(wait_promise).not_to be_resolved
      page.evaluate("() => history.pushState({}, '', '/third.html')")
      Timeout.timeout(1) { wait_promise.value! }
    end
  end

  it 'should work on frame', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/frames/one-frame.html")
      frame = page.frames.last
      frame.evaluate("url => window.location.href = url", arg: "#{server_prefix}/grid.html")
      Timeout.timeout(1) { frame.wait_for_url('**/grid.html') }
    end
  end
end
