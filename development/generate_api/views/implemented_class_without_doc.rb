class ImplementedClassWithoutDoc
  # @param class_name [String]
  # @param klass [Class]
  # @param inflector [Dry::Inflector]
  def initialize(class_name, klass, inflector)
    @class_name = class_name
    @klass = klass
    @inflector = inflector
  end

  # @returns Enumerable<String>
  def lines
    Enumerator.new do |data|
      require_lines.each(&data)
      data << 'module Playwright'
      data << '  # @nodoc'
      data << "  class #{@class_name} < #{super_class_name || 'PlaywrightApi'}"
      method_lines.each(&data)
      data << '  end'
      data << 'end'
    end
  end

  def api_coverages
    Enumerator.new do |data|
      # nothing
    end
  end

  private

  # @returns [String|nil]
  def super_class_name
    if [Playwright::ChannelOwner, Object].include?(@klass.superclass)
      nil
    else
      @inflector.demodulize(@klass.superclass)
    end
  end

  # @returns [Enumerable<String>]
  def require_lines
    Enumerator.new do |data|
      if super_class_name
        data << "require_relative './#{@inflector.underscore(super_class_name)}.rb'"
        data << ''
      end
    end
  end

  def method_lines
    Enumerator.new do |data|
      (@klass.public_instance_methods - @klass.superclass.public_instance_methods).each do |method_sym|
        method = @klass.public_instance_method(method_sym)
        data << '' # insert blank line before definition.
        ImplementedMethodWithoutDoc.new(method, @inflector).lines.each(&data)
      end

      unless (@klass.public_instance_methods & Playwright::EventListenerInterface.public_instance_methods).empty?
        EventEmitterMethods.new(@inflector).lines.each(&data)
      end
    end
  end
end
