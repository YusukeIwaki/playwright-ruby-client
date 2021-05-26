require_relative './experimental_flag'

class UnimplementedClassWithDoc
  include ExperimentalFlag

  # @param doc [Doc]
  # @param inflector [Dry::Inflector]
  def initialize(doc, inflector)
    @doc = doc
    @inflector = inflector
  end

  def filename
    @inflector.underscore(class_name)
  end

  # @returns [String]
  def class_name
    @doc.name
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
    @doc.comment_without_unusable_code_examples
  end

  def properties_with_doc
    @doc.property_docs.map do |property_doc|
      method_name = MethodName.new(@inflector, property_doc.name)
      UnimplementedPropertyWithDoc.new(property_doc, @inflector)
    end
  end

  def methods_with_doc
    @doc.method_docs.map do |method_doc|
      method_name = MethodName.new(@inflector, method_doc.name)
      UnimplementedMethodWithDoc.new(method_doc, @inflector)
    end
  end
end
