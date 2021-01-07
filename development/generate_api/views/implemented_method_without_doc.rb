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
    @method.name
  end

  def method_call_with_args
    @method.name
  end
end
