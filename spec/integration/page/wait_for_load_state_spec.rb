require 'spec_helper'

# https://github.com/microsoft/playwright/blob/main/tests/page/page-wait-for-load-state.spec.ts
RSpec.describe 'Page#wait_for_load_state' do
  it 'should respect timeout', sinatra: true do
    with_page do |page|
      sinatra.get('/one-style.css') do
        sleep 0.5
      end
      page.goto("#{server_prefix}/one-style.html", waitUntil: 'domcontentloaded')
      expect { page.wait_for_load_state(state: 'load', timeout: 10) }.to raise_error(/Timeout 10ms exceeded./)
    end
  end

  it 'should resolve immediately if loaded', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/one-style.html")
      page.wait_for_load_state
    end
  end

  it 'should resolve immediately if load state matches', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      sinatra.get('/one-style.css') do
        sleep 0.5
      end
      page.goto("#{server_prefix}/one-style.html", waitUntil: 'domcontentloaded')
      page.wait_for_load_state(state: 'domcontentloaded', timeout: 10)
    end
  end
end

RSpec.describe 'wait_for_load_state - bugfix' do
  it 'should not notify waitForEventInfo twice', sinatra: true do
    # https://github.com/YusukeIwaki/playwright-ruby-client/issues/285
    # https://github.com/YusukeIwaki/capybara-playwright-driver/issues/72
    sinatra.get('/xx') do
      '<h1>It works!</h1>'
    end

    with_page do |page|
      page.goto("#{server_prefix}/xx")
      page.wait_for_load_state(state: 'networkidle', timeout: 1000)
      sleep 2
    end
  end
end
