module Playwright
  # ref: https://github.com/microsoft/playwright-python/blob/main/playwright/_impl/_assertions.py
  define_api_implementation :LocatorAssertionsImpl do
    def self._define_negation(method_name)
      define_method("not_#{method_name}") do |*args, **kwargs|
        if kwargs.empty? # for Ruby < 2.7
          _not.public_send(method_name, *args)
        else
          _not.public_send(method_name, *args, **kwargs)
        end
      end
    end

    def initialize(locator, timeout, is_not, message)
      @locator = locator
      @timeout = timeout
      @is_not = is_not
      @custom_message = message
    end

    private def expect_impl(expression, expect_options, expected, message)
      expect_options[:timeout] ||= 5000
      expect_options[:isNot] = @is_not
      message.gsub!("expected to", "not expected to") if @is_not
      expect_options.delete(:useInnerText) if expect_options.key?(:useInnerText) && expect_options[:useInnerText].nil?

      result = @locator.expect(expression, expect_options)

      if result["matches"] == @is_not
        actual = result["received"]

        log =
          if result.key?("log")
            log_contents = result["log"].join("\n").strip

            "\nCall log:\n #{log_contents}"
          else
            ""
          end

        out_message =
          if @custom_message && expected
            "\nExpected value: '#{expected}'"
          elsif @custom_message
            @custom_message
          elsif message != "" && expected
            "\n#{message} '#{expected}'"
          else
            "\n#{message}"
          end

          out = "#{out_message}\nActual value #{actual} #{log}"
          raise AssertionError.new(out)
      else
        true
      end
    end

    private def _not # "not" is reserved in Ruby
      LocatorAssertionsImpl.new(
        @locator,
        @timeout,
        !@is_not,
        @message
      )
    end

    private def expected_regex(pattern, match_substring, normalize_white_space, ignore_case)
      regex = JavaScript::Regex.new(pattern)
      expected = {
        regexSource: regex.source,
        regexFlags: regex.flag,
        matchSubstring: match_substring,
        normalizeWhiteSpace: normalize_white_space,
        ignoreCase: ignore_case
      }
      expected.delete(:ignoreCase) if ignore_case.nil?

      expected
    end

    private def to_expected_text_values(items, match_substring: false, normalize_white_space: false, ignore_case: false)
      return [] unless items.respond_to?(:each)

      items.each.with_object([]) do |item, out|
        out <<
          if item.is_a?(String) && ignore_case
            {
              string: item,
              matchSubstring: match_substring,
              normalizeWhiteSpace: normalize_white_space,
              ignoreCase: ignore_case,
            }
          elsif item.is_a?(String)
            {
              string: item,
              matchSubstring: match_substring,
              normalizeWhiteSpace: normalize_white_space,
            }
          elsif item.is_a?(Regexp)
            expected_regex(item, match_substring, normalize_white_space, ignore_case)
          else
            raise ArgumentError.new("Expected value provided to assertion to be a string or regex, got #{item.class}")
          end
      end
    end

    def to_contain_text(expected, ignoreCase: nil, timeout: nil, useInnerText: nil)
      useInnerText = false if useInnerText.nil?

      if expected.respond_to?(:each)
        expected_text = to_expected_text_values(
          expected,
          match_substring: true,
          normalize_white_space: true,
          ignore_case: ignoreCase,
        )

        expect_impl(
          "to.contain.text.array",
          {
            expectedText: expected_text,
            useInnerText: useInnerText,
            timeout: timeout,
          },
          expected,
          "Locator expected to contain text"
        )
      else
        expected_text = to_expected_text_values(
          [expected],
          match_substring: true,
          normalize_white_space: true,
          ignore_case: ignoreCase,
        )

        expect_impl(
          "to.have.text",
          {
            expectedText: expected_text,
            useInnerText: useInnerText,
            timeout: timeout,
          },
          expected,
          "Locator expected to contain text"
        )
      end
    end
    _define_negation :to_contain_text

    def to_have_accessible_name(name, ignoreCase: nil, timeout: nil)
      expected_text = to_expected_text_values([name], ignore_case: ignoreCase)
      expect_impl(
        "to.have.accessible.name",
        {
          expectedText: expected_text,
          timeout: timeout,
        },
        name,
        "Locator expected to have accessible name"
      )
    end
    _define_negation :to_have_accessible_name

    def to_have_accessible_description(name, ignoreCase: nil, timeout: nil)
      expected_text = to_expected_text_values([name], ignore_case: ignoreCase)
      expect_impl(
        "to.have.accessible.description",
        {
          expectedText: expected_text,
          timeout: timeout,
        },
        name,
        "Locator expected to have accessible description"
      )
    end
    _define_negation :to_have_accessible_description

    def to_have_attribute(name, value, ignoreCase: nil, timeout: nil)
      expected_text = to_expected_text_values([value], ignore_case: ignoreCase)
      expect_impl(
        "to.have.attribute.value",
        {
          expressionArg: name,
          expectedText: expected_text,
          timeout: timeout,
        },
        value,
        "Locator expected to have attribute"
      )
    end
    _define_negation :to_have_attribute

    def to_have_class(expected, timeout: nil)
      if expected.respond_to?(:each)
        expected_text = to_expected_text_values(expected)
        expect_impl(
          "to.have.class.array",
          {
            expectedText: expected_text,
            timeout: timeout,
          },
          expected,
          "Locator expected to have class"
        )
      else
        expected_text = to_expected_text_values([expected])
        expect_impl(
          "to.have.class",
          {
            expectedText: expected_text,
            timeout: timeout,
          },
          expected,
          "Locator expected to have class"
        )
      end
    end
    _define_negation :to_have_class

    def to_have_count(count, timeout: nil)
      expect_impl(
        "to.have.count",
        {
          expectedNumber: count,
          timeout: timeout,
        },
        count,
        "Locator expected to have count"
      )
    end
    _define_negation :to_have_count

    def to_have_css(name, value, timeout: nil)
      expected_text = to_expected_text_values([value])
      expect_impl(
        "to.have.css",
        {
          expressionArg: name,
          expectedText: expected_text,
          timeout: timeout,
        },
        value,
        "Locator expected to have CSS"
      )
    end
    _define_negation :to_have_css

    def to_have_id(id, timeout: nil)
      expected_text = to_expected_text_values([id])
      expect_impl(
        "to.have.id",
        {
          expectedText: expected_text,
          timeout: timeout,
        },
        id,
        "Locator expected to have ID"
      )
    end
    _define_negation :to_have_id

    def to_have_js_property(name, value, timeout: nil)
      expect_impl(
        "to.have.property",
        {
          expressionArg: name,
          expectedValue: value,
          timeout: timeout,
        },
        value,
        "Locator expected to have JS Property"
      )
    end
    _define_negation :to_have_js_property

    def to_have_role(role, timeout: nil)
      if role.is_a?(Regexp)
        raise ArgumentError.new('"role" argument in to_have_role must be a string')
      end

      expected_text = to_expected_text_values([role])
      expect_impl(
        "to.have.role",
        {
          expectedText: expected_text,
          timeout: timeout,
        },
        role,
        "Locator expected to have accessible role",
      )
    end
    _define_negation :to_have_role

    def to_have_value(value, timeout: nil)
      expected_text = to_expected_text_values([value])

      expect_impl(
        "to.have.value",
        {
          expectedText: expected_text,
          timeout: timeout,
        },
        value,
        "Locator expected to have Value"
      )
    end
    _define_negation :to_have_value

    def to_have_values(values, timeout: nil)
      expected_text = to_expected_text_values(values)

      expect_impl(
        "to.have.values",
        {
          expectedText: expected_text,
          timeout: timeout,
        },
        values,
        "Locator expected to have Values"
      )
    end
    _define_negation :to_have_values

    def to_have_text(expected, ignoreCase: nil, timeout: nil, useInnerText: nil)
      if expected.respond_to?(:each)
        expected_text = to_expected_text_values(
          expected,
          match_substring: true,
          normalize_white_space: true,
          ignore_case: ignoreCase,
        )
        expect_impl(
          "to.have.text.array",
          {
            expectedText: expected_text,
            useInnerText: useInnerText,
            timeout: timeout,
          },
          expected,
          "Locator expected to have text"
        )
      else
        expected_text = to_expected_text_values(
          [expected],
          match_substring: true,
          normalize_white_space: true,
          ignore_case: ignoreCase,
        )
        expect_impl(
          "to.have.text",
          {
            expectedText: expected_text,
            useInnerText: useInnerText,
            timeout: timeout,
          },
          expected,
          "Locator expected to have text"
        )
      end
    end
    _define_negation :to_have_text

    def to_match_aria_snapshot(expected, timeout: nil)
      expect_impl(
        'to.match.aria',
        {
          expectedValue: expected,
          timeout: timeout,
        },
        expected,
        'Locator expected to match Aria snapshot',
      )
    end

    def to_be_attached(attached: nil, timeout: nil)
      expect_impl(
        (attached || attached.nil?) ? "to.be.attached" : "to.be.detached",
        { timeout: timeout },
        nil,
        "Locator expected to be attached"
      )
    end
    _define_negation :to_be_attached

    def to_be_checked(checked: nil, timeout: nil)
      expect_impl(
        (checked || checked.nil?) ? "to.be.checked" : "to.be.unchecked",
        { timeout: timeout },
        nil,
        "Locator expected to be checked"
      )
    end
    _define_negation :to_be_checked

    def to_be_disabled(timeout: nil)
      expect_impl(
        "to.be.disabled",
        { timeout: timeout },
        nil,
        "Locator expected to be disabled"
      )
    end
    _define_negation :to_be_disabled

    def to_be_editable(editable: nil, timeout: nil)
      expect_impl(
        (editable || editable.nil?) ? "to.be.editable" : "to.be.readonly",
        { timeout: timeout },
        nil,
        "Locator expected to be editable"
      )
    end
    _define_negation :to_be_editable

    def to_be_empty(timeout: nil)
      expect_impl(
        "to.be.empty",
        { timeout: timeout },
        nil,
        "Locator expected to be empty"
      )
    end
    _define_negation :to_be_empty

    def to_be_enabled(enabled: nil, timeout: nil)
      expect_impl(
        (enabled || enabled.nil?) ? "to.be.enabled" : "to.be.disabled",
        { timeout: timeout },
        nil,
        "Locator expected to be enabled"
      )
    end
    _define_negation :to_be_enabled

    def to_be_hidden(timeout: nil)
      expect_impl(
        "to.be.hidden",
        { timeout: timeout },
        nil,
        "Locator expected to be hidden"
      )
    end
    _define_negation :to_be_hidden

    def to_be_visible(timeout: nil, visible: nil)
      expect_impl(
        (visible || visible.nil?) ? "to.be.visible" : "to.be.hidden",
        { timeout: timeout },
        nil,
        "Locator expected to be visible"
      )
    end
    _define_negation :to_be_visible

    def to_be_focused(timeout: nil)
      expect_impl(
        "to.be.focused",
        { timeout: timeout },
        nil,
        "Locator expected to be focused"
      )
    end
    _define_negation :to_be_focused

    def to_be_in_viewport(ratio: nil, timeout: nil)
      expect_impl(
        "to.be.in.viewport",
        { timeout: timeout, expectedNumber: ratio },
        nil,
        "Locator expected to be in viewport"
      )
    end
    _define_negation :to_be_in_viewport

  end
end
