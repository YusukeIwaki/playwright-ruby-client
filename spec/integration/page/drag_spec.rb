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

  [
    {
      title: 'drag_and_drop',
      drag: ->(page, steps) { page.drag_and_drop('#red', '#blue', steps: steps) }
    },
    {
      title: 'drag_to',
      drag: ->(page, steps) { page.locator('#red').drag_to(page.locator('#blue'), steps: steps) }
    }
  ].each do |config|
    it "should #{config[:title]} with tweened mouse movement" do
      with_page do |page|
        page.content = <<~HTML
        <body style="margin: 0; padding: 0;">
          <div style="width:100px;height:100px;background:red;" id="red"></div>
          <div style="width:300px;height:100px;background:blue;" id="blue"></div>
        </body>
        HTML

        events_handle = page.evaluate_handle(<<~JAVASCRIPT)
        () => {
          const events = [];
          document.addEventListener('mousedown', event => {
            events.push({ type: 'mousedown', x: event.pageX, y: event.pageY });
          });
          document.addEventListener('mouseup', event => {
            events.push({ type: 'mouseup', x: event.pageX, y: event.pageY });
          });
          document.addEventListener('mousemove', event => {
            events.push({ type: 'mousemove', x: event.pageX, y: event.pageY });
          });
          return events;
        }
        JAVASCRIPT

        config[:drag].call(page, 4)

        expect(events_handle.json_value).to eq([
          { 'type' => 'mousemove', 'x' => 50, 'y' => 50 },
          { 'type' => 'mousedown', 'x' => 50, 'y' => 50 },
          { 'type' => 'mousemove', 'x' => 75, 'y' => 75 },
          { 'type' => 'mousemove', 'x' => 100, 'y' => 100 },
          { 'type' => 'mousemove', 'x' => 125, 'y' => 125 },
          { 'type' => 'mousemove', 'x' => 150, 'y' => 150 },
          { 'type' => 'mouseup', 'x' => 150, 'y' => 150 }
        ])
      end
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

  it 'should work with locators', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/drag-n-drop.html")
      page.locator('#source').drag_to(page.locator('#target'))
      expect(page.eval_on_selector('#target', "target => target.contains(document.querySelector('#source'))")).to eq(true)
    end
  end
end
