require 'spec_helper'

RSpec.describe 'accessibility' do
  it 'should work' do
    with_page do |page|
      page.content = <<~HTML
      <head>
        <title>Accessibility Test</title>
      </head>
      <body>
        <h1>Inputs</h1>
        <input placeholder="Empty input" autofocus />
        <input placeholder="readonly input" readonly />
        <input placeholder="disabled input" disabled />
        <input aria-label="Input with whitespace" value="  " />
        <input value="value only" />
        <input aria-placeholder="placeholder" value="and a value" />
        <div aria-hidden="true" id="desc">This is a description!</div>
        <input aria-placeholder="placeholder" value="and a value" aria-describedby="desc" />
      </body>
      HTML

      # autofocus happens after a delay in chrome these days
      page.wait_for_function("() => document.activeElement.hasAttribute('autofocus')")

      golden =
        if chromium?
          {
            'role' => 'WebArea',
            'name' => 'Accessibility Test',
            'children' => [
              { 'role' => 'heading', 'name' => 'Inputs', 'level' => 1 },
              { 'role' => 'textbox', 'name' => 'Empty input', 'focused' => true },
              { 'role' => 'textbox', 'name' => 'readonly input', 'readonly' => true },
              { 'role' => 'textbox', 'name' => 'disabled input', 'disabled' => true },
              { 'role' => 'textbox', 'name' => 'Input with whitespace', 'value' => '  ' },
              { 'role' => 'textbox', 'name' => '', 'value' => 'value only' },
              { 'role' => 'textbox', 'name' => 'placeholder', 'value' => 'and a value' },
              { 'role' => 'textbox', 'name' => 'placeholder', 'value' => 'and a value', 'description' => 'This is a description!' },
            ],
          }
        elsif webkit?
          {
            'role' => 'WebArea',
            'name' => 'Accessibility Test',
            'children' => [
              { 'role' => 'heading', 'name' => 'Inputs', 'level' => 1 },
              { 'role' => 'textbox', 'name' => 'Empty input', 'focused' => true },
              { 'role' => 'textbox', 'name' => 'readonly input', 'readonly' => true },
              { 'role' => 'textbox', 'name' => 'disabled input', 'disabled' => true },
              { 'role' => 'textbox', 'name' => 'Input with whitespace', 'value' => '  ' },
              { 'role' => 'textbox', 'name' => '', 'value' => 'value only' },
              { 'role' => 'textbox', 'name' => 'placeholder', 'value' => 'and a value' },
              # webkit uses the description over placeholder for the name
              { 'role' => 'textbox', 'name' => 'This is a description!', 'value' => 'and a value' },
            ],
          }
        else
          raise 'Not implemented'
        end
      expect(page.accessibility.snapshot).to eq(golden)
    end
  end

  it 'should work with regular text' do
    with_page do |page|
      page.content = '<div>Hello World</div>'
      snapshot = page.accessibility.snapshot
      expect(snapshot['children'].first).to eq({ 'role' => 'text', 'name' => 'Hello World' })
    end
  end

  it 'roledescription' do
    with_page do |page|
      page.content = '<p tabIndex=-1 aria-roledescription="foo">Hi</p>'
      snapshot = page.accessibility.snapshot
      expect(snapshot['children'].first['roledescription']).to eq('foo')
    end
  end

  it 'orientation' do
    with_page do |page|
      page.content = '<a href="" role="slider" aria-orientation="vertical">11</a>'
      snapshot = page.accessibility.snapshot
      expect(snapshot['children'].first['orientation']).to eq('vertical')
    end
  end

  it 'autocomplete' do
    with_page do |page|
      page.content = '<div role="textbox" aria-autocomplete="list">hi</div>'
      snapshot = page.accessibility.snapshot
      expect(snapshot['children'].first['autocomplete']).to eq('list')
    end
  end

  it 'multiselectable' do
    with_page do |page|
      page.content = '<div role="grid" tabIndex=-1 aria-multiselectable=true>hey</div>'
      snapshot = page.accessibility.snapshot
      expect(snapshot['children'].first['multiselectable']).to eq(true)
    end
  end

  it 'keyshortcuts' do
    with_page do |page|
      page.content = '<div role="grid" tabIndex=-1 aria-keyshortcuts="foo">hey</div>'
      snapshot = page.accessibility.snapshot
      expect(snapshot['children'].first['keyshortcuts']).to eq('foo')
    end
  end

  it 'should not report text nodes inside controls' do
    with_page do |page|
      page.content = <<~HTML
      <div role="tablist">
        <div role="tab" aria-selected="true"><b>Tab1</b></div>
        <div role="tab">Tab2</div>
      </div>
      HTML

      golden = {
        'role' => 'WebArea',
        'name' => '',
        'children' => [
          {
            'role' => 'tab',
            'name' => 'Tab1',
            'selected' => true,
          },
          {
            'role' => 'tab',
            'name' => 'Tab2',
          },
        ]
      }

      expect(page.accessibility.snapshot).to eq(golden)
    end
  end

  it 'non editable textbox with role and tabIndex and label should not have children' do
    with_page do |page|
      page.content = <<~HTML
      <div role="textbox" tabIndex=0 aria-checked="true" aria-label="my favorite textbox">
        this is the inner content<img alt="yo" src="fakeimg.png">
      </div>
      HTML

      golden = {
        'role' => 'textbox',
        'name' => 'my favorite textbox',
        'value' => 'this is the inner content',
      }
      snapshot = page.accessibility.snapshot
      expect(snapshot['children'].first).to eq(golden)
    end
  end

  it 'checkbox with and tabIndex and label should not have children' do
    with_page do |page|
      page.content = <<~HTML
      <div role="checkbox" tabIndex=0 aria-checked="true" aria-label="my favorite checkbox">
        this is the inner content
        <img alt="yo" src="fakeimg.png">
      </div>
      HTML

      golden = {
        'role' => 'checkbox',
        'name' => 'my favorite checkbox',
        'checked' => true,
      }
      snapshot = page.accessibility.snapshot
      expect(snapshot['children'].first).to eq(golden)
    end
  end

  it 'checkbox without label should not have children' do
    with_page do |page|
      page.content = <<~HTML
      <div role="checkbox" aria-checked="true">
        this is the inner content
        <img alt="yo" src="fakeimg.png">
      </div>
      HTML

      golden = {
        'role' => 'checkbox',
        'name' => 'this is the inner content yo',
        'checked' => true,
      }
      snapshot = page.accessibility.snapshot
      expect(snapshot['children'].first).to eq(golden)
    end
  end

  it 'should work a button' do
    with_page do |page|
      page.content = '<button>My Button</button>'

      button = page.query_selector('button')
      expect(page.accessibility.snapshot(root: button)).to eq({
        'role' => 'button',
        'name' => 'My Button',
      })
    end
  end

  it 'should work an input' do
    with_page do |page|
      page.content = '<input title="My Input" value="My Value">'

      input = page.query_selector('input')
      expect(page.accessibility.snapshot(root: input)).to eq({
        'role' => 'textbox',
        'name' => 'My Input',
        'value' => 'My Value',
      })
    end
  end

  it 'should work on a menu' do
    with_page do |page|
      page.content = <<~HTML
      <div role="menu" title="My Menu">
        <div role="menuitem">First Item</div>
        <div role="menuitem">Second Item</div>
        <div role="menuitem">Third Item</div>
      </div>
      HTML

      menu = page.query_selector('div[role="menu"]')
      golden = {
        'role' => 'menu',
        'name' => 'My Menu',
        'children' => [
          { 'role' => 'menuitem', 'name' => 'First Item' },
          { 'role' => 'menuitem', 'name' => 'Second Item' },
          { 'role' => 'menuitem', 'name' => 'Third Item' },
        ],
        'orientation' => 'vertical',
      }
      expect(page.accessibility.snapshot(root: menu)).to eq(golden)
    end
  end

  it 'should return null when the element is no longer in DOM' do
    with_page do |page|
      page.content = '<button>My Button</button>'

      button = page.query_selector('button')
      page.eval_on_selector('button', 'btn => btn.remove()')
      expect(page.accessibility.snapshot(root: button)).to be_nil
    end
  end

  it 'should show uninteresting nodes' do
    with_page do |page|
      page.content = <<~HTML
      <div id="root" role="textbox">
        <div>
          hello
          <div>
            world
          </div>
        </div>
      </div>
      HTML

      root = page.query_selector('#root')
      snapshot = page.accessibility.snapshot(root: root, interestingOnly: false)
      expect(snapshot['role']).to eq('textbox')
      expect(snapshot['value']).to include('hello')
      expect(snapshot['value']).to include('world')
      expect(snapshot['children']).not_to be_empty
    end
  end

  it 'should work when there is a title ' do
    with_page do |page|
      page.content = <<~HTML
      <title>This is the title</title>
      <div>This is the content</div>
      HTML

      root = page.query_selector('#root')
      snapshot = page.accessibility.snapshot
      expect(snapshot['name']).to eq('This is the title')
      expect(snapshot['children'].first['name']).to eq('This is the content')
    end
  end
end
