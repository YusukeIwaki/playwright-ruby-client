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

    it 'should connect to an existing cdp session twice' do
      browser_server = browser_type.launch(args: ["--remote-debugging-port=9339"])
      cdp_browsers = 2.times.map { browser_type.connect_over_cdp("http://localhost:9339/") }
      expect(cdp_browsers.first.contexts.size).to eq(1)
      cdp_browsers.first.contexts.first.new_page
      expect(cdp_browsers.last.contexts.size).to eq(1)
      cdp_browsers.last.contexts.first.new_page

      expect(cdp_browsers.first.contexts.first.pages.size).to eq(2)
      expect(cdp_browsers.last.contexts.first.pages.size).to eq(2)

      cdp_browsers.map(&:close)
      browser_server.close
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
  end
end
