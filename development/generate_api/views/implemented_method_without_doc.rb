class ImplementedMethodWithoutDoc
    # @param name [Symbol]
    # @param inflector [Dry::Inflector]
    def initialize(name, inflector)
      @name = name
      @inflector = inflector
    end

    # @returns Enumerable<String>
    def lines
      Enumerator.new do |data|
        data << '    # @nodoc'
        data << "    def #{method_name_and_args}"
        data << "      wrap_channel_owner(@channel_owner.#{@name})"
        data << '    end'
      end
    end

    private

    def method_name_and_args
      @name
    end
  end
