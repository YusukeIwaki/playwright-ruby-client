require 'spec_helper'
require 'playwright/test'

# https://github.com/microsoft/playwright/blob/v1.60.0/tests/library/locator-highlight.spec.ts
RSpec.describe 'Locator highlight', playwright_under_test: true do
  include Playwright::Test::Matchers

  it 'should highlight locator', sinatra: true do
    with_context do |context|
      page = context.new_page
      page.goto("#{server_prefix}/input/button.html")

      page.get_by_role('button').highlight

      highlight = page.locator('x-pw-highlight')
      expect(highlight).to be_visible
      expect(highlight.bounding_box).to eq(page.get_by_role('button').bounding_box)
    end
  end

  it 'highlight should accept a CSS string style', sinatra: true do
    with_context do |context|
      page = context.new_page
      page.goto("#{server_prefix}/input/button.html")

      page.get_by_role('button').highlight(style: 'outline: 3px solid rgb(255, 0, 0); background-color: rgba(0, 255, 0, 0.25)')

      highlight = page.locator('x-pw-highlight')
      expect(highlight).to be_visible
      style = highlight.evaluate(<<~JAVASCRIPT)
        (el) => ({
          outline: el.style.outline,
          backgroundColor: el.style.backgroundColor,
        })
      JAVASCRIPT
      expect(style['outline']).to eq('rgb(255, 0, 0) solid 3px')
      expect(style['backgroundColor']).to eq('rgba(0, 255, 0, 0.25)')
    end
  end

  it 'hideHighlight removes a styled highlight', sinatra: true do
    with_context do |context|
      page = context.new_page
      page.goto("#{server_prefix}/input/button.html")

      button = page.get_by_role('button')
      button.highlight(style: 'outline: 2px solid red')
      expect(page.locator('x-pw-highlight')).to be_visible

      button.hide_highlight
      expect(page.locator('x-pw-highlight')).to have_count(0)
    end
  end

  it 'Page.hideHighlight clears all locator highlights' do
    with_context do |context|
      page = context.new_page
      page.content = '<button>One</button><button>Two</button>'

      page.get_by_role('button', name: 'One').highlight
      page.get_by_role('button', name: 'Two').highlight
      expect(page.locator('x-pw-highlight')).to have_count(2)

      page.hide_highlight
      expect(page.locator('x-pw-highlight')).to have_count(0)
    end
  end
end
