require 'spec_helper'

RSpec.describe 'selector/text' do
  it 'should work @smoke' do
    with_page do |page|
      page.content = '<div>yo</div><div>ya</div><div>\nye  </div>'
      expect(page.eval_on_selector('text=ya', 'e => e.outerHTML')).to eq('<div>ya</div>')
      expect(page.eval_on_selector('text=/^[ay]+$/', 'e => e.outerHTML')).to eq('<div>ya</div>')
      expect(page.eval_on_selector('text=/Ya/i', 'e => e.outerHTML')).to eq('<div>ya</div>')
      expect(page.eval_on_selector('text=ye', 'e => e.outerHTML')).to eq('<div>\nye  </div>')
      expect(page.get_by_text('ye').evaluate('e => e.outerHTML')).to eq('<div>\nye  </div>')

      page.content = '<div> ye </div><div>ye</div>'
      expect(page.eval_on_selector('text="ye"', 'e => e.outerHTML')).to eq('<div> ye </div>')
      expect(page.get_by_text('ye', exact: true).first.evaluate('e => e.outerHTML')).to eq('<div> ye </div>')

      page.content = '<div>yo</div><div>"ya</div><div> hello world! </div>'
      expect(page.eval_on_selector('text="\"ya"', 'e => e.outerHTML')).to eq('<div>"ya</div>')
      expect(page.eval_on_selector('text=/hello/', 'e => e.outerHTML')).to eq('<div> hello world! </div>')
      expect(page.eval_on_selector('text=/^\s*heLLo/i', 'e => e.outerHTML')).to eq('<div> hello world! </div>')

      page.content = '<div>yo<div>ya</div>hey<div>hey</div></div>'
      expect(page.eval_on_selector('text=hey', 'e => e.outerHTML')).to eq('<div>hey</div>')
      expect(page.eval_on_selector('text=yo>>text="ya"', 'e => e.outerHTML')).to eq('<div>ya</div>')
      expect(page.eval_on_selector('text=yo>> text="ya"', 'e => e.outerHTML')).to eq('<div>ya</div>')
      expect(page.eval_on_selector("text=yo >>text='ya'", 'e => e.outerHTML')).to eq('<div>ya</div>')
      expect(page.eval_on_selector("text=yo >> text='ya'", 'e => e.outerHTML')).to eq('<div>ya</div>')
      expect(page.eval_on_selector("'yo' >> \"ya\"", 'e => e.outerHTML')).to eq('<div>ya</div>')
      expect(page.eval_on_selector("\"yo\" >> 'ya'", 'e => e.outerHTML')).to eq('<div>ya</div>')

      page.content = '<div>yo<span id="s1"></span></div><div>yo<span id="s2"></span><span id="s3"></span></div>'
      expect(page.eval_on_selector_all('text=yo', 'es => es.map(e => e.outerHTML).join("\n")')).to eq(
        "<div>yo<span id=\"s1\"></span></div>\n<div>yo<span id=\"s2\"></span><span id=\"s3\"></span></div>"
      )

      page.content = "<div>'</div><div>\"</div><div>\\</div><div>x</div>"
      expect(page.eval_on_selector("text='\\''", "e => e.outerHTML")).to eq("<div>'</div>")
      expect(page.eval_on_selector("text='\"'", "e => e.outerHTML")).to eq('<div>"</div>')
      expect(page.eval_on_selector("text=\"\\\"\"", "e => e.outerHTML")).to eq('<div>"</div>')
      expect(page.eval_on_selector("text=\"'\"", "e => e.outerHTML")).to eq("<div>'</div>")
      expect(page.eval_on_selector("text=\"\\x\"", "e => e.outerHTML")).to eq('<div>x</div>')
      expect(page.eval_on_selector("text='\\x'", "e => e.outerHTML")).to eq('<div>x</div>')
      expect(page.eval_on_selector("text='\\\\'", "e => e.outerHTML")).to eq('<div>\</div>')
      expect(page.eval_on_selector("text=\"\\\\\"", "e => e.outerHTML")).to eq('<div>\</div>')
      expect(page.eval_on_selector("text=\"", "e => e.outerHTML")).to eq('<div>"</div>')
      expect(page.eval_on_selector("text='", "e => e.outerHTML")).to eq("<div>'</div>")
      expect(page.eval_on_selector('"x"', "e => e.outerHTML")).to eq('<div>x</div>')
      expect(page.eval_on_selector("'x'", "e => e.outerHTML")).to eq('<div>x</div>')

      expect { page.query_selector('"') }.to raise_error(::Playwright::Error)
      expect { page.query_selector("'") }.to raise_error(::Playwright::Error)

      page.content = "<div> ' </div><div> \" </div>"
      expect(page.eval_on_selector('text="', 'e => e.outerHTML')).to eq('<div> " </div>')
      expect(page.eval_on_selector("text='", "e => e.outerHTML")).to eq("<div> ' </div>")

      page.content = "<div>Hi''&gt;&gt;foo=bar</div>"
      expect(page.eval_on_selector("text=\"Hi''>>foo=bar\"", "e => e.outerHTML")).to eq("<div>Hi''&gt;&gt;foo=bar</div>")

      page.content = "<div>Hi'\"&gt;&gt;foo=bar</div>"
      expect(page.eval_on_selector("text=\"Hi'\\\">>foo=bar\"", "e => e.outerHTML")).to eq("<div>Hi'\"&gt;&gt;foo=bar</div>")

      page.content = "<div>Hi&gt;&gt;<span></span></div>"
      expect(page.eval_on_selector('text="Hi>>">>span', 'e => e.outerHTML')).to eq("<span></span>")

      page.content = '<div>a<br>b</div><div>a</div>'
      expect(page.eval_on_selector('text=a', 'e => e.outerHTML')).to eq('<div>a<br>b</div>')
      expect(page.eval_on_selector('text=b', 'e => e.outerHTML')).to eq('<div>a<br>b</div>')
      expect(page.eval_on_selector('text=ab', 'e => e.outerHTML')).to eq('<div>a<br>b</div>')
      expect(page.query_selector('text=abc')).to be_nil
      expect(page.eval_on_selector_all('text=a', 'els => els.length')).to eq(2)
      expect(page.eval_on_selector_all('text=b', 'els => els.length')).to eq(1)
      expect(page.eval_on_selector_all('text=ab', 'els => els.length')).to eq(1)
      expect(page.eval_on_selector_all('text=abc', 'els => els.length')).to eq(0)

      page.content = '<div></div><span></span>'
      page.eval_on_selector('div', <<~JAVASCRIPT)
      div => {
        div.appendChild(document.createTextNode('hello'));
        div.appendChild(document.createTextNode('world'));
      }
      JAVASCRIPT
      page.eval_on_selector('span', <<~JAVASCRIPT)
      span => {
        span.appendChild(document.createTextNode('hello'));
        span.appendChild(document.createTextNode('world'));
      }
      JAVASCRIPT
      expect(page.eval_on_selector('text=lowo', 'e => e.outerHTML')).to eq('<div>helloworld</div>')
      expect(page.eval_on_selector_all('text=lowo', "els => els.map(e => e.outerHTML).join('')")).to eq('<div>helloworld</div><span>helloworld</span>')

      page.content = "<span>Sign&nbsp;in</span><span>Hello\n \nworld</span>"
      expect(page.eval_on_selector('text=Sign in', 'e => e.outerHTML')).to eq('<span>Sign&nbsp;in</span>')
      expect(page.query_selector_all("text=Sign \tin").length).to eq(1)
      expect(page.query_selector_all('text="Sign in"').length).to eq(1)
      expect(page.eval_on_selector('text=lo wo', 'e => e.outerHTML')).to eq("<span>Hello\n \nworld</span>")
      expect(page.eval_on_selector('text="Hello world"', 'e => e.outerHTML')).to eq("<span>Hello\n \nworld</span>")
      expect(page.query_selector('text="lo wo"')).to be_nil
      expect(page.query_selector_all("text=lo \nwo").length).to eq(1)
      expect(page.query_selector_all("text=\"lo \nwo\"").length).to eq(0)
    end
  end


  it 'should work with paired quotes in the middle of selector' do
    with_page do |page|
      page.content = "<div>pattern \"^-?\\d+$\"</div>"
      expect(page.locator("div >> text=pattern \"^-?\\d+$").visible?).to eq(true)
      expect(page.locator("div >> text=pattern \"^-?\\d+$\"").visible?).to eq(true)
      # Should double escape inside quoted text.
      expect(page.locator("div >> text='pattern \"^-?\\\\d+$\"'").visible?).to eq(true)
      expect(page.locator("div >> text=pattern \"^-?\\d+$").visible?).to eq(true)
      expect(page.locator("div >> text=pattern \"^-?\\d+$\"").visible?).to eq(true)
      # Should double escape inside quoted text.
      expect(page.locator("div >> text='pattern \"^-?\\\\d+$\"'").visible?).to eq(true)
    end
  end

  it 'hasText and internal:text should match full node text in strict mode' do
    with_page do |page|
      page.content = <<~HTML
      <div id=div1>hello<span>world</span></div>
      <div id=div2>hello</div>
      HTML

      expect(page.get_by_text('helloworld', exact: true)['id']).to eq('div1')
      expect(page.get_by_text('hello', exact: true)['id']).to eq('div2')
      expect(page.locator('div', hasText: /^helloworld$/ )['id']).to eq('div1')
      expect(page.locator('div', hasText: /^hello$/)['id']).to eq('div2')

      page.content = <<~HTML
      <div id=div1><span id=span1>hello</span>world</div>
      <div id=div2><span id=span2>hello</span></div>
      HTML

      expect(page.get_by_text('helloworld', exact: true)['id']).to eq('div1')
      expect(page.get_by_text('hello', exact: true).evaluate_all('els => els.map(e => e.id)')).to contain_exactly('span1', 'span2')
      expect(page.locator('div', hasText: /^helloworld$/)['id']).to eq('div1')
      expect(page.locator('div', hasText: /^hello$/)['id']).to eq('div2')
    end
  end
end
