module Playwright
  # this module is responsible for running playwright assertions and integrating
  # with test frameworks.
  module Test
    @@expect_timeout = nil

    def self.expect_timeout
      @@expect_timeout || 5000 # default timeout is 5000ms
    end

    def self.expect_timeout=(timeout)
      @@expect_timeout = timeout
    end

    def self.with_timeout(expect_timeout, &block)
      old_timeout = @@expect_timeout
      @@expect_timeout = expect_timeout
      block.call
    ensure
      @@expect_timeout = old_timeout
    end

    # ref: https://github.com/microsoft/playwright-python/blob/main/playwright/sync_api/__init__.py#L90
    module Matchers
      class PlaywrightMatcher
        def initialize(expectation_method, *args, **kwargs)
          @method = expectation_method
          @args = args
          @kwargs = kwargs
        end

        def matches?(actual)
          call_assertion(actual, false)
          true
        rescue AssertionError => e
          @failure_message = e.full_message
          false
        end

        def does_not_match?(actual)
          call_assertion(actual, true)
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

        private

        def call_assertion(actual, is_not)
          args = @args
          kwargs = @kwargs
          if ['to_have_attribute', 'not_to_have_attribute'].include?(@method) && args.length == 2 && !kwargs.key?(:value)
            args = [args.first]
            kwargs = kwargs.merge(value: @args.last)
          end
          assertions_for(actual, is_not).send(@method, *args, **kwargs)
        end

        def assertions_for(actual, is_not)
          if actual.respond_to?(:_assertions)
            actual._assertions(::Playwright::Test.expect_timeout, is_not, nil)
          else
            raise NotImplementedError.new("Only page and locator assertions are currently implemented")
          end
        end
      end

      (PageAssertions.instance_methods(false) + LocatorAssertions.instance_methods(false)).each do |method_name_sym|
        # to_be_visible => be_visible
        # not_to_be_visible => not_be_visible
        method_name = method_name_sym.to_s
        define_method(method_name.gsub("to_", "")) do |*args, **kwargs|
          Matchers::PlaywrightMatcher.new(method_name, *args, **kwargs)
        end
      end
    end
  end
end
