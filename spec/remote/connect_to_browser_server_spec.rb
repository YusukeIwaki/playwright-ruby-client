require 'spec_helper'

RSpec.describe 'Playwright.connect_to_browser_server' do
  around do |example|
    unless ENV['PLAYWRIGHT_BROWSER_WS_ENDPOINT']
      skip 'This spec requires PLAYWRIGHT_BROWSER_WS_ENDPOINT'
    end

    Playwright.connect_to_browser_server(ENV['PLAYWRIGHT_BROWSER_WS_ENDPOINT']) do |browser|
      @browser = browser
      example.run
    end
  end

  def with_page(**kwargs, &block)
    page = @browser.new_page(**kwargs)
    begin
      block.call(page)
    ensure
      page.close unless page.closed?
    end
  end

  def with_context(**kwargs, &block)
    context = @browser.new_context(**kwargs)
    begin
      block.call(context)
    ensure
      context.close
    end
  end

  it 'should work' do
    with_page do |page|
      page.goto('https://github.com/YusukeIwaki')
    end
  end

  it 'should work with tracing' do
    Dir.mktmpdir do |tmpdir|
      with_context do |context|
        context.tracing.start(screenshots: true, snapshots: true)
        page = context.new_page
        page.goto('https://github.com/YusukeIwaki')
        page.screenshot(path: './YusukeIwaki.png')
        context.tracing.stop(path: File.join(tmpdir, 'trace.zip'))
      end
    end
  end
end
