require "spec_helper"
require "minitest"
require "playwright/test"

class MinitestTest < Minitest::Test
  include Playwright::Test::Assertions
  include IntegrationTestCaseMethods

  def self.run(playwright_browser, server_empty_page, *args, **kwargs)
    @@playwright_browser = playwright_browser
    @@server_empty_page = server_empty_page
    super(*args, **kwargs)
  end

  # minitest will assume there is a seed and throw an exception
  # unless the test order is either alpha or sorted
  def self.test_order
    :sorted
  end

  def setup
    @playwright_browser = @@playwright_browser
  end

  def server_empty_page
    @@server_empty_page
  end

  def test_should_work_with_to_contain_test
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div id=foobar>kek</div>")
      assert_contain_text page.locator("div#foobar"), "kek"
      refute_contain_text page.locator("div#foobar"), "bar", timeout: 200

      assert_raises(Minitest::Assertion) do
        assert_contain_text page.locator("div#foobar"), "bar", timeout: 100
      end

      page.set_content("<div>Text \n1</div><div>Text2</div><div>Text3</div>")
      assert_contain_text page.locator("div"), ["ext    1", /ext3/]
    end
  end

  def test_should_work_with_to_have_accessible_name
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div role=button aria-label='Hello'></div>")

      div = page.locator("div")
      assert_has_accessible_name div, "Hello"

      assert_raises(Minitest::Assertion) do
        assert_has_accessible_name div, "hello", timeout: 100
      end

      begin
        assert_has_accessible_name div, "hello", timeout: 100
      rescue Minitest::Assertion => e
        assert_includes e.message, "Locator expected to have accessible name 'hello'"
      end
      assert_has_accessible_name div, "hello", ignoreCase: true
      assert_has_accessible_name div, /ell\w/
      assert_raises(Minitest::Assertion) do
        assert_has_accessible_name div, /hello/, timeout: 100
      end
      assert_has_accessible_name div, "hello", ignoreCase: true
    end
  end

  def test_should_work_with_to_have_accessible_description
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div role=button aria-description='Hello'></div>")

      div = page.locator("div")
      assert_has_accessible_description div, "Hello"

      assert_raises(Minitest::Assertion) do
        assert_has_accessible_description div, "hello", timeout: 100
      end
      begin
        assert_has_accessible_description div, "hello", timeout: 100
      rescue Minitest::Assertion => e
        assert_includes e.message, "Locator expected to have accessible description 'hello'"
      end
      assert_has_accessible_description div, "hello", ignoreCase: true
      assert_has_accessible_description div, /ell\w/
      assert_raises(Minitest::Assertion) do
        assert_has_accessible_description div, /hello/, timeout: 100
      end
      assert_has_accessible_description div, /hello/, ignoreCase: true
    end
  end

  def test_should_work_with_to_have_attribute
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div id=foobar>kek</div>")
      assert_has_attribute page.locator("div#foobar"), "id", "foobar"
      assert_has_attribute page.locator("div#foobar"), "id", /foobar/
      refute_has_attribute page.locator("div#foobar"), "id", "kek", timeout: 100

      assert_raises(Minitest::Assertion) do
        assert_has_attribute page.locator("div#foobar"), "id", "koko", timeout: 100
      end
    end
  end

  def test_should_work_with_to_have_class
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div class=foobar>kek</div>")
      assert_has_class page.locator("div.foobar"), "foobar"
      assert_has_class page.locator("div.foobar"), ["foobar"]
      assert_has_class page.locator("div.foobar"), /foobar/
      refute_has_class page.locator("div.foobar"), "kekstar", timeout: 100

      assert_raises(Minitest::Assertion) do 
        assert_has_class page.locator("div.foobar"), "oh-no", timeout: 100
      end
    end
  end

  def test_should_work_with_to_have_count
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div class=foobar>kek</div><div class=foobar>kek</div>")
      assert_has_count page.locator("div.foobar"), 2
      refute_has_count page.locator("div.foobar"), 42, timeout: 100

      assert_raises(Minitest::Assertion) do
        assert_has_count page.locator("div.foobar"), 42, timeout: 100
      end
    end
  end

  def test_should_work_with_to_have_css
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div class=foobar style='color: rgb(234, 74, 90);'>kek</div>")

      assert_has_css page.locator("div.foobar"), "color", "rgb(234, 74, 90)"
      refute_has_css page.locator("div.foobar"), "color", "rgb(42, 42, 42)", timeout: 100

      assert_raises(Minitest::Assertion) do
        assert_has_css page.locator("div.foobar"), "color", "rgb(42, 42, 42)", timeout: 100
      end
    end
  end

  def test_should_work_with_to_have_id
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div class=foobar id=kek>kek</div>")
      assert_has_id page.locator("div.foobar"), "kek"
      refute_has_id page.locator("div.foobar"), "top", timeout: 100

      assert_raises(Minitest::Assertion) do
        assert_has_id page.locator("div.foobar"), "top", timeout: 100
      end
    end
  end

  def test_should_work_with_to_have_js_property
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div></div>")
      page.eval_on_selector(
        "div", "e => e.foo = { a: 1, b: 'string', c: new Date(1627503992000) }"
      )
      assert_has_js_property page.locator("div"), "foo", { "a" => 1, "b" => "string", "c" => Time.at(1627503992000 / 1000) }
    end
  end

  ## describe #to_have_js_property
  def test_to_have_js_property_should_work_with_pass_string
    with_page do |page|
      page.set_content("<div></div>")
      page.eval_on_selector("div", "e => e.foo = 'string'")
      locator = page.locator("div")
      assert_has_js_property locator, "foo", "string"
    end
  end

  def test_to_have_js_property_should_work_with_fail_string
    with_page do |page|
      page.set_content("<div></div>")
      page.eval_on_selector("div", "e => e.foo = 'string'")
      locator = page.locator("div")
      assert_raises(Minitest::Assertion) do
        assert_has_js_property locator, "foo", "error", timeout: 500
      end
    end
  end

  def test_to_have_js_property_should_work_with_pass_number
    with_page do |page|
      page.set_content("<div></div>")
      page.eval_on_selector("div", "e => e.foo = 2021")
      locator = page.locator("div")
      assert_has_js_property locator, "foo", 2021
    end
  end

  def test_to_have_js_property_should_work_with_fail_number
    with_page do |page|
      page.set_content("<div></div>")
      page.eval_on_selector("div", "e => e.foo = 2021")
      locator = page.locator("div")

      assert_raises(Minitest::Assertion) do
        assert_has_js_property locator, "foo", 1, timeout: 500
      end
    end
  end

  def test_to_have_js_property_should_work_with_pass_boolean
    with_page do |page|
      page.set_content("<div></div>")
      page.eval_on_selector("div", "e => e.foo = true")
      locator = page.locator("div")
      assert_has_js_property locator, "foo", true
    end
  end

  def test_to_have_js_property_should_work_with_fail_boolean
    with_page do |page|
      page.set_content("<div></div>")
      page.eval_on_selector("div", "e => e.foo = false")
      locator = page.locator("div")

      assert_raises(Minitest::Assertion) do
        assert_has_js_property locator, "foo", true, timeout: 500
      end
    end
  end

  def test_to_have_js_property_should_work_with_pass_boolean_2
    with_page do |page|
      page.set_content("<div></div>")
      page.eval_on_selector("div", "e => e.foo = false")
      locator = page.locator("div")
      assert_has_js_property locator, "foo", false
    end
  end

  def test_to_have_js_property_should_work_with_fail_boolean_2
    with_page do |page|
      page.set_content("<div></div>")
      page.eval_on_selector("div", "e => e.foo = true")
      locator = page.locator("div")

      assert_raises(Minitest::Assertion) do
        assert_has_js_property locator, "foo", false, timeout: 500
      end
    end
  end

  def test_to_have_js_property_should_work_with_pass_null
    with_page do |page|
      page.set_content("<div></div>")
      page.eval_on_selector("div", "e => e.foo = null")
      locator = page.locator("div")
      assert_has_js_property locator, "foo", nil
    end
  end
  ##

  def test_should_work_with_to_have_role
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content('<div role="button">Button!</div>')

      div = page.locator("div")
      assert_has_role div, "button"
      assert_raises(Minitest::Assertion) do
        assert_has_role div, "checkbox", timeout: 100
      end
      begin
        assert_has_role div, "checkbox", timeout: 100
      rescue Minitest::Assertion => e
        assert_includes e.message, "Locator expected to have accessible role 'checkbox'"
      end

      e = assert_raises(ArgumentError) do
        assert_has_role div, /button|checkbox/
      end
      assert_match /must be a string/, e.message
    end
  end

  ## describe #to_have_title
  def test_to_have_title_should_work
    with_page do |page|
      page.set_content('<title>  Hello     world</title>')
      assert_has_title page, "Hello  world"

      page.set_content('<title>  Hello     world</title>')
      assert_raises(Minitest::Assertion) do
        assert_has_title page, "Hello", timeout: 100
      end
      begin
        assert_has_title page, "Hello", timeout: 100
      rescue Minitest::Assertion => e
        assert_includes e.message, "Page title expected to be 'Hello'"
      end
    end
  end
  ##

  ## describe #to_have_text
  def test_to_have_text_should_work
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div id=foobar>kek</div>")
      assert_has_text page.locator("div#foobar"), "kek"
      refute_has_text page.locator("div#foobar"), "kak"
      refute_contain_text page.locator("div#foobar"), "top", timeout: 100

      page.set_content("<div>Text    \n1</div><div>Text   2a</div>")
      assert_has_text page.locator("div"), ["Text  1", /Text   \d+a/]
    end
  end

  def test_to_have_text_should_ignore_case
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div id=target>apple BANANA</div><div>orange</div>")
      assert_has_text page.locator("div#target"), "apple BANANA"
      assert_has_text page.locator("div#target"), "apple banana", ignoreCase: true

      # defaults false
      assert_raises(Minitest::Assertion) do
        assert_has_text page.locator("div#target"), "apple banana", timeout: 300
      end
      begin
        assert_has_text page.locator("div#target"), "apple banana", timeout: 300
      rescue Minitest::Assertion => e
        assert_includes e.message, "to have text"
      end

      # array variant
      assert_has_text page.locator("div"), ["apple BANANA", "orange"]
      assert_has_text page.locator("div"), ["apple banana", "ORANGE"], ignoreCase: true

      # defaults false
      assert_raises(Minitest::Assertion) do
        assert_has_text page.locator("div"), ["apple banana", "ORANGE"], timeout: 300
      end
      begin
        assert_has_text page.locator("div#target"), "apple banana", timeout: 300
      rescue Minitest::Assertion => e
        assert_includes e.message, "to have text"
      end

      # not variant
      refute_has_text page.locator("div#target"), "apple banana"
      assert_raises(Minitest::Assertion) do
        refute_has_text page.locator("div#target"), "apple banana", ignoreCase: true, timeout: 300
      end
      begin
        refute_has_text page.locator("div#target"), "apple banana", ignoreCase: true, timeout: 300
      rescue Minitest::Assertion => e
        assert_includes e.message, "to have text"
      end
    end
  end

  def test_to_have_text_should_ignore_case_regex
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div id=target>apple BANANA</div><div>orange</div>")
      assert_has_text page.locator("div#target"), /apple BANANA/
      assert_has_text page.locator("div#target"), /apple banana/, ignoreCase: true

      assert_raises(Minitest::Assertion) do
        assert_has_text page.locator("div#target"), /apple banana/, timeout: 300
      end
      begin
        assert_has_text page.locator("div#target"), /apple banana/, timeout: 300
      rescue Minitest::Assertion => e
        assert_includes e.message, "to have text"
      end

      assert_raises(Minitest::Assertion) do
        assert_has_text page.locator("div#target"), /apple banana/i, ignoreCase: false, timeout: 300
      end
      begin
        assert_has_text page.locator("div#target"), /apple banana/i, ignoreCase: false, timeout: 300
      rescue Minitest::Assertion => e
        assert_includes e.message, "to have text"
      end

      # array variant
      assert_has_text page.locator("div"), [/apple BANANA/, /orange/]
      assert_has_text page.locator("div"), [/apple banana/, /ORANGE/], ignoreCase: true

      # defaults regex flag
      assert_raises(Minitest::Assertion) do
        assert_has_text page.locator("div"), [/apple banana/, /ORANGE/], timeout: 300
      end
      begin
        assert_has_text page.locator("div"), [/apple banana/, /ORANGE/], timeout: 300
      rescue Minitest::Assertion => e
        assert_includes e.message, "to have text"
      end

      # overrides regex flag
      assert_raises(Minitest::Assertion) do
        assert_has_text page.locator("div"), [/apple banana/i, /ORANGE/i], ignoreCase: false, timeout: 300
      end
      begin
        assert_has_text page.locator("div"), [/apple banana/i, /ORANGE/i], ignoreCase: false, timeout: 300
      rescue Minitest::Assertion => e
        assert_includes e.message, "to have text"
      end

      # not variant
      refute_has_text page.locator("div#target"), /apple banana/
      assert_raises(Minitest::Assertion) do
        refute_has_text page.locator("div#target"), /apple banana/, ignoreCase: true, timeout: 300
      end
      begin
        refute_has_text page.locator("div#target"), /apple banana/, ignoreCase: true, timeout: 300
      rescue Minitest::Assertion => e
        assert_includes e.message, "to have text"
      end
    end
  end

  def test_to_have_text_should_be_able_to_serialize_regex_correctly
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div>iGnOrEcAsE</div>")
      assert_has_text page.locator("div"), /ignorecase/i

      page.set_content(<<~HTML)
        <div>start

        some
        lines
        between
        end</div>
      HTML
      assert_has_text page.locator("div"), /start.*end/m

      page.set_content(<<~HTML)
        <div>line1
        line2
        line3</div>
      HTML
      assert_has_text page.locator("div"), /^line2$/m
    end
  end

  def test_to_have_text_should_fail_with_comprehensive_error_message
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div>3.141592</div>")
      e = assert_raises(ArgumentError) do
        assert_has_text page.locator("div"), 3.14159
      end
      assert_match /Expected value provided to assertion to be a string or regex/, e.message
    end
  end
  ##

  ## describe #to_have_url
  def test_to_have_url_should_work
    with_page do |page|
      page.goto("data:text/html,<div>A</div>")
      assert_has_url page, "data:text/html,<div>A</div>"

      assert_raises(Minitest::Assertion) do
        assert_has_url page, "data:text/html,<div>B</div>", timeout: 100
      end
      begin
        assert_has_url page, "data:text/html,<div>B</div>", timeout: 100
      rescue Minitest::Assertion => e
        assert_includes e.message, "Page URL expected to be"
      end
    end
  end

  def test_to_have_url_should_ignore_case
    with_page do |page|
      page.goto("data:text/html,<div>A</div>")
      assert_has_url page, "DATA:teXT/HTml,<div>a</div>", ignoreCase: true
    end
  end
  ##

  ## describe #to_contain_text
  def test_to_contain_text_should_ignore_case
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div id=target>apple BANANA</div><div>orange</div>")
      assert_contain_text page.locator("div#target"), "apple BANANA"
      assert_contain_text page.locator("div#target"), "apple banana", ignoreCase: true

      # defaults false
      assert_raises(Minitest::Assertion) do
        assert_contain_text page.locator("div#target"), "apple banana", timeout: 300
      end
      begin
        assert_contain_text page.locator("div#target"), "apple banana", timeout: 300
      rescue Minitest::Assertion => e
        assert_includes e.message, "to contain text"
      end

      # array variant
      assert_contain_text page.locator("div"), ["apple BANANA", "orange"]
      assert_contain_text page.locator("div"), ["apple banana", "ORANGE"], ignoreCase: true

      # defaults false
      assert_raises(Minitest::Assertion) do
        assert_contain_text page.locator("div"), ["apple banana", "ORANGE"], timeout: 300
      end
      begin
        assert_contain_text page.locator("div#target"), "apple banana", timeout: 300
      rescue Minitest::Assertion => e
        assert_includes e.message, "to contain text"
      end

      # not variant
      refute_contain_text page.locator("div#target"), "apple banana"
      assert_raises(Minitest::Assertion) do
        refute_contain_text page.locator("div#target"), "apple banana", ignoreCase: true
      end
      begin
        refute_contain_text page.locator("div#target"), "apple banana", ignoreCase: true, timeout: 300
      rescue Minitest::Assertion => e
        assert_includes e.message, "to contain text"
      end
    end
  end

  def test_to_contain_text_should_ignore_case_regex
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div id=target>apple BANANA</div><div>orange</div>")
      assert_contain_text page.locator("div#target"), /apple BANANA/
      assert_contain_text page.locator("div#target"), /apple banana/, ignoreCase: true

      assert_raises(Minitest::Assertion) do
        assert_contain_text page.locator("div#target"), /apple banana/, timeout: 300
      end
      begin
        assert_contain_text page.locator("div#target"), /apple banana/, timeout: 300
      rescue Minitest::Assertion => e
        assert_includes e.message, "to contain text"
      end

      assert_raises(Minitest::Assertion) do
        assert_contain_text page.locator("div#target"), /apple banana/i, ignoreCase: false, timeout: 300
      end
      begin
        assert_contain_text page.locator("div#target"), /apple banana/i, ignoreCase: false, timeout: 300
      rescue Minitest::Assertion => e
        assert_includes e.message, "to contain text"
      end

      # array variant
      assert_contain_text page.locator("div"), [/apple BANANA/, /orange/]
      assert_contain_text page.locator("div"), [/apple banana/, /ORANGE/], ignoreCase: true

      # defaults regex flag
      assert_raises(Minitest::Assertion) do
        assert_contain_text page.locator("div"), [/apple banana/, /ORANGE/], timeout: 300
      end
      begin
        assert_contain_text page.locator("div"), [/apple banana/, /ORANGE/], timeout: 300
      rescue Minitest::Assertion => e
        assert_includes e.message, "to contain text"
      end

      # overrides regex flag
      assert_raises(Minitest::Assertion) do
        assert_contain_text page.locator("div"), [/apple banana/i, /ORANGE/i], ignoreCase: false, timeout: 300
      end
      begin
        assert_contain_text page.locator("div"), [/apple banana/i, /ORANGE/i], ignoreCase: false, timeout: 300
      rescue Minitest::Assertion => e
        assert_includes e.message, "to contain text"
      end

      # not variant
      refute_contain_text page.locator("div#target"), /apple banana/
      assert_raises(Minitest::Assertion) do
        refute_contain_text page.locator("div#target"), /apple banana/, ignoreCase: true, timeout: 300
      end
      begin
        refute_contain_text page.locator("div#target"), /apple banana/, ignoreCase: true, timeout: 300
      rescue Minitest::Assertion => e
        assert_includes e.message, "to contain text"
      end
    end
  end
  ##

  def test_should_work_with_to_have_value
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<input type=text id=foo>")
      my_input = page.locator("#foo")
      assert_has_value my_input, ""
      refute_has_value my_input, "bar", timeout: 100
      my_input.fill("kektus")
      assert_has_value my_input, "kektus"
    end
  end

  ## describe #to_have_values
  def test_to_have_values_should_work_with_text
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
      assert_has_values locator, ["R", "G"]
    end
  end

  def test_to_have_values_should_follow_labels
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
      assert_has_values locator, ["R", "G"]
    end
  end

  def test_to_have_values_must_exactly_match_text
   with_page do |page|
      page.set_content(<<~HTML)
      <select multiple>
        <option value="RR">Red</option>
        <option value="GG">Green</option>
      </select>
      HTML

      locator = page.locator("select")
      locator.select_option(value: ["RR", "GG"])
      assert_raises(Minitest::Assertion) do
        assert_has_values locator, ["R", "G"], timeout: 500
      end
      begin
        assert_has_values locator, ["R", "G"], timeout: 500
      rescue Minitest::Assertion => e
        assert_includes e.message, "Locator expected to have Values '[\"R\", \"G\"]'"
        actual_value = '["RR", "GG"]'
        assert_includes e.message, "Actual value #{actual_value}"
      end
    end
  end

  def test_to_have_values_should_work_with_regex
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
      assert_has_values locator, [/R/, /G/]
    end
  end

  def test_to_have_values_should_work_when_items_not_selected
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
      assert_raises(Minitest::Assertion) do
        assert_has_values locator, ["R", "G"], timeout: 500
      end
      begin
        assert_has_values locator, ["R", "G"], timeout: 500
      rescue Minitest::Assertion => e
        assert_includes e.message, "Locator expected to have Values '[\"R\", \"G\"]'"
        actual_value = '["B"]'
        assert_includes e.message, "Actual value #{actual_value}"
      end
    end
  end

  def test_to_have_values_should_fail_when_multiple_not_specified
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
      assert_raises(Playwright::Error) do
        assert_has_values locator, ["R", "G"], timeout: 500
      end
      begin
        assert_has_values locator, ["R", "G"], timeout: 500
      rescue Playwright::Error => e
        assert_includes e.message, "Error: Not a select element with a multiple attribute"
      end
    end
  end

  def test_to_have_values_should_fail_when_not_a_select_element
    with_page do |page|
      page.set_content("<input type='text'>")
      locator = page.locator("input")
      assert_raises(Playwright::Error) do
        assert_has_values locator, ["R", "G"], timeout: 500
      end
      begin
        assert_has_values locator, ["R", "G"], timeout: 500
      rescue Playwright::Error => e
        assert_includes e.message, "Error: Not a select element with a multiple attribute"
      end
    end
  end
  ##

  def test_works_with_to_be_checked
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<input type=checkbox>")
      my_checkbox = page.locator("input")
      refute_checked my_checkbox

      assert_raises(Minitest::Assertion) do
        assert_checked my_checkbox, timeout: 100
      end
      assert_checked my_checkbox, timeout: 100, checked: false

      assert_raises(Minitest::Assertion) do
        assert_checked my_checkbox, timeout: 100, checked: true
      end

      my_checkbox.check()
      assert_checked my_checkbox, timeout: 100, checked: true

      assert_raises(Minitest::Assertion) do
        assert_checked my_checkbox, timeout: 100, checked: false
      end

      assert_checked my_checkbox
    end
  end

  def test_should_work_with_to_be_enabled_to_be_disabled
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<input type=checkbox>")
      my_checkbox = page.locator("input")
      refute_disabled my_checkbox
      assert_enabled my_checkbox

      assert_raises(Minitest::Assertion) do
        assert_disabled my_checkbox, timeout: 100
      end
      my_checkbox.evaluate("e => e.disabled = true")
      assert_disabled my_checkbox

      assert_raises(Minitest::Assertion) do
        assert_enabled my_checkbox, timeout: 100
      end
    end
  end

  ## describe #to_be_enabled
  def test_to_be_enabled_to_be_disabled_should_work_with_true
    with_page do |page|
      page.set_content("<button>Text</button>")
      assert_enabled page.locator("button"), enabled: true
    end
  end

  def test_to_be_enabled_to_be_disabled_should_work_with_false
    with_page do |page|
      page.set_content("<button disabled>Text</button>")
      assert_enabled page.locator("button"), enabled: false
    end
  end

  def test_to_be_enabled_to_be_disabled_should_work_with_not_and_false
    with_page do |page|
      page.set_content("<button>Text</button>")
      refute_enabled page.locator("button"), enabled: false
    end
  end

  def test_to_be_enabled_to_be_disabled_should_work_eventually
    with_page do |page|
      page.set_content("<button disabled>Text</button>")
      page.eval_on_selector("button", <<~JS)
        button => setTimeout(() => {
          button.removeAttribute('disabled')
        }, 700)
      JS
      assert_enabled page.locator("button")
    end
  end

  def test_to_be_enabled_to_be_disabled_should_work_eventually_with_not
    with_page do |page|
      page.set_content("<button>Text</button>")
      page.eval_on_selector("button", <<~JS)
        button => setTimeout(() => {
          button.setAttribute('disabled', '')
        }, 700)
      JS
      refute_enabled page.locator("button")
    end
  end
  ##

  ## describe #to_be_editable
  def test_to_be_editable_should_work
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<input></input><button disabled>Text</button>")
      refute_editable page.locator("button")
      assert_editable page.locator("input")
      assert_raises(Minitest::Assertion) do
        assert_editable page.locator("button"), timeout: 100 
      end
    end
  end

  def test_to_be_editable_should_work_with_true
    with_page do |page|
      page.set_content("<input></input>")
      assert_editable page.locator("input"), editable: true
    end
  end

  def test_to_be_editable_should_work_with_false
    with_page do |page|
      page.set_content("<input readonly></input>")
      assert_editable page.locator("input"), editable: false
    end
  end

  def test_to_be_editable_should_work_with_not_and_false
    with_page do |page|
      page.set_content("<input></input>")
      refute_editable page.locator("input"), editable: false
    end
  end
  ##

  def test_should_work_with_to_be_empty
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<input value=text name=input1></input><input name=input2></input>")
      refute_empty page.locator("input[name=input1]")
      assert_empty page.locator("input[name=input2]")
      assert_raises(Minitest::Assertion) do
        assert_empty page.locator("input[name=input1]"), timeout: 100
      end
    end
  end

  def test_should_work_with_to_be_focused
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<input type=checkbox>")
      my_checkbox = page.locator("input")
      assert_raises(Minitest::Assertion) do
        assert_focused my_checkbox, timeout: 100
      end
      my_checkbox.focus()
      assert_focused my_checkbox
    end
  end

  def test_should_work_with_to_be_hidden_to_be_visible
    with_page do |page|
      page.goto(server_empty_page)
      page.set_content("<div style='width: 50px; height: 50px;'>Something</div>")
      my_checkbox = page.locator("div")
      assert_visible my_checkbox
      assert_raises(Minitest::Assertion) do
        assert_hidden my_checkbox, timeout: 100
      end

      my_checkbox.evaluate("e => e.style.display = 'none'")
      assert_hidden my_checkbox

      assert_raises(Minitest::Assertion) do
        assert_visible my_checkbox, timeout: 100
      end
    end
  end

  ## describe #to_be_visible
  def test_to_be_visible_should_work_with_true
    with_page do |page|
      page.set_content("<button>hello</button")
      assert_visible page.locator("button"), visible: true
    end
  end

  def test_to_be_visible_should_work_with_false
    with_page do |page|
      page.set_content("<button hidden>hello</button")
      assert_visible page.locator("button"), visible: false
    end
  end

  def test_to_be_visible_should_work_with_not_and_false
    with_page do |page|
      page.set_content("<button>hello</button")
      refute_visible page.locator("button"), visible: false
    end
  end

  def test_to_be_visible_should_work_eventually
    with_page do |page|
      page.set_content("<div></div>")
      page.eval_on_selector("div", <<~JS)
        div => setTimeout(() => {
          div.innerHTML = '<span>Hello</span>'
        }, 700)
      JS
      assert_visible page.locator("span")
    end
  end

  def test_to_be_visible_should_work_eventually_with_not
    with_page do |page|
      page.set_content("<div><span>Hello</span></div>")
      page.eval_on_selector("span", <<~JS)
        span => setTimeout(() => {
          span.textContent = ''
        }, 700)
      JS

      refute_visible page.locator("span")
    end
  end
  ##
