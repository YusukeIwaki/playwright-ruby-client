require 'spec_helper'
require 'playwright/test'

# https://github.com/microsoft/playwright/blob/release-1.60/tests/library/screencast-actions.spec.ts
RSpec.describe 'screencast actions', sinatra: true, playwright_under_test: true do
  include Playwright::Test::Matchers

  before { skip 'Annotations use an open shadow root only in default mode' if remote? }

  it 'should show annotation on click' do
    context = browser.new_context
    page = context.new_page
    page.goto("#{server_prefix}/input/button.html")

    page.screencast.show_actions(duration: 5000)
    Concurrent::Promises.future { page.click('button') rescue nil }

    expect(page.locator('x-pw-highlight')).to be_visible
    expect(page.locator('x-pw-action-point')).to be_visible
    expect(page.locator('x-pw-title')).to be_visible
    expect(page.locator('x-pw-title')).to have_text(/click/i)

    context.close
  end

  it 'should render annotation styles' do
    context = browser.new_context
    page = context.new_page
    page.goto("#{server_prefix}/input/button.html")

    page.screencast.show_actions(duration: 5000, fontSize: 32)
    Concurrent::Promises.future { page.click('button') rescue nil }

    highlight = page.locator('x-pw-highlight')
    expect(highlight).to be_visible
    highlight_style = highlight.evaluate(<<~JAVASCRIPT)
    (el) => ({
      backgroundColor: el.style.backgroundColor,
      borderColor: el.style.borderColor,
    })
    JAVASCRIPT
    expect(highlight_style['backgroundColor']).to eq('rgba(0, 128, 255, 0.15)')
    expect(highlight_style['borderColor']).to eq('rgba(0, 128, 255, 0.6)')
    box = highlight.bounding_box
    expect(box['width']).to be > 0
    expect(box['height']).to be > 0

    action_point = page.locator('x-pw-action-point')
    expect(action_point).to be_visible
    action_point_style = action_point.evaluate(<<~JAVASCRIPT)
    (el) => {
      const cs = getComputedStyle(el);
      return { width: cs.width, height: cs.height, background: cs.backgroundColor, borderRadius: cs.borderRadius };
    }
    JAVASCRIPT
    expect(action_point_style['width']).to eq('20px')
    expect(action_point_style['height']).to eq('20px')
    expect(action_point_style['background']).to eq('rgb(255, 0, 0)')
    expect(action_point_style['borderRadius']).to eq('10px')

    title = page.locator('x-pw-title')
    expect(title).to be_visible
    title_style = title.evaluate(<<~JAVASCRIPT)
    (el) => {
      const cs = getComputedStyle(el);
      return {
        color: cs.color, borderRadius: cs.borderRadius, padding: cs.padding,
        top: el.style.top, right: el.style.right, fontSize: el.style.fontSize,
      };
    }
    JAVASCRIPT
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

    page.screencast.show_actions(duration: 1000)
    page.click('button')

    expect(page.locator('x-pw-action-point')).to be_hidden
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
end
