# generating documentation/docs/include/api_coverage.md
class ApiCoverageRenderer
  def initialize(target_classes)
    @sub_renderers = target_classes.map do |target_class|
      ClassApiCoverageRenderer.new(target_class)
    end
  end

  def render
    FileUtils.mkdir_p(File.join('.', 'documentation', 'docs', 'include'))
    File.open(File.join('.', 'documentation', 'docs', 'include', 'api_coverage.md'), 'w') do |f|
      f.write("# API coverages\n")

      @sub_renderers.each do |renderer|
        f.write("\n")
        renderer.render_lines.each do |line|
          f.write(line)
          f.write("\n")
        end
      end
    end
  end

  class ClassApiCoverageRenderer
    def initialize(target_class)
      @target_class = target_class
    end

    # @returns [Enumerable<String>]
    def render_lines
      Enumerator.new do |data|
        data << "## #{class_name}"
        data << ''
        method_names.each do |method_name|
          data << "* #{method_name}"
        end
        property_names.each do |property_name|
          data << "* #{property_name}"
        end
      end
    end

    private def class_name
      case @target_class
      when ImplementedClassWithDoc, ImplementedClassWithoutDoc
        @target_class.class_name
      when UnimplementedClassWithDoc
        "~~#{@target_class.class_name}~~"
      else
        raise "What is this? -> #{@target_class}"
      end
    end

    private def method_names
      Enumerator.new do |data|
        next unless @target_class.respond_to?(:methods_with_doc)

        @target_class.methods_with_doc.each do |method_with_doc|
          case method_with_doc
          when ImplementedMethodWithDoc
            data << method_with_doc.method_name
          when UnimplementedMethodWithDoc
            data << "~~#{method_with_doc.method_name}~~"
          else
            raise "What is this? -> #{method_with_doc}"
          end
        end
      end
    end

    private def property_names
      Enumerator.new do |data|
        next unless @target_class.respond_to?(:properties_with_doc)

        @target_class.properties_with_doc.each do |property_with_doc|
          case property_with_doc
          when ImplementedPropertyWithDoc
            data << property_with_doc.property_name
          when UnimplementedPropertyWithDoc
            data << "~~#{property_with_doc.property_name}~~"
          else
            raise "What is this? -> #{property_with_doc}"
          end
        end
      end
    end
  end
end
