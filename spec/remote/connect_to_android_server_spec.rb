require 'spec_helper'

RSpec.describe 'Playwright.connect_to_android_server' do
  around do |example|
    unless ENV['PLAYWRIGHT_ANDROID_WS_ENDPOINT']
      skip 'This spec requires PLAYWRIGHT_ANDROID_WS_ENDPOINT'
    end

    Playwright.connect_to_android_server(ENV['PLAYWRIGHT_ANDROID_WS_ENDPOINT']) do |android|
      @android = android
      example.run
    end
  end

  def with_page(**kwargs, &block)
    context = @android.launch_browser
    page = context.pages.last
    begin
      block.call(page)
    ensure
      page.close unless page.closed?
    end
  end

  it 'should work' do
    puts "Connected to Android device: #{@android.model} (#{@android.serial})"
    expect(@android.serial).not_to be_nil
    expect(@android.model).not_to be_nil

    with_page do |page|
      page.goto('https://github.com/YusukeIwaki')
      page.screenshot(path: 'screenshot.png')
    end
  end
end
