require 'spec_helper'
require 'net/http'

RSpec.describe 'chromium' do
  before { skip unless chromium? }

  example_group 'ServiceWorker' do
    it 'should create a worker from a service worker', sinatra: true do
      with_page do |page|
        worker = page.context.expect_event('serviceworker') do
          page.goto("#{server_prefix}/serviceworkers/empty/sw.html")
        end
        expect(worker.evaluate('() => self.toString()')).to eq('[object ServiceWorkerGlobalScope]')
      end
    end

    it 'service_workers should return current workers', sinatra: true do
      with_context do |context|
        page = context.new_page
        worker = page.context.expect_event('serviceworker') do
          page.goto("#{server_prefix}/serviceworkers/empty/sw.html")
        end
        expect(context.service_workers.size).to eq(1)

        worker2 = page.context.expect_event('serviceworker') do
          page.goto("#{server_cross_process_prefix}/serviceworkers/empty/sw.html")
        end
        expect(context.service_workers.size).to eq(2)

        expect(context.service_workers).to include(worker)
        expect(context.service_workers).to include(worker2)
      end
    end

    it 'should not create a worker from a shared worker', sinatra: true do
      with_page do |page|
        page.goto(server_empty_page)
        page.evaluate("() => { new SharedWorker('data:text/javascript,console.log(\"hi\")'); }")
        expect(page.context.service_workers).to be_empty
      end
    end
  end

  example_group 'CDPSession' do
    before(:all) do
      @execution = Playwright.create(playwright_cli_executable_path: ENV['PLAYWRIGHT_CLI_EXECUTABLE_PATH'])
      @playwright_chromium = @execution.playwright.chromium
    end
    after(:all) do
      @execution.stop
    end
    let(:browser_type) { @playwright_chromium }

    it 'should connect to an existing cdp session' do
      browser_server = browser_type.launch(args: ["--remote-debugging-port=9339"])
      cdp_browser = browser_type.connect_over_cdp("http://localhost:9339/")
      expect(cdp_browser.contexts.size).to eq(1)
      cdp_browser.close
      browser_server.close
    end

    # https://github.com/microsoft/playwright/blob/v1.65.1/tests/library/chromium/connect-over-cdp.spec.ts
    it 'should connect to an existing cdp session twice', sinatra: true do
      browser_server = browser_type.launch(args: ["--remote-debugging-port=9339"])
      begin
        cdp_browser1 = browser_type.connect_over_cdp('http://127.0.0.1:9339/')
        cdp_browser2 = browser_type.connect_over_cdp('http://127.0.0.1:9339/')
        contexts1 = cdp_browser1.contexts
        expect(contexts1.size).to eq(1)
        context1 = contexts1.first
        page1 = context1.new_page
        page1.goto(server_empty_page)

        contexts2 = cdp_browser2.contexts
        expect(contexts2.size).to eq(1)
        context2 = contexts2.first
        page2 = context2.new_page
        page2.goto(server_empty_page)

        expect(context1.pages.size).to eq(2)
        expect(context2.pages.size).to eq(2)

        page1.evaluate("() => alert('dialog race')")
        expect(context2.pages.first.title).to eq('')

        cdp_browser1.close
        cdp_browser2.close
      ensure
        browser_server.close
      end
    end

    it 'should connect over a ws endpoint' do
      browser_server = browser_type.launch(args: ["--remote-debugging-port=9339"])
      resp = Net::HTTP.get_response(URI('http://localhost:9339/json/version/'))
      json = JSON.parse(resp.body)
      cdp_browser = browser_type.connect_over_cdp(json['webSocketDebuggerUrl'])
      expect(cdp_browser.contexts.size).to eq(1)
      cdp_browser.close
      browser_server.close
    end

    it 'should send extra headers with connect request' do
      browser_server = browser_type.launch(args: ["--remote-debugging-port=9339"])
      resp = Net::HTTP.get_response(URI('http://localhost:9339/json/version/'))
      json = JSON.parse(resp.body)
      headers = {
        'User-Agent' => 'Playwright',
        'foo' => 'bar',
      }
      cdp_browser = browser_type.connect_over_cdp(json['webSocketDebuggerUrl'], headers: headers)

      # TODO: check

      cdp_browser.close
      browser_server.close
    end

    it 'should skip default overrides with noDefaults', sinatra: true do
      sinatra.get('/download') do
        response.headers['Content-Type'] = 'application/octet-stream'
        response.headers['Content-Disposition'] = 'attachment; filename=file.txt'
        'Hello world'
      end

      browser_server = browser_type.launch(args: ["--remote-debugging-port=9339"])
      cdp_browser = nil
      begin
        cdp_browser = browser_type.connect_over_cdp('http://127.0.0.1:9339/', noDefaults: true)
        default_context = cdp_browser.contexts[0]
        page = default_context.new_page

        page.content = %(<a href="#{server_prefix}/download">download</a>)
        saw_download = false
        page.on('download', ->(_download) { saw_download = true })
        page.click('a')
        page.wait_for_timeout(500)
        expect(saw_download).to eq(false)
      ensure
        cdp_browser&.close
        browser_server.close
      end
    end

    it 'noDefaults should not affect new contexts' do
      browser_server = browser_type.launch(args: ["--remote-debugging-port=9339"])
      cdp_browser = nil
      begin
        cdp_browser = browser_type.connect_over_cdp('http://127.0.0.1:9339/', noDefaults: true)
        new_context = cdp_browser.new_context
        page = new_context.new_page
        expect(page.evaluate('() => document.hasFocus()')).to eq(true)
        new_context.close
      ensure
        cdp_browser&.close
        browser_server.close
      end
    end
  end
end
