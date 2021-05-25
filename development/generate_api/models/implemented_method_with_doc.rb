class ImplementedMethodWithDoc
  # @param doc [Doc]
  # @param method [Method]
  # @param inflector [Dry::Inflector]
  def initialize(doc, method, inflector)
    @doc = doc
    @method = method
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
    @method_args ||= DocumentedMethodArgs.new(@inflector, @doc.arg_docs, with_block: has_block?)
  end

  def has_block?
    @method.parameters.last&.first == :block
  end
end
