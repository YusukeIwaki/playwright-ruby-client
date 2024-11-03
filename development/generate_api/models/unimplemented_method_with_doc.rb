require_relative './method_aliasing'

class UnimplementedMethodWithDoc
  include MethodAliasing

  # @param doc [Doc]
  # @param inflector [Dry::Inflector]
  def initialize(doc, inflector)
    @doc = doc
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
    @method_args ||= DocumentedMethodArgs.new(@inflector, @doc.arg_docs)
  end

  def has_block?
    nil
  end
end
