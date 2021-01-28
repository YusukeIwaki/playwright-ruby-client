require 'spec_helper'

RSpec.describe 'spec_helper' do
  it 'browser_type', skip: ENV['BROWSER'].nil? do
    expect(chromium?).to eq(ENV['BROWSER'] == 'chromium')
    expect(webkit?).to eq(ENV['BROWSER'] == 'webkit')
    expect(firefox?).to eq(ENV['BROWSER'] == 'firefox')
  end
end
