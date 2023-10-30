require 'spec_helper'

RSpec.describe 'Locator' do
  it 'locator.all should work' do
    with_page do |page|
      page.content = "<div><p id='a'>A</p><p id='b'>B</p><p id='c'>C</p></div>"

      texts = page.locator('div >> p').all.map(&:text_content)
      expect(texts).to eq(%w[A B C])

      ids = page.locator('div >> p').all.map { |p| p['id'] }
      expect(ids).to eq(%w[a b c])

      expect(page.locator('span').all.to_a).to be_empty
    end
  end
end
