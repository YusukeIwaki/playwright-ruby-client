require 'spec_helper'
require 'playwright/test'

# https://github.com/microsoft/playwright/blob/v1.63.0/tests/page/locator-any-frame.spec.ts
RSpec.describe 'FrameLocator across frames', sinatra: true do
  include Playwright::Test::Matchers

  def route_page(page, url, body)
    page.route("**/#{url}", ->(route, _) { route.fulfill(body: body, contentType: 'text/html') })
  end

  def wait_for_frames(page, count, selector = nil)
    Timeout.timeout(5) { sleep 0.01 until page.frames.size == count }
    if selector
      page.frames.reject { |frame| frame == page.main_frame }.each do |frame|
        frame.wait_for_selector(selector, state: 'attached')
      end
    end
  end

  it "should click a button inside an iframe" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<button onclick=\"window.__clicked = true\">Click me</button>")
      page.goto(server_empty_page)
      page.frame_locator.get_by_role('button', name: 'Click me').click
      expect(page.frames[1].evaluate('() => window.__clicked')).to eq(true)
    end
  end

  it "should click a button in the main frame" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe><button onclick=\"window.__clicked = true\">Click me</button>")
      route_page(page, "a.html", "<div>No buttons here</div>")
      page.goto(server_empty_page)
      page.frame_locator.locator('button').click
      expect(page.evaluate('() => window.__clicked')).to eq(true)
    end
  end

  it "should fail click when elements match in multiple frames" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe><iframe src=\"b.html\"></iframe>")
      route_page(page, "a.html", "<button>one</button>")
      route_page(page, "b.html", "<button>two</button>")
      page.goto(server_empty_page)
      wait_for_frames(page, 3, "button")
      expect { page.frame_locator.locator('button').click(timeout: 3000) }.to raise_error(/multiple frames/)
    end
  end

  it "should fail click upon strict mode violation inside a single frame" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<button>one</button><button>two</button>")
      page.goto(server_empty_page)
      wait_for_frames(page, 2, "button")
      expect { page.frame_locator.locator('button').click(timeout: 3000) }.to raise_error(/strict mode violation/)
    end
  end

  it "should time out on click when there are no matches" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<div>Nothing here</div>")
      page.goto(server_empty_page)
      expect { page.frame_locator.locator('button').click(timeout: 1000) }.to raise_error(/Timeout 1000ms exceeded/)
    end
  end

  it "should count elements in a single frame" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<div>1</div><div>2</div><div>3</div>")
      page.goto(server_empty_page)
      wait_for_frames(page, 2, "div")
      expect(page.frame_locator.locator('div').count).to eq(3)
      expect(page.frame_locator.locator('button').count).to eq(0)
    end
  end

  it "should fail count when elements match in multiple frames" do
    with_page do |page|
      route_page(page, "empty.html", "<div>main</div><iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<div>child</div>")
      page.goto(server_empty_page)
      wait_for_frames(page, 2, "div")
      expect { page.frame_locator.locator('div').count }.to raise_error(/multiple frames/)
    end
  end

  it "should support toHaveCount" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<span>one</span><span>two</span>")
      page.goto(server_empty_page)
      expect(page.frame_locator.locator('span')).to have_count(2)
      expect(page.frame_locator.locator('button')).to have_count(0)
    end
  end

  it "should wait for a frame to appear with toHaveCount" do
    with_page do |page|
      route_page(page, "empty.html", "<div>No frames yet</div>")
      route_page(page, "a.html", "<span>one</span><span>two</span>")
      page.goto(server_empty_page)
      page.evaluate(<<~JS)
        () => setTimeout(() => {
          const iframe = document.createElement('iframe');
          iframe.src = 'a.html';
          document.body.appendChild(iframe);
        }, 500)
      JS
      expect(page.frame_locator.locator('span')).to have_count(2)
    end
  end

  it "should fail toHaveCount when elements match in multiple frames" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe><iframe src=\"b.html\"></iframe>")
      route_page(page, "a.html", "<span>one</span>")
      route_page(page, "b.html", "<span>two</span>")
      page.goto(server_empty_page)
      wait_for_frames(page, 3, "span")
      expect { expect(page.frame_locator.locator('span')).to have_count(2, timeout: 3000) }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /multiple frames/)
    end
  end

  it "should support toHaveText" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<div>Hello iframe</div>")
      page.goto(server_empty_page)
      expect(page.frame_locator.locator('div')).to have_text('Hello iframe')
    end
  end

  it "should support toHaveText with an array" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<span>one</span><span>two</span>")
      page.goto(server_empty_page)
      expect(page.frame_locator.locator('span')).to have_text(['one', 'two'])
    end
  end

  it "should fail toHaveText when elements match in multiple frames" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe><iframe src=\"b.html\"></iframe>")
      route_page(page, "a.html", "<div>one</div>")
      route_page(page, "b.html", "<div>two</div>")
      page.goto(server_empty_page)
      wait_for_frames(page, 3, "div")
      expect { expect(page.frame_locator.locator('div')).to have_text('one', timeout: 3000) }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /multiple frames/)
    end
  end

  it "should fail toHaveText with an array when elements match in multiple frames" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe><iframe src=\"b.html\"></iframe>")
      route_page(page, "a.html", "<span>one</span>")
      route_page(page, "b.html", "<span>two</span>")
      page.goto(server_empty_page)
      wait_for_frames(page, 3, "span")
      expect { expect(page.frame_locator.locator('span')).to have_text(['one', 'two'], timeout: 3000) }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /multiple frames/)
    end
  end

  it "should fail toHaveText upon strict mode violation inside a single frame" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<div>one</div><div>two</div>")
      page.goto(server_empty_page)
      wait_for_frames(page, 2, "div")
      expect { expect(page.frame_locator.locator('div')).to have_text('one', timeout: 3000) }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /strict mode violation/)
    end
  end

  it "should support evaluate" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<div data-foo=\"bar\">Hello</div>")
      page.goto(server_empty_page)
      expect(page.frame_locator.locator('div').evaluate("e => e.getAttribute('data-foo')")).to eq('bar')
    end
  end

  it "should fail evaluate when elements match in multiple frames" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe><iframe src=\"b.html\"></iframe>")
      route_page(page, "a.html", "<div>one</div>")
      route_page(page, "b.html", "<div>two</div>")
      page.goto(server_empty_page)
      wait_for_frames(page, 3, "div")
      expect { page.frame_locator.locator('div').evaluate('e => e.textContent', timeout: 3000) }.to raise_error(/multiple frames/)
    end
  end

  it "should time out on evaluate when there are no matches" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<div>Nothing here</div>")
      page.goto(server_empty_page)
      expect { page.frame_locator.locator('button').evaluate('e => e.textContent', timeout: 1000) }.to raise_error(/Timeout 1000ms exceeded/)
    end
  end

  it "should support evaluateAll" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<span>one</span><span>two</span>")
      page.goto(server_empty_page)
      wait_for_frames(page, 2, "span")
      expect(page.frame_locator.locator('span').evaluate_all('els => els.map(e => e.textContent)')).to eq(['one', 'two'])
      expect(page.frame_locator.locator('button').evaluate_all('els => els.length')).to eq(0)
    end
  end

  it "should fail evaluateAll when elements match in multiple frames" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe><iframe src=\"b.html\"></iframe>")
      route_page(page, "a.html", "<span>one</span>")
      route_page(page, "b.html", "<span>two</span>")
      page.goto(server_empty_page)
      wait_for_frames(page, 3, "span")
      expect { page.frame_locator.locator('span').evaluate_all('els => els.length') }.to raise_error(/multiple frames/)
    end
  end

  it "should support hasText filter" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<div>foo</div><div>bar</div>")
      page.goto(server_empty_page)
      expect(page.frame_locator.locator('div', hasText: 'bar')).to have_text('bar')
    end
  end

  it "should support first/last/nth" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<span>one</span><span>two</span><span>three</span>")
      page.goto(server_empty_page)
      wait_for_frames(page, 2, "span")
      expect(page.frame_locator.locator('span').first).to have_text('one')
      expect(page.frame_locator.locator('span').last).to have_text('three')
      expect(page.frame_locator.locator('span').nth(1)).to have_text('two')
    end
  end

  it "should support nth in the middle of the chain" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<div><span>one</span></div><div><span>two</span></div>")
      page.goto(server_empty_page)
      expect(page.frame_locator.locator('div').nth(1).locator('span')).to have_text('two')
    end
  end

  it "should support composite locators" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<div><span>foo</span></div><div><i>bar</i></div>")
      page.goto(server_empty_page)
      expect(page.frame_locator.locator('div', has: page.locator('span'))).to have_text('foo')
    end
  end

  it "should support capture" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<div id=\"target\"><span>hello</span></div>")
      page.goto(server_empty_page)
      expect(page.frame_locator.locator('*css=div >> span')).to have_attribute('id', 'target')
    end
  end

  it "should find a frame inside the scope" do
    with_page do |page|
      route_page(page, "empty.html", "<section><iframe src=\"a.html\"></iframe></section><button>outside</button>")
      route_page(page, "a.html", "<button>inside</button>")
      page.goto(server_empty_page)
      wait_for_frames(page, 2, "button")
      buttons = page.query_selector('section').query_selector_all('internal:control=any-frame >> button')
      expect(buttons.size).to eq(1)
      expect(buttons[0].text_content).to eq('inside')
    end
  end

  it "should find a nested frame inside the scope" do
    with_page do |page|
      route_page(page, "empty.html", "<section><iframe src=\"a.html\"></iframe></section><iframe src=\"b.html\"></iframe>")
      route_page(page, "a.html", "<iframe src=\"c.html\"></iframe>")
      route_page(page, "b.html", "<button>outside</button>")
      route_page(page, "c.html", "<button>deep</button>")
      page.goto(server_empty_page)
      wait_for_frames(page, 4)
      page.frames.select { |frame| frame.url.end_with?('b.html', 'c.html') }.each do |frame|
        frame.wait_for_selector('button', state: 'attached')
      end
      buttons = page.query_selector('section').query_selector_all('internal:control=any-frame >> button')
      expect(buttons.size).to eq(1)
      expect(buttons[0].text_content).to eq('deep')
    end
  end

  it "should find a frame inside the scope while another iframe is stalled" do
    with_page do |page|
      route_page(page, "empty.html", "<section><iframe src=\"a.html\"></iframe><iframe src=\"stall.html\"></iframe></section>")
      route_page(page, "a.html", "<button>inside</button>")
      page.route('**/stall.html', ->(_) {})
      page.goto(server_empty_page, waitUntil: 'domcontentloaded')
      wait_for_frames(page, 3)
      buttons = page.query_selector('section').query_selector_all('internal:control=any-frame >> button')
      expect(buttons.size).to eq(1)
      expect(buttons[0].text_content).to eq('inside')
    end
  end

  it "should respect the scope without a frame inside the scope" do
    with_page do |page|
      route_page(page, "empty.html", "<section><button>target</button></section><iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<button>in-frame</button>")
      page.goto(server_empty_page)
      wait_for_frames(page, 2, "button")
      buttons = page.query_selector('section').query_selector_all('internal:control=any-frame >> button')
      expect(buttons.size).to eq(1)
      expect(buttons[0].text_content).to eq('target')
    end
  end

  it "should not match a chain across a frame boundary" do
    with_page do |page|
      route_page(page, "empty.html", "<section><iframe src=\"a.html\"></iframe></section>")
      route_page(page, "a.html", "<iframe src=\"b.html\"></iframe>")
      route_page(page, "b.html", "<button>deep</button>")
      page.goto(server_empty_page)
      wait_for_frames(page, 3)
      page.frames.find { |frame| frame.url.end_with?('b.html') }.wait_for_selector('button', state: 'attached')
      expect(page.frame_locator.locator('section').locator('button')).to have_count(0)
      expect(page.frame_locator.locator('button')).to have_text('deep')
    end
  end

  it "should only search frames inside the starting frame" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe><button>main</button>")
      route_page(page, "a.html", "<iframe src=\"b.html\"></iframe>")
      route_page(page, "b.html", "<button>deep</button>")
      page.goto(server_empty_page)
      wait_for_frames(page, 3)
      page.frames.find { |frame| frame.url.end_with?('b.html') }.wait_for_selector('button', state: 'attached')
      middle_frame = page.frames.find { |frame| frame.url.end_with?('a.html') }
      expect(middle_frame.frame_locator.locator('button')).to have_text('deep')
    end
  end

  it "should enter a frame found in a nested frame" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe><button>main</button>")
      route_page(page, "a.html", "<iframe id=\"target\" src=\"b.html\"></iframe><button>decoy</button>")
      route_page(page, "b.html", "<button>inside</button>")
      page.goto(server_empty_page)
      expect(page.frame_locator.frame_locator('#target').locator('button')).to have_text('inside')
    end
  end

  it "should click inside an entered frame" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<iframe id=\"target\" src=\"b.html\"></iframe><button>Click me</button>")
      route_page(page, "b.html", "<button onclick=\"window.__clicked = true\">Click me</button>")
      page.goto(server_empty_page)
      page.frame_locator.frame_locator('#target').get_by_role('button', name: 'Click me').click
      frame = page.frames.find { |candidate| candidate.url.end_with?('b.html') }
      expect(frame.evaluate('() => window.__clicked')).to eq(true)
    end
  end

  it "should not search nested frames after entering a frame" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe id=\"target\" src=\"a.html\"></iframe><button>main</button>")
      route_page(page, "a.html", "<iframe src=\"b.html\"></iframe>")
      route_page(page, "b.html", "<button>deep</button>")
      page.goto(server_empty_page)
      wait_for_frames(page, 3)
      expect(page.frame_locator.frame_locator('#target').locator('button')).to have_count(0)
    end
  end

  it "should support two frameLocators" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<iframe id=\"x\" src=\"b.html\"></iframe>")
      route_page(page, "b.html", "<iframe id=\"y\" src=\"c.html\"></iframe><button>decoy</button>")
      route_page(page, "c.html", "<button>bottom</button>")
      page.goto(server_empty_page)
      expect(page.frame_locator.frame_locator('#x').frame_locator('#y').locator('button')).to have_text('bottom')
    end
  end

  it "should support locator before frameLocator" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<section><iframe src=\"b.html\"></iframe></section><iframe src=\"c.html\"></iframe>")
      route_page(page, "b.html", "<button>in-section</button>")
      route_page(page, "c.html", "<button>outside</button>")
      page.goto(server_empty_page)
      expect(page.frame_locator.locator('section').frame_locator('iframe').locator('button')).to have_text('in-section')
    end
  end

  it "should support owner of a frameLocator" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<iframe id=\"target\" src=\"b.html\"></iframe>")
      route_page(page, "b.html", "<button>inside</button>")
      page.goto(server_empty_page)
      expect(page.frame_locator.frame_locator('#target').owner).to have_attribute('id', 'target')
    end
  end

  it "should wait for the frame to enter to appear" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<div>Nothing yet</div>")
      route_page(page, "b.html", "<button>late</button>")
      page.goto(server_empty_page)
      wait_for_frames(page, 2)
      page.frames[1].evaluate(<<~JS)
        () => setTimeout(() => {
          const iframe = document.createElement('iframe');
          iframe.id = 'late';
          iframe.src = 'b.html';
          document.body.appendChild(iframe);
        }, 3000)
      JS
      expect(page.frame_locator.frame_locator('#late').locator('button')).to have_text('late')
    end
  end

  it "should fail when the frame to enter matches in multiple frames" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe><iframe src=\"b.html\"></iframe>")
      route_page(page, "a.html", "<iframe class=\"inner\" src=\"c.html\"></iframe>")
      route_page(page, "b.html", "<iframe class=\"inner\" src=\"c.html\"></iframe>")
      route_page(page, "c.html", "<button>Click me</button>")
      page.goto(server_empty_page)
      wait_for_frames(page, 5)
      page.frames.select { |frame| frame.url.end_with?('c.html') }.each { |frame| frame.wait_for_selector('button', state: 'attached') }
      expect { page.frame_locator.frame_locator('.inner').locator('button').click(timeout: 3000) }.to raise_error(/multiple frames/)
    end
  end

  it "should support contentFrame" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<iframe id=\"target\" src=\"b.html\"></iframe><button>decoy</button>")
      route_page(page, "b.html", "<button>inside</button>")
      page.goto(server_empty_page)
      expect(page.frame_locator.locator('#target').content_frame.locator('button')).to have_text('inside')
    end
  end

  it "should not allow frameLocator() inside a composite locator" do
    with_page do |page|
      route_page(page, "empty.html", "<button>main</button><iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<a href=\"#\">link</a>")
      page.goto(server_empty_page)
      wait_for_frames(page, 2, "a")
      [
        page.locator('button').or(page.frame_locator.locator('a')),
        page.locator('button').filter(has: page.frame_locator.locator('a')),
        page.frame_locator.locator('button').or(page.frame_locator.locator('a')),
        page.frame_locator.frame_locator('#f').locator('a').or(page.frame_locator.frame_locator('#f').locator('button')),
      ].each do |locator|
        expect { locator.count }.to raise_error(/not allowed inside composite locators/)
      end
      expect { page.frame_locator.locator('a').or(page.locator('button')).count }.to raise_error(/multiple frames/)
    end
  end

  it "should support a composite locator under frameLocator()" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<div class=\"classname\">first</div><button>second</button>")
      page.goto(server_empty_page)
      wait_for_frames(page, 2, "button")
      expect(page.frame_locator.locator('.classname').or(page.get_by_role('button'))).to have_text(['first', 'second'])
    end
  end

  it "should support a composite locator under frameLocator() and a frame locator" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<iframe id=\"f\" src=\"b.html\"></iframe>")
      route_page(page, "b.html", "<div class=\"classname\">first</div><button>second</button>")
      page.goto(server_empty_page)
      wait_for_frames(page, 3)
      expect(page.frame_locator.frame_locator('#f').locator('.classname').or(page.frame_locator('#f').get_by_role('button'))).to have_text(['first', 'second'])
    end
  end

  it "should not allow first/last/nth on frameLocator()" do
    with_page do |page|
      expect { page.frame_locator.first }.to raise_error(/Selecting the nth frame is not allowed on frameLocator\(\)/)
      expect { page.frame_locator.last }.to raise_error(/Selecting the nth frame is not allowed on frameLocator\(\)/)
      expect { page.frame_locator.nth(1) }.to raise_error(/Selecting the nth frame is not allowed on frameLocator\(\)/)
    end
  end

  it "should not allow owner on frameLocator()" do
    with_page do |page|
      expect { page.frame_locator.owner.count }.to raise_error(/Selector cannot be empty after frameLocator/)
    end
  end

  it "should resolve aria-ref selectors" do
    with_page do |page|
      route_page(page, "empty.html", "<button>main</button><iframe src=\"a.html\"></iframe>")
      route_page(page, "a.html", "<button>inside</button>")
      page.goto(server_empty_page)
      wait_for_frames(page, 2, "button")
      snapshot = page.aria_snapshot(mode: 'ai')
      ref = snapshot.match(/button "inside" \[ref=(.*?)\]/)[1]
      expect(ref).to match(/^f\d+e\d+$/)
      expect(page.frame_locator.locator("aria-ref=#{ref}")).to have_text('inside')
    end
  end

  it "should click while another iframe is stalled" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe><iframe src=\"stall.html\"></iframe>")
      route_page(page, "a.html", "<button onclick=\"window.__clicked = true\">Click me</button>")
      page.route('**/stall.html', ->(_) {})
      page.goto(server_empty_page, waitUntil: 'domcontentloaded')
      wait_for_frames(page, 3)
      page.frame_locator.locator('button').click
      frame = page.frames.find { |candidate| candidate.url.end_with?('a.html') }
      expect(frame.evaluate('() => window.__clicked')).to eq(true)
    end
  end

  it "should support toBeVisible while another iframe is stalled" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe><iframe src=\"stall.html\"></iframe>")
      route_page(page, "a.html", "<button>Click me</button>")
      page.route('**/stall.html', ->(_) {})
      page.goto(server_empty_page, waitUntil: 'domcontentloaded')
      wait_for_frames(page, 3)
      expect(page.frame_locator.locator('button')).to be_visible
    end
  end

  it "should support toHaveCount while another iframe is stalled" do
    with_page do |page|
      route_page(page, "empty.html", "<iframe src=\"a.html\"></iframe><iframe src=\"stall.html\"></iframe>")
      route_page(page, "a.html", "<button>Click me</button>")
      page.route('**/stall.html', ->(_) {})
      page.goto(server_empty_page, waitUntil: 'domcontentloaded')
      wait_for_frames(page, 3)
      expect(page.frame_locator.locator('button')).to have_count(1)
    end
  end

end
