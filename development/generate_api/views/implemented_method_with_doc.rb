class ImplementedMethodWithDoc
  # @param doc [Doc]
  # @param inflector [Dry::Inflector]
  def initialize(doc, inflector)
    @doc = doc
    @inflector = inflector
  end

  # @returns Enumerable<String>
  def lines
    Enumerator.new do |data|
      method_comment_lines.each(&data)
      data << "    def #{method_name_and_args}"
      # FIXME: args and method call shoud be different implementation
      data << "      wrap_channel_owner(@channel_owner.#{method_name_and_args})"
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
    method_name = MethodName.new(@inflector, @doc.name)

    if @doc.arg_docs.empty?
      method_name.rubyish_name
    else
      "#{method_name.rubyish_name}(#{args.join(", ")})"
    end
  end

  def args
    @doc.arg_docs.map(&:name)
  end
end
