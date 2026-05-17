require 'spec_helper'

RSpec.describe 'Browser' do
  it 'should return browserType' do
    expect(browser.browser_type).to eq(browser_type)
  end

  # https://github.com/microsoft/playwright/blob/v1.60.0/tests/library/browser.spec.ts
  it 'should fire context event on newContext' do
    events = []
    browser.on('context', ->(context) { events << context })
    context = browser.new_context
    expect(events).to eq([context])
    context.close
  end
end
