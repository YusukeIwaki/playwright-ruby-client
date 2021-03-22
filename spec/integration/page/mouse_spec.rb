require 'spec_helper'

RSpec.describe 'mouse' do
  let(:dimensions) {
    <<~JAVASCRIPT
    () => {
      const rect = document.querySelector('textarea').getBoundingClientRect();
      return {
        x: rect.left,
        y: rect.top,
        width: rect.width,
        height: rect.height
      };
    }
    JAVASCRIPT
  }
  it 'should click the document' do
    with_page do |page|
      js = <<~JAVASCRIPT
        () => {
          window['clickPromise'] = new Promise(resolve => {
            document.addEventListener('click', event => {
              resolve({
                type: event.type,
                detail: event.detail,
                clientX: event.clientX,
                clientY: event.clientY,
                isTrusted: event.isTrusted,
                button: event.button
              });
            });
          });
        }
      JAVASCRIPT
      page.evaluate(js)
      page.mouse.click(50, 60)
      event = page.evaluate("() => window['clickPromise']")
      expect(event['type']).to eq('click')
      expect(event['detail']).to eq(1)
      expect(event['clientX']).to eq(50)
      expect(event['clientY']).to eq(60)
      expect(event['isTrusted']).to eq(true)
      expect(event['button']).to eq(0)
    end
  end

  it 'should dblclick the div' do
    with_page do |page|
      page.content = "<div style='width: 100px; height: 100px;'>Click me</div>"
      js = <<~JAVASCRIPT
        () => {
          window['dblclickPromise'] = new Promise(resolve => {
            document.querySelector('div').addEventListener('dblclick', event => {
              resolve({
                type: event.type,
                detail: event.detail,
                clientX: event.clientX,
                clientY: event.clientY,
                isTrusted: event.isTrusted,
                button: event.button,
              });
            });
          });
        }
      JAVASCRIPT
      page.evaluate(js)
      page.mouse.dblclick(50, 60)
      event = page.evaluate("() => window['dblclickPromise']")
      expect(event['type']).to eq('dblclick')
      expect(event['detail']).to eq(2)
      expect(event['clientX']).to eq(50)
      expect(event['clientY']).to eq(60)
      expect(event['isTrusted']).to eq(true)
      expect(event['button']).to eq(0)
    end
  end

  it 'should select the text with mouse', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/textarea.html")
      page.focus('textarea')
      text = 'This is the text that we are going to try to select. Let\'s see how it goes.'
      page.keyboard.type(text)

      # Firefox needs an extra frame here after typing or it will fail to set the scrollTop
      page.evaluate('() => new Promise(requestAnimationFrame)')
      page.evaluate("() => document.querySelector('textarea').scrollTop = 0")
      result = page.evaluate(dimensions)
      x = result['x']
      y = result['y']
      page.mouse.move(x + 2, y + 2)
      page.mouse.down
      page.mouse.move(200, 200)
      page.mouse.up
      js = <<~JAVASCRIPT
      () => {
        const textarea = document.querySelector('textarea');
        return textarea.value.substring(textarea.selectionStart, textarea.selectionEnd);
      }
      JAVASCRIPT
      expect(page.evaluate(js)).to eq(text)
    end
  end

  it 'should trigger hover state', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/scrollable.html")
      page.hover('#button-6')
      expect(page.evaluate("() => document.querySelector('button:hover').id")).to eq('button-6')
      page.hover('#button-2')
      expect(page.evaluate("() => document.querySelector('button:hover').id")).to eq('button-2')
      page.hover('#button-91')
      expect(page.evaluate("() => document.querySelector('button:hover').id")).to eq('button-91')
    end
  end

  it 'should trigger hover state on disabled button', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/scrollable.html")
      page.eval_on_selector('#button-6', '(button) => button.disabled = true')
      page.hover('#button-6', timeout: 5000)
      expect(page.evaluate("() => document.querySelector('button:hover').id")).to eq('button-6')
    end
  end

  it 'should trigger hover state with removed window.Node', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/scrollable.html")
      page.evaluate('() => delete window.Node')
      page.hover('#button-6')
      expect(page.evaluate("() => document.querySelector('button:hover').id")).to eq('button-6')
    end
  end

  it 'should set modifier keys on click', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/scrollable.html")
      page.evaluate("() => document.querySelector('#button-3').addEventListener('mousedown', e => window['lastEvent'] = e, true)")
      modifiers = {
        'Shift' => 'shiftKey',
        'Control' => 'ctrlKey',
        'Alt' => 'altKey',
        'Meta' => 'metaKey',
      }
      # In Firefox, the Meta modifier only exists on Mac
      # if (isFirefox && !isMac)
      #   delete modifiers['Meta'];

      modifiers.each do |key, value|
        page.keyboard.down(key)
        page.click('#button-3')
        last_event_modifier = page.evaluate("mod => window['lastEvent'][mod]", arg: value)
        page.keyboard.up(key)
        unless last_event_modifier
          raise "#{value} should be truthy"
        end
      end

      page.click('#button-3')
      modifiers.each do |key, value|
        last_event_modifier = page.evaluate("mod => window['lastEvent'][mod]", arg: value)
        if last_event_modifier
          raise "#{value} should be falsey"
        end
      end
    end
  end

  it 'should tween mouse movement' do
    with_page do |page|
      # The test becomes flaky on WebKit without next line.
      page.evaluate("() => new Promise(requestAnimationFrame)") if webkit?
      page.mouse.move(100, 100)
      js = <<~JAVASCRIPT
        () => {
          window['result'] = [];
          document.addEventListener('mousemove', event => {
            window['result'].push([event.clientX, event.clientY]);
          });
        }
      JAVASCRIPT
      page.evaluate(js)
      page.mouse.move(200, 300, steps: 5)
      result = page.evaluate('result')
      expect(result).to eq([
        [120, 140],
        [140, 180],
        [160, 220],
        [180, 260],
        [200, 300],
      ])
    end
  end

  it 'should work with mobile viewports and cross process navigations', sinatra: true do
    skip if firefox?

    # @see https://crbug.com/929806
    with_context(viewport: { width: 360, height: 640 }, isMobile: true) do |context|
      page = context.new_page
      page.goto(server_empty_page)
      page.goto("#{server_cross_process_prefix}/mobile.html")
      js = <<~JAVASCRIPT
        () => {
          document.addEventListener('click', event => {
            window['result'] = {x: event.clientX, y: event.clientY};
          });
        }
      JAVASCRIPT
      page.evaluate(js)

      page.mouse.click(30, 40)
      result = page.evaluate('result')
      expect(result['x']).to eq(30)
      expect(result['y']).to eq(40)
    end
  end
end
