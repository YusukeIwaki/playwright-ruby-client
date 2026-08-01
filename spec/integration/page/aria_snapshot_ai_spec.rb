require 'spec_helper'
require "playwright/test"

# Port of tests/page/page-aria-snapshot-ai.spec.ts
# Helper matching upstream's toContainYaml: strip common indent, then check string inclusion.
def unshift(text)
  lines = text.split("\n").reject { |l| l.strip.empty? }
  min_indent = lines.map { |l| l.match(/^(\s*)/)[1].length }.min || 0
  lines.map { |l| l[min_indent..] }.join("\n")
end

# Upstream helper: page.ariaSnapshot({ ...options, mode: 'ai' })
def snapshot_for_ai(page, timeout: nil, depth: nil)
  page.snapshot_for_ai(timeout: timeout, depth: depth)
end

RSpec.describe 'ariaSnapshot AI' do
  include Playwright::Test::Matchers

  it 'should generate refs' do
    with_page do |page|
      page.content = '<button>One</button><button>Two</button><button>Three</button>'

      snapshot1 = snapshot_for_ai(page)
      expect(snapshot1).to include(unshift(<<~YAML))
        - generic [active] [ref=e1]:
          - button "One" [ref=e2]
          - button "Two" [ref=e3]
          - button "Three" [ref=e4]
      YAML
      expect(page.locator('aria-ref=e2')).to have_text('One')
      expect(page.locator('aria-ref=e3')).to have_text('Two')
      expect(page.locator('aria-ref=e4')).to have_text('Three')

      page.locator('aria-ref=e3').evaluate("e => e.textContent = 'Not Two'")

      snapshot2 = snapshot_for_ai(page)
      expect(snapshot2).to include(unshift(<<~YAML))
        - generic [active] [ref=e1]:
          - button "One" [ref=e2]
          - button "Not Two" [ref=e5]
          - button "Three" [ref=e4]
      YAML
    end
  end

  it 'should list iframes' do
    with_page do |page|
      page.content = '<h1>Hello</h1><iframe name="foo" src="data:text/html,<h1>World</h1>">'

      snapshot1 = snapshot_for_ai(page)
      expect(snapshot1).to include('- iframe')

      frame_snapshot = page.frame_locator('iframe').locator('body').aria_snapshot
      expect(frame_snapshot).to eq('- heading "World" [level=1]')
    end
  end

  it 'should snapshot a locator inside an iframe' do
    with_page do |page|
      page.content = '<h1>Main Page</h1><iframe srcdoc="<ul><li>Item 1</li><li>Item 2</li></ul>"></iframe>'

      list = page.frames[1].locator('ul')
      snapshot = list.aria_snapshot(mode: 'ai')
      expect(snapshot).to include(unshift(<<~YAML))
        - list [ref=f1e1]:
          - listitem [ref=f1e2]: Item 1
          - listitem [ref=f1e3]: Item 2
      YAML
    end
  end

  it 'should limit depth across iframe boundary' do
    with_page do |page|
      page.content = <<~HTML
        <nav>
          <iframe srcdoc="<ul><li><button>Deep</button></li></ul>"></iframe>
        </nav>
      HTML

      snapshot = snapshot_for_ai(page, depth: 3)
      expect(snapshot).to include(unshift(<<~YAML))
        - navigation [ref=e2]:
          - iframe [ref=e3]:
            - list [ref=f1e2]:
              - listitem [ref=f1e3]
      YAML
      expect(snapshot).not_to include('button')
    end
  end

  it 'should stitch all frame snapshots', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/frames/nested-frames.html")
      snapshot = snapshot_for_ai(page)
      expect(snapshot).to include(unshift(<<~YAML))
        - generic [active] [ref=e1]:
          - iframe [ref=e2]:
            - generic [ref=f1e1]:
              - iframe [ref=f1e2]:
                - generic [ref=f3e1]: Hi, I'm frame
              - iframe [ref=f1e3]:
                - generic [ref=f4e1]: Hi, I'm frame
          - iframe [ref=e3]:
            - generic [ref=f2e1]: Hi, I'm frame
      YAML

      href = page.locator('aria-ref=e1').evaluate('e => e.ownerDocument.defaultView.location.href')
      expect(href).to eq("#{server_prefix}/frames/nested-frames.html")

      href2 = page.locator('aria-ref=f1e2').evaluate('e => e.ownerDocument.defaultView.location.href')
      expect(href2).to eq("#{server_prefix}/frames/two-frames.html")

      href3 = page.locator('aria-ref=f4e2').evaluate('e => e.ownerDocument.defaultView.location.href')
      expect(href3).to eq("#{server_prefix}/frames/frame.html")

      resolved = page.locator('aria-ref=e1').normalize
      expect(resolved.to_s).to eq('Locator@body')

      resolved2 = page.locator('aria-ref=f4e2').normalize
      expect(resolved2.to_s).to eq(
        'Locator@iframe[name="2frames"] >> internal:control=enter-frame >> iframe[name="dos"] >> internal:control=enter-frame >> internal:text="Hi, I\'m frame"i'
      )

      # Should tolerate .describe().
      resolved3 = page.locator('aria-ref=f3e2').describe('foo bar').normalize
      expect(resolved3.to_s).to eq(
        'Locator@iframe[name="2frames"] >> internal:control=enter-frame >> iframe[name="uno"] >> internal:control=enter-frame >> internal:text="Hi, I\'m frame"i'
      )

      expect {
        page.locator('aria-ref=e1000').normalize
      }.to raise_error(/No element matching aria-ref=e1000/)
    end
  end

  it 'should persist iframe references' do
    with_page do |page|
      page.content = <<~HTML
        <ul>
          <li><iframe srcdoc="<button>button1</button>"></iframe></li>
          <li><iframe srcdoc="<button>button2</button>"></iframe></li>
        </ul>
      HTML

      expect(snapshot_for_ai(page)).to include(unshift(<<~YAML))
        - list [ref=e2]:
          - listitem [ref=e3]:
            - iframe [ref=e4]:
              - button "button1" [ref=f1e2]
          - listitem [ref=e5]:
            - iframe [ref=e6]:
              - button "button2" [ref=f2e2]
      YAML

      page.evaluate("() => document.querySelector('iframe').remove()")
      expect(snapshot_for_ai(page)).to include(unshift(<<~YAML))
        - list [ref=e2]:
          - listitem [ref=e3]
          - listitem [ref=e5]:
            - iframe [ref=e6]:
              - button "button2" [ref=f2e2]
      YAML
      expect(page.locator('aria-ref=f2e2')).to have_text('button2')

      page.evaluate(<<~JS)
        () => {
          const frame = document.createElement('iframe');
          frame.setAttribute('srcdoc', '<button>button1</button>');
          document.querySelector('li').appendChild(frame);
        }
      JS
      expect(snapshot_for_ai(page)).to include(unshift(<<~YAML))
        - list [ref=e2]:
          - listitem [ref=e3]:
            - iframe [ref=e7]:
              - button "button1" [ref=f3e2]
          - listitem [ref=e5]:
            - iframe [ref=e6]:
              - button "button2" [ref=f2e2]
      YAML
      expect(page.locator('aria-ref=f3e2')).to have_text('button1')
      expect(page.locator('aria-ref=f2e2')).to have_text('button2')
    end
  end

  it 'should not generate refs for elements with pointer-events:none' do
    with_page do |page|
      page.content = <<~HTML
        <button style="pointer-events: none">no-ref</button>
        <div style="pointer-events: none">
          <button style="pointer-events: auto">with-ref</button>
        </div>
        <div style="pointer-events: none">
          <div style="pointer-events: initial">
            <button>with-ref</button>
          </div>
        </div>
        <div style="pointer-events: none">
          <div style="pointer-events: auto">
            <button>with-ref</button>
          </div>
        </div>
        <div style="pointer-events: auto">
          <div style="pointer-events: none">
            <button>no-ref</button>
          </div>
        </div>
      HTML

      snapshot = snapshot_for_ai(page)
      expect(snapshot).to include(unshift(<<~YAML))
        - generic [active] [ref=e1]:
          - button "no-ref"
          - button "with-ref" [ref=e2]
          - button "with-ref" [ref=e4]
          - button "with-ref" [ref=e6]
          - generic [ref=e7]:
            - generic:
              - button "no-ref"
      YAML
    end
  end

  it 'emit generic roles for nodes w/o roles' do
    with_page do |page|
      page.content = <<~HTML
        <style>
        input {
          width: 0;
          height: 0;
          opacity: 0;
        }
        </style>
        <div>
          <label>
            <span>
              <input type="radio" value="Apple" checked="">
            </span>
            <span>Apple</span>
          </label>
          <label>
            <span>
              <input type="radio" value="Pear">
            </span>
            <span>Pear</span>
          </label>
          <label>
            <span>
              <input type="radio" value="Orange">
            </span>
            <span>Orange</span>
          </label>
        </div>
      HTML

      snapshot = snapshot_for_ai(page)
      expect(snapshot).to include(unshift(<<~YAML))
        - generic [ref=e2]:
          - generic [ref=e3]:
            - generic [ref=e4]:
              - radio "Apple" [checked]
            - text: Apple
          - generic [ref=e5]:
            - generic [ref=e6]:
              - radio "Pear"
            - text: Pear
          - generic [ref=e7]:
            - generic [ref=e8]:
              - radio "Orange"
            - text: Orange
      YAML
    end
  end

  it 'should collapse generic nodes' do
    with_page do |page|
      page.content = '<div><div><div><button>Button</button></div></div></div>'

      snapshot = snapshot_for_ai(page)
      expect(snapshot).to include('- button "Button" [ref=e5]')
    end
  end

  it 'should include cursor pointer hint' do
    with_page do |page|
      page.content = '<button style="cursor: pointer">Button</button>'

      snapshot = snapshot_for_ai(page)
      expect(snapshot).to include('- button "Button" [ref=e2] [cursor=pointer]')
    end
  end

  it 'should not nest cursor pointer hints' do
    with_page do |page|
      page.content = <<~HTML
        <a style="cursor: pointer" href="about:blank">
          Link with a button
          <button style="cursor: pointer">Button</button>
        </a>
      HTML

      snapshot = snapshot_for_ai(page)
      expect(snapshot).to include(unshift(<<~YAML))
        - link [ref=e2] [cursor=pointer]:
          - /url: about:blank
          - text: Link with a button
          - button "Button" [ref=e3]
      YAML
    end
  end

  it 'should gracefully fallback when child frame cant be captured', sinatra: true do
    with_page do |page|
      page.set_content(<<~HTML, waitUntil: 'domcontentloaded')
        <p>Test</p>
        <iframe src="#{server_prefix}/redirectloop1.html#depth=100000"></iframe>
      HTML

      snapshot = snapshot_for_ai(page)
      expect(snapshot).to include(unshift(<<~YAML))
        - generic [active] [ref=e1]:
          - paragraph [ref=e2]: Test
          - iframe [ref=e3]
      YAML
    end
  end

  it 'should auto-wait for navigation', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/frames/frame.html")
      # Upstream uses Promise.all([reload, snapshotForAI]) to test concurrent auto-wait.
      snapshot = nil
      reload_future = Concurrent::Promises.future { page.evaluate('window.location.reload()') }
      snapshot = snapshot_for_ai(page)
      reload_future.value!
      expect(snapshot).to include('Hi, I\'m frame')
    end
  end

  it 'should show visible children of hidden elements' do
    with_page do |page|
      page.content = <<~HTML
        <div style="visibility: hidden">
          <div style="visibility: visible">
            <button>Visible</button>
          </div>
          <div style="visibility: hidden">
            <button style="visibility: visible">Visible</button>
          </div>
          <div>
            <div style="visibility: visible">
              <button style="visibility: hidden">Hidden</button>
            </div>
            <button>Hidden</button>
          </div>
        </div>
      HTML

      snapshot = snapshot_for_ai(page)
      expect(snapshot).to eq(unshift(<<~YAML))
        - generic [active] [ref=e1]:
          - button "Visible" [ref=e3]
          - button "Visible" [ref=e4]
      YAML
    end
  end

  it 'should include active element information' do
    with_page do |page|
      page.content = <<~HTML
        <button id="btn1">Button 1</button>
        <button id="btn2" autofocus>Button 2</button>
        <div>Not focusable</div>
      HTML

      page.wait_for_function("document.activeElement && document.activeElement.id == 'btn2'")

      snapshot = snapshot_for_ai(page)
      expect(snapshot).to include(unshift(<<~YAML))
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

      initial_snapshot = snapshot_for_ai(page)
      expect(initial_snapshot).to include(unshift(<<~YAML))
        - generic [active] [ref=e1]:
          - textbox "First input" [ref=e2]
          - textbox "Second input" [ref=e3]
      YAML

      page.locator('#input2').focus

      after_focus_snapshot = snapshot_for_ai(page)
      expect(after_focus_snapshot).to include(unshift(<<~YAML))
        - generic [ref=e1]:
          - textbox "First input" [ref=e2]
          - textbox "Second input" [active] [ref=e3]
      YAML
    end
  end

  it 'should mark iframe as active when it contains focused element' do
    with_page do |page|
      page.content = <<~HTML
        <input id="regular-input" placeholder="Regular input">
        <iframe src="data:text/html,<input id='iframe-input' placeholder='Input in iframe'>" tabindex="0"></iframe>
      HTML

      page.frame_locator('iframe').locator('#iframe-input').focus
      snapshot = snapshot_for_ai(page)

      expect(snapshot).to include(unshift(<<~YAML))
        - generic [ref=e1]:
          - textbox "Regular input" [ref=e2]
          - iframe [active] [ref=e3]:
            - textbox "Input in iframe" [active] [ref=f1e2]
      YAML
    end
  end

  it 'return empty snapshot when iframe is not loaded', sinatra: true do
    with_page do |page|
      page.content = <<~HTML
        <div style="height: 5000px;">Test</div>
        <iframe loading="lazy" src="#{server_prefix}/frame.html"></iframe>
      HTML

      page.wait_for_selector('iframe')

      snapshot = snapshot_for_ai(page, timeout: 3000)
      expect(snapshot).to include(unshift(<<~YAML))
        - generic [active] [ref=e1]:
          - generic [ref=e2]: Test
          - iframe [ref=e3]
      YAML
    end
  end

  it 'should support many properties on iframes' do
    with_page do |page|
      page.content = <<~HTML
        <input id="regular-input" placeholder="Regular input">
        <iframe style='cursor: pointer' src="data:text/html,<input id='iframe-input' placeholder='Input in iframe'/>" tabindex="0"></iframe>
      HTML

      page.frame_locator('iframe').locator('#iframe-input').focus
      snapshot = snapshot_for_ai(page)

      expect(snapshot).to include(unshift(<<~YAML))
        - generic [ref=e1]:
          - textbox "Regular input" [ref=e2]
          - iframe [active] [ref=e3] [cursor=pointer]:
            - textbox "Input in iframe" [active] [ref=f1e2]
      YAML
    end
  end

  it 'should collapse inline generic nodes' do
    with_page do |page|
      page.content = <<~HTML
        <ul>
          <li><b>3</b> <abbr>bds</abbr></li>
          <li><b>2</b> <abbr>ba</abbr></li>
          <li><b>1,200</b> <abbr>sqft</abbr></li>
        </ul>
        <ul>
          <li><div>3</div></li>
          <li><div>2</div></li>
          <li><div>1,200</div></li>
        </ul>
      HTML

      snapshot = snapshot_for_ai(page)
      expect(snapshot).to include(unshift(<<~YAML))
        - generic [active] [ref=e1]:
          - list [ref=e2]:
            - listitem [ref=e3]: 3 bds
            - listitem [ref=e4]: 2 ba
            - listitem [ref=e5]: 1,200 sqft
          - list [ref=e6]:
            - listitem [ref=e7]:
              - generic [ref=e8]: "3"
            - listitem [ref=e9]:
              - generic [ref=e10]: "2"
            - listitem [ref=e11]:
              - generic [ref=e12]: 1,200
      YAML
    end
  end

  it 'should not remove generic nodes with title' do
    with_page do |page|
      page.content = '<div title="Element title">Element content</div>'

      snapshot = snapshot_for_ai(page)
      expect(snapshot).to include('generic "Element title" [ref=e2]')
    end
  end

  it 'should limit depth' do
    with_page do |page|
      page.content = <<~HTML
        <ul>
          <li>item1</li>
          <a href="about:blank" style="cursor:pointer">link</a>
          <li>
            <ul id=target>
              <li>item2</li>
              <li>
                <ul>
                  <li>item3</li>
                </ul>
              </li>
            </ul>
          </li>
        </ul>
      HTML

      snapshot1 = snapshot_for_ai(page, depth: 1)
      expect(snapshot1).to include(unshift(<<~YAML))
        - list [ref=e2]:
          - listitem [ref=e3]: item1
          - link "link" [ref=e4] [cursor=pointer]:
            - /url: about:blank
          - listitem [ref=e5]
      YAML

      snapshot2 = snapshot_for_ai(page, depth: 3)
      expect(snapshot2).to include(unshift(<<~YAML))
        - list [ref=e2]:
          - listitem [ref=e3]: item1
          - link "link" [ref=e4] [cursor=pointer]:
            - /url: about:blank
          - listitem [ref=e5]:
            - list [ref=e6]:
              - listitem [ref=e7]: item2
              - listitem [ref=e8]
      YAML

      snapshot3 = snapshot_for_ai(page, depth: 100)
      expect(snapshot3).to include(unshift(<<~YAML))
        - list [ref=e2]:
          - listitem [ref=e3]: item1
          - link "link" [ref=e4] [cursor=pointer]:
            - /url: about:blank
          - listitem [ref=e5]:
            - list [ref=e6]:
              - listitem [ref=e7]: item2
              - listitem [ref=e8]:
                - list [ref=e9]:
                  - listitem [ref=e10]: item3
      YAML

      snapshot4 = page.locator('#target').aria_snapshot(mode: 'ai', depth: 1)
      expect(snapshot4).to include(unshift(<<~YAML))
        - list [ref=e6]:
          - listitem [ref=e7]: item2
          - listitem [ref=e8]
      YAML
    end
  end
end
