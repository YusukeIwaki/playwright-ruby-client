class ImplementedMethodWithoutDoc
  # @param method [Method]
  # @param inflector [Dry::Inflector]
  def initialize(method, inflector)
    @method = method
    @inflector = inflector
  end

  # @returns [String]
  def method_name
    @method.name
  end

  def method_args
    @method_args ||= UndocumentedMethodArgs.new(@inflector, @method.name, @method.parameters)
  end

  def has_block?
    @method.parameters.last&.first == :block
  end
end
