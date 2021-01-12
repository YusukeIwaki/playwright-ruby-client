require 'spec_helper'

RSpec.describe 'example' do
  it 'should take a screenshot' do
    page = browser.new_page
    page.goto('https://github.com/YusukeIwaki')
    page.screenshot(path: './YusukeIwaki.png')
  end
end
