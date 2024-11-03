require_relative '../example_codes'
require 'digest'

class ApidocRenderer
  def initialize(target_classes)
    @target_classes = target_classes
    @comment_converter = CommentConverter.new(target_classes)
    @example_code_converter = ExampleCodeConverter.new
  end

  def render
    @target_classes.each do |target_class|
      next if target_class.is_a?(ImplementedClassWithoutDoc)

      renderer = ClassWithDocRenderer.new(target_class, @comment_converter, @example_code_converter)

      filepath =
        if target_class.experimental?
          File.join('.', 'documentation', 'docs', 'api', 'experimental', "#{target_class.filename}.md")
        else
          File.join('.', 'documentation', 'docs', 'api', "#{target_class.filename}.md")
        end
      File.open(filepath, 'w') do |f|
        renderer.render_lines.each do |line|
          f.write(line)
          f.write("\n")
        end
      end
    end

    File.open(File.join('.', 'development', 'unimplemented_examples.md'), 'w') do |f|
      f.write("# Unimplemented examples\n\n")
      f.write("Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.\n\n")
      f.write("The examples listed below is not yet implemented, and documentation shows Python code.\n\n")
      @example_code_converter.no_impl_examples.each do |key, code|
        f.write("\n### #{key}\n")
        f.write("\n```\n#{code}\n```\n")
      end
    end
  end

  class ClassWithDocRenderer
    def initialize(class_with_doc, comment_converter, example_code_converter)
      @class_with_doc = class_with_doc
      @comment_converter = comment_converter
      @example_code_converter = example_code_converter
      case class_with_doc
      when ImplementedClassWithDoc
        @implemented = true
      when UnimplementedClassWithDoc
        @implemented = false
      end
    end

    def render_lines
      Enumerator.new do |data|
        data << "---"
        data << "sidebar_position: 10"
        data << "---"
        data << ''
        data << "# #{@class_with_doc.class_name}"
        data << ''
        if @implemented
          if @class_with_doc.class_comment
            comment = @comment_converter.convert(@class_with_doc.class_comment)
            data << @example_code_converter.convert(comment, memo: @class_with_doc.class_name)
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
        if @class_with_doc.locator_assertions?
          @class_with_doc.methods_with_doc.each do |method_with_doc|
            next unless method_with_doc.is_a?(ImplementedMethodWithDoc)

            data << ''
            ImplementedAssertionMethodWithDocRenderer.new(@class_with_doc, method_with_doc, @comment_converter, @example_code_converter).render_lines.each do |line|
              data << line
            end
          end
        else
          @class_with_doc.methods_with_doc.each do |method_with_doc|
            next unless method_with_doc.is_a?(ImplementedMethodWithDoc)

            data << ''
            ImplementedMethodWithDocRenderer.new(@class_with_doc, method_with_doc, @comment_converter, @example_code_converter).render_lines.each do |line|
              data << line
            end
          end
        end
      end
    end

    class ImplementedMethodWithDocRenderer
      def initialize(class_with_doc, method_with_doc, comment_converter, example_code_converter)
        @class_with_doc = class_with_doc
        @method_with_doc = method_with_doc
        @comment_converter = comment_converter
        @example_code_converter = example_code_converter
      end

      def render_lines
        Enumerator.new do |data|
          data << "## #{@method_with_doc.method_name}"
          data << ''
          data << '```'
          data << "def #{method_name_and_args}"
          data << '```'
          if @method_with_doc.method_alias
            data << "alias: `#{@method_with_doc.method_alias}`"
          end

          if @method_with_doc.method_deprecated_comment
            data << ''
            data << ":::warning"
            data << ''
            data << @comment_converter.convert(@method_with_doc.method_deprecated_comment)
            data << ''
            data << ":::"
          end

          data << ''
          comment = @comment_converter.convert(@method_with_doc.method_comment)
          data << @example_code_converter.convert(comment, memo: "#{@class_with_doc.class_name}##{@method_with_doc.method_name}")
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
    end

    class ImplementedAssertionMethodWithDocRenderer < ImplementedMethodWithDocRenderer
      def render_lines
        Enumerator.new do |data|
          data << "## #{@method_with_doc.method_name}"
          data << ''
          data << '```ruby'
          _method_name_and_args = method_name_and_args
          if _method_name_and_args.start_with?('to_')
            data << "expect(locator).to #{_method_name_and_args[3..-1]}"
          elsif _method_name_and_args.start_with?('not_to_')
            data << "expect(locator).not_to #{_method_name_and_args[7..-1]}"
          else
            raise "What is this? -> #{_method_name_and_args}"
          end
          data << '```'
          data << ''
          comment = @comment_converter.convert(@method_with_doc.method_comment)
          data << @example_code_converter.convert(comment, memo: "#{@class_with_doc.class_name}##{@method_with_doc.method_name}")
        end
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
            raise "What is this? -> #{arg}"
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

    private def property_lines
      Enumerator.new do |data|
        @class_with_doc.properties_with_doc.each do |property_with_doc|
          next unless property_with_doc.is_a?(ImplementedPropertyWithDoc)

          data << ''
          ImplementedPropertyWithDocRenderer.new(@class_with_doc, property_with_doc, @comment_converter, @example_code_converter).render_lines.each do |line|
            data << line
          end
        end
      end
    end

    class ImplementedPropertyWithDocRenderer
      def initialize(class_with_doc, property_with_doc, comment_converter, example_code_converter)
        @class_with_doc = class_with_doc
        @property_with_doc = property_with_doc
        @comment_converter = comment_converter
        @example_code_converter = example_code_converter
      end

      def render_lines
        Enumerator.new do |data|
          data << "## #{@property_with_doc.property_name}"

          if @property_with_doc.property_comment && @property_with_doc.property_comment.size > 0
            data << ''
            comment = @comment_converter.convert(@property_with_doc.property_comment)
            data << @example_code_converter.convert(comment, memo: "#{@class_with_doc.class_name}##{@property_with_doc.property_name}")
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
        convert_misc_static_link
        convert_content_for_ruby
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
      content.gsub(/\[([^\]]+)\]\(\.+\/([^)]+)\.md(#[^)]*)?\)/) { "[#{$1}](https://playwright.dev/python/docs/#{$2}#{$3})"}
    end

    private def convert_misc_static_link(content)
      # Some links are not property documented yet in api.json.
      # Convert statically.

      convertion = {
        "`browser.newContext()`" => "[Browser#new_context](./browser#new_context)",
        "`jsHandle.evaluate`" => "[JSHandle#evaluate](./js_handle#evaluate)",
        "`jsHandle.evaluateHandle`" => "[JSHandle#evaluate_handle](./js_handle#evaluate_handle)",
        "[`method: Page.waitForNavigation`]" => "[Page#expect_navigation](./page#expect_navigation)",
        "[`method: Frame.waitForNavigation`]" => "[Frame#expect_navigation](./frame#expect_navigation)",
        '[Playwright Tracing](../trace-viewer)' => '[Playwright Tracing](https://playwright.dev/python/docs/trace-viewer)',
        '[here](./class-tracing)' => '[here](./tracing)',
        '`redirectedTo()`' => '[redirected_to](./request#redirected_to)',
        '`redirectedFrom()`' => '[redirected_from](./request#redirected_from)',
      }
      convertion.inject(content) do |current, entry|
        str_from, str_to = entry
        current.gsub(str_from, str_to)
      end
    end

    private def convert_content_for_ruby(content)
      # Some contents are not optimized for Ruby.
      # Convert them statically

      convertion = {
        "If predicate is provided, it passes [Page](./page)\nvalue into the `predicate` function and waits for `predicate(event)` to return a truthy value." \
          => "If predicate is provided, it passes [Page](./page) value into the `predicate` and waits for `predicate.call(page)` to return a truthy value.",

        "If predicate is provided, it passes [Popup] value into the `predicate`\nfunction and waits for `predicate(page)` to return a truthy value. Will throw an error if the page is closed before the\npopup event is fired." \
          => "If predicate is provided, it passes popup [Page](./page) value into the predicate function and waits for `predicate.call(page)` to return a truthy value. Will throw an error if the page is closed before the popup event is fired.",

        "If predicate is provided, it passes [WebSocket](./web_socket) value into the\n`predicate` function and waits for `predicate(webSocket)` to return a truthy value. Will throw an error if the page is\nclosed before the WebSocket event is fired." \
        => "If predicate is provided, it passes [WebSocket](./web_socket) value into the `predicate` function and waits for `predicate.call(web_socket)` to return a truthy value. Will throw an error if the page is closed before the WebSocket event is fired.",

        " waits for `predicate(fileChooser)` to return a truthy value" \
          => " waits for `predicate.call(fileChooser)` to return a truthy value",

        "The first argument of the `callback` function contains information about the caller: `{ browserContext: BrowserContext,\npage: Page, frame: Frame }`." \
          => "The first argument of the `callback` function contains information about the caller: `{ browser_context: BrowserContext, page: Page, frame: Frame }`.",

        'protocol methods can be called with `session.send` method.' \
          => 'protocol methods can be called with `session.send_message` method.',

        "if the website `http://example.com` redirects to `https://example.com`:" \
          => "if the website `http://github.com` redirects to `https://github.com`:",

        "The [LocatorAssertions](./locator_assertions) class provides assertion methods that can be used to make assertions about the [Locator](./locator) state in the tests." \
          => "The LocatorAssertions class provides assertion methods for RSpec like `expect(locator).to have_text(\"Something\")`. Note that we have to explicitly include `playwright/test` and `Playwright::Test::Matchers` for using RSpec matchers.\n\n```ruby\nrequire 'playwright/test'\n\ndescribe 'your system testing' do\n  include Playwright::Test::Matchers\n```\n\nSince the matcher comes with auto-waiting feature, we don't have to describe trivial codes waiting for elements any more :)"
      }
      convertion.inject(content) do |current, entry|
        str_from, str_to = entry
        current.gsub(str_from, str_to)
      end
    end
  end

  class ExampleCodeConverter
    def initialize
      @code_lines = File.readlines(Kernel.const_source_location(:ExampleCodes).first)
      @methods = ExampleCodes.instance_methods.map do |sym|
        [sym.to_s, definition_for(ExampleCodes.instance_method(sym))]
      end.to_h
      @no_impl_examples = []
    end

    attr_reader :no_impl_examples

    # @param example_method [UnboundMethod]
    # @returns [String]
    #
    # This method uses AST and requires Ruby >= 2.6
    private def definition_for(example_method)
      ast = RubyVM::AbstractSyntaxTree.of(example_method)

      # def example_xxxx <-- ast.first_lineno ... index = ast.first_lineno-1
      #
      # end <-- ast.last_lineno ... index= ast.last_lineno-1

      @code_lines[ast.first_lineno..ast.last_lineno-2].map do |line|
        if line.start_with?('    ')
          line[4..-1] # remove indent
        else
          line
        end
      end.join("")
    end

    # @param content [String]
    # @returns [String]
    def convert(content, memo:)
      content.gsub(/```(py.*?)\n(.*?)```/m).with_index do |code, index|
        key = "example_#{Digest::SHA256.hexdigest(code)}"
        if @methods[key]
          "```ruby\n#{@methods[key].rstrip}\n```"
        else
          @no_impl_examples << ["#{key} (#{memo})", $2]
          "```#{$1.split(" ").first} title=\"#{key}.py\"\n#{$2}\n```"
        end
      end
    end
  end
end
