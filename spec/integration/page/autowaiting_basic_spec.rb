require 'spec_helper'

RSpec.describe 'autowaiting basic' do
  def init_server
    messages = []
    mutex = Mutex.new

    sinatra.get('/empty.html') do
      mutex.synchronize { messages << 'route' }
      headers('Content-Type' => 'text/html')
      body("<link rel='stylesheet' href='./one-style.css'>")
    end
    sinatra.post('/empty.html') do
      mutex.synchronize { messages << 'route' }
      headers('Content-Type' => 'text/html')
      body("<link rel='stylesheet' href='./one-style.css'>")
    end

    [messages, mutex]
  end

  def record_event(page, event, messages, mutex, label)
    future = Concurrent::Promises.resolvable_future
    listener = ->(*_args) {
      mutex.synchronize { messages << label }
      future.fulfill(nil)
    }
    page.on(event, listener)
    [future, listener]
  end

  it 'should await navigation when clicking anchor', sinatra: true do
    messages, mutex = init_server

    with_page do |page|
      page.content = "<a id=\"anchor\" href=\"#{server_empty_page}\" >empty.html</a>"

      future, listener = record_event(page, 'framenavigated', messages, mutex, 'navigated')
      page.click('a')
      mutex.synchronize { messages << 'click' }
      future.value!
      page.off('framenavigated', listener)
    end

    expect(messages).to eq(%w(route navigated click))
  end

  it 'should await cross-process navigation when clicking anchor', sinatra: true do
    messages, mutex = init_server

    with_page do |page|
      page.content = "<a href=\"#{server_cross_process_prefix}/empty.html\" >empty.html</a>"

      future, listener = record_event(page, 'framenavigated', messages, mutex, 'navigated')
      page.click('a')
      mutex.synchronize { messages << 'click' }
      future.value!
      page.off('framenavigated', listener)
    end

    expect(messages).to eq(%w(route navigated click))
  end

  it 'should await form-get on click', sinatra: true do
    messages, mutex = init_server

    with_page do |page|
      html = <<~HTML
      <form action="#{server_cross_process_prefix}/empty.html" method="get">
        <input name="foo" value="bar">
        <input type="submit" value="Submit">
      </form>
      HTML
      page.content = html

      future, listener = record_event(page, 'framenavigated', messages, mutex, 'navigated')
      page.click('input[type=submit]')
      mutex.synchronize { messages << 'click' }
      future.value!
      page.off('framenavigated', listener)
    end

    expect(messages).to eq(%w(route navigated click))
  end

  it 'should await form-post on click', sinatra: true do
    messages, mutex = init_server

    with_page do |page|
      html = <<~HTML
      <form action="#{server_cross_process_prefix}/empty.html" method="post">
        <input name="foo" value="bar">
        <input type="submit" value="Submit">
      </form>
      HTML
      page.content = html

      future, listener = record_event(page, 'framenavigated', messages, mutex, 'navigated')
      page.click('input[type=submit]')
      mutex.synchronize { messages << 'click' }
      future.value!
      page.off('framenavigated', listener)
    end

    expect(messages).to eq(%w(route navigated click))
  end

  it 'should await navigating specified target', sinatra: true do
    skip '@see https://github.com/microsoft/playwright/pull/5847/files#r596302374'

    messages, mutex = init_server

    with_page do |page|
      html = <<~HTML
      <a href="#{server_empty_page}" target=target>empty.html</a>
      <iframe name=target></iframe>
      HTML
      page.content = html

      frame = page.frame({name: 'target'})
      future, listener = record_event(page, 'framenavigated', messages, mutex, 'navigated')
      page.click('a')
      mutex.synchronize { messages << 'click' }
      future.value!
      page.off('framenavigated', listener)
      expect(frame.url).to eq(server_empty_page)
    end

    expect(messages).to eq(%w(route navigated click))
  end

  it 'should work with noWaitAfter: true', sinatra: true do
    sinatra.get('/empty.html') { sleep 30 }

    with_page do |page|
      page.content = "<a href=\"#{server_empty_page}\" >empty.html</a>"

      Timeout.timeout(3) do
        page.click('a', noWaitAfter: true)
      end
    end
  end

  it 'should work with dblclick noWaitAfter: true', sinatra: true do
    sinatra.get('/empty.html') { sleep 30 }

    with_page do |page|
      page.content = "<a href=\"#{server_empty_page}\" >empty.html</a>"

      Timeout.timeout(3) do
        page.dblclick('a', noWaitAfter: true)
      end
    end
  end

  it 'should work with waitForLoadState(load)', sinatra: true do
    messages, mutex = init_server

    with_page do |page|
      page.content = "<a href=\"#{server_empty_page}\" >empty.html</a>"

      future, listener = record_event(page, 'load', messages, mutex, 'load')
      page.click('a')
      page.wait_for_load_state(state: 'load')
      mutex.synchronize { messages << 'clickload' }
      future.value!
      page.off('load', listener)
    end
    expect(messages).to eq(%w(route load clickload))
  end

  it 'should work with goto following click', sinatra: true do
    sinatra.get('/login.html') do
      headers('Content-Type' => 'text/html')
      body('You are logged in')
    end

    with_page do |page|
      html = <<~HTML
      <form action="#{server_prefix}/login.html" method="get">
        <input type="text">
        <input type="submit" value="Submit">
      </form>
      HTML
      page.content = html

      page.fill('input[type="text"]', 'admin')
      page.click('input[type="submit"]')
      page.goto(server_empty_page)
    end
  end

  # it('should report navigation in the log when clicking anchor', (test, { mode }) => {
  #   test.skip(mode !== 'default');
  # }, async ({page, server}) => {
  #   await page.setContent(`<a href="${server.PREFIX + '/frames/one-frame.html'}">click me</a>`);
  #   const __testHookAfterPointerAction = () => new Promise(f => setTimeout(f, 6000));
  #   const error = await page.click('a', { timeout: 5000, __testHookAfterPointerAction } as any).catch(e => e);
  #   expect(error.message).toContain('page.click: Timeout 5000ms exceeded.');
  #   expect(error.message).toContain('waiting for scheduled navigations to finish');
  #   expect(error.message).toContain(`navigated to "${server.PREFIX + '/frames/one-frame.html'}"`);
  # });
end
