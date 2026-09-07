# generating lib/playwright_api/ codes
class PlaywrightApiRenderer
  def initialize(target_classes)
    @target_classes = target_classes
  end

  def render
    @target_classes.each do |target_class|
      renderer = case target_class
      when ImplementedClassWithoutDoc
        ClassWithoutDocRenderer.new(target_class)
      else
        ClassWithDocRenderer.new(target_class)
      end

      File.open(File.join('.', 'lib', 'playwright_api', "#{target_class.filename}.rb"), 'w') do |f|
        renderer.render_lines.each do |line|
          f.write(line.rstrip)
          f.write("\n")
        end
      end
    end
  end

  class ClassWithoutDocRenderer
    # @param class_without_doc [ImplementedClassWithoutDoc]
    def initialize(class_without_doc)
      @class_without_doc = class_without_doc
    end

    # @returns [Enumerable<String>]
    def render_lines
      Enumerator.new do |data|
        data << 'module Playwright'
        data << "  class #{@class_without_doc.class_name} < PlaywrightApi"
        method_lines.each do |line|
          data << "  #{line}"
        end
        data << '  end'
        data << 'end'
      end
    end

    private def method_lines
      Enumerator.new do |data|
        @class_without_doc.methods_without_doc.each do |method_without_doc|
          data << ''
          MethodWithoutDocRenderer.new(method_without_doc).render_lines.each do |line|
            data << "  #{line}"
          end
        end
      end
    end
  end

  class ClassWithDocRenderer
    def initialize(class_with_doc)
      @class_with_doc = class_with_doc
      case class_with_doc
      when ImplementedClassWithDoc
        @implemented = true
      when UnimplementedClassWithDoc
        @implemented = false
      else
        raise "What is this? -> #{class_with_doc.class_name}"
      end
    end

    # @returns [Enumerable<String>]
    def render_lines
      Enumerator.new do |data|
        require_lines.each do |line|
          data << line
        end
        data << 'module Playwright'
        class_comment_lines.each do |line|
          data << "  #{line}"
        end
        data << "  class #{@class_with_doc.class_name} < #{super_class_name}"
        property_lines.each do |line|
          data << "  #{line}"
        end
        method_lines.each do |line|
          data << "  #{line}"
        end
        data << '  end'
        data << 'end'
      end
    end

    # @returns [Enumerable<String>]
    private def require_lines
      Enumerator.new do |data|
        if @class_with_doc.super_class_filename
          data << "require_relative './#{@class_with_doc.super_class_filename}.rb'"
          data << ''
        end
      end
    end

    private def super_class_name
      @class_with_doc.super_class_name || 'PlaywrightApi'
    end

    private def class_comment_lines
      Enumerator.new do |data|
        @class_with_doc.class_comment&.split("\n")&.each do |line|
          data << "# #{line}"
        end
      end
    end

    private def property_lines
      Enumerator.new do |data|
        @class_with_doc.properties_with_doc.each do |property_with_doc|
          data << ''
          PropertyWithDocRenderer.new(property_with_doc).render_lines.each do |line|
            data << "  #{line}"
          end
        end
      end
    end

    private def method_lines
      Enumerator.new do |data|
        @class_with_doc.methods_with_doc.each do |method_with_doc|
          data << ''
          MethodWithDocRenderer.new(method_with_doc).render_lines.each do |line|
            data << "  #{line}"
          end
        end

        if @implemented
          @class_with_doc.methods_without_doc.each do |method_without_doc|
            data << ''
            MethodWithoutDocRenderer.new(method_without_doc).render_lines.each do |line|
              data << "  #{line}"
            end
          end

          @class_with_doc.event_emitter_methods.each do |event_emitter_method|
            data << ''
            EventEmitterMethodRenderer.new(event_emitter_method).render_lines.each do |line|
              data << "  #{line}"
            end
          end

          if @class_with_doc.implement_event_emitter?
            data << ''
            data << '  private def event_emitter_proxy'
            data << '    @event_emitter_proxy ||= EventEmitterProxy.new(self, @impl)'
            data << '  end'
          end
        end
      end
    end
  end

  class PropertyWithDocRenderer
    def initialize(property_with_doc)
      @property_with_doc = property_with_doc
      case property_with_doc
      when ImplementedPropertyWithDoc
        @implemented = true
      when UnimplementedPropertyWithDoc
        @implemented = false
      else
        raise "What is this? -> #{property_with_doc}"
      end
    end

    # @returns [Enumerable<String>]
    def render_lines
      Enumerator.new do |data|
        property_comment_lines.each do |line|
          data << line
        end
        data << "def #{@property_with_doc.property_name} # property"
        data << "  #{body}"
        data << 'end'
      end
    end

    private def property_comment_lines
      Enumerator.new do |data|
        @property_with_doc.property_comment&.split("\n")&.each do |line|
          data << "# #{line}"
        end
      end
    end

    private def body
      if @implemented
        "wrap_impl(@impl.#{@property_with_doc.property_name})"
      else
        "raise NotImplementedError.new('#{@property_with_doc.property_name} is not implemented yet.')"
      end
    end
  end

  class MethodWithDocRenderer
    def initialize(method_with_doc)
      @method_with_doc = method_with_doc
      case method_with_doc
      when ImplementedMethodWithDoc
        @implemented = true
      when UnimplementedMethodWithDoc
        @implemented = false
      else
        raise "What is this? -> #{method_with_doc}"
      end
    end

    # @returns [Enumerable<String>]
    def render_lines
      Enumerator.new do |data|
        method_comment_lines.each do |line|
          data << line
        end
        data << "def #{method_name_and_args}"
        data << "  #{body}"
        data << 'end'
        if @method_with_doc.method_alias
          data << "alias_method :#{@method_with_doc.method_alias}, :#{@method_with_doc.method_name}"
        end
      end
    end

    private def method_comment_lines
      Enumerator.new do |data|
        @method_with_doc.method_comment&.split("\n")&.each do |line|
          data << "# #{line}"
        end
        if @method_with_doc.method_deprecated_comment
          data << '#'
          data << "# @deprecated #{@method_with_doc.method_deprecated_comment}"
        end
      end
    end

    private def method_name_and_args
      if @method_with_doc.method_args.empty?
        @method_with_doc.method_name
      else
        renderer = DocumentedArgsRenderer.new(@method_with_doc.method_args)
        "#{@method_with_doc.method_name}(#{renderer.render_for_method_definition})"
      end
    end

    private def body
      if @implemented
        "wrap_impl(@impl.#{method_call_with_args})"
      else
        "raise NotImplementedError.new('#{@method_with_doc.method_name} is not implemented yet.')"
      end
    end

    private def method_call_with_args
      if @method_with_doc.method_args.empty?
        @method_with_doc.method_name
      else
        renderer = DocumentedArgsRenderer.new(@method_with_doc.method_args)
        "#{@method_with_doc.method_name}(#{renderer.render_for_method_call})"
      end
    end
  end

  class MethodWithoutDocRenderer
    def initialize(method_without_doc)
      @method_without_doc = method_without_doc
    end

    # @returns [Enumerable<String>]
    def render_lines
      Enumerator.new do |data|
        data << '# @nodoc'
        data << "def #{method_name_and_args}"
        data << "  #{body}"
        data << 'end'
      end
    end

    private def method_name_and_args
      if @method_without_doc.method_args.empty?
        @method_without_doc.method_name
      else
        renderer = UndocumentedArgsRenderer.new(@method_without_doc.method_args)
        "#{@method_without_doc.method_name}(#{renderer.render_for_method_definition})"
      end
    end

    private def body
      "wrap_impl(@impl.#{method_call_with_args})"
    end

    private def method_call_with_args
      if @method_without_doc.method_args.empty?
        @method_without_doc.method_name
      else
        renderer = UndocumentedArgsRenderer.new(@method_without_doc.method_args)
        "#{@method_without_doc.method_name}(#{renderer.render_for_method_call})"
      end
    end
  end

  class EventEmitterMethodRenderer
    def initialize(event_emitter_method)
      @event_emitter_method = event_emitter_method
    end

    # @returns [Enumerable<String>]
    def render_lines
      Enumerator.new do |data|
        data << '# -- inherited from EventEmitter --'
        data << '# @nodoc'
        data << "def #{method_name_and_args}"
        data << "  #{body}"
        data << 'end'
      end
    end

    private def method_name_and_args
      renderer = UndocumentedArgsRenderer.new(@event_emitter_method.method_args)
      "#{@event_emitter_method.method_name}(#{renderer.render_for_method_definition})"
    end

    private def body
      "event_emitter_proxy.#{method_name_and_args}"
    end
  end

  class DocumentedArgsRenderer
    def initialize(documented_args)
      @documented_args = documented_args
    end

    def render_for_method_definition
      args_for_method_definition = @documented_args.map do |arg|
        case arg
        when DocumentedMethodArgs::RequiredArg
          arg.name
        when DocumentedMethodArgs::OptionalArg, DocumentedMethodArgs::OptionalKwArg
          "#{arg.name}: nil"
        when DocumentedMethodArgs::BlockArg
          "&block"
        else
          "What is this? -> #{arg}"
        end
      end

      if args_for_method_definition.size >= 5
        joined = args_for_method_definition.join(",\n          ")
        "\n          #{joined}"
      else
        args_for_method_definition.join(", ")
      end
    end

    def render_for_method_call
      args_for_method_call = @documented_args.map do |arg|
        case arg
        when DocumentedMethodArgs::RequiredArg
          "unwrap_impl(#{arg.name})"
        when DocumentedMethodArgs::OptionalArg, DocumentedMethodArgs::OptionalKwArg
          "#{arg.name}: unwrap_impl(#{arg.name})"
        when DocumentedMethodArgs::BlockArg
          "&wrap_block_call(block)"
        else
          "What is this? -> #{arg}"
        end
      end
      args_for_method_call.join(", ")
    end
  end

  class UndocumentedArgsRenderer
    def initialize(undocumented_args)
      @undocumented_args = undocumented_args
    end

    def render_for_method_definition
      args_for_method_definition = @undocumented_args.map do |arg|
        case arg
        when UndocumentedMethodArgs::RequiredArg
          arg.name
        when UndocumentedMethodArgs::OptionalKwArg
          "#{arg.name}: nil"
        when UndocumentedMethodArgs::BlockArg
          "&block"
        else
          "What is this? -> #{arg}"
        end
      end
      args_for_method_definition.join(", ")
    end

    def render_for_method_call
      args_for_method_call = @undocumented_args.map do |arg|
        case arg
        when UndocumentedMethodArgs::RequiredArg
          "unwrap_impl(#{arg.name})"
        when UndocumentedMethodArgs::OptionalKwArg
          "#{arg.name}: unwrap_impl(#{arg.name})"
        when UndocumentedMethodArgs::BlockArg
          "&wrap_block_call(block)"
        else
          "What is this? -> #{arg}"
        end
      end
      args_for_method_call.join(", ")
    end
  end
end
