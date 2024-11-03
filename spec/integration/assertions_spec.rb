require "spec_helper"
require "playwright/test"

# ref: https://github.com/microsoft/playwright-python/blob/main/tests/sync/test_assertions.py
RSpec.describe Playwright::LocatorAssertions, sinatra: true do
  include Playwright::Test::Matchers

  it "should work with #to_contain_text" do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div id=foobar>kek</div>")
      expect(page.locator("div#foobar")).to contain_text("kek")
      expect(page.locator("div#foobar")).to not_contain_text("bar", timeout: 100)

      expect {
        expect(page.locator("div#foobar")).to contain_text("bar", timeout: 100)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)

      page.set_content("<div>Text \n1</div><div>Text2</div><div>Text3</div>")
      expect(page.locator("div")).to contain_text(["ext    1", /ext3/])
    end
  end

  it 'should work with #to_have_accessible_name' do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div role=button aria-label='Hello'></div>")

      div = page.locator("div")
      expect(div).to have_accessible_name("Hello")
      expect {
        expect(div).to have_accessible_name("hello", timeout: 100)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      begin
        expect(div).to have_accessible_name("hello", timeout: 100)
      rescue RSpec::Expectations::ExpectationNotMetError => e
        expect(e.message).to include("Locator expected to have accessible name 'hello'")
      end
      expect(div).to have_accessible_name("hello", ignoreCase: true)
      expect(div).to have_accessible_name(/ell\w/)
      expect {
        expect(div).to have_accessible_name(/hello/, timeout: 100)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      expect(div).to have_accessible_name(/hello/, ignoreCase: true)
    end
  end

  it 'should work with #to_have_accessible_description' do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div role=button aria-description='Hello'></div>")

      div = page.locator("div")
      expect(div).to have_accessible_description("Hello")
      expect {
        expect(div).to have_accessible_description("hello", timeout: 100)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      begin
        expect(div).to have_accessible_description("hello", timeout: 100)
      rescue RSpec::Expectations::ExpectationNotMetError => e
        expect(e.message).to include("Locator expected to have accessible description 'hello'")
      end
      expect(div).to have_accessible_description("hello", ignoreCase: true)
      expect(div).to have_accessible_description(/ell\w/)
      expect {
        expect(div).to have_accessible_description(/hello/, timeout: 100)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      expect(div).to have_accessible_description(/hello/, ignoreCase: true)
    end
  end

  it "should work with #to_have_attribute" do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div id=foobar>kek</div>")
      expect(page.locator("div#foobar")).to have_attribute("id", "foobar")
      expect(page.locator("div#foobar")).to have_attribute("id", /foobar/)
      expect(page.locator("div#foobar")).to not_have_attribute("id", "kek", timeout: 100)

      expect {
        expect(page.locator("div#foobar")).to have_attribute("id", "koko", timeout: 100)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  it "should work with #to_have_class" do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div class=foobar>kek</div>")
      expect(page.locator("div.foobar")).to have_class("foobar")
      expect(page.locator("div.foobar")).to have_class(["foobar"])
      expect(page.locator("div.foobar")).to have_class(/foobar/)
      expect(page.locator("div.foobar")).to not_have_class("kekstar", timeout: 100)

      expect {
        expect(page.locator("div.foobar")).to have_class("oh-no", timeout: 100)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  it "should work with #to_have_count" do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div class=foobar>kek</div><div class=foobar>kek</div>")
      expect(page.locator("div.foobar")).to have_count(2)
      expect(page.locator("div.foobar")).to not_have_count(42, timeout: 100)

      expect {
        expect(page.locator("div.foobar")).to have_count(42, timeout: 100)
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  it "should work with #to_have_css" do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div class=foobar style='color: rgb(234, 74, 90);'>kek</div>")
      expect(page.locator("div.foobar")).to have_css("color", "rgb(234, 74, 90)")
      expect(page.locator("div.foobar")).to not_have_css(
        "color", "rgb(42, 42, 42)", timeout: 100)

      expect {
        expect(page.locator("div.foobar")).to have_css(
          "color", "rgb(42, 42, 42)", timeout: 100
        )
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  it "should work with #to_have_id" do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div class=foobar id=kek>kek</div>")
      expect(page.locator("div.foobar")).to have_id("kek")
      expect(page.locator("div.foobar")).to not_have_id("top", timeout: 100)

      expect {
        expect(page.locator("div.foobar")).to have_id("top", timeout: 100)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  it "should work with #to_have_js_property" do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div></div>")
      page.eval_on_selector(
        "div", "e => e.foo = { a: 1, b: 'string', c: new Date(1627503992000) }"
      )
      expect(page.locator("div")).to have_js_property(
        "foo",
        { "a" => 1, "b" => "string", "c" => Time.at(1627503992000 / 1000) }
      )
    end
  end

  describe "#to_have_js_property" do
    it "should work with pass string" do
      with_page do |page|
        page.set_content("<div></div>")
        page.eval_on_selector("div", "e => e.foo = 'string'")
        locator = page.locator("div")
        expect(locator).to have_js_property("foo", "string")
      end
    end

    it "should work with fail string" do
      with_page do |page|
        page.set_content("<div></div>")
        page.eval_on_selector("div", "e => e.foo = 'string'")
        locator = page.locator("div")
        expect {
          expect(locator).to have_js_property("foo", "error", timeout: 500)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    it "should work with pass number" do
      with_page do |page|
        page.set_content("<div></div>")
        page.eval_on_selector("div", "e => e.foo = 2021")
        locator = page.locator("div")
        expect(locator).to have_js_property("foo", 2021)
      end
    end

    it "should work with fail number" do
      with_page do |page|
        page.set_content("<div></div>")
        page.eval_on_selector("div", "e => e.foo = 2021")
        locator = page.locator("div")

        expect {
          expect(locator).to have_js_property("foo", 1, timeout: 500)
        }
      end
    end

    it "should work with pass boolean" do
      with_page do |page|
        page.set_content("<div></div>")
        page.eval_on_selector("div", "e => e.foo = true")
        locator = page.locator("div")
        expect(locator).to have_js_property("foo", true)
      end
    end

    it "should work with fail boolean" do
      with_page do |page|
        page.set_content("<div></div>")
        page.eval_on_selector("div", "e => e.foo = false")
        locator = page.locator("div")

        expect {
          expect(locator).to have_js_property("foo", true, timeout: 500)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    it "should work with pass boolean 2" do
      with_page do |page|
        page.set_content("<div></div>")
        page.eval_on_selector("div", "e => e.foo = false")
        locator = page.locator("div")
        expect(locator).to have_js_property("foo", false)
      end
    end

    it "should work with fail boolean 2" do
      with_page do |page|
        page.set_content("<div></div>")
        page.eval_on_selector("div", "e => e.foo = true")
        locator = page.locator("div")

        expect {
          expect(locator).to have_js_property("foo", false, timeout: 500)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    it "should work with pass null" do
      with_page do |page|
        page.set_content("<div></div>")
        page.eval_on_selector("div", "e => e.foo = null")
        locator = page.locator("div")
        expect(locator).to have_js_property("foo", nil)
      end
    end
  end

  it 'should work with #to_have_role' do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content('<div role="button">Button!</div>')

      div = page.locator("div")
      expect(div).to have_role("button")
      expect {
        expect(div).to have_role("checkbox", timeout: 100)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      begin
        expect(div).to have_role("checkbox", timeout: 100)
      rescue RSpec::Expectations::ExpectationNotMetError => e
        expect(e.message).to include("Locator expected to have accessible role 'checkbox'")
      end

      expect {
        expect(div).to have_role(/button|checkbox/)
      }.to raise_error(/must be a string/)
    end
  end

  describe '#to_have_title' do
    it 'should work' do
      with_page do |page|
        page.set_content('<title>  Hello     world</title>')
        expect(page).to have_title('Hello  world')

        page.set_content('<title>  Hello     world</title>')
        expect {
          expect(page).to have_title('Hello', timeout: 100)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        begin
          expect(page).to have_title('Hello', timeout: 100)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(e.message).to include("Page title expected to be 'Hello'")
        end
      end
    end
  end

  describe "#to_have_text" do
    it "should work" do
      with_page do |page|
        page.goto(server_empty_page)
        page.set_content("<div id=foobar>kek</div>")
        expect(page.locator("div#foobar")).to have_text("kek")
        expect(page.locator("div#foobar")).to not_have_text("kak")
        expect(page.locator("div#foobar")).to not_contain_text("top", timeout: 100)

        page.set_content("<div>Text    \n1</div><div>Text   2a</div>")
        expect(page.locator("div")).to have_text(
          ["Text  1", /Text   \d+a/]
        )
      end
    end

    it "should ignore case" do
      with_page do |page|
        page.goto(server_empty_page)
        page.set_content("<div id=target>apple BANANA</div><div>orange</div>")
        expect(page.locator("div#target")).to have_text("apple BANANA")
        expect(page.locator("div#target")).to have_text("apple banana", ignoreCase: true)

        # defaults false
        expect {
          expect(page.locator("div#target")).to have_text("apple banana", timeout: 300)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        begin
          expect(page.locator("div#target")).to have_text("apple banana", timeout: 300)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(e.full_message).to include("to have text")
        end

        # array variant
        expect(page.locator("div")).to have_text(["apple BANANA", "orange"])
        expect(page.locator("div")).to have_text(["apple banana", "ORANGE"], ignoreCase: true)

        # defaults false
        expect {
          expect(page.locator("div")).to have_text(["apple banana", "ORANGE"], timeout: 300)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        begin
          expect(page.locator("div#target")).to have_text("apple banana", timeout: 300)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(e.full_message).to include("to have text")
        end

        # not variant
        expect(page.locator("div#target")).to not_have_text("apple banana")
        expect {
          expect(page.locator("div#target")).to not_have_text("apple banana", ignoreCase: true, timeout: 300)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        begin
          expect(page.locator("div#target")).to not_have_text("apple banana", ignoreCase: true, timeout: 300)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(e.full_message).to include("to have text")
        end
      end
    end

    it "should ignore case regex" do
      with_page do |page|
        page.goto(server_empty_page)
        page.set_content("<div id=target>apple BANANA</div><div>orange</div>")
        expect(page.locator("div#target")).to have_text(/apple BANANA/)
        expect(page.locator("div#target")).to have_text(/apple banana/, ignoreCase: true)

        expect {
          expect(page.locator("div#target")).to have_text(/apple banana/, timeout: 300)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        begin
          expect(page.locator("div#target")).to have_text(/apple banana/, timeout: 300)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(e.full_message).to include("to have text")
        end

        expect {
          expect(page.locator("div#target")).to have_text(/apple banana/i, ignoreCase: false, timeout: 300)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        begin
          expect(page.locator("div#target")).to have_text(/apple banana/i, ignoreCase: false, timeout: 300)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(e.full_message).to include("to have text")
        end

        # array variant
        expect(page.locator("div")).to have_text([/apple BANANA/, /orange/])
        expect(page.locator("div")).to have_text([/apple banana/, /ORANGE/], ignoreCase: true)

        # defaults regex flag
        expect {
          expect(page.locator("div")).to have_text([/apple banana/, /ORANGE/], timeout: 300)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        begin
          expect(page.locator("div")).to have_text([/apple banana/, /ORANGE/], timeout: 300)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(e.full_message).to include("to have text")
        end

        # overrides regex flag
        expect {
          expect(page.locator("div")).to have_text([/apple banana/i, /ORANGE/i], ignoreCase: false, timeout: 300)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        begin
          expect(page.locator("div")).to have_text([/apple banana/i, /ORANGE/i], ignoreCase: false, timeout: 300)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(e.full_message).to include("to have text")
        end

        # not variant
        expect(page.locator("div#target")).to not_have_text(/apple banana/)
        expect {
          expect(page.locator("div#target")).to not_have_text(/apple banana/, ignoreCase: true, timeout: 300)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        begin
          expect(page.locator("div#target")).to not_have_text(/apple banana/, ignoreCase: true, timeout: 300)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(e.full_message).to include("not expected to have text")
        end
      end
    end

    it "should be able to serialize regex correctly" do
      with_page do |page|
        page.goto(server_empty_page)
        page.set_content("<div>iGnOrEcAsE</div>")
        expect(page.locator("div")).to have_text(/ignorecase/i)

        page.set_content(<<~HTML)
          <div>start

          some
          lines
          between
          end</div>
        HTML
        expect(page.locator("div")).to have_text(/start.*end/m)

        page.set_content(<<~HTML)
          <div>line1
          line2
          line3</div>
        HTML
        expect(page.locator("div")).to have_text(/^line2$/m)
      end
    end

    it 'should fail with conprehensive error message' do
      with_page do |page|
        page.goto(server_empty_page)
        page.set_content("<div>3.141592</div>")
        expect {
          expect(page.locator("div")).to have_text(3.14159)
        }.to raise_error(/Expected value provided to assertion to be a string or regex/)
      end
    end
  end

  describe '#to_have_url' do
    it "should work" do
      with_page do |page|
        page.goto("data:text/html,<div>A</div>")
        expect(page).to have_url("data:text/html,<div>A</div>")

        expect {
          expect(page).to have_url("data:text/html,<div>B</div>", timeout: 100)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        begin
          expect(page).to have_url("data:text/html,<div>B</div>", timeout: 100)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(e.full_message).to include("Page URL expected to be")
        end
      end
    end

    it "should ignore case" do
      with_page do |page|
        page.goto("data:text/html,<div>A</div>")
        expect(page).to have_url("DATA:teXT/HTml,<div>a</div>", ignoreCase: true)
      end
    end
  end

  describe "#to_contain_text" do
    it "should ignore case" do
      with_page do |page|
        page.goto(server_empty_page)
        page.set_content("<div id=target>apple BANANA</div><div>orange</div>")
        expect(page.locator("div#target")).to contain_text("apple BANANA")
        expect(page.locator("div#target")).to contain_text("apple banana", ignoreCase: true)

        # defaults false
        expect {
          expect(page.locator("div#target")).to contain_text("apple banana", timeout: 300)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        begin
          expect(page.locator("div#target")).to contain_text("apple banana", timeout: 300)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(e.full_message).to include("to contain text")
        end

        # array variant
        expect(page.locator("div")).to contain_text(["apple BANANA", "orange"])
        expect(page.locator("div")).to contain_text(["apple banana", "ORANGE"], ignoreCase: true)

        # defaults false
        expect {
          expect(page.locator("div")).to contain_text(["apple banana", "ORANGE"], timeout: 300)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        begin
          expect(page.locator("div#target")).to contain_text("apple banana", timeout: 300)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(e.full_message).to include("to contain text")
        end

        # not variant
        expect(page.locator("div#target")).to not_contain_text("apple banana")
        expect {
          expect(page.locator("div#target")).to not_contain_text("apple banana", ignoreCase: true, timeout: 300)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        begin
          expect(page.locator("div#target")).to not_contain_text("apple banana", ignoreCase: true, timeout: 300)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(e.full_message).to include("to contain text")
        end
      end
    end

    it "should ignore case regex" do
      with_page do |page|
        page.goto(server_empty_page)
        page.set_content("<div id=target>apple BANANA</div><div>orange</div>")
        expect(page.locator("div#target")).to contain_text(/apple BANANA/)
        expect(page.locator("div#target")).to contain_text(/apple banana/, ignoreCase: true)

        expect {
          expect(page.locator("div#target")).to contain_text(/apple banana/, timeout: 300)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        begin
          expect(page.locator("div#target")).to contain_text(/apple banana/, timeout: 300)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(e.full_message).to include("to contain text")
        end

        expect {
          expect(page.locator("div#target")).to contain_text(/apple banana/i, ignoreCase: false, timeout: 300)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        begin
          expect(page.locator("div#target")).to contain_text(/apple banana/i, ignoreCase: false, timeout: 300)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(e.full_message).to include("to contain text")
        end

        # array variant
        expect(page.locator("div")).to contain_text([/apple BANANA/, /orange/])
        expect(page.locator("div")).to contain_text([/apple banana/, /ORANGE/], ignoreCase: true)

        # defaults regex flag
        expect {
          expect(page.locator("div")).to contain_text([/apple banana/, /ORANGE/], timeout: 300)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        begin
          expect(page.locator("div")).to contain_text([/apple banana/, /ORANGE/], timeout: 300)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(e.full_message).to include("to contain text")
        end

        # overrides regex flag
        expect {
          expect(page.locator("div")).to contain_text([/apple banana/i, /ORANGE/i], ignoreCase: false, timeout: 300)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        begin
          expect(page.locator("div")).to contain_text([/apple banana/i, /ORANGE/i], ignoreCase: false, timeout: 300)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(e.full_message).to include("to contain text")
        end

        # not variant
        expect(page.locator("div#target")).to not_contain_text(/apple banana/)
        expect {
          expect(page.locator("div#target")).to not_contain_text(/apple banana/, ignoreCase: true, timeout: 300)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        begin
          expect(page.locator("div#target")).to not_contain_text(/apple banana/, ignoreCase: true, timeout: 300)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(e.full_message).to include("not expected to contain text")
        end
      end
    end

    it "should work with #to_have_value" do
      with_page do |page|
        page.goto(server_empty_page)
        page.set_content("<input type=text id=foo>")
        my_input = page.locator("#foo")
        expect(my_input).to have_value("")
        expect(my_input).to not_have_value("bar", timeout: 100)
        my_input.fill("kektus")
        expect(my_input).to have_value("kektus")
      end
    end
  end

  describe "#to_have_values" do
    it "should work with text" do
      with_page do |page|
        page.set_content(<<~HTML)
        <select multiple>
          <option value="R">Red</option>
          <option value="G">Green</option>
          <option value="B">Blue</option>
        </select>
        HTML

        locator = page.locator("select")
        locator.select_option(value: ["R", "G"])
        expect(locator).to have_values(["R", "G"])
      end
    end

    it "should follow labels" do
      with_page do |page|
        page.set_content(<<~HTML)
        <label for="colors">Pick a Color</label>
        <select id="colors" multiple>
            <option value="R">Red</option>
            <option value="G">Green</option>
            <option value="B">Blue</option>
        </select>
        HTML

        locator = page.locator("text=Pick a color")
        locator.select_option(value: ["R", "G"])
        expect(locator).to have_values(["R", "G"])
      end
    end

    it "must exactly match text" do
      with_page do |page|
        page.set_content(<<~HTML)
        <select multiple>
          <option value="RR">Red</option>
          <option value="GG">Green</option>
        </select>
        HTML

        locator = page.locator("select")
        locator.select_option(value: ["RR", "GG"])
        expect {
          expect(locator).to have_values(["R", "G"], timeout: 500)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        begin
          expect(locator).to have_values(["R", "G"], timeout: 500)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(e.full_message).to include("Locator expected to have Values '[\"R\", \"G\"]'")
          actual_value = '["RR", "GG"]'
          expect(e.full_message).to include("Actual value #{actual_value}") # TODO: print actual value in prettier format?
        end
      end
    end

    it "should work with regex" do
      with_page do |page|
        page.set_content(<<~HTML)
        <select multiple>
          <option value="R">Red</option>
          <option value="G">Green</option>
          <option value="B">Blue</option>
        </select>
        HTML

        locator = page.locator("select")
        locator.select_option(value: ["R", "G"])
        expect(locator).to have_values([/R/, /G/])
      end
    end

    it "should work when items not selected" do
      with_page do |page|
        page.set_content(<<~HTML)
        <select multiple>
          <option value="R">Red</option>
          <option value="G">Green</option>
          <option value="B">Blue</option>
        </select>
        HTML

        locator = page.locator("select")
        locator.select_option(value: ["B"])
        expect {
          expect(locator).to have_values(["R", "G"], timeout: 500)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        begin
          expect(locator).to have_values(["R", "G"], timeout: 500)
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(e.full_message).to include("Locator expected to have Values '[\"R\", \"G\"]'")
          actual_value = '["B"]'
          expect(e.full_message).to include("Actual value #{actual_value}") # TODO: print actual value in prettier format?
        end
      end
    end

    it "should fail when multiple not specified" do
      with_page do |page|
        page.set_content(<<~HTML)
        <select>
          <option value="R">Red</option>
          <option value="G">Green</option>
          <option value="B">Blue</option>
        </select>
        HTML

        locator = page.locator("select")
        locator.select_option(value: ["B"])
        expect {
          expect(locator).to have_values(["R", "G"], timeout: 500)
        }.to raise_error(Playwright::Error)
        begin
          expect(locator).to have_values(["R", "G"], timeout: 500)
        rescue Playwright::Error => e
          expect(e.full_message).to include("Error: Not a select element with a multiple attribute")
        end
      end
    end

    it "should fail when not a select element" do
      with_page do |page|
        page.set_content("<input type='text'>")
        locator = page.locator("input")
        expect {
          expect(locator).to have_values(["R", "G"], timeout: 500)
        }.to raise_error(Playwright::Error)
        begin
          expect(locator).to have_values(["R", "G"], timeout: 500)
        rescue Playwright::Error => e
          expect(e.full_message).to include("Error: Not a select element with a multiple attribute")
        end
      end
    end
  end

  it "works with #to_be_checked" do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<input type=checkbox>")
      my_checkbox = page.locator("input")
      expect(my_checkbox).to not_be_checked

      expect {
        expect(my_checkbox).to be_checked(timeout: 100)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)

      expect(my_checkbox).to be_checked(timeout: 100, checked: false)

      expect {
        expect(my_checkbox).to be_checked(timeout: 100, checked: true)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)

      my_checkbox.check()
      expect(my_checkbox).to be_checked(timeout: 100, checked: true)

      expect {
        expect(my_checkbox).to be_checked(timeout: 100, checked: false)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)

      expect(my_checkbox).to be_checked
    end
  end

  it "should work with #to_be_enabled / #to_be_disabled" do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<input type=checkbox>")
      my_checkbox = page.locator("input")
      expect(my_checkbox).to not_be_disabled
      expect(my_checkbox).to be_enabled

      expect {
        expect(my_checkbox).to be_disabled(timeout: 100)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      my_checkbox.evaluate("e => e.disabled = true")
      expect(my_checkbox).to be_disabled

      expect {
        expect(my_checkbox).to be_enabled(timeout: 100)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  describe "#to_be_enabled" do
    it "should work with true" do
      with_page do |page|
        page.set_content("<button>Text</button>")
        expect(page.locator("button")).to be_enabled(enabled: true)
      end
    end

    it "should work with false" do
      with_page do |page|
        page.set_content("<button disabled>Text</button>")
        expect(page.locator("button")).to be_enabled(enabled: false)
      end
    end

    it "should work with not and false" do
      with_page do |page|
        page.set_content("<button>Text</button>")
        expect(page.locator("button")).to not_be_enabled(enabled: false)
      end
    end

    it "should work eventually" do
      with_page do |page|
        page.set_content("<button disabled>Text</button>")
        page.eval_on_selector("button", <<~JS)
          button => setTimeout(() => {
            button.removeAttribute('disabled')
          }, 700)
        JS
        expect(page.locator("button")).to be_enabled
      end
    end

    it "should work eventually with not" do
      with_page do |page|
        page.set_content("<button>Text</button>")
        page.eval_on_selector("button", <<~JS)
          button => setTimeout(() => {
            button.setAttribute('disabled', '')
          }, 700)
        JS
        expect(page.locator("button")).to not_be_enabled
      end
    end

    it "should work eventually when negated" do
      with_page do |page|
        page.set_content("<button>Text</button>")
        page.eval_on_selector("button", <<~JS)
          button => setTimeout(() => {
            button.setAttribute('disabled', '')
          }, 700)
        JS
        expect(page.locator("button")).not_to be_enabled
      end
    end
  end

  describe "#to_be_editable" do
    it "should work" do
      with_page do |page|
        page.goto(server_empty_page)
        page.set_content("<input></input><button disabled>Text</button>")
        expect(page.locator("button")).to not_be_editable
        expect(page.locator("input")).to be_editable
        expect {
          expect(page.locator("button")).to be_editable(timeout: 100)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    it "should work with true" do
      with_page do |page|
        page.set_content("<input></input>")
        expect(page.locator("input")).to be_editable(editable: true)
      end
    end

    it "should work with false" do
      with_page do |page|
        page.set_content("<input readonly></input>")
        expect(page.locator("input")).to be_editable(editable: false)
      end
    end

    it "should work with not and false" do
      with_page do |page|
        page.set_content("<input></input>")
        expect(page.locator("input")).to not_be_editable(editable: false)
      end
    end
  end

  it "should work with #to_be_empty" do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<input value=text name=input1></input><input name=input2></input>")
      expect(page.locator("input[name=input1]")).to not_be_empty
      expect(page.locator("input[name=input2]")).to be_empty
      expect {
        expect(page.locator("input[name=input1]")).to be_empty(timeout: 100)
      }
    end
  end

  it "should work with #to_be_focused" do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<input type=checkbox>")
      my_checkbox = page.locator("input")
      expect {
        expect(my_checkbox).to be_focused(timeout: 100)
      }
      my_checkbox.focus()
      expect(my_checkbox).to be_focused
    end
  end

  it "should work with #to_be_hidden / #to_be_visible" do
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div style='width: 50px; height: 50px;'>Something</div>")
      my_checkbox = page.locator("div")
      expect(my_checkbox).to be_visible
      expect {
        expect(my_checkbox).to be_hidden(timeout: 100)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)

      my_checkbox.evaluate("e => e.style.display = 'none'")
      expect(my_checkbox).to be_hidden

      expect {
        expect(my_checkbox).to be_visible(timeout: 100)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end

  describe "#to_be_visible" do
    it "should work with true" do
      with_page do |page|
        page.set_content("<button>hello</button")
        expect(page.locator("button")).to be_visible(visible: true)
      end
    end

    it "should work with false" do
      with_page do |page|
        page.set_content("<button hidden>hello</button")
        expect(page.locator("button")).to be_visible(visible: false)
      end
    end

    it "should work with not and false" do
      with_page do |page|
        page.set_content("<button>hello</button")
        expect(page.locator("button")).to not_be_visible(visible: false)
      end
    end

    it "should work eventually" do
      with_page do |page|
        page.set_content("<div></div>")
        page.eval_on_selector("div", <<~JS)
          div => setTimeout(() => {
            div.innerHTML = '<span>Hello</span>'
          }, 700)
        JS
        expect(page.locator("span")).to be_visible
      end
    end

    it "should work eventually with not" do
      with_page do |page|
        page.set_content("<div><span>Hello</span></div>")
        page.eval_on_selector("span", <<~JS)
          span => setTimeout(() => {
            span.textContent = ''
          }, 700)
        JS

        expect(page.locator("span")).to not_be_visible
      end
    end

    it "should work eventually when negated" do
      with_page do |page|
        page.set_content("<div><span>Hello</span></div>")
        page.eval_on_selector("span", <<~JS)
          span => setTimeout(() => {
            span.textContent = ''
          }, 700)
        JS

        expect(page.locator("span")).not_to be_visible
      end
    end
  end
end
