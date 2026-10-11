require 'spec_helper'
require 'playwright/test'

# https://github.com/microsoft/playwright/blob/release-1.64/tests/library/screencast-actions.spec.ts
RSpec.describe 'screencast actions', sinatra: true, playwright_under_test: true do
  include Playwright::Test::Matchers

  before { skip 'Annotations use an open shadow root only in default mode' if remote? }

  it 'should show annotation on click' do
    context = browser.new_context
    page = context.new_page
    page.goto("#{server_prefix}/input/button.html")

    page.screencast.show_actions(duration: 5000)
    Concurrent::Promises.future { page.click('button') rescue nil }

    expect(page.locator('x-pw-screencast-highlight')).to have_count(0)
    expect(page.locator('x-pw-screencast-point')).to have_count(0)
    expect(page.locator('x-pw-title')).to be_visible
    expect(page.locator('x-pw-title')).to have_text(/click/i)

    context.close
  end

  it 'should render annotation styles' do
    context = browser.new_context
    page = context.new_page
    page.goto("#{server_prefix}/input/button.html")

    page.screencast.show_actions(duration: 5000, fontSize: 32, style: {
      point: 'width: 20px; height: 20px; border-radius: 50%; background: red',
      highlight: 'outline: 2px solid #333',
      title: 'top: 100px; background-color: rgb(1, 2, 3)',
    })
    button_box = page.locator('button').bounding_box
    Concurrent::Promises.future { page.click('button') rescue nil }

    highlight = page.locator('x-pw-screencast-highlight')
    expect(highlight).to be_visible
    expect(highlight.evaluate('(el) => getComputedStyle(el).outlineWidth')).to eq('2px')
    box = highlight.bounding_box
    %w[x y width height].each { |key| expect(box[key]).to be_within(0.5).of(button_box[key]) }
    point = page.locator('x-pw-screencast-point').bounding_box
    expect(point['width']).to eq(20)
    expect((point['x'] + 10 - (button_box['x'] + button_box['width'] / 2)).abs).to be <= 1
    expect((point['y'] + 10 - (button_box['y'] + button_box['height'] / 2)).abs).to be <= 1

    title = page.locator('x-pw-title')
    expect(title).to be_visible
    title_style = title.evaluate(<<~JAVASCRIPT)
    (el) => {
      const cs = getComputedStyle(el);
      return {
        color: cs.color, borderRadius: cs.borderRadius, padding: cs.padding, backgroundColor: cs.backgroundColor,
        top: el.style.top, right: el.style.right, fontSize: el.style.fontSize,
      };
    }
    JAVASCRIPT
    expect(title_style['backgroundColor']).to eq('rgb(1, 2, 3)')
    expect(title_style['color']).to eq('rgb(255, 255, 255)')
    expect(title_style['borderRadius']).to eq('6px')
    expect(title_style['padding']).to eq('6px')
    expect(title_style['top']).to eq('6px')
    expect(title_style['right']).to eq('6px')
    expect(title_style['fontSize']).to eq('32px')

    context.close
  end

  [
    ['top-left', { 'top' => '6px', 'left' => '6px' }],
    ['top', { 'top' => '6px', 'left' => '50%' }],
    ['bottom-left', { 'bottom' => '6px', 'left' => '6px' }],
    ['bottom', { 'bottom' => '6px', 'left' => '50%' }],
    ['bottom-right', { 'bottom' => '6px', 'right' => '6px' }],
  ].each do |position, expected|
    it "should position title at #{position}" do
      context = browser.new_context
      page = context.new_page
      page.goto("#{server_prefix}/input/button.html")

      page.screencast.show_actions(duration: 5000, position: position)
      Concurrent::Promises.future { page.click('button') rescue nil }

      title = page.locator('x-pw-title')
      expect(title).to be_visible

      title_style = title.evaluate(<<~JAVASCRIPT)
      (el) => ({
        top: el.style.top,
        bottom: el.style.bottom,
        left: el.style.left,
        right: el.style.right,
      })
      JAVASCRIPT

      expected.each do |key, value|
        expect(title_style[key]).to eq(value)
      end

      context.close
    end
  end

  it 'should clear annotation after duration' do
    context = browser.new_context
    page = context.new_page
    page.goto("#{server_prefix}/input/button.html")

    page.screencast.show_actions(duration: 1000, style: { point: 'width: 20px; height: 20px', highlight: 'outline: 2px solid #333' })
    page.click('button')

    expect(page.locator('x-pw-screencast-point')).to have_count(0)
    expect(page.locator('x-pw-screencast-highlight')).to have_count(0)
    expect(page.locator('x-pw-title')).to be_hidden

    context.close
  end

  it 'should annotate fill action' do
    context = browser.new_context
    page = context.new_page
    page.goto("#{server_prefix}/input/textarea.html")

    page.screencast.show_actions(duration: 5000)
    Concurrent::Promises.future { page.fill('textarea', 'hello') rescue nil }

    title = page.locator('x-pw-title')
    expect(title).to be_visible
    expect(title).to have_text(/fill/i)

    context.close
  end

  it 'should stop showing actions after dispose' do
    context = browser.new_context
    page = context.new_page
    page.goto("#{server_prefix}/input/button.html")

    actions = page.screencast.show_actions(duration: 1000)
    page.click('button')
    actions.dispose

    page.goto("#{server_prefix}/input/button.html")
    page.click('button')

    expect(page.locator('x-pw-title')).to be_hidden

    context.close
  end

  it 'should stop showing actions after hideActions' do
    context = browser.new_context
    page = context.new_page
    page.goto("#{server_prefix}/input/button.html")

    page.screencast.show_actions(duration: 1000)
    page.click('button')
    page.screencast.hide_actions

    page.goto("#{server_prefix}/input/button.html")
    page.click('button')

    expect(page.locator('x-pw-title')).to be_hidden

    context.close
  end

  it 'should render an action cursor that animates to the click point' do
    context = browser.new_context
    page = context.new_page
    page.goto("#{server_prefix}/input/button.html")

    page.screencast.show_actions(duration: 5000)
    Concurrent::Promises.future { page.click('button') rescue nil }

    cursor = page.locator('x-pw-action-cursor')
    expect(cursor).to be_visible
    initial = cursor.evaluate(<<~JAVASCRIPT)
    (el) => ({
      top: el.style.top,
      left: el.style.left,
    })
    JAVASCRIPT
    expect(initial['top']).to match(/\d+px/)
    expect(initial['left']).to match(/\d+px/)

    context.close
  end

  it 'cursor moves between two pointer actions' do
    context = browser.new_context
    page = context.new_page
    page.content = <<~HTML
      <div style="position: fixed; top: 20px; left: 20px; width: 60px; height: 60px;" id="a">A</div>
      <div style="position: fixed; bottom: 20px; right: 20px; width: 60px; height: 60px;" id="b">B</div>
    HTML

    page.screencast.show_actions(duration: 5000)
    cursor = page.locator('x-pw-action-cursor')

    first_action = Concurrent::Promises.future { page.click('#a', force: true) rescue nil }
    expect(cursor).to be_visible
    first = cursor.evaluate("(el) => ({ top: el.style.top, left: el.style.left })")
    first_action.value! rescue nil

    second_action = Concurrent::Promises.future { page.click('#b', force: true) rescue nil }
    second = nil
    Timeout.timeout(5) do
      loop do
        second = cursor.evaluate("(el) => ({ top: el.style.top, left: el.style.left })")
        break if second != first
        sleep 0.05
      end
    end
    expect(second).not_to eq(first)
    second_action.value! rescue nil

    context.close
  end

  it 'cursor: "none" suppresses the action cursor decoration' do
    context = browser.new_context
    page = context.new_page
    page.goto("#{server_prefix}/input/button.html")

    page.screencast.show_actions(duration: 5000, cursor: 'none')
    Concurrent::Promises.future { page.click('button') rescue nil }

    expect(page.locator('x-pw-title')).to be_visible
    expect(page.locator('x-pw-action-cursor')).to be_hidden

    context.close
  end

  it 'should survive navigation' do
    context = browser.new_context
    page = context.new_page
    page.goto("#{server_prefix}/input/button.html")

    page.screencast.show_actions(duration: 5000)
    Concurrent::Promises.future { page.click('button') rescue nil }

    expect(page.locator('x-pw-title')).to be_visible

    page.goto("#{server_prefix}/input/button.html")
    Concurrent::Promises.future { page.click('button') rescue nil }

    expect(page.locator('x-pw-title')).to be_visible

    context.close
  end

  it 'cursor stays at the last action point until hideActions' do
    with_page do |page|
      page.goto("#{server_prefix}/input/button.html")
      page.screencast.show_actions(duration: 100)
      page.click('button')
      expect(page.locator('x-pw-title')).to be_hidden
      cursor = page.locator('x-pw-action-cursor')
      expect(cursor).to be_visible
      position = cursor.evaluate('(el) => ({ top: el.style.top, left: el.style.left })')
      page.goto(server_empty_page)
      expect(cursor).to be_visible
      expect(cursor.evaluate('(el) => ({ top: el.style.top, left: el.style.left })')).to eq(position)
      page.screencast.hide_actions
      expect(cursor).to be_hidden
    end
  end

end
