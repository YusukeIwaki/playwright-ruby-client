require 'spec_helper'

RSpec.describe 'ElementHandle' do
  it 'should have a nice preview', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/dom.html")
      outer = page.query_selector('#outer')
      inner = page.query_selector('#inner')
      check = page.query_selector('#check')
      text = inner.evaluate_handle('e => e.firstChild')
      page.evaluate('() => 1') # Give them a chance to calculate the preview.
      expect(outer.to_s).to eq('JSHandle@<div id="outer" name="value">…</div>')
      expect(inner.to_s).to eq('JSHandle@<div id="inner">Text,↵more text</div>')
      expect(text.to_s).to eq('JSHandle@#text=Text,↵more text')
      expect(check.to_s).to eq('JSHandle@<input checked id="check" foo="bar"" type="checkbox"/>')
    end
  end

  it 'get_attribute should work', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/dom.html")
      handle = page.query_selector('#outer')
      expect(handle['name']).to eq('value')
      expect(handle['foo']).to be_nil
      expect(page.get_attribute('#outer', 'name')).to eq('value')
      expect(page.get_attribute('#outer', 'foo')).to be_nil
    end
  end

  it 'inner_html should work', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/dom.html")
      handle = page.query_selector('#outer')
      expect(handle.inner_html).to eq("<div id=\"inner\">Text,\nmore text</div>")
      expect(page.inner_html('#outer')).to eq("<div id=\"inner\">Text,\nmore text</div>")
    end
  end

  it 'inner_text should work', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/dom.html")
      handle = page.query_selector('#inner')
      expect(handle.inner_text).to eq("Text, more text")
      expect(page.inner_text('#inner')).to eq("Text, more text")
    end
  end

  it 'inner_text should throw' do
    with_page do |page|
      page.content = '<svg>text</svg>'
      handle = page.query_selector('svg')
      expect { handle.inner_text }.to raise_error(/Not an HTMLElement/)
      expect { page.inner_text('svg') }.to raise_error(/Not an HTMLElement/)
    end
  end

  it 'text_content should work', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/dom.html")
      handle = page.query_selector('#inner')
      expect(handle.text_content).to eq("Text,\nmore text")
      expect(page.text_content('#inner')).to eq("Text,\nmore text")
    end
  end

  it 'text_content should be atomic' do
    script = <<~JAVASCRIPT
    {
      query(root, selector) {
        const result = root.querySelector(selector);
        if (result)
          Promise.resolve().then(() => result.textContent = 'modified');
        return result;
      },
      queryAll(root, selector) {
        const result = Array.from(root.querySelectorAll(selector));
        for (const e of result)
          Promise.resolve().then(() => e.textContent = 'modified');
        return result;
      }
    }
    JAVASCRIPT

    playwright.selectors.register('textContent', script: script)
    with_page do |page|
      page.content = '<div>Hello</div>'
      tc = page.text_content('textContent=div')
      expect(tc).to eq('Hello')
      expect(page.evaluate("() => document.querySelector('div').textContent")).to eq('modified')
    end
  end


  it 'inner_text should be atomic' do
    script = <<~JAVASCRIPT
    {
      query(root, selector) {
        const result = root.querySelector(selector);
        if (result)
          Promise.resolve().then(() => result.textContent = 'modified');
        return result;
      },
      queryAll(root, selector) {
        const result = Array.from(root.querySelectorAll(selector));
        for (const e of result)
          Promise.resolve().then(() => e.textContent = 'modified');
        return result;
      }
    }
    JAVASCRIPT

    playwright.selectors.register('innerText', script: script)
    with_page do |page|
      page.content = '<div>Hello</div>'
      tc = page.inner_text('innerText=div')
      expect(tc).to eq('Hello')
      expect(page.evaluate("() => document.querySelector('div').innerText")).to eq('modified')
    end
  end

  it 'inner_html should be atomic' do
    script = <<~JAVASCRIPT
    {
      query(root, selector) {
        const result = root.querySelector(selector);
        if (result)
          Promise.resolve().then(() => result.textContent = 'modified');
        return result;
      },
      queryAll(root, selector) {
        const result = Array.from(root.querySelectorAll(selector));
        for (const e of result)
          Promise.resolve().then(() => e.textContent = 'modified');
        return result;
      }
    }
    JAVASCRIPT

    playwright.selectors.register('innerHTML', script: script)
    with_page do |page|
      page.content = '<div>Hello<span>world</span></div>'
      tc = page.inner_html('innerHTML=div')
      expect(tc).to eq('Hello<span>world</span>')
      expect(page.evaluate("() => document.querySelector('div').innerHTML")).to eq('modified')
    end
  end

  it 'get_attribute should be atomic' do
    script = <<~JAVASCRIPT
    {
      query(root, selector) {
        const result = root.querySelector(selector);
        if (result)
          Promise.resolve().then(() => result.setAttribute('foo', 'modified'));
        return result;
      },
      queryAll(root, selector) {
        const result = Array.from(root.querySelectorAll(selector));
        for (const e of result)
          Promise.resolve().then(() => e.setAttribute('foo', 'modified'));
        return result;
      }
    }
    JAVASCRIPT

    playwright.selectors.register('getAttribute', script: script)
    with_page do |page|
      page.content = '<div foo=hello></div>'
      tc = page.get_attribute('getAttribute=div', 'foo')
      expect(tc).to eq('hello')
      expect(page.evaluate("() => document.querySelector('div').getAttribute('foo')")).to eq('modified')
    end
  end

  it 'visible? and hidden? should work' do
    with_page do |page|
      page.content = '<div>Hi</div><span></span>'

      div = page.query_selector('div')
      expect(div.visible?).to eq(true)
      expect(div.hidden?).to eq(false)
      expect(page.visible?('div')).to eq(true)
      expect(page.hidden?('div')).to eq(false)

      span = page.query_selector('span')
      expect(span.visible?).to eq(false)
      expect(span.hidden?).to eq(true)
      expect(page.visible?('span')).to eq(false)
      expect(page.hidden?('span')).to eq(true)

      expect(page.visible?('no-such-element')).to eq(false)
      expect(page.hidden?('no-such-element')).to eq(true)
    end
  end

  it 'element state checks should work for label with zero-sized input' do
    with_page do |page|
      page.content = <<~HTML
      <label>
        Click me
        <input disabled style="width:0;height:0;padding:0;margin:0;border:0;">
      </label>
      HTML

      # Visible checks the label.
      expect(page.visible?('text=Click me')).to eq(true)
      expect(page.hidden?('text=Click me')).to eq(false)

      # Enabled checks the input.
      expect(page.enabled?('text=Click me')).to eq(false)
      expect(page.disabled?('text=Click me')).to eq(true)
    end
  end

  it 'enabled? and disabled? should work' do
    with_page do |page|
      page.content = <<~HTML
      <button disabled>button1</button>
      <button>button2</button>
      <div>div</div>
      HTML

      query = 'div'
      div = page.query_selector(query)
      expect(div.enabled?).to eq(true)
      expect(div.disabled?).to eq(false)
      expect(page.enabled?(query)).to eq(true)
      expect(page.disabled?(query)).to eq(false)

      query = ':text("button1")'
      button1 = page.query_selector(query)
      expect(button1.enabled?).to eq(false)
      expect(button1.disabled?).to eq(true)
      expect(page.enabled?(query)).to eq(false)
      expect(page.disabled?(query)).to eq(true)

      query = ':text("button2")'
      button2 = page.query_selector(query)
      expect(button2.enabled?).to eq(true)
      expect(button2.disabled?).to eq(false)
      expect(page.enabled?(query)).to eq(true)
      expect(page.disabled?(query)).to eq(false)
    end
  end

  it 'editable? should work' do
    with_page do |page|
      page.content = '<input id=input1 disabled><textarea></textarea><input id=input2>'
      page.eval_on_selector('textarea', 't => t.readOnly = true')

      input1 = page.query_selector('#input1')
      expect(input1.editable?).to eq(false)
      expect(page.editable?('#input1')).to eq(false)

      input2 = page.query_selector('#input2')
      expect(input2.editable?).to eq(true)
      expect(page.editable?('#input2')).to eq(true)

      textarea = page.query_selector('textarea')
      expect(textarea.editable?).to eq(false)
      expect(page.editable?('textarea')).to eq(false)
    end
  end

  it 'checked? should work' do
    with_page do |page|
      page.content = "<input type='checkbox' checked><div>Not a checkbox</div>"
      handle = page.query_selector('input')

      expect(handle.checked?).to eq(true)
      expect(page.checked?('input')).to eq(true)

      handle.evaluate('input => input.checked = false')

      expect(handle.checked?).to eq(false)
      expect(page.checked?('input')).to eq(false)

      expect { page.checked?('div') }.to raise_error(/Not a checkbox or radio button/)
    end
  end
end
