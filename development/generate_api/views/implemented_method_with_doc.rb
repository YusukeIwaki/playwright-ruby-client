class ImplementedMethodWithDoc
  # @param doc [Doc]
  # @param method [Method]
  # @param inflector [Dry::Inflector]
  def initialize(doc, method, inflector)
    @doc = doc
    @method = method
    @inflector = inflector
  end

  # @returns Enumerable<String>
  def lines
    Enumerator.new do |data|
      method_comment_lines.each(&data)
      data << "    def #{method_name_and_args}"
      data << "      wrap_channel_owner(@channel_owner.#{method_call_with_args})"
      data << '    end'
    end
  end

  private

  def method_comment_lines
    Enumerator.new do |data|
      @doc.comment&.split("\n")&.each do |line|
        data << '    #' if line.start_with?("```js")
        data << "    # #{line}"
      end
    end
  end

  def method_name_and_args
    if @doc.arg_docs.empty?
      method_name.rubyish_name
    else
      "#{method_name.rubyish_name}(#{method_args.for_method_definition.join(", ")})"
    end
  end

  def method_call_with_args
    if @doc.arg_docs.empty?
      method_name.rubyish_name
    else
      "#{method_name.rubyish_name}(#{method_args.for_method_call.join(", ")})"
    end
  end

  def method_name
    @method_name ||= MethodName.new(@inflector, @doc.name)
  end

  def method_args
    @method_args ||= MethodArgs.new(@inflector, @doc.arg_docs)
  end
end
