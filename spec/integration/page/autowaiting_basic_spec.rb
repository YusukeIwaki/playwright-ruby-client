require 'spec_helper'

RSpec.describe 'autowaiting basic' do
  def init_server
    messages = []

    sinatra.get('/empty.html') do
      messages << 'route'
      headers('Content-Type' => 'text/html')
      body("<link rel='stylesheet' href='./one-style.css'>")
    end
    sinatra.post('/empty.html') do
      messages << 'route'
      headers('Content-Type' => 'text/html')
      body("<link rel='stylesheet' href='./one-style.css'>")
    end

    messages
  end

  def await_all(futures)
    futures.map(&:value!)
  end

  it 'should await navigation when clicking anchor', sinatra: true do
    messages = init_server

    with_page do |page|
      page.content = "<a id=\"anchor\" href=\"#{server_empty_page}\" >empty.html</a>"

      promises = [
        Playwright::AsyncEvaluation.new {
          page.click('a')
          messages << 'click'
        },
        Playwright::AsyncEvaluation.new {
          page.expect_event('framenavigated')
          messages << 'navigated'
        }
      ]
      await_all(promises)
    end

    expect(messages).to eq(%w(route navigated click))
  end

  it 'should await navigation when clicking anchor programmatically', sinatra: true do
    messages = init_server

    with_page do |page|
      page.content = "<a id=\"anchor\" href=\"#{server_empty_page}\" >empty.html</a>"

      promises = [
        Playwright::AsyncEvaluation.new {
          page.evaluate("() => window.anchor.click()")
          messages << 'click'
        },
        Playwright::AsyncEvaluation.new {
          page.expect_event('framenavigated')
          messages << 'navigated'
        }
      ]
      await_all(promises)
    end

    expect(messages).to eq(%w(route navigated click))
  end

  it 'should await navigation when clicking anchor via $eval', sinatra: true do
    messages = init_server

    with_page do |page|
      page.content = "<a id=\"anchor\" href=\"#{server_empty_page}\" >empty.html</a>"

      promises = [
        Playwright::AsyncEvaluation.new {
          page.eval_on_selector('#anchor', "(anchor) => anchor.click()")
          messages << 'click'
        },
        Playwright::AsyncEvaluation.new {
          page.expect_event('framenavigated')
          messages << 'navigated'
        }
      ]
      await_all(promises)
    end

    expect(messages).to eq(%w(route navigated click))
  end

  it 'should await navigation when clicking anchor via handle.eval', sinatra: true do
    messages = init_server

    with_page do |page|
      page.content = "<a id=\"anchor\" href=\"#{server_empty_page}\" >empty.html</a>"
      handle = page.evaluate_handle('document')

      promises = [
        Playwright::AsyncEvaluation.new {
          handle.evaluate("(doc) => doc.getElementById('anchor').click()")
          messages << 'click'
        },
        Playwright::AsyncEvaluation.new {
          page.expect_event('framenavigated')
          messages << 'navigated'
        }
      ]
      await_all(promises)
    end

    expect(messages).to eq(%w(route navigated click))
  end

  it 'should await navigation when clicking anchor via handle.$eval', sinatra: true do
    messages = init_server

    with_page do |page|
      page.content = "<a id=\"anchor\" href=\"#{server_empty_page}\" >empty.html</a>"
      handle = page.query_selector('body')

      promises = [
        Playwright::AsyncEvaluation.new {
          handle.eval_on_selector('#anchor', "(anchor) => anchor.click()")
          messages << 'click'
        },
        Playwright::AsyncEvaluation.new {
          page.expect_event('framenavigated')
          messages << 'navigated'
        }
      ]
      await_all(promises)
    end

    expect(messages).to eq(%w(route navigated click))
  end

  it 'should await cross-process navigation when clicking anchor', sinatra: true do
    messages = init_server

    with_page do |page|
      page.content = "<a href=\"#{server_cross_process_prefix}/empty.html\" >empty.html</a>"

      promises = [
        Playwright::AsyncEvaluation.new {
          page.click('a')
          messages << 'click'
        },
        Playwright::AsyncEvaluation.new {
          page.expect_event('framenavigated')
          messages << 'navigated'
        }
      ]
      await_all(promises)
    end

    expect(messages).to eq(%w(route navigated click))
  end

  it 'should await cross-process navigation when clicking anchor programatically', sinatra: true do
    messages = init_server

    with_page do |page|
      page.content = "<a id=\"anchor\" href=\"#{server_cross_process_prefix}/empty.html\" >empty.html</a>"

      promises = [
        Playwright::AsyncEvaluation.new {
          page.evaluate('window.anchor.click()')
          messages << 'click'
        },
        Playwright::AsyncEvaluation.new {
          page.expect_event('framenavigated')
          messages << 'navigated'
        }
      ]
      await_all(promises)
    end

    expect(messages).to eq(%w(route navigated click))
  end

  it 'should await form-get on click', sinatra: true do
    messages = init_server

    with_page do |page|
      html = <<~HTML
      <form action="#{server_cross_process_prefix}/empty.html" method="get">
        <input name="foo" value="bar">
        <input type="submit" value="Submit">
      </form>
      HTML
      page.content = html

      promises = [
        Playwright::AsyncEvaluation.new {
          page.click('input[type=submit]')
          messages << 'click'
        },
        Playwright::AsyncEvaluation.new {
          page.expect_event('framenavigated')
          messages << 'navigated'
        }
      ]
      await_all(promises)
    end

    expect(messages).to eq(%w(route navigated click))
  end

  it 'should await form-post on click', sinatra: true do
    messages = init_server

    with_page do |page|
      html = <<~HTML
      <form action="#{server_cross_process_prefix}/empty.html" method="post">
        <input name="foo" value="bar">
        <input type="submit" value="Submit">
      </form>
      HTML
      page.content = html

      promises = [
        Playwright::AsyncEvaluation.new {
          page.click('input[type=submit]')
          messages << 'click'
        },
        Playwright::AsyncEvaluation.new {
          page.expect_event('framenavigated')
          messages << 'navigated'
        }
      ]
      await_all(promises)
    end

    expect(messages).to eq(%w(route navigated click))
  end

  it 'should await navigation when assigning location', sinatra: true do
    messages = init_server

    with_page do |page|
      promises = [
        Playwright::AsyncEvaluation.new {
          page.evaluate("window.location.href = \"#{server_cross_process_prefix}/empty.html\"")
          messages << 'evaluate'
        },
        Playwright::AsyncEvaluation.new {
          page.expect_event('framenavigated')
          messages << 'navigated'
        }
      ]
      await_all(promises)
    end

    expect(messages).to eq(%w(route navigated evaluate))
  end

  it 'should await navigation when assigning location twice', sinatra: true do
    messages = []

    sinatra.get("/empty.html/cancel") { 'done' }
    sinatra.get("/empty.html/override") { messages << 'routeoverride' ; 'done' }

    with_page do |page|
      js = <<~JAVASCRIPT
      window.location.href = "#{server_cross_process_prefix}/empty.html/cancel";
      window.location.href = "#{server_cross_process_prefix}/empty.html/override";
      JAVASCRIPT

      page.evaluate(js)
      messages << 'evaluate'
    end

    expect(messages).to eq(%w(routeoverride evaluate))
  end

  it 'should await navigation when evaluating reload', sinatra: true do
    messages = init_server

    with_page do |page|
      page.goto(server_empty_page)
      messages.clear

      promises = [
        Playwright::AsyncEvaluation.new {
          page.evaluate('window.location.reload()')
          messages << 'evaluate'
        },
        Playwright::AsyncEvaluation.new {
          page.expect_event('framenavigated')
          messages << 'navigated'
        }
      ]
      await_all(promises)
    end

    expect(messages).to eq(%w(route navigated evaluate))
  end

  it 'should await navigating specified target', sinatra: true do
    skip '@see https://github.com/microsoft/playwright/pull/5847/files#r596302374'

    messages = init_server

    with_page do |page|
      html = <<~HTML
      <a href="#{server_empty_page}" target=target>empty.html</a>
      <iframe name=target></iframe>
      HTML
      page.content = html

      frame = page.frame({name: 'target'})
      promises = [
        Playwright::AsyncEvaluation.new {
          page.click('a')
          messages << 'click'
        },
        Playwright::AsyncEvaluation.new {
          page.expect_event('framenavigated')
          messages << 'navigated'
        }
      ]
      await_all(promises)
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
    messages = init_server

    with_page do |page|
      page.content = "<a href=\"#{server_empty_page}\" >empty.html</a>"

      promises = [
        Playwright::AsyncEvaluation.new {
          page.click('a')
          page.wait_for_load_state(state: 'load')
          messages << 'clickload'
        },
        Playwright::AsyncEvaluation.new {
          page.expect_event('framenavigated')
          page.wait_for_load_state(state: 'domcontentloaded')
          messages << 'domcontentloaded'
        }
      ]
      await_all(promises)
    end
    expect(messages).to eq(%w(route domcontentloaded clickload))
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
