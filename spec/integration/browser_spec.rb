require 'spec_helper'

RSpec.describe 'Browser' do
  it 'should return browserType' do
    expect(browser.browser_type).to eq(browser_type)
  end
end
