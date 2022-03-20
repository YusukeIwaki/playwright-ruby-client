require 'spec_helper'

RSpec.describe 'Locator' do
  it 'should highlight locator', pending: 'Requires isUnderTest to be true https://github.com/microsoft/playwright/pull/12420' do
    with_page do |page|
      page.content = "<input type='text' />"
      page.locator('input').highlight
      x=page.locator('x-pw-tooltip').locator('text=input').element_handle
      expect(page.locator('x-pw-highlight')).to be_visible
      box1 = page.locator('input').bounding_box
      box2 = page.locator('x-pw-highlight').bounding_box
      expect(box2).to eq(box1)
    end
  end
end
