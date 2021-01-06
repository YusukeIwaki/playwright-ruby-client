class ImplementedClassWithoutDoc
  # @param klass [Class]
  # @param inflector [Dry::Inflector]
  def initialize(klass, inflector)
    @klass = klass
    @inflector = inflector
  end

  # @returns Enumerable<String>
  def lines
    Enumerator.new do |data|
      require_lines.each(&data)
      data << 'module Playwright'
      data << '  # @nodoc'
      data << "  class #{class_name} < #{super_class_name || 'PlaywrightApi'}"
      method_lines.each(&data)
      data << '  end'
      data << 'end'
    end
  end

  private

  # @returns [String]
  def class_name
    @inflector.demodulize(@klass)
  end

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
        data << '' # insert blank line before definition.
        ImplementedMethodWithoutDoc.new(method_sym, @inflector).lines.each(&data)
      end
    end
  end
end
