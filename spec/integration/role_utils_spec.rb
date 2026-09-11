require 'spec_helper'
require 'playwright/test'

# https://github.com/microsoft/playwright/blob/v1.63.0/tests/library/role-utils.spec.ts
RSpec.describe 'role utils' do
  include Playwright::Test::Matchers

  it 'searchbox embedded control should contribute its value' do
    with_page do |page|
      page.content = <<~HTML
        <button id="b1" aria-labelledby="l1"></button><div id="l1" hidden><input type="text" value="Query"></div>
        <button id="b2" aria-labelledby="l2"></button><div id="l2" hidden><input type="search" value="Query"></div>
        <label for="c1">Flash the screen <input type="search" value="5"> times.</label>
        <input type="checkbox" id="c1">
        <h1><input type="search" value="Foo bar"></h1>
      HTML
      # Assert each element's role and exact accessible name through public APIs.
      expect(page.locator('#b1')).to have_role('button')
      expect(page.locator('#b1')).to have_accessible_name('Query')
      expect(page.locator('#b2')).to have_role('button')
      expect(page.locator('#b2')).to have_accessible_name('Query')
      expect(page.locator('#c1')).to have_role('checkbox')
      expect(page.locator('#c1')).to have_accessible_name('Flash the screen 5 times.')
      expect(page.locator('h1')).to have_role('heading')
      expect(page.locator('h1')).to have_accessible_name('Foo bar')
    end
  end
end
