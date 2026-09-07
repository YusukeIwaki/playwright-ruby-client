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
      # Assert through public role/name selectors instead of upstream's injected helper.
      expect(page.get_by_role('button', name: 'Query')).to have_count(2)
      expect(page.get_by_role('checkbox', name: 'Flash the screen 5 times.')).to have_id('c1')
      expect(page.get_by_role('heading', name: 'Foo bar')).to have_count(1)
    end
  end
end
