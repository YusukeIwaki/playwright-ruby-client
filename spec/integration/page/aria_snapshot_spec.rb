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
            - link "link"
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
            - link "Sponsor"
      SNAPSHOT
    end
  end

  it 'should snapshot multiline text' do
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

  # it('should include pseudo in text', async ({ page }) => {
  #   await page.setContent(`
  #     <style>
  #       span:before {
  #         content: 'world';
  #       }
  #       div:after {
  #         content: 'bye';
  #       }
  #     </style>
  #     <a href="about:blank">
  #       <span>hello</span>
  #       <div>hello</div>
  #     </a>
  #   `);

  #   await checkAndMatchSnapshot(page.locator('body'), `
  #     - link "worldhello hellobye"
  #   `);
  # });

  # it('should not include hidden pseudo in text', async ({ page }) => {
  #   await page.setContent(`
  #     <style>
  #       span:before {
  #         content: 'world';
  #         display: none;
  #       }
  #       div:after {
  #         content: 'bye';
  #         visibility: hidden;
  #       }
  #     </style>
  #     <a href="about:blank">
  #       <span>hello</span>
  #       <div>hello</div>
  #     </a>
  #   `);

  #   await checkAndMatchSnapshot(page.locator('body'), `
  #     - link "hello hello"
  #   `);
  # });

  # it('should include new line for block pseudo', async ({ page }) => {
  #   await page.setContent(`
  #     <style>
  #       span:before {
  #         content: 'world';
  #         display: block;
  #       }
  #       div:after {
  #         content: 'bye';
  #         display: block;
  #       }
  #     </style>
  #     <a href="about:blank">
  #       <span>hello</span>
  #       <div>hello</div>
  #     </a>
  #   `);

  #   await checkAndMatchSnapshot(page.locator('body'), `
  #     - link "world hello hello bye"
  #   `);
  # });

  # it('should work with slots', async ({ page }) => {
  #   // Text "foo" is assigned to the slot, should not be used twice.
  #   await page.setContent(`
  #     <button><div>foo</div></button>
  #     <script>
  #       (() => {
  #         const container = document.querySelector('div');
  #         const shadow = container.attachShadow({ mode: 'open' });
  #         const slot = document.createElement('slot');
  #         shadow.appendChild(slot);
  #       })();
  #     </script>
  #   `);
  #   await checkAndMatchSnapshot(page.locator('body'), `
  #     - button "foo"
  #   `);

  #   // Text "foo" is assigned to the slot, should be used instead of slot content.
  #   await page.setContent(`
  #     <div>foo</div>
  #     <script>
  #       (() => {
  #         const container = document.querySelector('div');
  #         const shadow = container.attachShadow({ mode: 'open' });
  #         const button = document.createElement('button');
  #         shadow.appendChild(button);
  #         const slot = document.createElement('slot');
  #         button.appendChild(slot);
  #         const span = document.createElement('span');
  #         span.textContent = 'pre';
  #         slot.appendChild(span);
  #       })();
  #     </script>
  #   `);
  #   await checkAndMatchSnapshot(page.locator('body'), `
  #     - button "foo"
  #   `);

  #   // Nothing is assigned to the slot, should use slot content.
  #   await page.setContent(`
  #     <div></div>
  #     <script>
  #       (() => {
  #         const container = document.querySelector('div');
  #         const shadow = container.attachShadow({ mode: 'open' });
  #         const button = document.createElement('button');
  #         shadow.appendChild(button);
  #         const slot = document.createElement('slot');
  #         button.appendChild(slot);
  #         const span = document.createElement('span');
  #         span.textContent = 'pre';
  #         slot.appendChild(span);
  #       })();
  #     </script>
  #   `);
  #   await checkAndMatchSnapshot(page.locator('body'), `
  #     - button "pre"
  #   `);
  # });

  # it('should snapshot inner text', async ({ page }) => {
  #   await page.setContent(`
  #     <div role="listitem">
  #       <div>
  #         <div>
  #           <span title="a.test.ts">a.test.ts</span>
  #         </div>
  #         <div>
  #           <button title="Run"></button>
  #           <button title="Show source"></button>
  #           <button title="Watch"></button>
  #         </div>
  #       </div>
  #     </div>
  #     <div role="listitem">
  #       <div>
  #         <div>
  #           <span title="snapshot">snapshot</span>
  #         </div>
  #         <div class="ui-mode-list-item-time">30ms</div>
  #         <div>
  #           <button title="Run"></button>
  #           <button title="Show source"></button>
  #           <button title="Watch"></button>
  #         </div>
  #       </div>
  #     </div>
  #   `);

  #   await checkAndMatchSnapshot(page.locator('body'), `
  #     - listitem:
  #       - text: a.test.ts
  #       - button "Run"
  #       - button "Show source"
  #       - button "Watch"
  #     - listitem:
  #       - text: snapshot 30ms
  #       - button "Run"
  #       - button "Show source"
  #       - button "Watch"
  #   `);
  # });

  # it('should include pseudo codepoints', async ({ page, server }) => {
  #   await page.goto(server.EMPTY_PAGE);
  #   await page.setContent(`
  #     <link href="codicon.css" rel="stylesheet" />
  #     <p class='codicon codicon-check'>hello</p>
  #   `);

  #   await checkAndMatchSnapshot(page.locator('body'), `
  #     - paragraph: \ueab2hello
  #   `);
  # });

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

  # it('should treat input value as text in templates', async ({ page }) => {
  #   await page.setContent(`
  #     <input value='hello world'>
  #   `);

  #   await checkAndMatchSnapshot(page.locator('body'), `
  #     - textbox: hello world
  #   `);
  # });

  # it('should respect aria-owns', async ({ page }) => {
  #   await page.setContent(`
  #     <a href='about:blank' aria-owns='input p'>
  #       <div role='region'>Link 1</div>
  #     </a>
  #     <a href='about:blank' aria-owns='input p'>
  #       <div role='region'>Link 2</div>
  #     </a>
  #     <input id='input' value='Value'>
  #     <p id='p'>Paragraph</p>
  #   `);

  #   // - Different from Chrome DevTools which attributes ownership to the last element.
  #   // - CDT also does not include non-owned children in accessible name.
  #   // - Disregarding these as aria-owns can't suggest multiple parts by spec.
  #   await checkAndMatchSnapshot(page.locator('body'), `
  #     - link "Link 1 Value Paragraph":
  #       - region: Link 1
  #       - textbox: Value
  #       - paragraph: Paragraph
  #     - link "Link 2 Value Paragraph":
  #       - region: Link 2
  #   `);
  # });

  it 'should be ok with circular ownership' do
    with_page do |page|
      page.content = <<~HTML
      <a href='about:blank' id='parent'>
        <div role='region' aria-owns='parent'>Hello</div>
      </a>
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - link "Hello":
          - region: Hello
      SNAPSHOT
    end
  end

  it 'should escape yaml text in text nodes' do
    pending 'not escaped by playwright driver...'

    with_page do |page|
      page.content = <<~HTML
      <details>
        <summary>one: <a href="#">link1</a> "two <a href="#">link2</a> 'three <a href="#">link3</a> `four</summary>
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
        - link "link1"
        - text: "\\\"two"
        - link "link2"
        - text: "'three"
        - link "link3"
        - text: "\`four"
      - list:
        - link "one"
        - text: ","
        - link "two"
        - text: (
        - link "three"
        - text: ") {"
        - link "four"
        - text: "} ["
        - link "five"
        - text: "]"
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
          - region: #{s}
      SNAPSHOT
    end
  end

  it 'should escape special yaml characters' do
    pending 'not escaped by playwright driver...'

    with_page do |page|
      page.content = <<~HTML
      <a href="#">@hello</a>@hello
      <a href="#">]hello</a>]hello
      <a href="#">hello\n</a>
      hello\n<a href="#">\n hello</a>\n hello
      <a href="#">#hello</a>#hello
      HTML
      check_and_match_snapshot(page.locator('body'), <<-SNAPSHOT)
        - link "@hello"
        - text: "@hello"
        - link "]hello"
        - text: "]hello"
        - link "hello"
        - text: hello
        - link "hello"
        - text: hello
        - link "#hello"
        - text: "#hello"
      SNAPSHOT
    end
  end

  it 'should escape special yaml values' do
    pending 'not escaped by playwright driver...'

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
        - link "true"
        - text: "False"
        - link "NO"
        - text: "yes"
        - link "y"
        - text: "N"
        - link "on"
        - text: "Off"
        - link "null"
        - text: "NULL"
        - link "123"
        - text: "123"
        - link "-1.2"
        - text: "-1.2"
        - textbox: "555"
      SNAPSHOT
    end
  end
end
