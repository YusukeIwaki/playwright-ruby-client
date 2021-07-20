require 'spec_helper'

RSpec.describe 'drag' do
  it 'should work with the helper method', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/drag-n-drop.html")
      page.drag_and_drop('#source', '#target')

      # could not find source in target
      expect(page.eval_on_selector('#target', "target => target.contains(document.querySelector('#source'))")).to eq(true)
    end
  end
end
