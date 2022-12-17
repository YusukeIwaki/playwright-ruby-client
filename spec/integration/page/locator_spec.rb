require 'spec_helper'

RSpec.describe 'locator' do
  # https://github.com/microsoft/playwright/blob/master/tests/page/locator-misc-1.spec.ts
  example_group 'misc1' do
    it 'should hover', sinatra: true do
      with_page do |page|
        page.goto("#{server_prefix}/input/scrollable.html")
        button = page.locator('#button-6')
        button.hover
        expect(page.evaluate("() => document.querySelector('button:hover').id")).to eq('button-6')
      end
    end

    it 'should hover when Node is removed', sinatra: true do
      with_page do |page|
        page.goto("#{server_prefix}/input/scrollable.html")
        page.evaluate("() => delete window['Node']")
        button = page.locator('#button-6')
        button.hover
        expect(page.evaluate("() => document.querySelector('button:hover').id")).to eq('button-6')
      end
    end

    it 'should fill input', sinatra: true do
      with_page do |page|
        page.goto("#{server_prefix}/input/textarea.html")
        input = page.locator('input')
        input.fill('some value')
        expect(page.evaluate("() => window['result']")).to eq('some value')
      end
    end

    it 'should fill input when Node is removed', sinatra: true do
      with_page do |page|
        page.goto("#{server_prefix}/input/textarea.html")
        page.evaluate("() => delete window['Node']")
        input = page.locator('input')
        input.fill('some value')
        expect(page.evaluate("() => window['result']")).to eq('some value')
      end
    end

    it 'should clear input', sinatra: true do
      with_page do |page|
        page.goto("#{server_prefix}/input/textarea.html")
        handle = page.locator('input')
        handle.fill('some value')
        expect { handle.clear }.to change {
          page.evaluate("() => window['result']")
        }.from('some value').to('')
      end
    end

    it 'should check the box' do
      with_page do |page|
        page.content = "<input id='checkbox' type='checkbox'></input>"
        input = page.locator('input')
        input.check
        expect(page.evaluate('checkbox.checked')).to eq(true)
      end
    end

    it 'should check the box using set_checked' do
      with_page do |page|
        page.content = "<input id='checkbox' type='checkbox'></input>"
        input = page.locator('input')
        input.checked = true
        expect(page.evaluate('checkbox.checked')).to eq(true)
        input.checked = false
        expect(page.evaluate('checkbox.checked')).to eq(false)
      end
    end

    it 'should uncheck the box' do
      with_page do |page|
        page.content = "<input id='checkbox' type='checkbox' checked></input>"
        input = page.locator('input')
        input.uncheck
        expect(page.evaluate('checkbox.checked')).to eq(false)
      end
    end

    it 'should select single option', sinatra: true do
      with_page do |page|
        page.goto("#{server_prefix}/input/select.html")
        sel = page.locator('select')
        sel.select_option(value: 'blue')
        expect(page.evaluate("() => window['result'].onInput")).to contain_exactly('blue')
        expect(page.evaluate("() => window['result'].onChange")).to contain_exactly('blue')
      end
    end

    it 'should focus and blur a button', sinatra: true do
      with_page do |page|
        page.goto("#{server_prefix}/input/button.html")
        button = page.locator('button')
        expect { button.focus }.to change {
          button.evaluate("button => document.activeElement === button")
        }.from(false).to(true)

        expect { button.blur }.to change {
          button.evaluate("button => document.activeElement === button")
        }.from(true).to(false)
      end
    end

    it 'should dispatch click event via ElementHandles', sinatra: true do
      with_page do |page|
        page.goto("#{server_prefix}/input/button.html")
        button = page.locator('button')
        button.dispatch_event('click')
        expect(page.evaluate("() => window['result']")).to eq('Clicked')
      end
    end

    it 'should upload the file', sinatra: true do
      with_page do |page|
        page.goto("#{server_prefix}/input/fileupload.html")
        filepath = File.join('spec', 'assets', 'file-to-upload.txt')
        input = page.locator('input[type=file]')
        input.set_input_files(filepath)
        expect(page.evaluate('e => e.files[0].name', arg: input.element_handle)).to eq('file-to-upload.txt')
      end
    end

    it 'should send all of the correct events', sinatra: true do
      with_page(hasTouch: true) do |page|
        page.content = <<~HTML
        <div id="a" style="background: lightblue; width: 50px; height: 50px">a</div>
        <div id="b" style="background: pink; width: 50px; height: 50px">b</div>
        HTML
        page.locator('#a').tap_point
        page.locator('#b').tap_point
      end
    end
  end

  # https://github.com/microsoft/playwright/blob/master/tests/page/locator-misc-2.spec.ts
  example_group 'misc2' do
    it 'should press' do
      with_page do |page|
        page.content = "<input type='text' />"
        page.locator('input').press('h')
        value = page.eval_on_selector('input', 'input => input.value')
        expect(value).to eq('h')
      end
    end

    it 'should scroll into view', sinatra: true do
      with_page do |page|
        page.goto("#{server_prefix}/offscreenbuttons.html")
        (0..10).each do |i|
          button = page.locator("#btn#{i}")

          before = button.evaluate('button => button.getBoundingClientRect().right - window.innerWidth')
          expect(before).to eq(10 * i)

          button.scroll_into_view_if_needed

          after = button.evaluate('button => button.getBoundingClientRect().right - window.innerWidth')
          expect(after).to be <= 0
          page.evaluate('() => window.scrollTo(0, 0)')
        end
      end
    end

    it 'should select textarea', sinatra: true do
      with_page do |page|
        page.goto("#{server_prefix}/input/textarea.html")
        textarea = page.locator('textarea')
        textarea.evaluate("textarea => textarea.value = 'some value'")
        textarea.select_text
        expect(page.evaluate('() => window.getSelection().toString()')).to eq('some value')
      end
    end

    it 'should type' do
      with_page do |page|
        page.content = "<input type='text' />"
        page.locator('input').type('hello')
        value = page.eval_on_selector('input', 'input => input.value')
        expect(value).to eq('hello')
      end
    end

    it 'should return bounding box', sinatra: true do
      with_page do |page|
        page.viewport_size = { width: 500, height: 500 }
        page.goto("#{server_prefix}/grid.html")
        element = page.locator('.box:nth-of-type(13)')
        box = element.bounding_box
        expect(box['x']).to eq(100)
        expect(box['y']).to eq(50)
        expect(box['width']).to eq(50)
        expect(box['height']).to eq(50)
      end
    end

    it 'should waitFor' do
      with_page do |page|
        page.content = '<div></div>'
        locator = page.locator('span')
        promise = Concurrent::Promises.future { locator.wait_for }
        page.eval_on_selector('div', "div => div.innerHTML = '<span>target</span>'")
        promise.value!
        expect(locator.text_content).to eq('target')
      end
    end

    it 'should waitFor hidden' do
      with_page do |page|
        page.content = '<div><span>target</span></div>'
        locator = page.locator('span')
        promise = Concurrent::Promises.future { locator.wait_for(state: :hidden) }
        page.eval_on_selector('div', "div => div.innerHTML = ''")
        promise.value!
      end
    end
  end
end