end

# ref: https://github.com/teamcapybara/capybara/blob/master/spec/minitest_spec.rb
RSpec.describe Playwright::LocatorAssertions, sinatra: true do
  it "should support minitest" do
    output = StringIO.new
    reporter = Minitest::SummaryReporter.new(output)
    reporter.start
    MinitestTest.run @playwright_browser, @server_empty_page, reporter
    reporter.report

    output.string.scrub!
    puts output.string

    expect(output.string).to match("0 failures")
    expect(output.string).to match("0 errors")
    expect(output.string).to match("0 skips")
    expect(output.string).to match("269 assertions")
  end

  # minitest spec expectations are a thin layer around minitest assertions, so it
  # should be ok to just check the methods are present
  it "should support minitest spec" do
    expect(Playwright::Test::Assertions.instance_methods(false)).to include(
      :must_not_have_title,
      :must_not_have_url,
      :must_have_title,
      :must_have_url,
      :must_contain_text,
      :must_have_accessible_name,
      :must_have_accessible_description,
      :must_have_attribute,
      :must_have_class,
      :must_have_count,
      :must_have_css,
      :must_have_id,
      :must_have_js_property,
      :must_have_role,
      :must_have_value,
      :must_have_values,
      :must_have_text,
      :must_match_aria_snapshot,
      :must_be_attached,
      :must_be_checked,
      :must_be_disabled,
      :must_be_editable,
      :must_be_empty,
      :must_be_enabled,
      :must_be_hidden,
      :must_be_visible,
      :must_be_focused,
      :must_be_in_viewport,
      :must_not_contain_text,
      :must_not_have_accessible_name,
      :must_not_have_accessible_description,
      :must_not_have_attribute,
      :must_not_have_class,
      :must_not_have_count,
      :must_not_have_css,
      :must_not_have_id,
      :must_not_have_js_property,
      :must_not_have_role,
      :must_not_have_value,
      :must_not_have_values,
      :must_not_have_text,
      :must_not_be_attached,
      :must_not_be_checked,
      :must_not_be_disabled,
      :must_not_be_editable,
      :must_not_be_empty,
      :must_not_be_enabled,
      :must_not_be_hidden,
      :must_not_be_visible,
      :must_not_be_focused,
      :must_not_be_in_viewport,
    )
  end
end
