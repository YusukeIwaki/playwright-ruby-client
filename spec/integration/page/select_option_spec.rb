require 'spec_helper'

RSpec.describe 'Page#select_option' do
  it 'should select single option by value', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      page.select_option('select', value: 'blue')
      expect(page.evaluate("() => window['result'].onInput")).to eq(['blue'])
      expect(page.evaluate("() => window['result'].onChange")).to eq(['blue'])
    end
  end

  it 'should select single option by label', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      page.select_option('select', label: 'Indigo')
      expect(page.evaluate("() => window['result'].onInput")).to eq(['indigo'])
      expect(page.evaluate("() => window['result'].onChange")).to eq(['indigo'])
    end
  end

  it 'should select single option by handle', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      handle = page.query_selector('[id=whiteOption]')
      page.select_option('select', element: handle)
      expect(page.evaluate("() => window['result'].onInput")).to eq(['white'])
      expect(page.evaluate("() => window['result'].onChange")).to eq(['white'])
    end
  end

  it 'should select single option by index', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      page.select_option('select', index: 2)
      expect(page.evaluate("() => window['result'].onInput")).to eq(['brown'])
      expect(page.evaluate("() => window['result'].onChange")).to eq(['brown'])
    end
  end

  it 'should select single option by multiple attributes', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      page.select_option('select', value: 'green', label: 'Green')
      expect(page.evaluate("() => window['result'].onInput")).to eq(['green'])
      expect(page.evaluate("() => window['result'].onChange")).to eq(['green'])
    end
  end

  # This behavior may be JavaScript-specific.
  xit 'should not select single option when some attributes do not match', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      page.eval_on_selector('select', 's => s.value = undefined')
      expect {
        page.select_option('select', value: 'green', label: 'Brown', timeout: 300)
      }.to raise_error(/Timeout/)
      expect(page.evaluate("() => document.querySelector('select').value")).to eq('')
    end
  end

  it 'should select only first option', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      page.select_option('select', value: ['blue', 'green', 'red'])
      expect(page.evaluate("() => window['result'].onInput")).to eq(['blue'])
      expect(page.evaluate("() => window['result'].onChange")).to eq(['blue'])
    end
  end

  it 'should not throw when select causes navigation', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      page.eval_on_selector(
        'select',
        "select => select.addEventListener('input', () => window.location.href = '/empty.html')",
      )
      page.expect_navigation do
        page.select_option('select', value: 'blue')
      end
      expect(page.url).to include('empty.html')
    end
  end

  it 'should select multiple options', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      page.evaluate("() => window['makeMultiple']()")
      page.select_option('select', value: %w[blue green red])
      expect(page.evaluate("() => window['result'].onInput")).to eq(%w[blue green red])
      expect(page.evaluate("() => window['result'].onChange")).to eq(%w[blue green red])
    end
  end

  it 'should select multiple options with attributes', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      page.evaluate("() => window['makeMultiple']()")
      page.select_option('select', value: 'blue', label: 'Green', index: 4)
      expect(page.evaluate("() => window['result'].onInput")).to eq(%w[blue gray green])
      expect(page.evaluate("() => window['result'].onChange")).to eq(%w[blue gray green])
    end
  end

  it 'should select options with sibling label' do
    with_page do |page|
      page.content = <<~HTML
      <label for=pet-select>Choose a pet</label>
      <select id='pet-select'>
        <option value='dog'>Dog</option>
        <option value='cat'>Cat</option>
      </select>
      HTML
      page.select_option('text=Choose a pet', value: 'cat')
      expect(page.eval_on_selector('select', 'select => select.options[select.selectedIndex].text')).to eq('Cat')
    end
  end

  it 'should select options with outer label' do
    with_page do |page|
      page.content = <<~HTML
      <label for=pet-select>Choose a pet
      <select id='pet-select'>
        <option value='dog'>Dog</option>
        <option value='cat'>Cat</option>
      </select></label>
      HTML
      page.select_option('text=Choose a pet', value: 'cat')
      expect(page.eval_on_selector('select', 'select => select.options[select.selectedIndex].text')).to eq('Cat')
    end
  end

  it 'should respect event bubbling', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      page.select_option('select', value: 'blue')
      expect(page.evaluate("() => window['result'].onBubblingInput")).to eq(%w[blue])
      expect(page.evaluate("() => window['result'].onBubblingChange")).to eq(%w[blue])
    end
  end

  it 'should throw when element is not a <select>', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      expect {
        page.select_option('body', value: '')
      }.to raise_error(/Element is not a <select> element./)
    end
  end

  it 'should return an array of matched values', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      page.evaluate("() => window['makeMultiple']()")
      result = page.select_option('select', value: %w[blue black magenta])
      expect(result).to match_array(%w[blue black magenta])
    end
  end

  it 'should return an array of one element when multiple is not set', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      result = page.select_option('select', value: %w[42 blue black magenta])
      expect(result.count).to eq(1)
    end
  end

  it 'should return [] on no values', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      result = page.select_option('select', value: [])
      expect(result).to eq([])
    end
  end

  it 'should not allow null items', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      page.evaluate("() => window['makeMultiple']()")
      expect {
        page.select_option('select', value: ['blue', nil, 'black', 'magenta'])
      }.to raise_error(/options\[1\]: expected object, got null/)
    end
  end

  it 'should unselect with null', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      page.evaluate("() => window['makeMultiple']()")
      result = page.select_option('select', value: %w[blue black magenta])
      expect(result.count).to eq(3)
      page.select_option('select', value: nil)
      expect(page.eval_on_selector('select', 'select => Array.from(select.options).every(option => !option.selected)')).to eq(true)
    end
  end

  it 'should deselect all options when passed no values for a multiple select', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      page.evaluate("() => window['makeMultiple']()")
      result = page.select_option('select', value: %w[blue black magenta])
      expect(result.count).to eq(3)
      page.select_option('select', value: [])
      expect(page.eval_on_selector('select', 'select => Array.from(select.options).every(option => !option.selected)')).to eq(true)
    end
  end

  it 'should deselect all options when passed no values for a select without multiple', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      page.select_option('select', value: %w[blue black magenta])
      page.select_option('select', value: [])
      expect(page.eval_on_selector('select', 'select => Array.from(select.options).every(option => !option.selected)')).to eq(true)
    end
  end

  # @see https://github.com/GoogleChrome/puppeteer/issues/3327
  it 'should work when re-defining top-level Event class', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      page.evaluate('() => window.Event = null')
      page.select_option('select', value: 'blue')
      expect(page.evaluate("() => window['result'].onInput")).to eq(['blue'])
      expect(page.evaluate("() => window['result'].onChange")).to eq(['blue'])
    end
  end

  it 'should wait for option to be present', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      select_promise = Concurrent::Promises.future { page.select_option('select', value: 'scarlet') }
      give_it_a_chance_to_resolve(page)
      expect(select_promise).not_to be_resolved
      js = <<~JAVASCRIPT
      select => {
        const option = document.createElement('option');
        option.value = 'scarlet';
        option.textContent = 'Scarlet';
        select.appendChild(option);
      }
      JAVASCRIPT
      page.eval_on_selector('select', js)
      Timeout.timeout(2) { expect(select_promise.value!).to contain_exactly('scarlet') }
    end
  end

  it 'should wait for option index to be present', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      len = page.eval_on_selector('select', 'select => select.options.length')
      select_promise = Concurrent::Promises.future { page.select_option('select', index: len) }
      give_it_a_chance_to_resolve(page)
      expect(select_promise).not_to be_resolved
      js = <<~JAVASCRIPT
      select => {
        const option = document.createElement('option');
        option.value = 'scarlet';
        option.textContent = 'Scarlet';
        select.appendChild(option);
      }
      JAVASCRIPT
      page.eval_on_selector('select', js)
      Timeout.timeout(2) { expect(select_promise.value!).to contain_exactly('scarlet') }
    end
  end

  it 'should wait for multiple options to be present', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      page.evaluate("() => window['makeMultiple']()")
      select_promise = Concurrent::Promises.future { page.select_option('select', value: %w[green scarlet]) }
      give_it_a_chance_to_resolve(page)
      expect(select_promise).not_to be_resolved
      js = <<~JAVASCRIPT
      select => {
        const option = document.createElement('option');
        option.value = 'scarlet';
        option.textContent = 'Scarlet';
        select.appendChild(option);
      }
      JAVASCRIPT
      page.eval_on_selector('select', js)
      Timeout.timeout(2) { expect(select_promise.value!).to match_array(%w[green scarlet]) }
    end
  end
end
