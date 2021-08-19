require 'spec_helper'

RSpec.describe 'strictSelectors' do
  it 'should not fail page.textContent in non-strict mode' do
    with_page do |page|
      page.content = '<span>span1</span><div><span>target</span></div>'
      expect(page.text_content('span')).to eq('span1')
    end
  end

  context 'with strict context mode' do
    it 'should fail page.textContent in strict mode' do
      with_page(strictSelectors: true) do |page|
        page.content = '<span>span1</span><div><span>target</span></div>'
        expect { page.text_content('span') }.to raise_error(/strict mode violation/)
      end
    end

    it 'should opt out of strict mode' do
      with_page(strictSelectors: true) do |page|
        page.content = '<span>span1</span><div><span>target</span></div>'
        expect(page.text_content('span', strict: false)).to eq('span1')
      end
    end
  end
end
