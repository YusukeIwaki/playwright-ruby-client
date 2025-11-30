require 'spec_helper'

RSpec.describe 'Locator' do
  it 'should have a nice preview', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/dom.html")
      outer = page.locator('#outer')
      inner = outer.locator('#inner')
      check = page.locator('#check')
      page.evaluate('() => 1') # Give them a chance to calculate the preview.
      expect(outer.to_s).to eq('Locator@#outer')
      expect(inner.to_s).to eq('Locator@#outer >> #inner')
      expect(check.to_s).to eq('Locator@#check')
    end
  end

  it 'get_attribute should work', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/dom.html")
      locator = page.locator('#outer')
      expect(locator.get_attribute('name')).to eq('value')
      expect(locator['name']).to eq('value')
      expect(locator.get_attribute('foo')).to be_nil
      expect(locator['foo']).to be_nil
    end
  end

  it 'input_value should work', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/dom.html")

      page.fill('#input', 'input value')
      handle = page.locator('#input')
      expect(handle.input_value).to eq('input value')

      handle2 = page.locator('#inner')
      expect {
        handle2.input_value
      }.to raise_error(/Node is not an <input>, <textarea> or <select> element/)
    end
  end

  it 'inner_html should work', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/dom.html")
      handle = page.locator('#outer')
      expect(handle.inner_html).to eq("<div id=\"inner\">Text,\nmore text</div>")
    end
  end

  it 'inner_text should work', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/dom.html")
      handle = page.locator('#inner')
      expect(handle.inner_text).to eq("Text, more text")
    end
  end

  it 'inner_text should throw' do
    with_page do |page|
      page.content = '<svg>text</svg>'
      locator = page.locator('svg')
      expect { locator.inner_text }.to raise_error(/Node is not an HTMLElement/)
    end
  end

  it 'text_content should work', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/dom.html")
      handle = page.locator('#inner')
      expect(handle.text_content).to eq("Text,\nmore text")
      expect(page.text_content('#inner')).to eq("Text,\nmore text")
    end
  end

  it 'visible? and hidden? should work' do
    with_page do |page|
      page.content = '<div>Hi</div><span></span>'

      div = page.locator('div')
      expect(div).to be_visible
      expect(div).not_to be_hidden

      span = page.locator('span')
      expect(span).not_to be_visible
      expect(span).to be_hidden
    end
  end

  it '">> visible=true" should work' do
    with_page do |page|
      page.content = '<div>Hi</div><span></span>'

      visible_div = page.locator('div >> visible=true')
      expect(visible_div.count).to eq(1)
      expect(visible_div.text_content).to eq('Hi')

      visible_span = page.locator('span >> visible=true')
      expect(visible_span.count).to eq(0)
    end
  end

  it 'enabled? and disabled? should work' do
    with_page do |page|
      page.content = <<~HTML
      <button disabled>button1</button>
      <button>button2</button>
      <div>div</div>
      HTML

      div = page.locator('div')
      expect(div).to be_enabled
      expect(div).not_to be_disabled

      button1 = page.locator(':text("button1")')
      expect(button1).not_to be_enabled
      expect(button1).to be_disabled

      button2 = page.locator(':text("button2")')
      expect(button2).to be_enabled
      expect(button2).not_to be_disabled
    end
  end

  it 'editable? should work' do
    with_page do |page|
      page.content = <<~HTML
      <input id=input1 disabled>
      <textarea></textarea>
      <input id=input2>
      <div contenteditable="true"></div>
      <span id=span1 role=textbox aria-readonly=true></span>
      <span id=span2 role=textbox></span>
      <button>button</button>
      HTML

      input1 = page.locator('#input1')
      expect(input1).not_to be_editable

      input2 = page.locator('#input2')
      expect(input2).to be_editable

      textarea = page.locator('textarea')
      expect(textarea).to be_editable
      page.eval_on_selector('textarea', 't => t.readOnly = true')
      expect(textarea).not_to be_editable

      div = page.locator('div')
      expect(div).to be_editable

      span1 = page.locator('#span1')
      expect(span1).not_to be_editable

      span2 = page.locator('#span2')
      expect(span2).to be_editable

      button = page.locator('button')
      expect { button.editable? }.to raise_error(/Element is not an <input>, <textarea>, <select> or \[contenteditable\] and does not have a role allowing \[aria-readonly\]/)
    end
  end

  it 'checked? should work' do
    with_page do |page|
      page.content = "<input type='checkbox' checked><div>Not a checkbox</div>"
      element = page.locator('input')
      expect(element).to be_checked
      page.eval_on_selector('input', 'input => input.checked = false')
      expect(element).not_to be_checked
    end
  end

  it 'all_text_contents should work' do
    with_page do |page|
      page.content = '<div>A</div><div>B</div><div>C</div>'
      expect(page.locator('div').all_text_contents).to eq(%w[A B C])
    end
  end

  it 'all_inner_texts should work' do
    with_page do |page|
      page.content = '<div>A</div><div>B</div><div>C</div>'
      expect(page.locator('div').all_inner_texts).to eq(%w[A B C])
    end
  end

  it 'should return page', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/frames/two-frames.html")

      outer = page.locator('#outer')
      expect(outer.page).to eq(page)

      inner = outer.locator('#inner')
      expect(inner.page).to eq(page)

      in_frame = page.frames[1].locator('div')
      expect(in_frame.page).to eq(page)
    end
  end

  it 'description should return nil for locator without description' do
    with_page do |page|
      page.content = '<button>Submit</button>'
      locator = page.locator('button')
      expect(locator.description).to be_nil
    end
  end

  it 'description should return description for locator with simple description' do
    with_page do |page|
      page.content = '<button>Submit</button>'
      locator = page.locator('button').describe('Submit button')
      expect(locator.description).to eq('Submit button')
    end
  end

  it 'description should return description with special characters' do
    with_page do |page|
      page.content = '<div>Button</div>'
      locator = page.locator('div').describe('Button with "quotes" and \'apostrophes\'')
      expect(locator.description).to eq('Button with "quotes" and \'apostrophes\'')
    end
  end

  it 'description should return description for chained locators' do
    with_page do |page|
      page.content = '<form><input></form>'
      locator = page.locator('form').locator('input').describe('Form input field')
      expect(locator.description).to eq('Form input field')
    end
  end

  it 'description should return description for locator with multiple describe calls' do
    with_page do |page|
      page.content = <<~HTML
      <div class="foo">
        <button>First</button>
      </div>
      HTML

      locator1 = page.locator('.foo').describe('First description')
      expect(locator1.description).to eq('First description')

      locator2 = locator1.locator('button').describe('Second description')
      expect(locator2.description).to eq('Second description')

      locator3 = locator2.locator('button')
      expect(locator3.description).to be_nil
    end
  end

  it 'to_s returns formatted locator', pending: "not implemented" do
    with_page do |page|
      page.content = '<button>Submit</button>'
      locator = page.get_by_role('button', name: 'Submit')
      expect(locator.to_s).to eq("getByRole('button', { name: 'Submit' })")
      expect(locator.description).to be_nil
    end
  end

  it 'to_s prefers description', pending: "not implemented" do
    with_page do |page|
      page.content = '<button>Submit</button>'
      locator = page.get_by_role('button', name: 'Submit').describe('Submit button')
      expect(locator.to_s).to eq('Submit button')
      expect(locator.to_s).to eq(locator.description)
    end
  end
end
