module Playwright
  module Utils
    module Errors
      module SafeCloseError
        # @param err [Exception]
        private def safe_close_error?(err)
          [
            'Browser has been closed',
            'Target page, context or browser has been closed',
          ].any? do |closed_message|
            err.message.end_with?(closed_message)
          end
        end
      end
    end
  end
end
