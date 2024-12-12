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
          raise NotImplementedError.new("Only locator and page assertions are currently implemented")
        end
      end
    end

    ALL_ASSERTIONS = PageAssertions.instance_methods(false) + LocatorAssertions.instance_methods(false)

    # RSpec compatible matchers
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

      ALL_ASSERTIONS
        .map(&:to_s)
        .each do |method_name|
          # to_be_visible => be_visible
          # not_to_be_visible => not_be_visible
          rspec_expectation_name = method_name.gsub("to_", "")
          define_method rspec_expectation_name do |*args, **kwargs|
            PlaywrightMatcher.new(method_name, *args, **kwargs)
          end
        end 
    end

    # Minitest compatible assertions and expectations
    module Assertions
      # in the case that minitest is not installed, do nothing
      minitest_installed = begin
        require "minitest"
        require "minitest/spec"
        true
      rescue LoadError
        false
      end

      if minitest_installed
        ALL_ASSERTIONS
          .map(&:to_s)
          .each do |method_name|
            # Minitest
            minitest_assertion_name = method_name
              .gsub("not_to_", "refute_")
              .gsub("to_", "assert_")
              .gsub("_have_", "_has_")
              .gsub("_be_", "_")

            define_method minitest_assertion_name do |actual, *args, **kwargs|
              begin
                Expect.new.call(actual, false).send(method_name, *args, **kwargs)
                assert true
              rescue AssertionError => e
                assert false, e.full_message
              end
            end

            minitest_expectation_name = method_name
              .gsub("not_to_", "must_not_")
              .gsub("to_", "must_")
            infect_an_assertion minitest_assertion_name, minitest_expectation_name, true
          end
      end
    end
  end
end
