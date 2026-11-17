require 'spec_helper'
require 'playwright/test'

# https://github.com/microsoft/playwright/blob/release-1.65/tests/page/expect-to-have-text.spec.ts
RSpec.describe 'toHaveText with text' do
  include Playwright::Test::Matchers

  it 'EX-281 pass contain' do
    with_page do |page|
      page.set_content('<div id=node>Text content</div>')
      locator = page.locator('#node')
      expect(locator).to contain_text('Text')
      # Should normalize whitespace.
      expect(locator).to contain_text("   ext        cont\n  ")
      # Should support ignoreCase.
      expect(locator).to contain_text('EXT', ignoreCase: true)
      # Should support falsy ignoreCase.
      expect(locator).not_to contain_text('TEXT', ignoreCase: false)
    end
  end

  it 'EX-282 fail' do
    with_page do |page|
      page.set_content('<div id=node>Text content</div>')
      locator = page.locator('#node')
      expect {
        expect(locator).to have_text('Text', timeout: 1000)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError) { |error|
        expect(error.message).to include("Locator expected to have text 'Text'")
        expect(error.message).to include('Actual value Text content')
      }
    end
  end

  it 'EX-286 fail with impossible timeout' do
    with_page do |page|
      page.set_content('<div id=node>Text content</div>')
      expect {
        expect(page.locator('#node')).to have_text('Text', timeout: 1)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError) { |error|
        expect(error.message).to include("Locator expected to have text 'Text'")
        expect(error.message).to include('Actual value Text content')
      }
    end
  end
end
