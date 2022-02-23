require 'spec_helper'

RSpec.describe 'Locator' do
  it 'should respect first() and last()' do
    with_page do |page|
      page.content = <<~HTML
      <section>
        <div><p>A</p></div>
        <div><p>A</p><p>A</p></div>
        <div><p>A</p><p>A</p><p>A</p></div>
      </section>
      HTML

      expect(page.locator('div >> p').count).to eq(6)
      expect(page.locator('div').locator('p').count).to eq(6)
      expect(page.locator('div').first.locator('p').count).to eq(1)
      expect(page.locator('div').last.locator('p').count).to eq(3)
    end
  end

  it 'should respect nth()' do
    with_page do |page|
      page.content = <<~HTML
      <section>
        <div><p>A</p></div>
        <div><p>A</p><p>A</p></div>
        <div><p>A</p><p>A</p><p>A</p></div>
      </section>
      HTML

      expect(page.locator('div >> p').nth(0).count).to eq(1)
      expect(page.locator('div').nth(1).locator('p').count).to eq(2)
      expect(page.locator('div').nth(2).locator('p').count).to eq(3)
    end
  end

  it 'should throw on capture w/ nth()' do
    with_page do |page|
      page.content = '<section><div><p>A</p></div></section>'
      expect { page.locator('*css=div >> p').nth(1).click }.to raise_error(/Can't query n-th element/)
    end
  end

  it 'should throw on due to strictness' do
    with_page do |page|
      page.content = '<div>A</div><div>B</div>'
      expect { page.locator('div').visible? }.to raise_error(/strict mode violation/)
    end
  end

  it 'should throw on due to strictness' do
    with_page do |page|
      page.content = '<select><option>One</option><option>Two</option></select>'
      expect { page.locator('option').evaluate('e => {}') }.to raise_error(/strict mode violation/)
    end
  end

  it 'should filter by text' do
    with_page do |page|
      page.content = '<div>Foobar</div><div>Bar</div>'
      expect(page.locator('div', hasText: 'Foo').text_content).to eq('Foobar')
    end
  end

  it 'should filter by text' do
    with_page do |page|
      page.content = '<div>foo <span>hello world</span> bar</div>'
      expect(page.locator('div', hasText: 'hello world').text_content).to eq('foo hello world bar')
    end
  end


  it 'should filter by regex' do
    with_page do |page|
      page.content = '<div>Foobar</div><div>Bar</div>'
      expect(page.locator('div', hasText: /Foo.*/).text_content).to eq('Foobar')
    end
  end

  it 'should filter by text with quotes' do
    with_page do |page|
      page.content = '<div>Hello "world"</div><div>Hello world</div>'
      expect(page.locator('div', hasText: 'Hello "world"').text_content).to eq('Hello "world"')
    end
  end

  it 'should filter by regex with quotes' do
    with_page do |page|
      page.content = '<div>Hello "world"</div><div>Hello world</div>'
      expect(page.locator('div', hasText: /Hello "world"/).text_content).to eq('Hello "world"')
    end
  end

  it 'should filter by regex and regexp flags' do
    with_page do |page|
      page.content = '<div>Hello "world"</div><div>Hello world</div>'
      expect(page.locator('div', hasText: /hElLo "world"/i).text_content).to eq('Hello "world"')
    end
  end

  it 'should support has:locator' do
    with_page do |page|
      page.content = '<div><span>hello</span></div><div><span>world</span></div>'
      expect(page.locator('div', has: page.locator('text=world')).count).to eq(1)
      expect(page.locator('div', has: page.locator('text=world')).evaluate('e => e.outerHTML')).to eq('<div><span>world</span></div>')

      expect(page.locator('div', has: page.locator('text=hello')).count).to eq(1)
      expect(page.locator('div', has: page.locator('text=hello')).evaluate('e => e.outerHTML')).to eq('<div><span>hello</span></div>')

      expect(page.locator('div', has: page.locator('xpath=./span')).count).to eq(2)
      expect(page.locator('div', has: page.locator('span')).count).to eq(2)
      expect(page.locator('div', has: page.locator('span', hasText: 'wor')).count).to eq(1)
      expect(page.locator('div', has: page.locator('span', hasText: 'wor')).evaluate('e => e.outerHTML')).to eq('<div><span>world</span></div>')
      expect(page.locator('div', has: page.locator('span'), hasText: 'wor').count).to eq(1)
    end
  end

  it 'should enforce same frame for has:locator', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/frames/two-frames.html")
      child = page.frames[1]
      expect {
        page.locator('div', has: child.locator('span'))
      }.to raise_error(/Inner "has" locator must belong to the same frame./)
    end
  end
end
