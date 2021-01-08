class ImplementedMethodWithoutDoc
  # @param method [Method]
  # @param inflector [Dry::Inflector]
  def initialize(method, inflector)
    @method = method
    @inflector = inflector
  end

  # @returns Enumerable<String>
  def lines
    Enumerator.new do |data|
      data << '    # @nodoc'
      data << "    def #{method_name_and_args}"
      data << "      wrap_channel_owner(@channel_owner.#{method_call_with_args})"
      data << '    end'
    end
  end

  private

  def method_name_and_args
    if method_args.empty?
      @method.name
    else
      "#{@method.name}(#{method_args.for_method_definition.join(", ")})"
    end
  end

  def method_call_with_args
    if method_args.empty?
      @method.name
    else
      "#{@method.name}(#{method_args.for_method_call.join(", ")})"
    end
  end

  def method_args
    @method_args ||= UndocumentedMethodArgs.new(@inflector, @method.name, @method.parameters)
  end
end
