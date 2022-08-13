class UndocumentedMethodArgs
  include Enumerable

  class RequiredArg
    def initialize(name)
      @name = name
    end

    attr_reader :name
  end

  class OptionalKwArg
    def initialize(name)
      @name = name
    end

    attr_reader :name
  end

  class BlockArg
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

  def each(&block)
    @args.each(&block)
  end

  def empty?
    @args.empty?
  end

  def requires_single?
    @args.count { |arg| arg.is_a?(RequiredArg) } == 1
  end
end
