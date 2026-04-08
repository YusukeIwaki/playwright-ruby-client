require 'spec_helper'
require 'playwright/test'

# https://github.com/microsoft/playwright/blob/release-1.59/tests/library/inspector/recorder-api.spec.ts
RSpec.describe 'recorder API' do
  include Playwright::Test::Matchers

  it 'page.pickLocator should return locator for picked element' do
    with_page do |page|
      page.content = '<button>Submit</button>'

      script_ready = Concurrent::Promises.resolvable_future
      page.on('console', ->(msg) {
        script_ready.fulfill(true) if msg.text == 'Recorder script ready for test'
      })

      pick_promise = Concurrent::Promises.future { page.pick_locator }
      script_ready.value!(5)

      box = page.get_by_role('button', name: 'Submit').bounding_box
      page.mouse.click(box['x'] + box['width'] / 2, box['y'] + box['height'] / 2)

      locator = pick_promise.value!
      expect(locator).to have_text('Submit')
    end
  end

  it 'page.cancelPickLocator should cancel ongoing pickLocator' do
    with_page do |page|
      pick_promise = Concurrent::Promises.future { page.pick_locator }
      sleep 0.1
      page.cancel_pick_locator

      expect { pick_promise.value! }.to raise_error(/cancelled/)
    end
  end

  it 'closing page should cancel ongoing pickLocator' do
    with_context do |context|
      page = context.new_page
      page.content = '<button>Click me</button>'

      pick_promise = Concurrent::Promises.future {
        begin
          page.pick_locator
        rescue => e
          e.message
        end
      }
      page.close

      result = pick_promise.value!
      expect(result).to include('Target page, context or browser has been closed')
    end
  end

  it 'page2.pickLocator() should cancel page1.pickLocator()' do
    with_context do |context|
      page1 = context.new_page
      pick1_promise = Concurrent::Promises.future {
        begin
          page1.pick_locator
        rescue => e
          e.message
        end
      }

      page2 = context.new_page
      Concurrent::Promises.future { page2.pick_locator rescue nil }

      result = pick1_promise.value!
      expect(result).to include('cancelled')
    end
  end
end
