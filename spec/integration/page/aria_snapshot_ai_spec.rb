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
              - generic [ref=f3e2]: Hi, I'm frame
            - iframe [ref=f1e3]:
              - generic [ref=f4e2]: Hi, I'm frame
        - iframe [ref=e3]:
          - generic [ref=f2e2]: Hi, I'm frame
      YAML

      href = page.locator('aria-ref=e1').evaluate('e => e.ownerDocument.defaultView.location.href')
      expect(href).to eq("#{server_prefix}/frames/nested-frames.html")

      href2 = page.locator('aria-ref=f1e2').evaluate('e => e.ownerDocument.defaultView.location.href')
      expect(href2).to eq("#{server_prefix}/frames/two-frames.html")

      href3 = page.locator('aria-ref=f3e2').evaluate('e => e.ownerDocument.defaultView.location.href')
      expect(href3).to eq("#{server_prefix}/frames/frame.html")

      locator_string = page.locator('aria-ref=e1').resolve_selector
      expect(locator_string).to eq("body")

      locator_string2 = page.locator('aria-ref=f4e2').resolve_selector
      expect(locator_string2).to eq("iframe[name=\"2frames\"] >> internal:control=enter-frame >> iframe[name=\"dos\"] >> internal:control=enter-frame >> internal:text=\"Hi, I'm frame\"i")

      # Should tolerate .describe().
      locator_string3 = page.locator('aria-ref=f3e2').describe('foo bar').resolve_selector
      expect(locator_string3).to eq("iframe[name=\"2frames\"] >> internal:control=enter-frame >> iframe[name=\"uno\"] >> internal:control=enter-frame >> internal:text=\"Hi, I'm frame\"i")

      expect {
        page.locator('aria-ref=e1000').resolve_selector
      }.to raise_error(/No element matching aria-ref=e1000/)
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

  it 'return empty snapshot when iframe is not loaded', annotation: { type: 'issue', description: 'https://github.com/microsoft/playwright/pull/36710' }, sinatra: true do
    with_page do |page|
      page.content = <<~HTML
        <div style="height: 5000px;">Test</div>
        <iframe loading="lazy" src="#{server_prefix}/frame.html"></iframe>
      HTML

      # Wait for the iframe element to appear (presence, not load)
      page.wait_for_selector('iframe')

      snapshot = YAML.load(page.snapshot_for_ai(timeout: 100))
      expect(snapshot).to eq(YAML.load(<<~YAML))
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

      # Focus the input inside the iframe
      page.frame_locator('iframe').locator('#iframe-input').focus
      input_in_iframe_focused_snapshot = YAML.load(page.snapshot_for_ai)

      expect(input_in_iframe_focused_snapshot).to eq(YAML.load(<<~YAML))
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

      snapshot = YAML.load(page.snapshot_for_ai)
      expect(snapshot).to eq(YAML.load(<<~YAML))
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

      snapshot = YAML.load(page.snapshot_for_ai)
      expect(snapshot).to eq(YAML.load(<<~YAML))
      - generic "Element title" [ref=e2]: Element content
      YAML
    end
  end

  it 'should create incremental snapshots on multiple tracks' do
    with_page do |page|
      page.content = <<~HTML
        <ul>
          <li><button>a button</button></li>
          <li><span>a span</span></li>
          <li id="hidden-li" style="display:none">some text</li>
        </ul>
      HTML

      first_full = YAML.load(page.snapshot_for_ai(track: 'first', mode: 'full'))
      expect(first_full).to eq(YAML.load(<<~YAML))
      - list [ref=e2]:
        - listitem [ref=e3]:
          - button "a button" [ref=e4]
        - listitem [ref=e5]: a span
      YAML

      second_full = YAML.load(page.snapshot_for_ai(track: 'second', mode: 'full'))
      expect(second_full).to eq(YAML.load(<<~YAML))
      - list [ref=e2]:
        - listitem [ref=e3]:
          - button "a button" [ref=e4]
        - listitem [ref=e5]: a span
      YAML

      expect(page.snapshot_for_ai(track: 'first', mode: 'incremental')).to eq('')

      page.evaluate(<<~JS)
        () => {
          document.querySelector('span').textContent = 'changed span';
          document.getElementById('hidden-li').style.display = 'inline';
        }
      JS
      first_incremental = YAML.load(page.snapshot_for_ai(track: 'first', mode: 'incremental'))
      expect(first_incremental).to eq(YAML.load(<<~YAML))
      - <changed> list [ref=e2]:
        - ref=e3 [unchanged]
        - listitem [ref=e5]: changed span
        - listitem [ref=e6]: some text
      YAML

      page.evaluate(<<~JS)
        () => {
          document.querySelector('span').textContent = 'a span';
          document.getElementById('hidden-li').style.display = 'none';
        }
      JS
      first_incremental = YAML.load(page.snapshot_for_ai(track: 'first', mode: 'incremental'))
      expect(first_incremental).to eq(YAML.load(<<~YAML))
      - <changed> list [ref=e2]:
        - ref=e3 [unchanged]
        - listitem [ref=e5]: a span
      YAML

      expect(page.snapshot_for_ai(track: 'second', mode: 'incremental')).to eq('')

      second_full = YAML.load(page.snapshot_for_ai(track: 'second', mode: 'full'))
      expect(second_full).to eq(YAML.load(<<~YAML))
      - list [ref=e2]:
        - listitem [ref=e3]:
          - button "a button" [ref=e4]
        - listitem [ref=e5]: a span
      YAML
    end
  end

  it 'should create incremental snapshot for attribute change' do
    with_page do |page|
      page.content = '<button>a button</button>'
      page.evaluate("() => document.querySelector('button').focus()")

      full_snapshot = YAML.load(page.snapshot_for_ai(track: 'track', mode: 'full'))
      expect(full_snapshot).to eq(YAML.load(<<~YAML))
      - button "a button" [active] [ref=e2]
      YAML

      page.evaluate("() => document.querySelector('button').blur()")
      incremental_snapshot = YAML.load(page.snapshot_for_ai(track: 'track', mode: 'incremental'))
      expect(incremental_snapshot).to eq(YAML.load(<<~YAML))
      - <changed> button "a button" [ref=e2]
      YAML
    end
  end

  it 'should create incremental snapshot for child removal' do
    with_page do |page|
      page.content = '<li><button>a button</button><span>some text</span></li>'

      full_snapshot = YAML.load(page.snapshot_for_ai(track: 'track', mode: 'full'))
      expect(full_snapshot).to eq(YAML.load(<<~YAML))
      - listitem [ref=e2]:
        - button "a button" [ref=e3]
        - text: some text
      YAML

      page.evaluate("() => document.querySelector('span').remove()")
      incremental_snapshot = YAML.load(page.snapshot_for_ai(track: 'track', mode: 'incremental'))
      expect(incremental_snapshot).to eq(YAML.load(<<~YAML))
      - <changed> listitem [ref=e2]:
        - ref=e3 [unchanged]
      YAML
    end
  end

  it 'should create incremental snapshot for child addition' do
    with_page do |page|
      page.content = '<li><button>a button</button><span style="display:none">some text</span></li>'

      full_snapshot = YAML.load(page.snapshot_for_ai(track: 'track', mode: 'full'))
      expect(full_snapshot).to eq(YAML.load(<<~YAML))
      - listitem [ref=e2]:
        - button "a button" [ref=e3]
      YAML

      page.evaluate("() => document.querySelector('span').style.display = 'inline'")
      incremental_snapshot = YAML.load(page.snapshot_for_ai(track: 'track', mode: 'incremental'))
      expect(incremental_snapshot).to eq(YAML.load(<<~YAML))
      - <changed> listitem [ref=e2]:
        - ref=e3 [unchanged]
        - text: some text
      YAML
    end
  end

  it 'should create incremental snapshot for prop change' do
    with_page do |page|
      page.content = '<a href="about:blank" style="cursor:pointer">a link</a>'

      full_snapshot = YAML.load(page.snapshot_for_ai(track: 'track', mode: 'full'))
      expect(full_snapshot).to eq(YAML.load(<<~YAML))
      - link "a link" [ref=e2] [cursor=pointer]:
        - /url: about:blank
      YAML

      page.evaluate("() => document.querySelector('a').setAttribute('href', 'https://playwright.dev')")
      incremental_snapshot = YAML.load(page.snapshot_for_ai(track: 'track', mode: 'incremental'))
      expect(incremental_snapshot).to eq(YAML.load(<<~YAML))
      - <changed> link "a link" [ref=e2] [cursor=pointer]:
        - /url: https://playwright.dev
      YAML
    end
  end

  it 'should create incremental snapshot for cursor change' do
    with_page do |page|
      page.content = '<a href="about:blank" style="cursor:pointer">a link</a>'

      full_snapshot = YAML.load(page.snapshot_for_ai(track: 'track', mode: 'full'))
      expect(full_snapshot).to eq(YAML.load(<<~YAML))
      - link "a link" [ref=e2] [cursor=pointer]:
        - /url: about:blank
      YAML

      page.evaluate("() => document.querySelector('a').style.cursor = 'default'")
      incremental_snapshot = YAML.load(page.snapshot_for_ai(track: 'track', mode: 'incremental'))
      expect(incremental_snapshot).to eq(YAML.load(<<~YAML))
      - <changed> link "a link" [ref=e2]:
        - /url: about:blank
      YAML
    end
  end

  it 'should create incremental snapshot for name change' do
    with_page do |page|
      page.content = '<button><span>a button</span></button>'

      full_snapshot = YAML.load(page.snapshot_for_ai(track: 'track', mode: 'full'))
      expect(full_snapshot).to eq(YAML.load(<<~YAML))
      - button "a button" [ref=e2]
      YAML

      page.evaluate("() => document.querySelector('span').textContent = 'new button'")
      incremental_snapshot = YAML.load(page.snapshot_for_ai(track: 'track', mode: 'incremental'))
      expect(incremental_snapshot).to eq(YAML.load(<<~YAML))
      - <changed> button "new button" [ref=e3]
      YAML
    end
  end

  it 'should create incremental snapshot for text change' do
    with_page do |page|
      page.content = '<li><span>an item</span></li>'

      full_snapshot = YAML.load(page.snapshot_for_ai(track: 'track', mode: 'full'))
      expect(full_snapshot).to eq(YAML.load(<<~YAML))
      - listitem [ref=e2]: an item
      YAML

      page.evaluate("() => document.querySelector('span').textContent = 'new text'")
      incremental_snapshot = YAML.load(page.snapshot_for_ai(track: 'track', mode: 'incremental'))
      expect(incremental_snapshot).to eq(YAML.load(<<~YAML))
      - <changed> listitem [ref=e2]: new text
      YAML
    end
  end

  it 'should produce incremental snapshot for iframes' do
    with_page do |page|
      page.content = <<~HTML
        <iframe srcdoc="
          <li>
            <span style='display:none'>outer text</span>
            <button>a button</button>
            <iframe src='data:text/html,<li>inner text</li>' style='display:none'></iframe>
          </li>
        "></iframe>
      HTML

      full_snapshot = YAML.load(page.snapshot_for_ai(track: 'track', mode: 'full'))
      expect(full_snapshot).to eq(YAML.load(<<~YAML))
      - iframe [ref=e2]:
        - listitem [ref=f1e2]:
          - button "a button" [ref=f1e3]
      YAML

      page.frames[1].evaluate(<<~JS)
        () => {
          document.querySelector('span').style.display = 'block';
          document.querySelector('iframe').style.display = 'block';
        }
      JS
      incremental_snapshot = YAML.load(page.snapshot_for_ai(track: 'track', mode: 'incremental'))
      expect(incremental_snapshot).to eq(YAML.load(<<~YAML))
      - <changed> listitem [ref=f1e2]:
        - generic [ref=f1e4]: outer text
        - ref=f1e3 [unchanged]
        - iframe [ref=f1e5]
      - <changed> iframe [ref=f1e5]:
        - listitem [ref=f2e2]: inner text
      YAML
    end
  end

  it 'should create multiple chunks in incremental snapshot' do
    with_page do |page|
      page.content = <<~HTML
        <ul>
          <li><span>item1</span></li>
          <li><span>item2</span></li>
          <li><div role="group"><span>item3</span></div></li>
          <ul>
            <li id="to-remove">to be removed</li>
            <li>one more</li>
          </ul>
        </ul>
      HTML

      full_snapshot = YAML.load(page.snapshot_for_ai(track: 'track', mode: 'full'))
      expect(full_snapshot).to eq(YAML.load(<<~YAML))
      - list [ref=e2]:
        - listitem [ref=e3]: item1
        - listitem [ref=e4]: item2
        - listitem [ref=e5]:
          - group [ref=e6]: item3
        - list [ref=e7]:
          - listitem [ref=e8]: to be removed
          - listitem [ref=e9]: one more
      YAML

      page.evaluate(<<~JS)
        () => {
          const spans = document.querySelectorAll('span');
          spans[0].textContent = 'new item1';
          spans[2].textContent = 'new item3';
          const button = document.createElement('button');
          button.textContent = 'button';
          spans[2].parentElement.appendChild(button);
          document.querySelector('#to-remove').remove();
        }
      JS
      incremental_snapshot = YAML.load(page.snapshot_for_ai(track: 'track', mode: 'incremental'))
      expect(incremental_snapshot).to eq(YAML.load(<<~YAML))
      - <changed> listitem [ref=e3]: new item1
      - <changed> group [ref=e6]:
        - text: new item3
        - button "button" [ref=e10]
      - <changed> list [ref=e7]:
        - ref=e9 [unchanged]
      YAML
    end
  end

  it 'should not create incremental snapshots without tracks' do
    with_page do |page|
      page.content = <<~HTML
        <ul>
          <li><button>a button</button></li>
          <li><span>a span</span></li>
          <li id="hidden-li" style="display:none">some text</li>
        </ul>
      HTML

      full_snapshot = YAML.load(page.snapshot_for_ai(mode: 'full'))
      expect(full_snapshot).to eq(YAML.load(<<~YAML))
      - list [ref=e2]:
        - listitem [ref=e3]:
          - button "a button" [ref=e4]
        - listitem [ref=e5]: a span
      YAML
      expect(page.snapshot_for_ai(mode: 'incremental')).to be_nil
    end
  end

  it 'should create incremental snapshot for children swap' do
    with_page do |page|
      page.content = <<~HTML
        <ul>
          <li>item 1</li>
          <li>item 2</li>
        </ul>
      HTML

      full_snapshot = YAML.load(page.snapshot_for_ai(track: 'track', mode: 'full'))
      expect(full_snapshot).to eq(YAML.load(<<~YAML))
      - list [ref=e2]:
        - listitem [ref=e3]: item 1
        - listitem [ref=e4]: item 2
      YAML

      page.evaluate("() => document.querySelector('ul').appendChild(document.querySelector('li'))")
      incremental_snapshot = YAML.load(page.snapshot_for_ai(track: 'track', mode: 'incremental'))
      expect(incremental_snapshot).to eq(YAML.load(<<~YAML))
      - <changed> list [ref=e2]:
        - ref=e4 [unchanged]
        - ref=e3 [unchanged]
      YAML
    end
  end
end
