class ImplementedClassWithDoc
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
      require_lines.each(&data)
      data << 'module Playwright'
      class_comment_lines.each(&data)
      data << "  class #{class_name} < #{super_class_name || 'PlaywrightApi'}"
      property_lines.each(&data)
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
      property_coverages.each(&data)
    end
  end

  private

  # @returns [String]
  def class_name
    @doc.name
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

  # @returns [Enumerable<String>]
  def class_comment_lines
    Enumerator.new do |data|
      @doc.comment&.split("\n")&.each do |line|
        data << '  #' if line.start_with?("```js")
        data << "  # #{line}"
      end
    end
  end

  def property_lines
    Enumerator.new do |data|
      @doc.property_docs.map do |property_doc|
        method_name = MethodName.new(@inflector, property_doc.name)

        data << '' # insert blank line before definition.
        if @klass.public_instance_methods.include?(method_name.rubyish_name.to_sym)
          method = @klass.public_instance_method(method_name.rubyish_name.to_sym)
          ImplementedPropertyWithDoc.new(property_doc, method, @inflector).lines.each(&data)
        else
          UnmplementedPropertyWithDoc.new(property_doc, @inflector).lines.each(&data)
        end
      end
    end
  end

  def property_coverages
    Enumerator.new do |data|
      @doc.property_docs.map do |property_doc|
        method_name = MethodName.new(@inflector, property_doc.name)

        if @klass.public_instance_methods.include?(method_name.rubyish_name.to_sym)
          method = @klass.public_instance_method(method_name.rubyish_name.to_sym)
          ImplementedPropertyWithDoc.new(property_doc, method, @inflector).api_coverages.each(&data)
        else
          UnmplementedPropertyWithDoc.new(property_doc, @inflector).api_coverages.each(&data)
        end
      end
    end
  end

  def method_lines
    Enumerator.new do |data|
      @doc.method_docs.each do |method_doc|
        method_name = MethodName.new(@inflector, method_doc.name)

        data << '' # insert blank line before definition.
        if @klass.public_instance_methods.include?(method_name.rubyish_name.to_sym)
          method = @klass.public_instance_method(method_name.rubyish_name.to_sym)
          ImplementedMethodWithDoc.new(method_doc, method, @inflector).lines.each(&data)
        else
          UnmplementedMethodWithDoc.new(method_doc, @inflector).lines.each(&data)
        end
      end

      skip_list = (@doc.property_docs + @doc.method_docs).map do |doc|
        MethodName.new(@inflector, doc.name).rubyish_name
      end
      (@klass.public_instance_methods - @klass.superclass.public_instance_methods).each do |method_sym|
        next if skip_list.include?(method_sym.to_s)

        method = @klass.public_instance_method(method_sym)
        data << '' # insert blank line before definition.
        ImplementedMethodWithoutDoc.new(method, @inflector).lines.each(&data)
      end

      unless (@klass.public_instance_methods & Playwright::EventListenerInterface.public_instance_methods).empty?
        EventEmitterMethods.new(@inflector).lines.each(&data)
      end
    end
  end

  def method_coverages
    Enumerator.new do |data|
      @doc.method_docs.each do |method_doc|
        method_name = MethodName.new(@inflector, method_doc.name)

        if @klass.public_instance_methods.include?(method_name.rubyish_name.to_sym)
          method = @klass.public_instance_method(method_name.rubyish_name.to_sym)
          ImplementedMethodWithDoc.new(method_doc, method, @inflector).api_coverages.each(&data)
        else
          UnmplementedMethodWithDoc.new(method_doc, @inflector).api_coverages.each(&data)
        end
      end
    end
  end
end
