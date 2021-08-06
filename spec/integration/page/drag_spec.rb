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

  it 'should allow specifying the position' do
    with_page do |page|
      page.content = <<~HTML
      <div style="width:100px;height:100px;background:red;" id="red">
      </div>
      <div style="width:100px;height:100px;background:blue;" id="blue">
      </div>
      HTML

      events_handle = page.evaluate_handle(<<~JAVASCRIPT)
      () => {
        const events = [];
        document.getElementById('red').addEventListener('mousedown', event => {
          events.push({
            type: 'mousedown',
            x: event.offsetX,
            y: event.offsetY,
          });
        });
        document.getElementById('blue').addEventListener('mouseup', event => {
          events.push({
            type: 'mouseup',
            x: event.offsetX,
            y: event.offsetY,
          });
        });
        return events;
      }
      JAVASCRIPT
      page.drag_and_drop('#red', '#blue',
        sourcePosition: {x: 34, y: 7},
        targetPosition: {x: 10, y: 20},
      )

      expect(events_handle.json_value).to eq([
        { 'type' => 'mousedown', 'x' => 34, 'y' => 7 },
        { 'type' => 'mouseup', 'x' => 10, 'y' => 20 },
      ])
    end
  end
end
