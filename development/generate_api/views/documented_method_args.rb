class DocumentedMethodArgs
  class RequiredArg
    def initialize(doc)
      @doc = doc
    end

    def options?
      false
    end

    def as_method_definition
      @doc.name
    end

    def as_method_call
      "unwrap_impl(#{@doc.name})"
    end
  end

  class OptionalArg
    def initialize(doc)
      @doc = doc
    end

    def options?
      @doc.name.end_with?('options') && @doc.type_signature == 'Object'
    end

    def optional_args
      @doc.properties&.map do |arg_doc|
        OptionalKwArg.new(arg_doc)
      end || []
    end

    def as_method_definition
      "#{@doc.name}: nil"
    end

    def as_method_call
      "#{@doc.name}: unwrap_impl(#{@doc.name})"
    end
  end

  class OptionalKwArg
    def initialize(doc)
      @doc = doc
    end

    def as_method_definition
      "#{@doc.name}: nil"
    end

    def as_method_call
      "#{@doc.name}: unwrap_impl(#{@doc.name})"
    end
  end

  class BlockArg
    def as_method_definition
      "&block"
    end

    def as_method_call
      "&wrap_block_call(block)"
    end
  end

  # @param inflector [Dry::Inflector]
  # @param arg_docs [Array<ArgDoc>]
  # @param with_block [Boolean]
  def initialize(inflector, arg_docs, with_block: false)
    @inflector = inflector

    # Some API definitions have preceding "options = {}" before python's optional parameters (ex: ElementHandle#select_option)
    # However Ruby assumes optional hash parameters put the last. So move it to the last.
    ruby_optional_args = []
    @args = arg_docs.each_with_object([]) do |arg_doc, args|
      if arg_doc.required?
        args << RequiredArg.new(arg_doc)
      elsif !arg_doc.langs.only_python?
        ruby_optional_args << OptionalArg.new(arg_doc)
      else
        args << OptionalArg.new(arg_doc)
      end
    end + ruby_optional_args
    extract_options
    if with_block
      @args << BlockArg.new
    end
  end

  def empty?
    @args.empty? && !@with_block
  end

  def single?
    @args.size == 1 && !@with_block
  end

  def setter_parameter?
    @args.count { |arg| arg.is_a?(RequiredArg) } == 1
  end

  # ['var1', 'var2', 'var3: nil', 'var4: nil']
  #
  # @returns [Arrau<String>]
  def for_method_definition
    @args.map(&:as_method_definition)
  end

  # ['var1', 'var2', 'var3: var3', 'var4: var4']
  #
  # @returns [Arrau<String>]
  def for_method_call
    @args.map(&:as_method_call)
  end

  private

  def extract_options
    return unless @args.count(&:options?) == 1
    return unless @args.last&.options?

    arg_to_extract = @args.pop
    @args.concat(arg_to_extract.optional_args)
  end
end
