require_relative './event_emitter_methods'
require_relative './experimental_flag'

class ImplementedClassWithDoc
  include EventEmitterMethods
  include ExperimentalFlag

  # @param doc [Doc]
  # @param klass [Class]
  # @param inflector [Dry::Inflector]
  def initialize(doc, klass, inflector)
    @doc = doc
    @klass = klass
    @inflector = inflector
  end

  def filename
    @inflector.underscore(class_name)
  end

  # @returns [String]
  def class_name
    @doc.name
  end

  def locator_assertions?
    @doc.name == 'LocatorAssertions'
  end

  def super_class_filename
    if super_class_name
      @inflector.underscore(super_class_name)
    else
      nil
    end
  end

  # @returns [String|nil]
  def super_class_name
    @doc.super_class_doc&.name
  end

  # @returns [String|nil]
  def class_comment
    @doc.comment_with_python_codes
  end

  def properties_with_doc
    @doc.property_docs.map do |property_doc|
      method_name = MethodName.new(@inflector, property_doc.name)

      if @klass.public_instance_methods.include?(method_name.rubyish_name.to_sym)
        method = @klass.public_instance_method(method_name.rubyish_name.to_sym)
        ImplementedPropertyWithDoc.new(property_doc, method, @inflector)
      else
        UnimplementedPropertyWithDoc.new(property_doc, @inflector)
      end
    end
  end

  def methods_with_doc
    @doc.method_docs.map do |method_doc|
      method_name = MethodName.new(@inflector, method_doc.name)

      if @klass.public_instance_methods.include?(method_name.rubyish_name.to_sym)
        method = @klass.public_instance_method(method_name.rubyish_name.to_sym)
        ImplementedMethodWithDoc.new(method_doc, method, @inflector)
      else
        UnimplementedMethodWithDoc.new(method_doc, @inflector)
      end
    end
  end

  def methods_without_doc
    ret = []

    skip_list = (@doc.property_docs + @doc.method_docs).map do |doc|
      MethodName.new(@inflector, doc.name).rubyish_name
    end
    (@klass.public_instance_methods - @klass.superclass.public_instance_methods).each do |method_sym|
      next if skip_list.include?(method_sym.to_s)

      method = @klass.public_instance_method(method_sym)
      ret << ImplementedMethodWithoutDoc.new(method, @inflector)
    end

    overridden_methods = %i(to_s inspect).freeze
    (@klass.public_instance_methods(false) & overridden_methods).each do |method_sym|
      method = @klass.public_instance_method(method_sym)
      ret << ImplementedMethodWithoutDoc.new(method, @inflector)
    end

    ret
  end
end
