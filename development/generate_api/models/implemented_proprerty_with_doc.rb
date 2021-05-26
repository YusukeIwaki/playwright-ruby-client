class ImplementedPropertyWithDoc
  # @param doc [Doc]
  # @param method [Method]
  # @param inflector [Dry::Inflector]
  def initialize(doc, method, inflector)
    @doc = doc
    @method = method
    @inflector = inflector
  end

  def property_comment
    @doc.comment_without_unusable_code_examples
  end

  def js_property_name
    @doc.name
  end

  # @returns [String]
  def property_name
    @property_name ||= MethodName.new(@inflector, @doc.name).rubyish_name
  end
end
