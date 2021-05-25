require_relative './event_emitter_methods'
require_relative './experimental_flag'

class ImplementedClassWithoutDoc
  include EventEmitterMethods
  include ExperimentalFlag

  # @param class_name [String]
  # @param klass [Class]
  # @param inflector [Dry::Inflector]
  def initialize(class_name, klass, inflector)
    @class_name = class_name
    @klass = klass
    @inflector = inflector
  end

  def filename
    @inflector.underscore(@class_name)
  end

  attr_reader :class_name

  def super_class_filename
    if super_class_name
      @inflector.underscore(super_class_name)
    else
      nil
    end
  end

  # @returns [String|nil]
  def super_class_name
    if [Playwright::ChannelOwner, Object].include?(@klass.superclass)
      nil
    else
      @inflector.demodulize(@klass.superclass)
    end
  end

  def methods_without_doc
    (@klass.public_instance_methods - @klass.superclass.public_instance_methods).map do |method_sym|
      method = @klass.public_instance_method(method_sym)
      ImplementedMethodWithoutDoc.new(method, @inflector)
    end
  end
end
