require 'async/condition'

module Playwright
  # Async::Condition wrapper, providing Concurrent::Promises::Future-like APIs
  class AsyncValue
    def initialize
      @fulfilled = false
      @resolved = false
      @value = nil
    end

    def fulfill(value = nil)
      raise ArgumentError.new('already resolved') if @resolved

      @fulfilled = true
      @resolved = true
      @value = value
      @notification&.signal(@value)

      nil
    end

    class Rejection < StandardError ; end

    def reject(error)
      raise ArgumentError.new('already resolved') if @resolved

      @resolved = true
      if error.is_a?(StandardError)
        @value = error
      else
        @value = Rejection.new(error)
      end
      @notification&.signal(@value)

      nil
    end

    def resolved?
      @resolved
    end

    def fulfilled?
      @resolved && @fulfilled
    end

    def rejected?
      @resolved && !@fulfilled
    end

    def value!
      result = wait_for_value
      if result.is_a?(StandardError)
        raise result
      else
        result
      end
    end

    private def wait_for_value
      return @value if @resolved

      @notification = Async::Condition.new
      @notification.wait
    end
  end
end
