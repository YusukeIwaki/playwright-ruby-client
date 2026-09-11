require 'spec_helper'
require 'playwright/test'

# https://github.com/microsoft/playwright/blob/v1.63.0/tests/page/locator-misc-2.spec.ts
RSpec.describe 'Locator#visible' do
  include Playwright::Test::Matchers

  it 'should support visible()' do
    with_page do |page|
      page.content = <<~HTML
        <div>
          <div class="item" style="display: none">Hidden data0</div>
          <div class="item">visible data1</div>
          <div class="item" style="display: none">Hidden data1</div>
          <div class="item">visible data2</div>
          <div class="item" style="display: none">Hidden data2</div>
          <div class="item">visible data3</div>
        </div>
      HTML
      expect(page.locator('.item').visible.nth(1)).to have_text('visible data2')
      expect(page.locator('.item').visible.get_by_text('data3')).to have_text('visible data3')
      expect(page.locator('.item').visible).to have_count(3)
    end
  end
end
