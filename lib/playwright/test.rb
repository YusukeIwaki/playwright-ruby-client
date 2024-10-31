module Playwright
  # this module is responsible for running playwright assertions and integrating
  # with test frameworks.
  module Test
    # ref: https://github.com/microsoft/playwright-python/blob/main/playwright/sync_api/__init__.py#L90
    class Expect
      def initialize
        @timeout_settings = TimeoutSettings.new
      end

      def call(actual, is_not)
        case actual
        when Page
          PageAssertions.new(
            PageAssertionsImpl.new(
              actual,
              @timeout_settings.timeout,
              is_not,
              nil,
            )
          )
        when Locator
          LocatorAssertions.new(
            LocatorAssertionsImpl.new(
              actual,
              @timeout_settings.timeout,
              is_not,
              nil,
            )
          )
        else
          raise NotImplementedError.new("Only locator assertions are currently implemented")
        end
      end
    end

    module Matchers
      class PlaywrightMatcher
        def initialize(expectation_method, *args, **kwargs)
          @method = expectation_method
          @args = args
          @kwargs = kwargs
        end

        def matches?(actual)
          Expect.new.call(actual, false).send(@method, *@args, **@kwargs)
          true
        rescue AssertionError => e
          @failure_message = e.full_message
          false
        end

        def does_not_match?(actual)
          Expect.new.call(actual, true).send(@method, *@args, **@kwargs)
          true
        rescue AssertionError => e
          @failure_message = e.full_message
          false
        end

        def failure_message
          @failure_message
        end

        def failure_message_when_negated
          @failure_message
        end
      end
    end

    ALL_ASSERTIONS = PageAssertions.instance_methods(false) + LocatorAssertions.instance_methods(false)

    ALL_ASSERTIONS
      .map(&:to_s)
      .each do |method_name|
        # to_be_visible => be_visible
        # not_to_be_visible => not_be_visible
        root_method_name = method_name.gsub("to_", "")
        Matchers.send(:define_method, root_method_name) do |*args, **kwargs|
          Matchers::PlaywrightMatcher.new(method_name, *args, **kwargs)
        end
      end
  end
end
