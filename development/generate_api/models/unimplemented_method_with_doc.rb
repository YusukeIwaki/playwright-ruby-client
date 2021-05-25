class UnimplementedMethodWithDoc
  # @param doc [Doc]
  # @param inflector [Dry::Inflector]
  def initialize(doc, inflector)
    @doc = doc
    @inflector = inflector
  end

  # @returns [String|nil]
  def method_comment
    @doc.comment_without_unusable_code_examples
  end

  # @returns [String]
  def method_name
    @method_name ||= MethodName.new(@inflector, @doc.name).rubyish_name
  end

  def method_args
    @method_args ||= DocumentedMethodArgs.new(@inflector, @doc.arg_docs)
  end

  def has_block?
    nil
  end
end
