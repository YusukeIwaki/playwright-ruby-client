require 'spec_helper'
require 'base64'

RSpec.describe 'screenshot' do
  def webp?(buffer)
    buffer.byteslice(0, 4) == 'RIFF' && buffer.byteslice(8, 4) == 'WEBP'
  end

  # Faithful Ruby port of packages/utils/webp/webp.ts:isLosslessWebp.
  def lossless_webp?(buffer)
    return false unless webp?(buffer) && buffer.bytesize >= 16

    offset = 12
    while offset + 8 <= buffer.bytesize
      fourcc = buffer.byteslice(offset, 4)
      return true if fourcc == 'VP8L'
      return false if fourcc == 'VP8 '

      size = buffer.byteslice(offset + 4, 4).unpack1('V')
      offset += 8 + size + (size & 1)
    end
    false
  end

  def image_info(page, buffer, mime_type:, points: [])
    arg = {
      data: Base64.strict_encode64(buffer),
      mimeType: mime_type,
      points: points,
    }
    page.evaluate(<<~JAVASCRIPT, arg: arg)
      async ({ data, mimeType, points }) => {
        const image = new Image();
        const loaded = new Promise((resolve, reject) => {
          image.onload = resolve;
          image.onerror = reject;
        });
        image.src = `data:${mimeType};base64,${data}`;
        await loaded;
        const canvas = document.createElement('canvas');
        canvas.width = image.width;
        canvas.height = image.height;
        const context = canvas.getContext('2d');
        context.drawImage(image, 0, 0);
        return {
          width: image.width,
          height: image.height,
          pixels: points.map(([x, y]) => Array.from(context.getImageData(x, y, 1, 1).data)),
        };
      }
    JAVASCRIPT
  end

  def images_have_equal_pixels?(page, first, second)
    arg = {
      first: Base64.strict_encode64(first),
      second: Base64.strict_encode64(second),
    }
    page.evaluate(<<~JAVASCRIPT, arg: arg)
      async ({ first, second }) => {
        const decode = async (data, mimeType) => {
          const image = new Image();
          const loaded = new Promise((resolve, reject) => {
            image.onload = resolve;
            image.onerror = reject;
          });
          image.src = `data:${mimeType};base64,${data}`;
          await loaded;
          const canvas = document.createElement('canvas');
          canvas.width = image.width;
          canvas.height = image.height;
          const context = canvas.getContext('2d');
          context.drawImage(image, 0, 0);
          return {
            width: image.width,
            height: image.height,
            data: context.getImageData(0, 0, image.width, image.height).data,
          };
        };
        const a = await decode(first, 'image/webp');
        const b = await decode(second, 'image/png');
        return {
          width: a.width,
          height: a.height,
          otherWidth: b.width,
          otherHeight: b.height,
          equal: a.data.length === b.data.length && a.data.every((value, index) => value === b.data[index]),
        };
      }
    JAVASCRIPT
  end

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

    it 'should work when mask color is not pink #F0F' do
      with_page do |page|
        page.viewport_size = { width: 500, height: 500 }
        page.goto("#{server_prefix}/grid.html")

        masked = page.screenshot(
          mask: [page.locator('div').nth(5)],
          maskColor: '#00FF00',
        )
        original = page.screenshot
        expect(masked).not_to eq(original)
      end
    end

    it 'should hide elements based on attr' do
      with_page do |page|
        page.viewport_size = { width: 500, height: 500 }
        page.goto("#{server_prefix}/grid.html")
        page.locator('div').nth(5).evaluate("element => {
          element.setAttribute('data-test-screenshot', 'hide');
        }")
        masked = page.screenshot(
          # path: 'screenshot-style1.png',
          style: <<~CSS
          [data-test-screenshot="hide"] {
            visibility: hidden;
          }
          CSS
        )
        original = page.screenshot
        expect(masked).not_to eq(original)
        visibility = page.locator('div').nth(5).evaluate("element => element.style.visibility")
        expect(visibility).to eq('')
      end
    end

    it 'should remove elements based on attr' do
      with_page do |page|
        page.viewport_size = { width: 500, height: 500 }
        page.goto("#{server_prefix}/grid.html")
        page.locator('div').nth(5).evaluate("element => {
          element.setAttribute('data-test-screenshot', 'remove');
        }")
        masked = page.screenshot(
          # path: 'screenshot-style2.png',
          style: <<~CSS
          [data-test-screenshot="remove"] {
            display: none;
          }
          CSS
        )
        original = page.screenshot
        expect(masked).not_to eq(original)
        display = page.locator('div').nth(5).evaluate("element => element.style.display")
        expect(display).to eq('')
      end
    end
  end

  describe 'webp', sinatra: true do
    # https://github.com/microsoft/playwright/blob/v1.62.1/tests/page/page-screenshot.spec.ts
    it 'should produce a valid webp screenshot' do
      with_page do |page|
        page.viewport_size = { width: 300, height: 300 }
        page.goto(server_empty_page)
        page.evaluate("() => document.body.style.background = 'rgb(255, 0, 0)'")
        screenshot = page.screenshot(type: 'webp')

        expect(webp?(screenshot)).to eq(true)
        info = image_info(page, screenshot, mime_type: 'image/webp', points: [[150, 150]])
        expect(info['width']).to eq(300)
        expect(info['height']).to eq(300)
        expect(info['pixels']).to eq([[255, 0, 0, 255]])
      end
    end

    # https://github.com/microsoft/playwright/blob/v1.62.1/tests/page/page-screenshot.spec.ts
    it 'path option should detect webp' do
      Dir.mktmpdir do |dir|
        with_page do |page|
          page.viewport_size = { width: 300, height: 300 }
          page.goto(server_empty_page)
          page.evaluate("() => document.body.style.background = 'rgb(255, 0, 0)'")
          output_path = File.join(dir, 'screenshot.webp')
          screenshot = page.screenshot(path: output_path)
          saved = File.binread(output_path)

          expect(saved).to eq(screenshot)
          expect(webp?(saved)).to eq(true)
          info = image_info(page, screenshot, mime_type: 'image/webp', points: [[150, 150]])
          expect(info['pixels']).to eq([[255, 0, 0, 255]])
        end
      end
    end

    # https://github.com/microsoft/playwright/blob/v1.62.1/tests/page/page-screenshot.spec.ts
    it 'quality option should work for webp' do
      with_page do |page|
        page.goto("#{server_prefix}/grid.html")
        low_quality = page.screenshot(type: 'webp', quality: 0)
        high_quality = page.screenshot(type: 'webp', quality: 100)
        expect(low_quality.bytesize).to be < high_quality.bytesize
      end
    end

    # https://github.com/microsoft/playwright/blob/v1.62.1/tests/page/page-screenshot.spec.ts
    it 'webp screenshots should be lossless by default' do
      with_page do |page|
        page.goto("#{server_prefix}/grid.html")
        expect(lossless_webp?(page.screenshot(type: 'webp'))).to eq(true)
        expect(lossless_webp?(page.screenshot(type: 'webp', quality: 80))).to eq(false)
      end
    end

    # https://github.com/microsoft/playwright/blob/v1.62.1/tests/page/page-screenshot.spec.ts
    it 'should allow transparency with webp' do
      skip 'Upstream marks this as expected to fail in Firefox' if firefox?

      with_page do |page|
        page.viewport_size = { width: 300, height: 300 }
        page.set_content(<<~HTML)
          <style>
            body { margin: 0 }
            div { width: 300px; height: 100px; }
          </style>
          <div style="background:black"></div>
          <div style="background:white"></div>
          <div style="background:transparent"></div>
        HTML
        screenshot = page.screenshot(omitBackground: true, type: 'webp')
        info = image_info(
          page,
          screenshot,
          mime_type: 'image/webp',
          points: [[150, 50], [150, 150], [150, 250]],
        )
        expect(info['width']).to eq(300)
        expect(info['height']).to eq(300)
        expect(info['pixels'][0]).to eq([0, 0, 0, 255])
        expect(info['pixels'][1]).to eq([255, 255, 255, 255])
        expect(info['pixels'][2][3]).to eq(0)
      end
    end

    # https://github.com/microsoft/playwright/blob/v1.62.1/tests/page/page-screenshot.spec.ts
    it 'quality option should throw for webp when out of range' do
      with_page do |page|
        expect {
          page.screenshot(type: 'webp', quality: 101)
        }.to raise_error(/Expected options\.quality to be between 0 and 100/)
      end
    end

    # https://github.com/microsoft/playwright/blob/v1.62.1/tests/page/elementhandle-screenshot.spec.ts
    it 'should work with webp' do
      with_page do |page|
        page.viewport_size = { width: 500, height: 500 }
        page.goto("#{server_prefix}/grid.html")
        element_handle = page.query_selector('.box:nth-of-type(3)')
        webp_image = element_handle.screenshot(type: 'webp')
        png_image = element_handle.screenshot(type: 'png')
        comparison = images_have_equal_pixels?(page, webp_image, png_image)

        expect(comparison['width']).to eq(comparison['otherWidth'])
        expect(comparison['height']).to eq(comparison['otherHeight'])
        expect(comparison['equal']).to eq(true)
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
