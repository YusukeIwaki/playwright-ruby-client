require_relative './method_aliasing'

class ImplementedMethodWithDoc
  include MethodAliasing

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
    @doc.comment_with_python_codes
  end

  # @returns [String|nil]
  def method_deprecated_comment
    @doc.deprecated_comment
  end

  def js_method_name
    @inflector.camelize_lower(@doc.name)
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

  def js_return_type
    @doc.return_type
  end
end
