require 'spec_helper'

RSpec.describe Playwright::Page do
  it 'should reject all promises when page is closed' do
    with_page do |page|
      never_resolved_promise = Playwright::AsyncEvaluation.new { page.evaluate('() => new Promise(r => {})') }
      page.close
      expect { never_resolved_promise.value! }.to raise_error(/Protocol error/)
    end
  end

  it 'should not be visible in context.pages' do
    with_context do |context|
      page = context.new_page
      expect(context.pages).to include(page)
      expect { page.close }.to change { context.pages.count }.by(-1)
      expect(context.pages).not_to include(page)
    end
  end

  it 'should set the page close state' do
    with_page do |page|
      expect { page.close }.to change { page.closed? }.from(false).to(true)
    end
  end

  it 'should terminate network waiters' do
    with_page do |page|
      request_promise = Playwright::AsyncEvaluation.new { page.expect_request('http://example.com/') }
      response_promise = Playwright::AsyncEvaluation.new { page.expect_response('http://example.com/') }
      page.close
      expect { request_promise.value! }.to raise_error(/Page closed/)
      expect { response_promise.value! }.to raise_error(/Page closed/)
    end
  end

  it 'should be callable twice' do
    with_page do |page|
      expect {
        page.close
        page.close
        page.close
      }.not_to raise_error
    end
  end

  it 'should fire load when expected' do
    with_page do |page|
      promise = Playwright::AsyncEvaluation.new { page.expect_event('load') }
      page.goto('about:blank')
      Timeout.timeout(1) do
        promise.value!
      end
    end
  end

  # it 'async stacks should work', sinatra: true do
  #   _sinatra = sinatra
  #   sinatra.get('/empty_kill.html') {
  #     _sinatra.quit! # server is closing gracefully, so we cant force kill it...
  #     sleep 10
  #   }
  #   with_page do |page|
  #     page.goto("#{server_prefix}/empty_kill.html")
  #   end
  #   #     expect(error).not.toBe(null);
  #   #     expect(error.stack).toContain(__filename);
  #   #   });
  # end

  it 'should provide access to the opener page' do
    with_page do |page|
      popup = page.expect_event('popup') do
        page.evaluate("() => window.open('about:blank')")
      end
      expect(popup.opener).to eq(page)
    end
  end

  it 'should return null if parent page has been closed' do
    with_page do |page|
      popup = page.expect_event('popup') do
        page.evaluate("() => window.open('about:blank')")
      end
      page.close

      expect(popup.opener).to be_nil
    end
  end

  it 'should fire domcontentloaded when expected' do
    with_page do |page|
      Timeout.timeout(3) do
        page.expect_event('domcontentloaded') do
          page.goto('about:blank')
        end
      end
    end
  end

  it 'should fail with error upon disconnect' do
    with_page do |page|
      expect {
        page.expect_event('download') do
          page.close
        end
      }.to raise_error(/Page closed/)
    end
  end

  it 'page.url should work', sinatra: true do
    with_page do |page|
      expect(page.url).to eq('about:blank')
      expect { page.goto(server_empty_page) }.to change { page.url }.
        from('about:blank').to(server_empty_page)
    end
  end

  it 'page.url should include hashes', sinatra: true do
    with_page do |page|
      page.goto("#{server_empty_page}#hash")
      expect(page.url).to eq("#{server_empty_page}#hash")
      page.evaluate("() => { window.location.hash = 'dynamic' }")
      expect(page.url).to eq("#{server_empty_page}#dynamic")
    end
  end

  it 'page.title should return the page title', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/title.html")
      expect(page.title).to eq('Woof-Woof')
    end
  end

  it 'page.close should work with window.close' do
    with_page do |page|
      new_page = page.expect_event('popup') do
        page.evaluate("() => window['newPage'] = window.open('about:blank')")
      end
      closed_promise = Playwright::AsyncValue.new
      new_page.once('close', -> { closed_promise.fulfill(nil) })
      page.evaluate("() => window['newPage'].close()")
      Timeout.timeout(1) do
        closed_promise.value!
      end
    end
  end

  it 'page.close should work with page.close' do
    with_context do |context|
      page = context.new_page
      closed_promise = Playwright::AsyncValue.new
      page.once('close', -> { closed_promise.fulfill(nil) })
      page.close
      Timeout.timeout(1) do
        closed_promise.value!
      end
    end
  end

  it 'page.context should return the correct instance' do
    with_context do |context|
      page = context.new_page
      expect(page.context).to eq(context)
    end
  end

  it 'page.frame should respect name' do
    with_page do |page|
      page.content = '<iframe name=target></iframe>'
      expect(page.frame(name: 'bogus')).to be_nil
      frame = page.frame(name: 'target')
      expect(frame).to be_a(::Playwright::Frame)
      expect(frame).to eq(page.main_frame.child_frames.first)
    end
  end

  it 'page.frame should respect url', sinatra: true do
    with_page do |page|
      page.content = "<iframe src=\"#{server_empty_page}\"></iframe>"
      expect(page.frame(url: /bogus/)).to be_nil
      frame = page.frame(url: /empty/)
      expect(frame).to be_a(::Playwright::Frame)
      expect(frame.url).to eq(server_empty_page)
    end
  end

  it 'should have sane user agent' do
    user_agent = with_page { |page| page.evaluate('() => navigator.userAgent') }
    parts = user_agent.split(/[()]/).map(&:strip)

    # First part is always "Mozilla/5.0"
    expect(parts.first).to eq('Mozilla/5.0')

    # Second part in parenthesis is platform - ignore it.

    # Third part for Firefox is the last one and encodes engine and browser versions.
    # if (isFirefox) {
    #   const [engine, browser] = part3.split(' ');
    #   expect(engine.startsWith('Gecko')).toBe(true);
    #   expect(browser.startsWith('Firefox')).toBe(true);
    #   expect(part4).toBe(undefined);
    #   expect(part5).toBe(undefined);
    #   return;
    # }
    # For both options.CHROMIUM and options.WEBKIT, third part is the AppleWebKit version.
    expect(parts[2]).to start_with('AppleWebKit/')
    expect(parts[3]).to eq('KHTML, like Gecko')

    # 5th part encodes real browser name and engine version.
    engine, browser = parts[4].split(' ')
    expect(browser).to start_with('Safari')

    if chromium?
      expect(engine).to include('Chrome/')
    else
      expect(engine).to start_with('Version/')
    end
  end

  it 'page.press should work', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/textarea.html")
      page.press('textarea', 'a')
      expect(page.evaluate("() => document.querySelector('textarea').value")).to eq('a')
    end
  end

  it 'page.press should work for Enter' do
    with_page do |page|
      page.content = <<~HTML
      <input onkeypress="console.log('press')"></input>
      HTML
      messages = []
      page.on('console', ->(message) { messages << message })
      page.press('input', 'Enter')
      expect(messages.count).to eq(1)
      expect(messages.first.text).to eq('press')
    end
  end

  it 'frame.press should work', sinatra: true do
    with_page do |page|
      page.content = <<~HTML
      <iframe name=inner src="#{server_prefix}/input/textarea.html"></iframe>
      HTML
      frame = page.frame(name: 'inner')
      frame.press('textarea', 'a')
      expect(frame.evaluate("() => document.querySelector('textarea').value")).to eq('a')
    end
  end

  it 'frame.focus should work multiple times' do
    with_context do |context|
      pages = [context.new_page, context.new_page]
      pages.each do |page|
        page.content = '<button id="foo" onfocus="window.gotFocus=true"></button>'
        page.focus('#foo')
        expect(page.evaluate("() => !!window['gotFocus']")).to eq(true)
      end
    end
  end
end
