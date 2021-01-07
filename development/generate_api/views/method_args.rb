require 'concurrent'

class MethodArgs
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
      @doc.name
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
      "#{@doc.name}: #{@doc.name}"
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
      "#{@doc.name}: #{@doc.name}"
    end
  end

  # @param inflector [Dry::Inflector]
  # @param arg_docs [Array<ArgDoc>]
  def initialize(inflector, arg_docs)
    @inflector = inflector
    @args = arg_docs.map do |arg_doc|
      if arg_doc.required?
        RequiredArg.new(arg_doc)
      else
        OptionalArg.new(arg_doc)
      end
    end
    extract_options
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
