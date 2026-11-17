require 'spec_helper'
require 'playwright/test'

RSpec.describe 'toHaveText' do
  include Playwright::Test::Matchers

  # https://github.com/microsoft/playwright/blob/release-1.65/tests/page/expect-to-have-text.spec.ts
  describe 'toHaveText with text' do
    it 'EX-281 pass contain' do
      with_page do |page|
        page.set_content('<div id=node>Text content</div>')
        locator = page.locator('#node')
        expect(locator).to contain_text('Text')
        # Should normalize whitespace.
        expect(locator).to contain_text("   ext        cont\n  ")
        # Should support ignoreCase.
        expect(locator).to contain_text('EXT', ignoreCase: true)
        # Should support falsy ignoreCase.
        expect(locator).not_to contain_text('TEXT', ignoreCase: false)
      end
    end

    it 'EX-282 fail' do
      with_page do |page|
        page.set_content('<div id=node>Text content</div>')
        locator = page.locator('#node')
        expect {
          expect(locator).to have_text('Text', timeout: 1000)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError) { |error|
          expect(error.message).to include("Locator expected to have text 'Text'")
          expect(error.message).to include('Actual value Text content')
        }
      end
    end

    it 'EX-286 fail with impossible timeout' do
      with_page do |page|
        page.set_content('<div id=node>Text content</div>')
        expect {
          expect(page.locator('#node')).to have_text('Text', timeout: 1)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError) { |error|
          expect(error.message).to include("Locator expected to have text 'Text'")
          expect(error.message).to include('Actual value Text content')
        }
      end
    end
  end

  # ref: https://github.com/microsoft/playwright-python/blob/main/tests/sync/test_assertions.py
  describe "#to_have_text", sinatra: true do
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

    it "should allow negating a substring mismatch" do
      with_page do |page|
        page.goto(server_empty_page)
        page.set_content("<div>Text content</div>")
        expect(page.locator("div")).to not_have_text("Text")
      end
    end

    it "should not match a substring in an array" do
      with_page do |page|
        page.goto(server_empty_page)
        page.set_content("<ul><li>Text 1</li><li>Text 2</li><li>Text 3</li></ul>")
        expect(page.locator("li")).to contain_text(["Text 1", "Text 2", "Text"])
        expect {
          expect(page.locator("li")).to have_text(["Text 1", "Text 2", "Text"], timeout: 300)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
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
end
