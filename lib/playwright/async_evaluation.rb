require 'async/condition'

module Playwright
  # Async { } wrapper, providing Concurrent::Promises::Future-like APIs
  class AsyncEvaluation
    def initialize(&block)
      raise ArgumentError.new('block must be given') unless block

      @task = Async(&block)
    end

    def resolved?
      %i(complete stopped failed).include?(@task.status)
    end

    def fulfilled?
      @task.status == :complete
    end

    def rejected?
      %i(stopped failed).include?(@task.status)
    end

    def value!
      @task.result
    end
  end
end
