# generates sig/*.rbs files
class RbsRenderer
  def initialize(target_classes)
    @target_classes = target_classes
  end

  def render
    File.open(File.join('.', 'sig', 'playwright.rbs'), 'w') do |f|
      render_lines.each do |line|
        f.write(line.rstrip)
        f.write("\n")
      end
    end
  end

  private

  def render_lines
    Enumerator.new do |data|
      data << 'module Playwright'
      custom_type_lines.each do |line|
        data << "  #{line}"
      end
      data << ''

      @target_classes.each do |target_class|
        next unless target_class.is_a?(ImplementedClassWithDoc)

        ClassRbsRenderer.new(target_class).render_lines.each { |line| data << "  #{line}" }
      end
      data << '  def self.create: (playwright_cli_executable_path: String) { (Playwright) -> void } -> void'
      data << 'end'
    end
  end

  def custom_type_lines
    Enumerator.new do |data|
      data << 'type function = String'
    end
  end

  class ClassRbsRenderer
    def initialize(class_with_doc)
      @class_with_doc = class_with_doc
    end

    # @returns [Enumerable<String>]
    def render_lines
      Enumerator.new do |data|
        data << "class #{class_declaration}"
        blank_required = false
        method_lines.each do |line|
          blank_required = true
          data << "  #{line}"
        end
        property_lines.each do |line|
          data << '' if blank_required
          blank_required = false
          data << "  #{line}"
        end
        data << 'end'
        data << ''
      end
    end

    private

    def class_declaration
      if @class_with_doc.super_class_name
        "#{@class_with_doc.class_name} < #{@class_with_doc.super_class_name}"
      else
        @class_with_doc.class_name
      end
    end

    private def method_lines
      Enumerator.new do |data|
        @class_with_doc.methods_with_doc.each do |method_with_doc|
          next unless method_with_doc.is_a?(ImplementedMethodWithDoc)

          MethodRbsRenderer.new(method_with_doc).render_lines.each do |line|
            data << line
          end
        end
      end
    end

    private def property_lines
      Enumerator.new do |data|
        @class_with_doc.properties_with_doc.each do |property_with_doc|
          next unless property_with_doc.is_a?(ImplementedPropertyWithDoc)

          PropertyRbsRenderer.new(property_with_doc).render_lines.each do |line|
            data << line
          end
        end
      end
    end
  end

  class MethodRbsRenderer
    def initialize(method_with_doc)
      @method_with_doc = method_with_doc
    end

    def render_lines
      Enumerator.new do |data|
        method_name_and_alias_name.each do |name|
          data << "def #{name}:#{method_args} -> #{return_type}"
        end
      end
    end

    private def method_name_and_alias_name
      Enumerator.new do |name|
        name << @method_with_doc.method_name
        if @method_with_doc.method_alias
          name << @method_with_doc.method_alias
        end
      end
    end

    private def method_args
      if @method_with_doc.method_args.empty?
        ''
      else
        renderer = DocumentedArgsRenderer.new(@method_with_doc.method_args)
        if @method_with_doc.has_block?
          " (#{renderer.render_for_method_definition}) #{block_definition}"
        else
          " (#{renderer.render_for_method_definition})"
        end
      end
    end

    private def return_type
      @method_with_doc.js_return_type&.ruby_signature || 'void'
    end

    private def block_definition
      case @method_with_doc.method_name
      when /\Aexpect_/
        '{ () -> void }'
      when 'launch' # BrowserType#launch
        '?{ (Browser) -> untyped }'
      when 'new_page' # Browser#new_page, BrowserContext#new_page
        '?{ (Page) -> untyped }'
      when 'new_context' # Browser#new_context
        '?{ (BrowserContext) -> untyped }'
      else
        "?{ (untyped) -> untyped }"
      end
    end

    class DocumentedArgsRenderer
      def initialize(documented_args)
        @documented_args = documented_args
      end

      RESERVED_NAME_MAP = {
        'type' => 'type_',
      }

      # "Integer arg_name"
      # "?arg_name: Integer"
      def render_for_method_definition
        args_for_method_definition = @documented_args.filter_map do |arg|
          case arg
          when DocumentedMethodArgs::RequiredArg
            "#{arg.js_type.ruby_signature} #{RESERVED_NAME_MAP[arg.name] || arg.name}"
          when DocumentedMethodArgs::OptionalArg, DocumentedMethodArgs::OptionalKwArg
            "?#{arg.name}: #{arg.js_type.ruby_signature}"
          when DocumentedMethodArgs::BlockArg
            nil
          else
            raise "What is this? -> #{arg}"
          end
        end

        args_for_method_definition.join(", ")
      end
    end
  end

  class PropertyRbsRenderer
    def initialize(property_with_doc)
      @property_with_doc = property_with_doc
    end

    def render_lines
      Enumerator.new do |data|
        data << "attr_reader #{@property_with_doc.property_name}: #{property_type}"
      end
    end

    private def property_type
      @property_with_doc.js_property_type.ruby_signature
    end
  end
end
