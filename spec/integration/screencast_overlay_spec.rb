require 'spec_helper'
require 'playwright/test'

# https://github.com/microsoft/playwright/blob/release-1.60/tests/library/screencast-overlay.spec.ts
RSpec.describe 'screencast overlay', sinatra: true, playwright_under_test: true do
  include Playwright::Test::Matchers

  before { skip 'Overlay uses an open shadow root only in default mode' if remote? }

  it 'should add and remove overlay' do
    context = browser.new_context
    page = context.new_page
    page.goto(server_empty_page)

    disposable = page.screencast.show_overlay('<div id="my-overlay">Hello Overlay</div>')
    expect(page.locator('x-pw-user-overlays')).to be_visible
    expect(page.locator('.x-pw-user-overlay')).to have_count(1)
    expect(page.locator('#my-overlay')).to have_text('Hello Overlay')

    disposable.dispose
    expect(page.locator('.x-pw-user-overlay')).to have_count(0)

    context.close
  end

  it 'should add multiple overlays' do
    context = browser.new_context
    page = context.new_page
    page.goto(server_empty_page)

    d1 = page.screencast.show_overlay('<div id="overlay-1">First</div>')
    d2 = page.screencast.show_overlay('<div id="overlay-2">Second</div>')
    expect(page.locator('.x-pw-user-overlay')).to have_count(2)
    expect(page.locator('#overlay-1')).to have_text('First')
    expect(page.locator('#overlay-2')).to have_text('Second')

    d1.dispose
    expect(page.locator('.x-pw-user-overlay')).to have_count(1)
    expect(page.locator('#overlay-2')).to have_text('Second')

    d2.dispose
    expect(page.locator('.x-pw-user-overlay')).to have_count(0)

    context.close
  end

  it 'should hide and show overlays' do
    context = browser.new_context
    page = context.new_page
    page.goto(server_empty_page)

    page.screencast.show_overlay('<div id="my-overlay">Visible</div>')
    expect(page.locator('x-pw-user-overlays')).to be_visible

    page.screencast.hide_overlays
    expect(page.locator('x-pw-user-overlays')).to be_hidden

    page.screencast.show_overlays
    expect(page.locator('x-pw-user-overlays')).to be_visible
    expect(page.locator('#my-overlay')).to have_text('Visible')

    context.close
  end

  it 'should survive navigation' do
    context = browser.new_context
    page = context.new_page
    page.goto(server_empty_page)

    page.screencast.show_overlay('<div id="persistent">Survives Reload</div>')
    expect(page.locator('#persistent')).to have_text('Survives Reload')

    page.goto(server_empty_page)
    expect(page.locator('#persistent')).to have_text('Survives Reload')

    page.reload
    expect(page.locator('#persistent')).to have_text('Survives Reload')

    context.close
  end

  it 'should remove overlay and not restore after navigation' do
    context = browser.new_context
    page = context.new_page
    page.goto(server_empty_page)

    disposable = page.screencast.show_overlay('<div id="temp">Temporary</div>')
    expect(page.locator('#temp')).to have_text('Temporary')

    disposable.dispose
    expect(page.locator('.x-pw-user-overlay')).to have_count(0)

    page.reload
    expect(page.locator('.x-pw-user-overlay')).to have_count(0)

    context.close
  end

  it 'should sanitize scripts from overlay html' do
    context = browser.new_context
    page = context.new_page
    page.goto(server_empty_page)

    page.screencast.show_overlay('<div id="safe">Safe</div><script>window.__injected = true</script>')
    expect(page.locator('#safe')).to have_text('Safe')
    expect(page.evaluate('() => window.__injected')).to be_nil

    context.close
  end

  it 'should strip event handlers from overlay html' do
    context = browser.new_context
    page = context.new_page
    page.goto(server_empty_page)

    page.screencast.show_overlay('<div id="clean" onclick="window.__clicked=true">Click me</div>')
    expect(page.locator('#clean')).to have_text('Click me')
    has_onclick = page.locator('#clean').evaluate('el => el.hasAttribute("onclick")')
    expect(has_onclick).to eq(false)

    context.close
  end

  it 'should auto-remove overlay after timeout' do
    context = browser.new_context
    page = context.new_page
    page.goto(server_empty_page)

    page.screencast.show_overlay('<div id="timed">Temporary</div>', duration: 1)
    expect(page.locator('.x-pw-user-overlay')).to have_count(0)

    context.close
  end

  it 'should allow styles in overlay html' do
    context = browser.new_context
    page = context.new_page
    page.goto(server_empty_page)

    page.screencast.show_overlay('<div id="styled" style="color: red; font-size: 20px;">Styled</div>')
    expect(page.locator('#styled')).to have_text('Styled')
    color = page.locator('#styled').evaluate('el => getComputedStyle(el).color')
    expect(color).to eq('rgb(255, 0, 0)')

    context.close
  end
end
