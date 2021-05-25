class ApidocRenderer
  def initialize(target_classes)
    @target_classes = target_classes
    @comment_converter = CommentConverter.new(target_classes)
  end

  def render
    @target_classes.each do |target_class|
      next if target_class.is_a?(ImplementedClassWithoutDoc)

      renderer = ClassWithDocRenderer.new(target_class, @comment_converter)

      File.open(File.join('.', 'docs', 'api', "#{target_class.filename}.md"), 'w') do |f|
        renderer.render_lines.each do |line|
          f.write(line)
          f.write("\n")
        end
      end
    end
  end

  class ClassWithDocRenderer
    def initialize(class_with_doc, comment_converter)
      @class_with_doc = class_with_doc
      @comment_converter = comment_converter
      case class_with_doc
      when ImplementedClassWithDoc
        @implemented = true
      when UnimplementedClassWithDoc
        @implemented = false
      end
    end

    def render_lines
      Enumerator.new do |data|
        data << "# #{@class_with_doc.class_name}"
        data << ''
        if @implemented
          if @class_with_doc.class_comment
            data << @comment_converter.convert(@class_with_doc.class_comment)
          end
          method_lines.each do |line|
            data << line
          end
          property_lines.each do |line|
            data << line
          end
        else
          data << 'Not Implemented'
        end
      end
    end

    private def method_lines
      Enumerator.new do |data|
        @class_with_doc.methods_with_doc.each do |method_with_doc|
          next unless method_with_doc.is_a?(ImplementedMethodWithDoc)

          data << ''
          ImplementedMethodWithDocRenderer.new(method_with_doc, @comment_converter).render_lines.each do |line|
            data << line
          end
        end
      end
    end

    class ImplementedMethodWithDocRenderer
      def initialize(method_with_doc, comment_converter)
        @method_with_doc = method_with_doc
        @comment_converter = comment_converter
      end

      def render_lines
        Enumerator.new do |data|
          data << "## #{@method_with_doc.method_name}"
          data << ''
          data << '```'
          data << "def #{method_name_and_args}"
          data << '```'
          data << ''
          data << @comment_converter.convert(@method_with_doc.method_comment)
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
            joined = args_for_method_definition.join(",\n      ")
            "\n      #{joined}"
          else
            args_for_method_definition.join(", ")
          end
        end
      end
    end

    private def property_lines
      Enumerator.new do |data|
        @class_with_doc.properties_with_doc.each do |property_with_doc|
          next unless property_with_doc.is_a?(ImplementedPropertyWithDoc)

          data << ''
          ImplementedPropertyWithDocRenderer.new(property_with_doc, @comment_converter).render_lines.each do |line|
            data << line
          end
        end
      end
    end

    class ImplementedPropertyWithDocRenderer
      def initialize(property_with_doc, comment_converter)
        @property_with_doc = property_with_doc
        @comment_converter = comment_converter
      end

      def render_lines
        Enumerator.new do |data|
          data << "## #{@property_with_doc.property_name}"

          if @property_with_doc.property_comment && @property_with_doc.property_comment.size > 0
            data << ''
            data << @comment_converter.convert(@property_with_doc.property_comment)
          end
        end
      end
    end
  end

  class CommentConverter
    def initialize(target_classes)
      @target_classes = target_classes
      @class_and_methods = target_classes.flat_map do |target_class|
        if target_class.respond_to?(:methods_with_doc)
          target_class.methods_with_doc.map { |m| [target_class, m] }
        else
          []
        end
      end
      @class_and_properties = target_classes.flat_map do |target_class|
        if target_class.respond_to?(:properties_with_doc)
          target_class.properties_with_doc.map { |prop| [target_class, prop] }
        else
          []
        end
      end
    end

    def convert(content)
      %w[
        convert_class_link
        convert_method_link
        convert_property_link
        convert_event_link
        convert_js_class_link
        convert_local_md_link
      ].inject(content) do |current, method_name|
        send(method_name, current)
      end
    end

    private def convert_class_link(content)
      @target_classes.inject(content) do |current, target_class|
        current.gsub(/`#{target_class.class_name}`/, "[#{target_class.class_name}](./#{target_class.filename})")
      end
    end

    private def convert_method_link(content)
      @class_and_methods.inject(content) do |current, class_and_method|
        target_class, method_with_doc = class_and_method
        current.gsub(
          /\[`method: #{target_class.class_name}.#{method_with_doc.js_method_name}`\]/,
          "[#{target_class.class_name}##{method_with_doc.method_name}](./#{target_class.filename}##{method_with_doc.method_name})",
        )
      end
    end

    private def convert_property_link(content)
      @class_and_properties.inject(content) do |current, class_and_property|
        target_class, property_with_doc = class_and_property
        current.gsub(
          /\[`property: #{target_class.class_name}.#{property_with_doc.js_property_name}`\]/,
          "[#{target_class.class_name}##{property_with_doc.property_name}](./#{target_class.filename}##{property_with_doc.property_name})",
        )
      end
    end

    private def convert_event_link(content)
      # TODO replace '[`event: Page.dialog`]'
      content
    end

    private def convert_js_class_link(content)
      # TODO replace '[EventEmitter]'
      content.
        gsub('[Promise]', '[Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise)').
        gsub('[Serializable]', '[Serializable](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify#description)')
    end

    private def convert_local_md_link(content)
      content.gsub(/\[(.+)\]\(\.\/(.+)\.md(#.*)?\)/) { "[#{$1}](https://playwright.dev/python/docs/#{$2})"}
    end
  end
end
