require 'spec_helper'

RSpec.describe 'screenshot' do
  describe 'scale option', sinatra: true do
    it 'should work with device scale factor and scale:css' do
      with_context(viewport: { width: 320, height: 480 }, deviceScaleFactor: 2) do |context|
        page = context.new_page
        page.goto("#{server_prefix}/grid.html")
        expect(page.screenshot(scale: :css, path: 'a.png')).not_to be_nil
        # TODO toHaveScreenshot https://github.com/microsoft/playwright/blob/main/tests/library/screenshot.spec.ts-snapshots/screenshot-device-scale-factor-css-size-chromium.png
      end
    end
  end

  it 'should not capture blinking caret by default' do
    with_page do |page|
      page.content = <<~HTML
      <!-- Refer to stylesheet from other origin. Accessing this
           stylesheet rules will throw.
      -->
      <link rel=stylesheet href="${server.CROSS_PROCESS_PREFIX + '/injectedstyle.css'}">
      <!-- make life harder: define caret color in stylesheet -->
      <style>
        div {
          caret-color: #000 !important;
        }
      </style>
      <div contenteditable="true"></div>
      HTML

      div = page.locator('div')
      div.type('foo bar')
      screenshot = div.screenshot

      10.times do
        # Caret blinking time is set to 500ms.
        # Try to capture variety of screenshots to make
        # sure we don't capture blinking caret.
        sleep 0.15
        new_screenshot = div.screenshot
        expect(new_screenshot).to eq(screenshot)
      end
    end
  end

  it 'should capture blinking caret if explicitly asked for' do
    with_page do |page|
      page.content = <<~HTML
      <!-- Refer to stylesheet from other origin. Accessing this
           stylesheet rules will throw.
      -->
      <link rel=stylesheet href="${server.CROSS_PROCESS_PREFIX + '/injectedstyle.css'}">
      <!-- make life harder: define caret color in stylesheet -->
      <style>
        div {
          caret-color: #000 !important;
        }
      </style>
      <div contenteditable="true"></div>
      HTML

      div = page.locator('div')
      div.type('foo bar')
      screenshot = div.screenshot

      has_different_screenshots = false
      10.times do
        # Caret blinking time is set to 500ms.
        # Try to capture variety of screenshots to make
        # sure we capture blinking caret.
        sleep 0.15
        has_different_screenshots = div.screenshot(caret: :initial) != screenshot
        break if has_different_screenshots
      end
      expect(has_different_screenshots).to eq(true)
    end
  end

  describe 'mask option', sinatra: true do
    it 'should work' do
      with_page do |page|
        page.viewport_size = { width: 500, height: 500 }
        page.goto("#{server_prefix}/grid.html")

        masked = page.screenshot(mask: [page.locator('div').nth(5)])
        original = page.screenshot
        expect(masked).not_to eq(original)
      end
    end

    it 'should work with locator' do
      with_page do |page|
        page.viewport_size = { width: 500, height: 500 }
        page.goto("#{server_prefix}/grid.html")

        body = page.locator('body')
        masked = body.screenshot(mask: [page.locator('div').nth(5)])
        original = body.screenshot
        expect(masked).not_to eq(original)
      end
    end

    it 'should work with elementhandle' do
      with_page do |page|
        page.viewport_size = { width: 500, height: 500 }
        page.goto("#{server_prefix}/grid.html")

        body = page.query_selector('body')
        masked = body.screenshot(mask: [page.locator('div').nth(5)])
        original = body.screenshot
        expect(masked).not_to eq(original)
      end
    end
  end

  describe 'page screenshot animations', sinatra: true do
    def rafraf(page)
      # Do a double raf since single raf does not
      # actually guarantee a new animation frame.
      page.evaluate(<<~JAVASCRIPT)
      () => new Promise(x => {
        requestAnimationFrame(() => requestAnimationFrame(x));
      })
      JAVASCRIPT
    end

    it 'should not capture infinite css animation' do
      with_page do |page|
        page.goto("#{server_prefix}/rotate-z.html")
        div = page.locator('div')
        screenshot = div.screenshot(animations: 'disabled')

        10.times do |i|
          rafraf(page)
          new_screenshot = div.screenshot(animations: 'disabled')

          expect(new_screenshot).to eq(screenshot)
        end
      end
    end

    it 'should resume infinite animations' do
      with_page do |page|
        page.goto("#{server_prefix}/rotate-z.html")
        page.screenshot(animations: 'disabled')
        buffer1 = page.screenshot
        rafraf(page)
        buffer2 = page.screenshot

        expect(buffer2).not_to eq(buffer1)
      end
    end

    it 'should fire transitionend for finite transitions' do
      with_page do |page|
        page.goto("#{server_prefix}/css-transition.html")
        div = page.locator('div')
        div.evaluate(<<~JAVASCRIPT)
        el => {
          el.addEventListener('transitionend', () => window['__TRANSITION_END'] = true, false);
        }
        JAVASCRIPT

        # make sure transition is actually running
        screenshot1 = page.screenshot
        rafraf(page)
        screenshot2 = page.screenshot
        raise 'transition is not running' if screenshot1 == screenshot2

        # Make a screenshot that finishes all finite animations.
        screenshot1 = div.screenshot(animations: :disabled)
        rafraf(page)
        screenshot2 = div.screenshot
        expect(screenshot2).to eq(screenshot1)
        expect(page.evaluate("() => window['__TRANSITION_END']")).to eq(true)
      end
    end
  end
end
