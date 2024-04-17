require 'spec_helper'

RSpec.describe 'ElementHandle misc' do
  it 'should focus a button', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/button.html")
      button = page.query_selector('button')
      expect(button.evaluate('(button) => document.activeElement === button')).to eq(false)
      button.focus
      expect(button.evaluate('(button) => document.activeElement === button')).to eq(true)
    end
  end

  it 'should allow disposing twice' do
    with_page do |page|
      page.content = '<section>39</section>'
      element = page.query_selector('section')
      expect(element).to be_a(Playwright::ElementHandle)
      element.dispose
      element.dispose
    end
  end
end
