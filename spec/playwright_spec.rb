# frozen_string_literal: true

RSpec.describe Playwright do
  it 'has a version number' do
    expect(Playwright::VERSION).not_to be nil
  end
end
