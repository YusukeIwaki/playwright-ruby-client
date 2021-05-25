class UnimplementedPropertyWithDoc
  # @param doc [Doc]
  # @param inflector [Dry::Inflector]
  def initialize(doc, inflector)
    @doc = doc
    @inflector = inflector
  end

  def property_comment
    @doc.comment_without_unusable_code_examples
  end

  # @returns [String]
  def property_name
    MethodName.new(@inflector, @doc.name).rubyish_name
  end
end
