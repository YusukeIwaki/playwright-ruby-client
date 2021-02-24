require 'spec_helper'

RSpec.describe Playwright::BrowserContext do
  it 'should create new context' do
    expect(browser.contexts).to be_empty
    with_context do |context|
      expect(browser.contexts.count).to eq(1)
      expect(browser.contexts.first).to eq(context)
      expect(browser).to eq(context.browser)
    end
    expect(browser.contexts).to be_empty
  end
end
