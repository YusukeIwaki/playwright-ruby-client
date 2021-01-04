class UnmplementedMethodWithDoc
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
      data << "      raise NotImplementedError.new('#{method_name} is not implemented yet.')"
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
      method_name
    else
      "#{method_name}(#{args.join(", ")})"
    end
  end

  def method_name
    @method_name ||= MethodName.new(@inflector, @doc.name).rubyish_name
  end

  def args
    @doc.arg_docs.map(&:name)
  end
end
