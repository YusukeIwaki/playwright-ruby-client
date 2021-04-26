module Playwright
  # wraps Concurrent::Promises.resolvable_future
  class AsyncValue
    def initialize
      @future = Concurrent::Promises.resolvable_future
      @resolved = false
    end

    class AlreadyResolvedError < StandardError ; end

    def fulfill(value = nil)
      raise AlreadyResolvedError.new('already resolved') if @resolved

      @resolved = true
      @future.fulfill(value)

      nil
    end

    def reject(error)
      raise AlreadyResolvedError.new('already resolved') if @resolved

      @resolved = true
      @future.reject(error)

      nil
    end

    def resolved?
      @resolved
    end

    def fulfilled?
      @future.fulfilled?
    end

    def rejected?
      @future.rejected?
    end

    def value!
      @future.value!
    end
  end
end
