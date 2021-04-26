require 'spec_helper'
require 'net/http'

RSpec.describe 'chromium' do
  around do |example|
    Playwright.create(playwright_cli_executable_path: ENV['PLAYWRIGHT_CLI_EXECUTABLE_PATH']) do |playwright|
      @playwright_chromium = playwright.chromium

      Timeout.timeout(5) { example.run }
    end
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
end
