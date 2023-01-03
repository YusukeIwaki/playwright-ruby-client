require 'spec_helper'

RSpec.describe 'Locator' do
  it 'locator.all should work' do
    with_page do |page|
      page.content = "<div><p>A</p><p>B</p><p>C</p></div>"

      texts = page.locator('div >> p').all.map(&:text_content)
      expect(texts).to eq(%w[A B C])

      expect(page.locator('span').all.to_a).to be_empty
    end
  end
end
