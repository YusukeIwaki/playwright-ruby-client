class ImplementedApiClassWithoutDoc
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
      data << 'module Playwright'
      data << '  # @nodoc'
      data << "  class #{@class_name} < PlaywrightApi"
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

  def method_lines
    Enumerator.new do |data|
      (@klass.public_instance_methods - @klass.superclass.public_instance_methods).each do |method_sym|
        method = @klass.public_instance_method(method_sym)

        data << '' # insert blank line before definition.
        ImplementedMethodWithoutDoc.new(method, @inflector).lines.each(&data)
      end
    end
  end
end
