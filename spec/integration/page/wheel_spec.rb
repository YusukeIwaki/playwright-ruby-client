require 'spec_helper'

RSpec.describe 'Mouse#wheel' do
  def listen_for_wheel_events(page, selector)
    page.evaluate(<<~JAVASCRIPT, arg: selector)
    selector => {
      document.querySelector(selector).addEventListener('wheel', (e) => {
        window['lastEvent'] = {
          deltaX: e.deltaX,
          deltaY: e.deltaY,
          clientX: e.clientX,
          clientY: e.clientY,
          deltaMode: e.deltaMode,
          ctrlKey: e.ctrlKey,
          shiftKey: e.shiftKey,
          altKey: e.altKey,
          metaKey: e.metaKey,
        };
      }, { passive: false });
    }
    JAVASCRIPT
  end

  it 'should dispatch wheel events' do
    with_page do |page|
      page.content = '<div style="width: 5000px; height: 5000px;"></div>'
      page.mouse.move(50, 60)
      listen_for_wheel_events(page, 'div')
      page.mouse.wheel(0, 100)

      last_event = page.evaluate('window.lastEvent')
      expect(last_event).to eq({
        'deltaX' => 0,
        'deltaY' => 100,
        'clientX' => 50,
        'clientY' => 60,
        'deltaMode' => 0,
        'ctrlKey' => false,
        'shiftKey' => false,
        'altKey' => false,
        'metaKey' => false,
      })
    end
  end

  it 'should scroll when nobody is listening', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/scrollable.html")
      page.mouse.move(50, 60)
      page.mouse.wheel(0, 100)
      page.wait_for_function('window.scrollY === 100')
    end
  end

  it 'should set the modifiers' do
    with_page do |page|
      page.content = '<div style="width: 5000px; height: 5000px;"></div>'
      page.mouse.move(50, 60)
      listen_for_wheel_events(page, 'div')
      page.keyboard.down('Shift')
      page.mouse.wheel(0, 100)

      last_event = page.evaluate('window.lastEvent')
      expect(last_event).to eq({
        'deltaX' => 0,
        'deltaY' => 100,
        'clientX' => 50,
        'clientY' => 60,
        'deltaMode' => 0,
        'ctrlKey' => false,
        'shiftKey' => true,
        'altKey' => false,
        'metaKey' => false,
      })
    end
  end

  it 'should scroll horizontally' do
    with_page do |page|
      page.content = '<div style="width: 5000px; height: 5000px;"></div>'
      page.mouse.move(50, 60)
      listen_for_wheel_events(page, 'div')
      page.keyboard.down('Shift')
      page.mouse.wheel(100, 0)

      last_event = page.evaluate('window.lastEvent')
      expect(last_event).to eq({
        'deltaX' => 100,
        'deltaY' => 0,
        'clientX' => 50,
        'clientY' => 60,
        'deltaMode' => 0,
        'ctrlKey' => false,
        'shiftKey' => true,
        'altKey' => false,
        'metaKey' => false,
      })
      page.wait_for_function('window.scrollX === 100')
    end
  end

  it 'should work when the event is canceled' do
    with_page do |page|
      page.content = '<div style="width: 5000px; height: 5000px;"></div>'
      page.mouse.move(50, 60)
      listen_for_wheel_events(page, 'div')
      page.evaluate(<<~JAVASCRIPT)
      () => {
        document.querySelector('div').addEventListener('wheel', e => e.preventDefault());
      }
      JAVASCRIPT
      page.mouse.wheel(0, 100)

      last_event = page.evaluate('window.lastEvent')
      expect(last_event).to eq({
        'deltaX' => 0,
        'deltaY' => 100,
        'clientX' => 50,
        'clientY' => 60,
        'deltaMode' => 0,
        'ctrlKey' => false,
        'shiftKey' => false,
        'altKey' => false,
        'metaKey' => false,
      })

      # give the page a chacne to scroll
      sleep 0.1

      # ensure that it did not.
      expect(page.evaluate('window.scrollY')).to eq(0)
    end
  end
end
