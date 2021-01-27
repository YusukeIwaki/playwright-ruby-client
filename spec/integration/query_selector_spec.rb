require 'spec_helper'

RSpec.describe 'query selector' do
  it 'should throw for non-string selector' do
    with_page do |page|
      expect { page.query_selector(nil) }.to raise_error(/selector: expected string, got object/)
    end
  end

  it 'should query existing element with css selector' do
    with_page do |page|
      page.content = '<section>test</section>'
      element = page.query_selector('css=section')
      expect(element).to be_a(Playwright::ElementHandle)
    end
  end

  it 'should query existing element with text selector' do
    with_page do |page|
      page.content = '<section>test</section>'
      element = page.query_selector('text=test')
      expect(element).to be_a(Playwright::ElementHandle)
    end
  end

  it 'should query existing element with xpath selector' do
    with_page do |page|
      page.content = '<section>test</section>'
      element = page.query_selector('xpath=/html/body/section')
      expect(element).to be_a(Playwright::ElementHandle)
    end
  end

  it 'should return null for non-existing element' do
    with_page do |page|
      page.content = '<section>test</section>'
      element = page.query_selector('non-existing-element')
      expect(element).to be_nil
    end
  end

  it 'should auto-detect xpath selector' do
    with_page do |page|
      page.content = '<section>test</section>'
      element = page.query_selector('//html/body/section')
      expect(element).to be_a(Playwright::ElementHandle)
    end
  end

  it 'should auto-detect xpath selector with starting parenthesis' do
    with_page do |page|
      page.content = '<section>test</section>'
      element = page.query_selector('(//section)[1]')
      expect(element).to be_a(Playwright::ElementHandle)
    end
  end

  it 'should auto-detect xpath selector starting with ..' do
    with_page do |page|
      page.content = '<div><section>test</section><span></span></div>'
      span = page.query_selector('"test" >> ../span')
      expect(span.evaluate('e => e.nodeName')).to eq('SPAN')
      div = page.query_selector('"test" >> ..')
      expect(div.evaluate('e => e.nodeName')).to eq('DIV')
    end
  end

  it 'should auto-detect text selector' do
    with_page do |page|
      page.content = '<section>test</section>'
      element = page.query_selector('"test"')
      expect(element).to be_a(Playwright::ElementHandle)
    end
  end

  it 'should auto-detect css selector' do
    with_page do |page|
      page.content = '<section>test</section>'
      element = page.query_selector('section')
      expect(element).to be_a(Playwright::ElementHandle)
    end
  end

  it 'should support >> syntax' do
    with_page do |page|
      page.content = '<section><div>test</div></section>'
      element = page.query_selector('css=section >> css=div')
      expect(element).to be_a(Playwright::ElementHandle)
    end
  end

  it 'should query existing elements' do
    with_page do |page|
      page.content = '<div>A</div><br/><div>B</div>'
      elements = page.query_selector_all('div')
      expect(elements.count).to eq(2)
      expect(elements.map { |el| page.evaluate('e => e.textContent', arg: el) }).to eq(['A', 'B'])
    end
  end

  it 'should return empty array if nothing is found', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      elements = page.query_selector_all('div')
      expect(elements).to be_empty
    end
  end

  it 'xpath should query existing element' do
    with_page do |page|
      page.content = '<section>test</section>'
      elements = page.query_selector_all('xpath=/html/body/section')
      expect(elements.count).to eq(1)
      expect(elements.first).to be_a(Playwright::ElementHandle)
    end
  end

  it 'xpath should return empty array for non-existing element' do
    with_page do |page|
      elements = page.query_selector_all('//html/body/non-existing-element')
      expect(elements).to be_empty
    end
  end

  it 'xpath should return multiple elements' do
    with_page do |page|
      page.content = '<div></div><div></div>'
      elements = page.query_selector_all('xpath=/html/body/div')
      expect(elements.count).to eq(2)
    end
  end

  it '$$ should work with bogus Array.from' do
    with_page do |page|
      page.content = '<div>hello</div><div></div>'
      js = <<~JAVASCRIPT
      () => {
        Array.from = () => [];
        return document.querySelector('div');
      }
      JAVASCRIPT
      div1 = page.evaluate_handle(js)

      elements = page.query_selector_all('div')
      expect(elements.count).to eq(2)

      # Check that element handle is functional and belongs to the main world.
      expect(elements.first.evaluate('(div, div1) => div === div1', arg: div1)).to eq(true)
    end
  end
end
