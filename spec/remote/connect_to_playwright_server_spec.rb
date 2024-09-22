require 'spec_helper'

RSpec.describe 'Playwright.connect_to_playwright_server' do
  around do |example|
    unless ENV['PLAYWRIGHT_SERVER_WS_ENDPOINT']
      skip 'This spec requires PLAYWRIGHT_SERVER_WS_ENDPOINT'
    end

    Playwright.connect_to_playwright_server(ENV['PLAYWRIGHT_SERVER_WS_ENDPOINT']) do |playwright|
      @playwright = playwright
      example.run
    end
  end

  def with_chromium_context(**kwargs, &block)
    browser = @playwright.chromium.launch
    begin
      context = browser.new_context(**kwargs)
      block.call(context)
    ensure
      browser.close
    end
  end

  it 'should work' do
    with_chromium_context do |context|
      page = context.new_page
      page.goto('https://github.com/YusukeIwaki')
    end
  end

  it 'should work with tracing' do
    Dir.mktmpdir do |tmpdir|
      with_chromium_context do |context|
        context.tracing.start(screenshots: true, snapshots: true)
        page = context.new_page
        page.goto('https://github.com/YusukeIwaki')
        page.screenshot(path: './YusukeIwaki.png')
        context.tracing.stop(path: File.join(tmpdir, 'trace.zip'))
      end
    end
  end
end
