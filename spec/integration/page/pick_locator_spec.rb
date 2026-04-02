require 'spec_helper'
require 'playwright/test'

# https://github.com/microsoft/playwright/blob/main/tests/library/inspector/recorder-api.spec.ts
RSpec.describe 'Page#pick_locator' do
  include Playwright::Test::Matchers

  it 'should return locator for picked element' do
    with_page do |page|
      page.content = '<button>Submit</button>'

      pick_promise = Concurrent::Promises.future { page.pick_locator }

      # Wait for the recorder script to be injected
      sleep 1

      box = page.get_by_role('button', name: 'Submit').bounding_box
      page.mouse.click(box['x'] + box['width'] / 2, box['y'] + box['height'] / 2)

      locator = pick_promise.value!
      expect(locator).to have_text('Submit')
    end
  end
end
