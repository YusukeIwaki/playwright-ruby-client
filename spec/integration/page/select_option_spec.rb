require 'spec_helper'

RSpec.describe 'Page#select_option' do
  def give_it_a_chance_to_resolve(page)
    5.times do
      sleep 0.04 # wait a bit for avoiding `undefined:1` error.
      page.evaluate('() => new Promise(f => requestAnimationFrame(() => requestAnimationFrame(f)))')
    end
  end

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

  # it('should select options with outer label', async ({page, server}) => {
  #   await page.setContent(`<label for=pet-select>Choose a pet
  #     <select id='pet-select'>
  #       <option value='dog'>Dog</option>
  #       <option value='cat'>Cat</option>
  #     </select></label>`);
  #   await page.selectOption('text=Choose a pet', 'cat');
  #   expect(await page.$eval('select', select => select.options[select.selectedIndex].text)).toEqual('Cat');
  # });

  # it('should respect event bubbling', async ({page, server}) => {
  #   await page.goto(server.PREFIX + '/input/select.html');
  #   await page.selectOption('select', 'blue');
  #   expect(await page.evaluate(() => window['result'].onBubblingInput)).toEqual(['blue']);
  #   expect(await page.evaluate(() => window['result'].onBubblingChange)).toEqual(['blue']);
  # });

  it 'should throw when element is not a <select>', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      expect {
        page.select_option('body', value: '')
      }.to raise_error(/Element is not a <select> element./)
    end
  end

  it 'should return [] on no matched values', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/select.html")
      result = page.select_option('select', value: [])
      expect(result).to eq([])
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

  # it('should return [] on no values',async ({page, server}) => {
  #   await page.goto(server.PREFIX + '/input/select.html');
  #   const result = await page.selectOption('select', []);
  #   expect(result).toEqual([]);
  # });

  # it('should not allow null items',async ({page, server}) => {
  #   await page.goto(server.PREFIX + '/input/select.html');
  #   await page.evaluate(() => window['makeMultiple']());
  #   let error = null;
  #   await page.selectOption('select', ['blue', null, 'black','magenta']).catch(e => error = e);
  #   expect(error.message).toContain('options[1]: expected object, got null');
  # });

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

  # it('should throw if passed wrong types', async ({page, server}) => {
  #   let error;
  #   await page.setContent('<select><option value="12"/></select>');

  #   error = null;
  #   try {
  #     // @ts-expect-error cannot select numbers
  #     await page.selectOption('select', 12);
  #   } catch (e) {
  #     error = e;
  #   }
  #   expect(error.message).toContain('options[0]: expected object, got number');

  #   error = null;
  #   try {
  #     // @ts-expect-error cannot select numbers
  #     await page.selectOption('select', { value: 12 });
  #   } catch (e) {
  #     error = e;
  #   }
  #   expect(error.message).toContain('options[0].value: expected string, got number');

  #   error = null;
  #   try {
  #     // @ts-expect-error cannot select numbers
  #     await page.selectOption('select', { label: 12 });
  #   } catch (e) {
  #     error = e;
  #   }
  #   expect(error.message).toContain('options[0].label: expected string, got number');

  #   error = null;
  #   try {
  #     // @ts-expect-error cannot select string indices
  #     await page.selectOption('select', { index: '12' });
  #   } catch (e) {
  #     error = e;
  #   }
  #   expect(error.message).toContain('options[0].index: expected number, got string');
  # });
  # // @see https://github.com/GoogleChrome/puppeteer/issues/3327
  # it('should work when re-defining top-level Event class', async ({page, server}) => {
  #   await page.goto(server.PREFIX + '/input/select.html');
  #   await page.evaluate(() => window.Event = null);
  #   await page.selectOption('select', 'blue');
  #   expect(await page.evaluate(() => window['result'].onInput)).toEqual(['blue']);
  #   expect(await page.evaluate(() => window['result'].onChange)).toEqual(['blue']);
  # });

  # it('should wait for option to be present',async ({page, server}) => {
  #   await page.goto(server.PREFIX + '/input/select.html');
  #   const selectPromise  = page.selectOption('select', 'scarlet');
  #   let didSelect = false;
  #   selectPromise.then(() => didSelect = true);
  #   await giveItAChanceToResolve(page);
  #   expect(didSelect).toBe(false);
  #   await page.$eval('select', select => {
  #     const option = document.createElement('option');
  #     option.value = 'scarlet';
  #     option.textContent = 'Scarlet';
  #     select.appendChild(option);
  #   });
  #   const items = await selectPromise;
  #   expect(items).toStrictEqual(['scarlet']);
  # });

  # it('should wait for option index to be present',async ({page, server}) => {
  #   await page.goto(server.PREFIX + '/input/select.html');
  #   const len = await page.$eval('select', select => select.options.length);
  #   const selectPromise  = page.selectOption('select', {index: len});
  #   let didSelect = false;
  #   selectPromise.then(() => didSelect = true);
  #   await giveItAChanceToResolve(page);
  #   expect(didSelect).toBe(false);
  #   await page.$eval('select', select => {
  #     const option = document.createElement('option');
  #     option.value = 'scarlet';
  #     option.textContent = 'Scarlet';
  #     select.appendChild(option);
  #   });
  #   const items = await selectPromise;
  #   expect(items).toStrictEqual(['scarlet']);
  # });

  # it('should wait for multiple options to be present',async ({page, server}) => {
  #   await page.goto(server.PREFIX + '/input/select.html');
  #   await page.evaluate(() => window['makeMultiple']());
  #   const selectPromise  = page.selectOption('select', ['green', 'scarlet']);
  #   let didSelect = false;
  #   selectPromise.then(() => didSelect = true);
  #   await giveItAChanceToResolve(page);
  #   expect(didSelect).toBe(false);
  #   await page.$eval('select', select => {
  #     const option = document.createElement('option');
  #     option.value = 'scarlet';
  #     option.textContent = 'Scarlet';
  #     select.appendChild(option);
  #   });
  #   const items = await selectPromise;
  #   expect(items).toStrictEqual(['green', 'scarlet']);
  # });
end
