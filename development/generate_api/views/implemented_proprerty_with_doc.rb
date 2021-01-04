class ImplementedPropertyWithDoc
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
      data << "    def #{property_name} # property"
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

  def property_name
    MethodName.new(@inflector, @doc.name).rubyish_name
  end
end
