module Playwright
  # this module is responsible for running playwright assertions and integrating
  # with test frameworks.
  module Test
    # ref: https://github.com/microsoft/playwright-python/blob/main/playwright/sync_api/__init__.py#L90
    class Expect
      def initialize
        @timeout_settings = TimeoutSettings.new
      end

      def call(actual, message = nil)
        if actual.is_a?(Locator)
          LocatorAssertions.new(
            LocatorAssertionsImpl.new(
              actual,
              @timeout_settings.timeout,
              false,
              message,
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
          Expect.new.call(actual).send(@method, *@args, **@kwargs)
          true
        rescue AssertionError => e
          @failure_message = e.full_message
          false
        end

        def failure_message
          @failure_message
        end

        # we have to invert the message again here because RSpec wants to control
        # its own negation
        def failure_message_when_negated
          @failure_message.gsub("expected to", "not expected to")
        end
      end
    end

    ALL_ASSERTIONS = LocatorAssertions.instance_methods(false)

    ALL_ASSERTIONS
      .map(&:to_s)
      .each do |method_name|
        # to_be_visible => be_visible
        # not_to_be_visible => not_be_visible
        root_method_name = method_name.gsub("to_", "")
        Matchers.define_method(root_method_name) do |*args, **kwargs| 
          Matchers::PlaywrightMatcher.new(method_name, *args, **kwargs)
        end
      end
  end
end