require 'spec_helper'

RSpec.describe 'BrowserContext (service_workers)', sinatra: true do
  it 'should allow service workers by default' do
    with_page do |page|
      page.goto("#{server_prefix}/serviceworkers/empty/sw.html")
      expect(page.evaluate("() => window['registrationPromise']")).not_to be_nil
    end

    with_context(serviceWorkers: 'allow') do |context|
      page = context.new_page
      page.goto("#{server_prefix}/serviceworkers/empty/sw.html")
      expect(page.evaluate("() => window['registrationPromise']")).not_to be_nil
    end
  end

  it 'blocks service worker registration' do
    with_context(serviceWorkers: 'block') do |context|
      page = context.new_page
      message = page.expect_console_message do
        page.goto("#{server_prefix}/serviceworkers/empty/sw.html")
      end
      expect(message.text).to eq('Service Worker registration blocked by Playwright')
      expect(page.evaluate("() => window['registrationPromise']")).to be_nil
    end
  end
end
