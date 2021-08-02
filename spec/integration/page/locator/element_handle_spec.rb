require 'spec_helper'

RSpec.describe 'Locator' do
  it 'should query existing element' do
    with_page do |page|
      page.content = '<html><body><div class="second"><div class="inner">A</div></div></body></html>'
      html = page.locator('html')
      second = html.locator('.second')
      inner = second.locator('.inner')
      content = page.evaluate('e => e.textContent', arg: inner.element_handle)
      expect(content).to eq('A')
    end
  end

  it 'should query existing elements' do
    with_page do |page|
      page.content = '<html><body><div>A</div><br/><div>B</div></body></html>'
      html = page.locator('html')
      elements = html.locator('div').element_handles
      expect(elements.size).to eq(2)
      values = elements.map do |element|
        page.evaluate('e => e.textContent', arg: element)
      end
      expect(values).to eq(%w[A B])
    end
  end

  it 'should return empty array for non-existing elements' do
    with_page do |page|
      page.content = '<html><body><span>A</span><br/><span>B</span></body></html>'
      html = page.locator('html')
      elements = html.locator('div').element_handles
      expect(elements).to be_a(Array)
      expect(elements).to be_empty
    end
  end

  it 'xpath should query existing element' do
    with_page do |page|
      page.content = '<html><body><div class="second"><div class="inner">A</div></div></body></html>'
      html = page.locator('html')
      second = html.locator("xpath=./body/div[contains(@class, 'second')]")
      inner = second.locator("xpath=./div[contains(@class, 'inner')]")
      content = page.evaluate('e => e.textContent', arg: inner.element_handle)
      expect(content).to eq('A')
    end
  end

  it 'xpath should return null for non-existing element' do
    with_page do |page|
      page.content = '<html><body><div class="second"><div class="inner">B</div></div></body></html>'
      html = page.locator('html')
      elements = html.locator("xpath=/div[contains(@class, 'third')]").element_handles
      expect(elements).to be_a(Array)
      expect(elements).to be_empty
    end
  end
end
