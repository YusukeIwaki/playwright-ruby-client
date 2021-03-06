module Playwright
  class Error < StandardError
    # ref: https://github.com/microsoft/playwright-python/blob/0b4a980fed366c4c1dee9bfcdd72662d629fdc8d/playwright/_impl/_helper.py#L155
    def self.parse(error_payload)
      if error_payload['name'] == 'TimeoutError'
        TimeoutError.new(
          message: error_payload['message'],
          stack: error_payload['stack'].split("\n"),
        )
      else
        new(
          name: error_payload['name'],
          message: error_payload['message'],
          stack: error_payload['stack'].split("\n"),
        )
      end
    end

    # @param name [String]
    # @param message [String]
    # @param stack [Array<String>]
    def initialize(name:, message:, stack:)
      super("#{name}: #{message}")
      @name = name
      @message = message
      @stack = stack
    end
  end

  class DriverCrashedError < StandardError
    def initialize
      super("[BUG] Playwright driver is crashed!")
    end
  end

  class TimeoutError < Error
    def initialize(message:, stack: [])
      super(name: 'TimeoutError', message: message, stack: stack)
    end
  end
end
