module Playwright
  class InputType
    def initialize(channel)
      @channel = channel
    end
  end

  # namespace declaration
  module InputTypes ; end

  def self.define_input_type(class_name, &block)
    klass = Class.new(InputType)
    klass.class_eval(&block) if block
    InputTypes.const_set(class_name, klass)
  end
end

# load subclasses
Dir[File.join(__dir__, 'input_types', '*.rb')].each { |f| require f }
