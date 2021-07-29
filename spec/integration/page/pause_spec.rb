require 'spec_helper'

RSpec.describe 'Page#pause' do
  it 'cannot pause without debug_console enabled', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      expect { page.pause }.to raise_error(/calling `browser_context.enable_debug_console!`/)
    end
  end

  it 'can pause and resume', sinatra: true do
    skip 'works only in Headful mode.'

    with_page do |page|
      page.context.enable_debug_console!
      page.goto(server_empty_page)
      promise = Concurrent::Promises.future do
        page.pause
      end
      sleep 1
      expect(promise).not_to be_resolved
      page.evaluate('() => playwright.resume()')
      Timeout.timeout(1) { promise.value! }
    end
  end
end
