class UnimplementedClassWithDoc
  # @param doc [Doc]
  # @param klass [Class]
  # @param inflector [Dry::Inflector]
  def initialize(doc, inflector)
    @doc = doc
    @inflector = inflector
  end

  # @returns Enumerable<String>
  def lines
    Enumerator.new do |data|
      require_lines.each(&data)
      data << 'module Playwright'
      class_comment_lines.each(&data)
      data << "  class #{class_name_with_extension}"
      property_lines.each(&data)
      method_lines.each(&data)
      data << '  end'
      data << 'end'
    end
  end

  private

  # @returns [Enumerable<String>]
  def class_comment_lines
    Enumerator.new do |data|
      @doc.comment&.split("\n")&.each do |line|
        data << '  #' if line.start_with?("```js")
        data << "  # #{line}"
      end
    end
  end

  # @returns [String|nil]
  def super_class_name
    @doc.super_class_doc&.name
  end

  # @returns [Enumerable<String>]
  def require_lines
    Enumerator.new do |data|
      if super_class_name
        data << "require_relative './#{@inflector.underscore(super_class_name)}.rb'"
        data << ''
      end
    end
  end

  # @returns [String]
  def class_name_with_extension
    [@doc.name ,super_class_name].compact.join(" < ")
  end

  def property_lines
    Enumerator.new do |data|
      @doc.property_docs.map do |property_doc|
        method_name = MethodName.new(@inflector, property_doc.name)

        data << '' # insert blank line before definition.
        UnmplementedPropertyWithDoc.new(property_doc, @inflector).lines.each(&data)
      end
    end
  end

  def method_lines
    Enumerator.new do |data|
      @doc.method_docs.map do |method_doc|
        method_name = MethodName.new(@inflector, method_doc.name)

        data << '' # insert blank line before definition.
        UnmplementedMethodWithDoc.new(method_doc, @inflector).lines.each(&data)
      end
    end
  end
end
