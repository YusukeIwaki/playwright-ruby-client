require 'spec_helper'

RSpec.describe 'screenshot' do
  describe 'page screenshot animations' do
    def rafraf(page)
      # Do a double raf since single raf does not
      # actually guarantee a new animation frame.
      page.evaluate(<<~JAVASCRIPT)
      () => new Promise(x => {
        requestAnimationFrame(() => requestAnimationFrame(x));
      })
      JAVASCRIPT
    end

    it 'should not capture infinite css animation', sinatra: true do
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

    it 'should resume infinite animations', sinatra: true do
      with_page do |page|
        page.goto("#{server_prefix}/rotate-z.html")
        page.screenshot(animations: 'disabled')
        buffer1 = page.screenshot
        rafraf(page)
        buffer2 = page.screenshot

        expect(buffer2).not_to eq(buffer1)
      end
    end

    it 'should fire transitionend for finite transitions', sinatra: true do
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
