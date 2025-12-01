require 'spec_helper'

RSpec.describe 'page-click' do
  it 'should click the button @smoke', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/button.html")
      page.click('button')
      expect(page.evaluate("() => window['result']")).to eq('Clicked')
    end
  end

  it 'should click button inside frameset', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/frames/frameset.html")
      frame_element = page.query_selector('frame')
      frame_element.evaluate("frame => frame.src = '/input/button.html'")
      frame = frame_element.content_frame
      frame.click('button')
      expect(frame.evaluate("() => window['result']")).to eq('Clicked')
    end
  end

  # ~~~
  # https://github.com/microsoft/playwright/blob/main/tests/page/page-click.spec.ts
  # ~~~

  it 'should click shadow root button' do
    # https://github.com/microsoft/playwright/issues/37768
    with_page do |page|
      page.content = <<~HTML
      <my-button>
        <template shadowrootmode="open">
          <button><slot></slot></button>
        </template>
        <div>Foo</div>
      </my-button>
      HTML

      page.locator('my-button').click
    end
  end

  it 'should click with tweened mouse movement' do
    with_page do |page|
      page.content = <<~HTML
      <body style="margin: 0; padding: 0; height: 500px; width: 500px;">
        <div style="position: relative; top: 280px; left: 150px; width: 100px; height: 40px">Click me</div>
      </body>
      HTML

      if respond_to?(:browser_name) && browser_name == 'webkit'
        page.evaluate('() => new Promise(requestAnimationFrame)')
      end

      page.mouse.move(100, 100)
      page.evaluate(<<~JAVASCRIPT)
      () => {
        window['result'] = [];
        document.addEventListener('mousemove', event => {
          window['result'].push([event.clientX, event.clientY]);
        });
      }
      JAVASCRIPT

      page.locator('div').click(steps: 5)
      expect(page.evaluate('() => window["result"]')).to eq([
        [120, 140],
        [140, 180],
        [160, 220],
        [180, 260],
        [200, 300]
      ])
    end
  end
end
