require 'spec_helper'

RSpec.describe 'Page#check' do
  it 'should check the box' do
    with_page do |page|
      page.content = "<input id='checkbox' type='checkbox'></input>"
      page.check('input')
      expect(page.evaluate("() => window['checkbox'].checked")).to eq(true)
    end
  end

  it 'should check the box with ElementHandle#check' do
    with_page do |page|
      page.content = "<input id='checkbox' type='checkbox'></input>"
      page.query_selector('input').check
      expect(page.evaluate("() => window['checkbox'].checked")).to eq(true)
    end
  end

  it 'should check the box with Page#set_checked' do
    with_page do |page|
      page.content = "<input id='checkbox' type='checkbox'></input>"
      page.set_checked('input', true)
      expect(page.evaluate("() => window['checkbox'].checked")).to eq(true)
    end
  end

  it 'should check the box with ElementHandle#set_checked' do
    with_page do |page|
      page.content = "<input id='checkbox' type='checkbox'></input>"
      page.query_selector('input').checked = true
      expect(page.evaluate("() => window['checkbox'].checked")).to eq(true)
    end
  end

  it 'should not check the checked box' do
    with_page do |page|
      page.content = "<input id='checkbox' type='checkbox' checked></input>"
      page.check('input')
      expect(page.evaluate("() => window['checkbox'].checked")).to eq(true)
    end
  end

  it 'should uncheck the box' do
    with_page do |page|
      page.content = "<input id='checkbox' type='checkbox' checked></input>"
      page.uncheck('input')
      expect(page.evaluate("() => window['checkbox'].checked")).to eq(false)
    end
  end

  it 'should uncheck the box with ElementHandle#uncheck' do
    with_page do |page|
      page.content = "<input id='checkbox' type='checkbox' checked></input>"
      page.query_selector('input').uncheck
      expect(page.evaluate("() => window['checkbox'].checked")).to eq(false)
    end
  end

  it 'should uncheck the box with Page#set_checked' do
    with_page do |page|
      page.content = "<input id='checkbox' type='checkbox' checked></input>"
      page.set_checked('input', false)
      expect(page.evaluate("() => window['checkbox'].checked")).to eq(false)
    end
  end

  it 'should uncheck the box with ElementHandle#set_checked' do
    with_page do |page|
      page.content = "<input id='checkbox' type='checkbox' checked></input>"
      page.query_selector('input').checked = false
      expect(page.evaluate("() => window['checkbox'].checked")).to eq(false)
    end
  end

  it 'should not uncheck the unchecked box' do
    with_page do |page|
      page.content = "<input id='checkbox' type='checkbox'></input>"
      page.uncheck('input')
      expect(page.evaluate("() => window['checkbox'].checked")).to eq(false)
    end
  end

  it 'should check the box by label' do
    with_page do |page|
      page.content = "<label for='checkbox'><input id='checkbox' type='checkbox'></input></label>"
      page.check('label')
      expect(page.evaluate("() => window['checkbox'].checked")).to eq(true)
    end
  end

  it 'should check the box outside label' do
    with_page do |page|
      page.content = "<label for='checkbox'>Text</label><div><input id='checkbox' type='checkbox'></input></div>"
      page.check('label')
      expect(page.evaluate("() => window['checkbox'].checked")).to eq(true)
    end
  end

  it 'should check the box inside label w/o id' do
    with_page do |page|
      page.content = "<label>Text<span><input id='checkbox' type='checkbox'></input></span></label>"
      page.check('label')
      expect(page.evaluate("() => window['checkbox'].checked")).to eq(true)
    end
  end

  it 'should check the box outside shadow dom label' do
    with_page do |page|
      page.content = '<div></div>'
      js = <<~JAVASCRIPT
      (div) => {
        const root = div.attachShadow({ mode: 'open' });
        const label = document.createElement('label');
        label.setAttribute('for', 'target');
        label.textContent = 'Click me';
        root.appendChild(label);
        const input = document.createElement('input');
        input.setAttribute('type', 'checkbox');
        input.setAttribute('id', 'target');
        root.appendChild(input);
      }
      JAVASCRIPT
      page.eval_on_selector('div', js)
      page.check('label')
      expect(page.eval_on_selector('input', 'input => input.checked')).to eq(true)
    end
  end

  it 'should check radio' do
    with_page do |page|
      page.content = <<~HTML
        <input type='radio'>one</input>
        <input id='two' type='radio'>two</input>
        <input type='radio'>three</input>`);
      HTML
      page.check('#two')
      expect(page.evaluate("() => window['two'].checked")).to eq(true)
    end
  end

  it 'should check the box by aria role' do
    with_page do |page|
      page.content = <<~HTML
        <div role='checkbox' id='checkbox'>CHECKBOX</div>
        <script>
          checkbox.addEventListener('click', () => checkbox.setAttribute('aria-checked', 'true'));
        </script>
      HTML
      page.check('div')
      expect(page.evaluate("() => window['checkbox'].getAttribute('aria-checked')")).to eq("true")
    end
  end

  it 'should throw when not a checkbox' do
    with_page do |page|
      page.content = '<div>Check me</div>'
      expect { page.check('div') }.to raise_error(/Not a checkbox or radio button/)
    end
  end

  it 'should check the box inside a button' do
    with_page do |page|
      page.content = "<div role='button'><input type='checkbox'></div>"
      page.check('input')
      expect(page.eval_on_selector('input', 'input => input.checked')).to eq(true)
      expect(page.checked?('input')).to eq(true)
      expect(page.query_selector('input')).to be_checked
    end
  end

  it 'should check the label with position' do
    with_page do |page|
      page.content = <<~HTML
        <input id='checkbox' type='checkbox' style='width: 5px; height: 5px;'>
        <label for='checkbox'>
          <a href=${JSON.stringify(server.EMPTY_PAGE)}>I am a long link that goes away so that nothing good will happen if you click on me</a>
          Click me
        </label>
      HTML
      box = page.query_selector('text=Click me').bounding_box
      page.check('text=Click me', position: { x: box["width"] - 10, y: 2 })
      expect(page.eval_on_selector('input', 'input => input.checked')).to eq(true)
    end
  end

  it 'trial run should not check' do
    with_page do |page|
      page.content = "<input id='checkbox' type='checkbox'></input>"
      page.check('input', trial: true)
      expect(page.evaluate("() => window['checkbox'].checked")).to eq(false)
    end
  end

  it 'trial run should not uncheck' do
    with_page do |page|
      page.content = "<input id='checkbox' type='checkbox' checked></input>"
      page.uncheck('input', trial: true)
      expect(page.evaluate("() => window['checkbox'].checked")).to eq(true)
    end
  end
end
