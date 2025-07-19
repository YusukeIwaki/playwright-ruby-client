require 'spec_helper'
require "playwright/test"
require 'yaml'

RSpec.describe 'ariaSnapshot AI' do
  include Playwright::Test::Matchers

  it 'should generate refs' do
    with_page do |page|
      page.content = '<button>One</button><button>Two</button><button>Three</button>'
      snapshot1 = YAML.load(page.snapshot_for_ai)
      expect(snapshot1).to eq([
        'generic [active] [ref=e1]' => [
          'button "One" [ref=e2]',
          'button "Two" [ref=e3]',
          'button "Three" [ref=e4]',
        ]
      ])
      expect(page.locator('aria-ref=e2')).to have_text('One')
      expect(page.locator('aria-ref=e3')).to have_text('Two')
      expect(page.locator('aria-ref=e4')).to have_text('Three')

      page.locator('aria-ref=e3').evaluate("e => e.textContent = 'Not Two'")

      snapshot2 = YAML.load(page.snapshot_for_ai)
      expect(snapshot2).to eq([
        'generic [active] [ref=e1]' => [
          'button "One" [ref=e2]',
          'button "Not Two" [ref=e5]',
          'button "Three" [ref=e4]',
        ]
      ])
    end
  end

  it 'should list iframes' do
    with_page do |page|
      page.content = '<h1>Hello</h1><iframe name="foo" src="data:text/html,<h1>World</h1>">'
      snapshot1 = page.snapshot_for_ai
      expect(snapshot1).to include('- iframe')
      frame_snapshot = page.frame_locator('iframe').locator('body').aria_snapshot
      expect(frame_snapshot).to eq('- heading "World" [level=1]')
    end
  end

  it 'should stitch all frame snapshots', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/frames/nested-frames.html")
      snapshot = YAML.load(page.snapshot_for_ai)
      expect(snapshot).to eq(YAML.load(<<~YAML))
      - generic [active] [ref=e1]:
        - iframe [ref=e2]:
          - generic [active] [ref=f1e1]:
            - iframe [ref=f1e2]:
              - generic [ref=f2e2]: Hi, I'm frame
            - iframe [ref=f1e3]:
              - generic [ref=f3e2]: Hi, I'm frame
        - iframe [ref=e3]:
          - generic [ref=f4e2]: Hi, I'm frame
      YAML

      href = page.locator('aria-ref=e1').evaluate('e => e.ownerDocument.defaultView.location.href')
      expect(href).to eq("#{server_prefix}/frames/nested-frames.html")

      href2 = page.locator('aria-ref=f1e2').evaluate('e => e.ownerDocument.defaultView.location.href')
      expect(href2).to eq("#{server_prefix}/frames/two-frames.html")

      href3 = page.locator('aria-ref=f3e2').evaluate('e => e.ownerDocument.defaultView.location.href')
      expect(href3).to eq("#{server_prefix}/frames/frame.html")

      locator_string = page.locator('aria-ref=e1').generate_locator_string
      expect(locator_string).to eq("locator(\"body\")")

      locator_string2 = page.locator('aria-ref=f3e2').generate_locator_string
      expect(locator_string2).to eq("locator(\"iframe[name=\\\"2frames\\\"]\").content_frame.locator(\"iframe[name=\\\"dos\\\"]\").content_frame.get_by_text(\"Hi, I'm frame\")")

      # Should tolerate .describe().
      locator_string3 = page.locator('aria-ref=f2e2').describe('foo bar').generate_locator_string
      expect(locator_string3).to eq("locator(\"iframe[name=\\\"2frames\\\"]\").content_frame.locator(\"iframe[name=\\\"uno\\\"]\").content_frame.get_by_text(\"Hi, I'm frame\")")

      expect {
        page.locator('aria-ref=e1000').generate_locator_string
      }.to raise_error(/No element matching locator\("aria-ref=e1000"\)/)
    end
  end

  it 'should include active element information' do
    with_page do |page|
      page.content = <<~HTML
        <button id="btn1">Button 1</button>
        <button id="btn2" autofocus>Button 2</button>
        <div>Not focusable</div>
      HTML

      # Wait for autofocus to take effect
      page.wait_for_function("document.activeElement && document.activeElement.id == 'btn2'")

      snapshot = YAML.load(page.snapshot_for_ai)
      expect(snapshot).to eq(YAML.load(<<~YAML))
      - generic [ref=e1]:
        - button "Button 1" [ref=e2]
        - button "Button 2" [active] [ref=e3]
        - generic [ref=e4]: Not focusable
      YAML
    end
  end

  it 'should update active element on focus' do
    with_page do |page|
      page.content = <<~HTML
        <input id="input1" placeholder="First input">
        <input id="input2" placeholder="Second input">
      HTML

      initial_snapshot = YAML.load(page.snapshot_for_ai)
      expect(initial_snapshot).to eq(YAML.load(<<~YAML))
      - generic [active] [ref=e1]:
        - textbox "First input" [ref=e2]
        - textbox "Second input" [ref=e3]
      YAML

      page.locator('#input2').focus

      after_focus_snapshot = YAML.load(page.snapshot_for_ai)
      expect(after_focus_snapshot).to eq(YAML.load(<<~YAML))
      - generic [ref=e1]:
        - textbox "First input" [ref=e2]
        - textbox "Second input" [active] [ref=e3]
      YAML
    end
  end
end
