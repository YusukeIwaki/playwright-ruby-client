require 'concurrent'

class UndocumentedMethodArgs
  class RequiredArg
    def initialize(name)
      @name = name
    end

    def as_method_definition
      @name
    end

    def as_method_call
      "unwrap_impl(#{@name})"
    end
  end

  class OptionalKwArg
    def initialize(name)
      @name = name
    end

    def as_method_definition
      "#{@name}: nil"
    end

    def as_method_call
      "#{@name}: unwrap_impl(#{@name})"
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
  # @param method_name [String]
  # @param parameters [Array<Array>]
  # @param with_block [Boolean]
  def initialize(inflector, method_name, parameters)
    @inflector = inflector
    @method_name = method_name
    @args = parameters.map do |parameter|
      # @see https://docs.ruby-lang.org/ja/latest/class/Method.html#I_PARAMETERS
      case parameter.first
      when :req
        RequiredArg.new(parameter.last)
      when :opt
        raise 'Hey developer! We should not use optional arg for keeping the simplicity of generate_api module.'
      when :rest
        raise "Hey developer! We should not use \"*arg\" for keeping the simplicity of generate_api module."
      when :keyreq
        raise "Hey developer! We should not use keyword argument without default value for keeping the simplicity of generate_api module: #{parameter}"
      when :key
        OptionalKwArg.new(parameter.last)
      when :keyrest
        raise "Hey developer! We should not use \"**options\" for keeping the simplicity of generate_api module"
      when :block
        BlockArg.new
      else
        raise "BUG -- something is wrong. Unknown parameter type."
      end
    rescue
      puts "error on handling #{@method_name} -> #{parameter.last}"
      raise
    end
  end

  def empty?
    @args.empty?
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
end
