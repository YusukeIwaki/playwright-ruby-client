require 'spec_helper'

RSpec.describe 'selector/role' do
  it 'should detect roles' do
    with_page do |page|
      page.content = <<~HTML
      <button>Hello</button>
      <select multiple="" size="2"></select>
      <select></select>
      <h3>Heading</h3>
      <details><summary>Hello</summary></details>
      <div role="dialog">I am a dialog</div>
      HTML

      expect(page.locator('role=button').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<button>Hello</button>'
      )

      expect(page.locator('role=listbox').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<select multiple="" size="2"></select>'
      )

      expect(page.locator('role=combobox').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<select></select>'
      )

      expect(page.locator('role=heading').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<h3>Heading</h3>'
      )

      expect(page.locator('role=group').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<details><summary>Hello</summary></details>'
      )

      expect(page.locator('role=dialog').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="dialog">I am a dialog</div>'
      )

      expect(page.locator('role=menuitem').evaluate_all('els => els.map(e => e.outerHTML)')).to be_empty
      expect(page.get_by_role('menuitem').evaluate_all('els => els.map(e => e.outerHTML)')).to be_empty
    end
  end

  it 'should support selected' do
    with_page do |page|
      page.content = <<~HTML
      <select>
        <option>Hi</option>
        <option selected>Hello</option>
      </select>
      <div>
        <div role="option" aria-selected="true">Hi</div>
        <div role="option" aria-selected="false">Hello</div>
      </div>
      HTML

      expect(page.locator('role=option[selected]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<option selected="">Hello</option>',
        '<div role="option" aria-selected="true">Hi</div>',
      )

      expect(page.locator('role=option[selected=true]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<option selected="">Hello</option>',
        '<div role="option" aria-selected="true">Hi</div>',
      )

      expect(page.get_by_role('option', selected: true).evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<option selected="">Hello</option>',
        '<div role="option" aria-selected="true">Hi</div>',
      )

      expect(page.locator('role=option[selected=false]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<option>Hi</option>',
        '<div role="option" aria-selected="false">Hello</div>',
      )

      expect(page.get_by_role('option', selected: false).evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<option>Hi</option>',
        '<div role="option" aria-selected="false">Hello</div>',
      )
    end
  end

  it 'should support checked' do
    with_page do |page|

      page.content = <<~HTML
      <input type=checkbox>
      <input type=checkbox checked>
      <input type=checkbox indeterminate>
      <div role=checkbox aria-checked="true">Hi</div>
      <div role=checkbox aria-checked="false">Hello</div>
      <div role=checkbox>Unknown</div>
      HTML

      page.eval_on_selector('[indeterminate]', 'input => { input.indeterminate = true }')

      expect(page.locator('role=checkbox[checked]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<input type="checkbox" checked="">',
        '<div role="checkbox" aria-checked="true">Hi</div>',
      )

      expect(page.locator('role=checkbox[checked=true]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<input type="checkbox" checked="">',
        '<div role="checkbox" aria-checked="true">Hi</div>',
      )

      expect(page.get_by_role('checkbox', checked: true).evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<input type="checkbox" checked="">',
        '<div role="checkbox" aria-checked="true">Hi</div>',
      )

      expect(page.locator('role=checkbox[checked=false]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<input type="checkbox">',
        '<div role="checkbox" aria-checked="false">Hello</div>',
        '<div role="checkbox">Unknown</div>',
      )

      expect(page.get_by_role('checkbox', checked: false).evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<input type="checkbox">',
        '<div role="checkbox" aria-checked="false">Hello</div>',
        '<div role="checkbox">Unknown</div>',
      )

      expect(page.locator('role=checkbox[checked=mixed]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<input type="checkbox" indeterminate="">',
      )

      expect(page.locator('role=checkbox').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<input type="checkbox">',
        '<input type="checkbox" checked="">',
        '<input type="checkbox" indeterminate="">',
        '<div role="checkbox" aria-checked="true">Hi</div>',
        '<div role="checkbox" aria-checked="false">Hello</div>',
        '<div role="checkbox">Unknown</div>',
      )
    end
  end

  it 'should support pressed' do
    with_page do |page|
      page.content = <<~HTML
      <button>Hi</button>
      <button aria-pressed="true">Hello</button>
      <button aria-pressed="false">Bye</button>
      <button aria-pressed="mixed">Mixed</button>
      HTML

      expect(page.locator('role=button[pressed]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<button aria-pressed="true">Hello</button>',
      )

      expect(page.locator('role=button[pressed=true]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<button aria-pressed="true">Hello</button>',
      )

      expect(page.get_by_role('button', pressed: true).evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<button aria-pressed="true">Hello</button>',
      )

      expect(page.locator('role=button[pressed=false]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<button>Hi</button>',
        '<button aria-pressed="false">Bye</button>',
      )

      expect(page.get_by_role('button', pressed: false).evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<button>Hi</button>',
        '<button aria-pressed="false">Bye</button>',
      )

      expect(page.locator('role=button[pressed=mixed]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<button aria-pressed="mixed">Mixed</button>',
      )

      expect(page.locator('role=button').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<button>Hi</button>',
        '<button aria-pressed="true">Hello</button>',
        '<button aria-pressed="false">Bye</button>',
        '<button aria-pressed="mixed">Mixed</button>',
      )
    end
  end

  it 'should support expanded' do
    with_page do |page|
      page.content = <<~HTML
      <div role="treeitem">Hi</div>
      <div role="treeitem" aria-expanded="true">Hello</div>
      <div role="treeitem" aria-expanded="false">Bye</div>
      HTML

      expect(page.locator('role=treeitem').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="treeitem">Hi</div>',
        '<div role="treeitem" aria-expanded="true">Hello</div>',
        '<div role="treeitem" aria-expanded="false">Bye</div>',
      )

      expect(page.get_by_role('treeitem').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="treeitem">Hi</div>',
        '<div role="treeitem" aria-expanded="true">Hello</div>',
        '<div role="treeitem" aria-expanded="false">Bye</div>',
      )

      expect(page.locator('role=treeitem[expanded]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="treeitem" aria-expanded="true">Hello</div>',
      )

      expect(page.locator('role=treeitem[expanded=true]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="treeitem" aria-expanded="true">Hello</div>',
      )

      expect(page.get_by_role('treeitem', expanded: true).evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="treeitem" aria-expanded="true">Hello</div>',
      )

      expect(page.locator('role=treeitem[expanded=false]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="treeitem" aria-expanded="false">Bye</div>',
      )

      expect(page.get_by_role('treeitem', expanded: false).evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="treeitem" aria-expanded="false">Bye</div>',
      )

      # Workaround for expanded="none".
      expect(page.locator('[role=treeitem]:not([aria-expanded])').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="treeitem">Hi</div>',
      )
    end
  end

  it 'should support disabled' do
    with_page do |page|
      page.content = <<~HTML
      <button>Hi</button>
      <button disabled>Bye</button>
      <button aria-disabled="true">Hello</button>
      <button aria-disabled="false">Oh</button>
      <fieldset disabled>
        <button>Yay</button>
      </fieldset>
      HTML

      expect(page.locator('role=button[disabled]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<button disabled="">Bye</button>',
        '<button aria-disabled="true">Hello</button>',
        '<button>Yay</button>',
      )

      expect(page.locator('role=button[disabled=true]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<button disabled="">Bye</button>',
        '<button aria-disabled="true">Hello</button>',
        '<button>Yay</button>',
      )

      expect(page.get_by_role('button', disabled: true).evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<button disabled="">Bye</button>',
        '<button aria-disabled="true">Hello</button>',
        '<button>Yay</button>',
      )

      expect(page.locator('role=button[disabled=false]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<button>Hi</button>',
        '<button aria-disabled="false">Oh</button>',
      )

      expect(page.get_by_role('button', disabled: false).evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<button>Hi</button>',
        '<button aria-disabled="false">Oh</button>',
      )
    end
  end

  it 'should support level' do
    with_page do |page|
      page.content = <<~HTML
      <h1>Hello</h1>
      <h3>Hi</h3>
      <div role="heading" aria-level="5">Bye</div>
      HTML

      expect(page.locator('role=heading[level=1]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<h1>Hello</h1>',
      )

      expect(page.get_by_role('heading', level: 1).evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<h1>Hello</h1>',
      )

      expect(page.locator('role=heading[level=3]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<h3>Hi</h3>',
      )

      expect(page.get_by_role('heading', level: 3).evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<h3>Hi</h3>',
      )

      expect(page.locator('role=heading[level=5]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="heading" aria-level="5">Bye</div>',
      )
    end
  end

  it 'should support name' do
    with_page do |page|
      page.content = <<~HTML
      <div role="button" aria-label=" Hello "></div>
      <div role="button" aria-label="Hallo"></div>
      <div role="button" aria-label="Hello" aria-hidden="true"></div>
      <div role="button" aria-label="123" aria-hidden="true"></div>
      <div role="button" aria-label='foo"bar' aria-hidden="true"></div>
      HTML

      expect(page.locator('role=button[name="Hello"]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="button" aria-label=" Hello "></div>',
      )

      expect(page.locator("role=button[name=\" \n Hello \"]").evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="button" aria-label=" Hello "></div>',
      )

      expect(page.get_by_role('button', name: 'Hello ').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="button" aria-label=" Hello "></div>',
      )

      expect(page.locator('role=button[name*="all"]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="button" aria-label="Hallo"></div>',
      )

      expect(page.locator('role=button[name=/^H[ae]llo$/]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="button" aria-label=" Hello "></div>',
        '<div role="button" aria-label="Hallo"></div>',
      )

      expect(page.get_by_role('button', name: /^H[ae]llo$/).evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="button" aria-label=" Hello "></div>',
        '<div role="button" aria-label="Hallo"></div>',
      )

      expect(page.locator('role=button[name=/^h.*o$/i]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="button" aria-label=" Hello "></div>',
        '<div role="button" aria-label="Hallo"></div>',
      )

      expect(page.get_by_role('button', name: /^h.*o$/i).evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="button" aria-label=" Hello "></div>',
        '<div role="button" aria-label="Hallo"></div>',
      )

      expect(page.locator('role=button[name="Hello"][include-hidden]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="button" aria-label=" Hello "></div>',
        '<div role="button" aria-label="Hello" aria-hidden="true"></div>',
      )

      expect(page.get_by_role('button', name: 'Hello', includeHidden: true).evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="button" aria-label=" Hello "></div>',
        '<div role="button" aria-label="Hello" aria-hidden="true"></div>',
      )

      expect(page.get_by_role('button', name: 'hello', includeHidden: true).evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="button" aria-label=" Hello "></div>',
        '<div role="button" aria-label="Hello" aria-hidden="true"></div>',
      )

      expect(page.locator('role=button[name=Hello]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="button" aria-label=" Hello "></div>',
      )

      expect(page.locator('role=button[name=123][include-hidden]').evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="button" aria-label="123" aria-hidden="true"></div>',
      )

      expect(page.get_by_role('button', name: '123', includeHidden: true).evaluate_all('els => els.map(e => e.outerHTML)')).to contain_exactly(
        '<div role="button" aria-label="123" aria-hidden="true"></div>',
      )
    end
  end
end
