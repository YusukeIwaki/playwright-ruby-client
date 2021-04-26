module Playwright
  # wraps Concurrent::Promises.future
  class AsyncEvaluation
    def initialize(&block)
      raise ArgumentError.new('block must be given') unless block

      @future = Concurrent::Promises.future(&block)
    end

    def resolved?
      @future.resolved?
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
