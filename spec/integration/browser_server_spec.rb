require 'json'
require 'tmpdir'

require 'spec_helper'

# https://github.com/microsoft/playwright/blob/release-1.60/tests/library/browser-server.spec.ts
RSpec.describe 'browser server', playwright_server_registry: true do
  before { skip 'browser.bind is not available in remote mode' if remote? }

  it 'should start and stop pipe server' do
    server_info = browser.bind('default')
    expect(server_info['endpoint']).to match(/browser@/)

    browser2 = browser_type.connect(server_info['endpoint'])
    page = browser2.new_page
    page.goto('data:text/html,<h1>Hello via pipe</h1>')
    expect(page.locator('h1').text_content).to eq('Hello via pipe')
    page.close
    browser2.close
    browser.unbind
  end

  it 'should write descriptor on start and remove on stop' do
    server_info = browser.bind('my-title')

    registry_dir = ENV.fetch('PLAYWRIGHT_SERVER_REGISTRY')
    file_name = Dir.children(registry_dir).first
    file = File.join(registry_dir, file_name)

    descriptor = JSON.parse(File.read(file))
    expect(descriptor['title']).to eq('my-title')
    expect(descriptor['playwrightVersion']).to be_truthy
    expect(descriptor['playwrightLib']).to be_truthy
    expect(descriptor.dig('browser', 'browserName')).to be_truthy
    expect(descriptor['endpoint']).to eq(server_info['endpoint'])

    expect(File.exist?(server_info['endpoint'])).to eq(true) unless Gem.win_platform?

    browser.unbind
    expect(File.exist?(file)).to eq(false)
    expect(File.exist?(server_info['endpoint'])).to eq(false) unless Gem.win_platform?
  end

  it 'should start ws server with host/port and produce well-formed endpoint' do
    server_info = browser.bind('default', host: 'localhost', port: 0)
    expect(server_info['endpoint']).to match(%r{\Aws://(127\.0\.0\.1|\[::1\]):\d+/[a-f0-9]+\z})

    browser2 = browser_type.connect(server_info['endpoint'])
    page = browser2.new_page
    page.goto('data:text/html,<h1>Hello via ws</h1>')
    expect(page.locator('h1').text_content).to eq('Hello via ws')
    page.close
    browser2.close
    browser.unbind
  end
end
