class ApidocRenderer
  def initialize(target_classes)
    @target_classes = target_classes
  end

  def render
    @target_classes.each do |target_class|
      next if target_class.is_a?(ImplementedClassWithoutDoc)

      renderer = ClassWithDocRenderer.new(target_class)

      File.open(File.join('.', 'docs', 'api', "#{target_class.filename}.md"), 'w') do |f|
        renderer.render_lines.each do |line|
          f.write(line)
          f.write("\n")
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
      end
    end

    def render_lines
      Enumerator.new do |data|
        data << "# #{@class_with_doc.class_name}"
        data << ''
        if @implemented
          data << @class_with_doc.class_comment if @class_with_doc.class_comment
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
          ImplementedMethodWithDocRenderer.new(method_with_doc).render_lines.each do |line|
            data << line
          end
        end
      end
    end

    class ImplementedMethodWithDocRenderer
      def initialize(method_with_doc)
        @method_with_doc = method_with_doc
      end

      def render_lines
        Enumerator.new do |data|
          data << "## #{@method_with_doc.method_name}"
          data << ''
          data << '```'
          data << "def #{method_name_and_args}"
          data << '```'
          data << ''
          data << @method_with_doc.method_comment
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
          ImplementedPropertyWithDocRenderer.new(property_with_doc).render_lines.each do |line|
            data << line
          end
        end
      end
    end

    class ImplementedPropertyWithDocRenderer
      def initialize(property_with_doc)
        @property_with_doc = property_with_doc
      end

      def render_lines
        Enumerator.new do |data|
          data << "## #{@property_with_doc.property_name}"

          if @property_with_doc.property_comment && @property_with_doc.property_comment.size > 0
            data << ''
            data << @property_with_doc.property_comment
          end
        end
      end
    end
  end
end
