class ImplementedApiClassWithDoc
  # @param doc [Doc]
  # @param klass [Class]
  # @param inflector [Dry::Inflector]
  def initialize(doc, klass, inflector)
    @doc = doc
    @klass = klass
    @inflector = inflector
  end

  # @returns Enumerable<String>
  def lines
    Enumerator.new do |data|
      data << 'module Playwright'
      class_comment_lines.each(&data)
      data << "  class #{class_name} < PlaywrightApi"
      method_lines.each(&data)
      data << '  end'
      data << 'end'
    end
  end

  def api_coverages
    Enumerator.new do |data|
      data << ''
      data << "## #{class_name}"
      data << ''
      method_coverages.each(&data)
    end
  end

  private

  # @returns [String]
  def class_name
    @doc.name
  end

  # @returns [Enumerable<String>]
  def class_comment_lines
    Enumerator.new do |data|
      @doc.comment&.split("\n")&.each do |line|
        data << '  #' if line.start_with?("```js")
        data << "  # #{line}"
      end
    end
  end

  def method_lines
    Enumerator.new do |data|
      @doc.method_docs.map do |method_doc|
        method_name = MethodName.new(@inflector, method_doc.name)

        data << '' # insert blank line before definition.
        if @klass.public_instance_methods.include?(method_name.rubyish_name.to_sym)
          method = @klass.public_instance_method(method_name.rubyish_name.to_sym)
          ImplementedApiMethod.new(method_doc, method, @inflector).lines.each(&data)
        else
          UnmplementedMethodWithDoc.new(method_doc, @inflector).lines.each(&data)
        end
      end
    end
  end

  def method_coverages
    Enumerator.new do |data|
      @doc.method_docs.map do |method_doc|
        method_name = MethodName.new(@inflector, method_doc.name)

        if @klass.public_instance_methods.include?(method_name.rubyish_name.to_sym)
          method = @klass.public_instance_method(method_name.rubyish_name.to_sym)
          ImplementedApiMethod.new(method_doc, method, @inflector).api_coverages.each(&data)
        else
          UnmplementedMethodWithDoc.new(method_doc, @inflector).api_coverages.each(&data)
        end
      end
    end
  end
end
