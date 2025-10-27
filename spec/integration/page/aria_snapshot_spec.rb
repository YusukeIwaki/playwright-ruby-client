require 'spec_helper'
require "playwright/test"

RSpec.describe 'ariaSnapshot' do
  include Playwright::Test::Matchers

  def unshift(snapshot)
    lines = snapshot.split("\n")
    whitespace_prefix_length = 100
    lines.each do |line|
      next if line.strip.length.zero?

      match = line.match(/^(\s*)/)
      if match && match[1].length < whitespace_prefix_length
        whitespace_prefix_length = match[1].length
      end
    end
    lines.select { |t| t.strip.length.positive? }.map { |line| line[whitespace_prefix_length..] }.join("\n")
  end

  def check_and_match_snapshot(locator, snapshot)
    expect(locator.aria_snapshot).to eq(unshift(snapshot))
    expect(locator).to match_aria_snapshot(snapshot)
  end

  it 'should snapshot' do
    with_page do |page|
      page.content = '<h1>title</h1>'
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - heading "title" [level=1]
      SNAPSHOT
    end
  end

  it 'should snapshot list' do
    with_page do |page|
      page.content = <<~HTML
      <h1>title</h1>
      <h1>title 2</h1>
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - heading "title" [level=1]
        - heading "title 2" [level=1]
      SNAPSHOT
    end
  end

  it 'should snapshot list with accessible name' do
    with_page do |page|
      page.content = <<~HTML
      <ul aria-label="my list">
        <li>one</li>
        <li>two</li>
      </ul>
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - list "my list":
          - listitem: one
          - listitem: two
      SNAPSHOT
    end
  end

  it 'should snapshot complex' do
    with_page do |page|
      page.content = <<~HTML
      <ul>
        <li>
          <a href='about:blank'>link</a>
        </li>
      </ul>
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - list:
          - listitem:
            - link "link":
              - /url: about:blank
      SNAPSHOT
    end
  end

  it 'should allow text nodes' do
    with_page do |page|
      page.content = <<~HTML
      <h1>Microsoft</h1>
      <div>Open source projects and samples from Microsoft</div>
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - heading "Microsoft" [level=1]
        - text: Open source projects and samples from Microsoft
      SNAPSHOT
    end
  end

  it 'should snapshot details visibility' do
    with_page do |page|
      page.content = <<~HTML
      <details>
        <summary>Summary</summary>
        <div>Details</div>
      </details>
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - group: Summary
      SNAPSHOT
    end
  end

  it 'should snapshot integration' do
    with_page do |page|
      page.content = <<~HTML
      <h1>Microsoft</h1>
      <div>Open source projects and samples from Microsoft</div>
      <ul>
        <li>
          <details>
            <summary>
              Verified
            </summary>
            <div>
              <div>
                <p>
                  We've verified that the organization <strong>microsoft</strong> controls the domain:
                </p>
                <ul>
                  <li class="mb-1">
                    <strong>opensource.microsoft.com</strong>
                  </li>
                </ul>
                <div>
                  <a href="about: blank">Learn more about verified organizations</a>
                </div>
              </div>
            </div>
          </details>
        </li>
        <li>
          <a href="about:blank">
            <summary title="Label: GitHub Sponsor">Sponsor</summary>
          </a>
        </li>
      </ul>
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - heading "Microsoft" [level=1]
        - text: Open source projects and samples from Microsoft
        - list:
          - listitem:
            - group: Verified
          - listitem:
            - link "Sponsor":
              - /url: about:blank
      SNAPSHOT
    end
  end

  it 'should support multiline text' do
    with_page do |page|
      page.content = <<~HTML
      <p>
        Line 1
        Line 2
        Line 3
      </p>
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - paragraph: Line 1 Line 2 Line 3
      SNAPSHOT
      expect(page.locator('body')).to match_aria_snapshot(<<~SNAPSHOT)
        - paragraph: |
              Line 1
              Line 2
              Line 3
      SNAPSHOT
    end
  end

  it 'should concatenate span text' do
    with_page do |page|
      page.content = <<~HTML
      <span>One</span> <span>Two</span> <span>Three</span>
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - text: One Two Three
      SNAPSHOT
    end
  end

  it 'should concatenate span text 2' do
    with_page do |page|
      page.content = <<~HTML
      <span>One </span><span>Two </span><span>Three</span>
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - text: One Two Three
      SNAPSHOT
    end
  end

  it 'should concatenate div text with spaces' do
    with_page do |page|
      page.content = <<~HTML
      <div>One</div><div>Two</div><div>Three</div>
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - text: One Two Three
      SNAPSHOT
    end
  end

  it 'should include pseudo in text' do
    with_page do |page|
      page.content = <<~HTML
        <style>
          span:before {
            content: 'world';
          }
          div:after {
            content: 'bye';
          }
        </style>
        <a href="about:blank">
          <span>hello</span>
          <div>hello</div>
        </a>
      HTML

      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - link "worldhello hellobye":
          - /url: about:blank
      SNAPSHOT
    end
  end

  it 'should not include hidden pseudo in text' do
    with_page do |page|
      page.content = <<~HTML
        <style>
          span:before {
            content: 'world';
            display: none;
          }
          div:after {
            content: 'bye';
            visibility: hidden;
          }
        </style>
        <a href="about:blank">
          <span>hello</span>
          <div>hello</div>
        </a>
      HTML

      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - link "hello hello":
          - /url: about:blank
      SNAPSHOT
    end
  end

  it 'should include new line for block pseudo' do
    with_page do |page|
      page.content = <<~HTML
        <style>
          span:before {
            content: 'world';
            display: block;
          }
          div:after {
            content: 'bye';
            display: block;
          }
        </style>
        <a href="about:blank">
          <span>hello</span>
          <div>hello</div>
        </a>
      HTML

      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - link "world hello hello bye":
          - /url: about:blank
      SNAPSHOT
    end
  end

  it 'should work with slots' do
    with_page do |page|
      # Text "foo" is assigned to the slot, should not be used twice.
      page.content = <<~HTML
        <button><div>foo</div></button>
        <script>
          (() => {
            const container = document.querySelector('div');
            const shadow = container.attachShadow({ mode: 'open' });
            const slot = document.createElement('slot');
            shadow.appendChild(slot);
          })();
        </script>
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - button "foo"
      SNAPSHOT

      # Text "foo" is assigned to the slot, should be used instead of slot content.
      page.content = <<~HTML
        <div>foo</div>
        <script>
          (() => {
            const container = document.querySelector('div');
            const shadow = container.attachShadow({ mode: 'open' });
            const button = document.createElement('button');
            shadow.appendChild(button);
            const slot = document.createElement('slot');
            button.appendChild(slot);
            const span = document.createElement('span');
            span.textContent = 'pre';
            slot.appendChild(span);
          })();
        </script>
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - button "foo"
      SNAPSHOT

      # Nothing is assigned to the slot, should use slot content.
      page.content = <<~HTML
        <div></div>
        <script>
          (() => {
            const container = document.querySelector('div');
            const shadow = container.attachShadow({ mode: 'open' });
            const button = document.createElement('button');
            shadow.appendChild(button);
            const slot = document.createElement('slot');
            button.appendChild(slot);
            const span = document.createElement('span');
            span.textContent = 'pre';
            slot.appendChild(span);
          })();
        </script>
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - button "pre"
      SNAPSHOT
    end
  end


  it 'should snapshot inner text' do
    with_page do |page|
      page.content = <<~HTML
        <div role="listitem">
          <div>
            <div>
              <span title="a.test.ts">a.test.ts</span>
            </div>
            <div>
              <button title="Run"></button>
              <button title="Show source"></button>
              <button title="Watch"></button>
            </div>
          </div>
        </div>
        <div role="listitem">
          <div>
            <div>
              <span title="snapshot">snapshot</span>
            </div>
            <div class="ui-mode-list-item-time">30ms</div>
            <div>
              <button title="Run"></button>
              <button title="Show source"></button>
              <button title="Watch"></button>
            </div>
          </div>
        </div>
      HTML

      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - listitem:
          - text: a.test.ts
          - button "Run"
          - button "Show source"
          - button "Watch"
        - listitem:
          - text: snapshot 30ms
          - button "Run"
          - button "Show source"
          - button "Watch"
      SNAPSHOT
    end
  end

  it 'should include pseudo codepoints', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      page.content = <<~HTML
        <link href="codicon.css" rel="stylesheet" />
        <p class='codicon codicon-check'>hello</p>
      HTML

      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - paragraph: \ueab2hello
      SNAPSHOT
    end
  end

  it 'check aria-hidden text' do
    with_page do |page|
      page.content = <<~HTML
      <p>
        <span>hello</span>
        <span aria-hidden="true">world</span>
      </p>
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - paragraph: hello
      SNAPSHOT
    end
  end

  it 'should ignore presentation and none roles' do
    with_page do |page|
      page.content = <<~HTML
      <ul>
        <li role='presentation'>hello</li>
        <li role='none'>world</li>
      </ul>
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - list: hello world
      SNAPSHOT
    end
  end

  it 'should treat input value as text in templates, but not for checkbox/radio/file' do
    with_page do |page|
      page.content = <<~HTML
        <input value='hello world'>
        <input type=file>
        <input type=checkbox checked>
        <input type=radio checked>
      HTML

      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - textbox: hello world
        - button "Choose File"
        - checkbox [checked]
        - radio [checked]
      SNAPSHOT
    end
  end

  it 'should not use on as checkbox value' do
    with_page do |page|
      page.content = <<~HTML
        <input type='checkbox'>
        <input type='radio'>
      HTML

      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - checkbox
        - radio
      SNAPSHOT
    end
  end

  it 'should respect aria-owns' do
    with_page do |page|
      page.content = <<~HTML
        <a href='about:blank' aria-owns='input p'>
          <div role='region'>Link 1</div>
        </a>
        <a href='about:blank' aria-owns='input p'>
          <div role='region'>Link 2</div>
        </a>
        <input id='input' value='Value'>
        <p id='p'>Paragraph</p>
      HTML

      # - Different from Chrome DevTools which attributes ownership to the last element.
      # - CDT also does not include non-owned children in accessible name.
      # - Disregarding these as aria-owns can't suggest multiple parts by spec.
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - link "Link 1 Value Paragraph":
          - /url: about:blank
          - region: Link 1
          - textbox: Value
          - paragraph: Paragraph
        - link "Link 2 Value Paragraph":
          - /url: about:blank
          - region: Link 2
      SNAPSHOT
    end
  end

  it 'should be ok with circular ownership' do
    with_page do |page|
      page.content = <<~HTML
      <a href='about:blank' id='parent'>
        <div role='region' aria-owns='parent'>Hello</div>
      </a>
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - link "Hello":
          - /url: about:blank
          - region: Hello
      SNAPSHOT
    end
  end

  it 'should escape yaml text in text nodes' do
    with_page do |page|
      page.content = <<~HTML
      <details>
        <summary>one: <a href="#">link1</a> "two <a href="#">link2</a> 'three <a href="#">link3</a> \`four</summary>
      </details>
      <ul>
        <a href="#">one</a>,<a href="#">two</a>
        (<a href="#">three</a>)
        {<a href="#">four</a>}
        [<a href="#">five</a>]
      </ul>
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
      - group:
        - text: "one:"
        - link "link1":
          - /url: "#"
        - text: "\\\"two"
        - link "link2":
          - /url: "#"
        - text: "'three"
        - link "link3":
          - /url: "#"
        - text: "\`four"
      - list:
        - link "one":
          - /url: "#"
        - text: ","
        - link "two":
          - /url: "#"
        - text: (
        - link "three":
          - /url: "#"
        - text: ") {"
        - link "four":
          - /url: "#"
        - text: "} ["
        - link "five":
          - /url: "#"
        - text: "]"
      SNAPSHOT
    end
  end

  it 'should normalize whitespace' do
    with_page do |page|
      page.content = <<~HTML
        <details>
          <summary> one  \n two <a href="#"> link &nbsp;\n  1 </a> </summary>
        </details>
        <input value='  hello   &nbsp; world '>
        <button>hello\u00ad\u200bworld</button>
      HTML

      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - group:
          - text: one two
          - link "link 1":
            - /url: "#"
        - textbox: hello world
        - button "helloworld"
      SNAPSHOT

      # Weird whitespace in the template should be normalized.
      expect(page.locator('body')).to match_aria_snapshot(<<~SNAPSHOT)
        - group:
          - text: |
              one
              two
          - link "  link     1 ":
            - /url: "#"
        - textbox:        hello  world
        - button "he\u00adlloworld\u200b"
      SNAPSHOT
    end
  end

  it 'should handle long strings' do
    with_page do |page|
      s = 'a' * 10000
      page.content = <<~HTML
      <a href='about:blank'>
        <div role='region'>#{s}</div>
      </a>
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - link:
          - /url: about:blank
          - region: #{s}
      SNAPSHOT
    end
  end

  it 'should escape special yaml characters' do
    with_page do |page|
      page.content = <<~HTML
      <a href="#">@hello</a>@hello
      <a href="#">]hello</a>]hello
      <a href="#">hello\n</a>
      hello\n<a href="#">\n hello</a>\n hello
      <a href="#">#hello</a>#hello
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - link "@hello":
          - /url: "#"
        - text: "@hello"
        - link "]hello":
          - /url: "#"
        - text: "]hello"
        - link "hello":
          - /url: "#"
        - text: hello
        - link "hello":
          - /url: "#"
        - text: hello
        - link "#hello":
          - /url: "#"
        - text: "#hello"
      SNAPSHOT
    end
  end

  it 'should escape special yaml values' do
    with_page do |page|
      page.content = <<~HTML
      <a href="#">true</a>False
      <a href="#">NO</a>yes
      <a href="#">y</a>N
      <a href="#">on</a>Off
      <a href="#">null</a>NULL
      <a href="#">123</a>123
      <a href="#">-1.2</a>-1.2
      <input type=text value="555">
      HTML

      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - link "true":
          - /url: "#"
        - text: "False"
        - link "NO":
          - /url: "#"
        - text: "yes"
        - link "y":
          - /url: "#"
        - text: "N"
        - link "on":
          - /url: "#"
        - text: "Off"
        - link "null":
          - /url: "#"
        - text: "NULL"
        - link "123":
          - /url: "#"
        - text: "123"
        - link "-1.2":
          - /url: "#"
        - text: "-1.2"
        - textbox: "555"
      SNAPSHOT
    end
  end

  it 'should not report textarea textContent' do
    with_page do |page|
      page.content = '<textarea>Before</textarea>'
      check_and_match_snapshot(page.locator('body'), <<~SNAPSHOT)
        - textbox: Before
      SNAPSHOT

      page.evaluate("() => { document.querySelector('textarea').value = 'After'; }")
      check_and_match_snapshot(page.locator('body'), <<~SNAPSHOT)
        - textbox: After
      SNAPSHOT
    end
  end

  it 'should not show visible children of hidden elements', annotation: { type: 'issue', description: 'https://github.com/microsoft/playwright/issues/36296' } do
    with_page do |page|
      page.content = <<~HTML
        <div style="visibility: hidden;">
          <div style="visibility: visible;">
            <button>Button</button>
          </div>
        </div>
      HTML
      expect(page.locator('body').aria_snapshot).to eq('')
    end
  end

  it 'should not show unhidden children of aria-hidden elements', annotation: { type: 'issue', description: 'https://github.com/microsoft/playwright/issues/36296' } do
    with_page do |page|
      page.content = <<~HTML
        <div aria-hidden="true">
          <div aria-hidden="false">
            <button>Button</button>
          </div>
        </div>
      HTML
      expect(page.locator('body').aria_snapshot).to eq('')
    end
  end

  it 'should snapshot placeholder when different from the name' do
    with_page do |page|
      page.content = '<input placeholder="Placeholder">'
      check_and_match_snapshot(page.locator('body'), <<~SNAPSHOT)
        - textbox "Placeholder"
      SNAPSHOT

      page.content = '<input placeholder="Placeholder" aria-label="Label">'
      check_and_match_snapshot(page.locator('body'), <<~SNAPSHOT)
        - textbox "Label":
          - /placeholder: Placeholder
      SNAPSHOT
    end
  end

  it 'match values both against regex and string' do
    with_page do |page|
      page.content = '<a href="/auth?r=/">Log in</a>'
      check_and_match_snapshot(page.locator('body'), <<~SNAPSHOT)
        - link "Log in":
          - /url: /auth?r=/
      SNAPSHOT
    end
  end
end
