class JsType
  TYPE_MAP = {
    'any' => 'untyped',
    'boolean' => 'bool',
    'float' => 'Float',
    'function' => 'function', # defined in rbs_renderer.rb
    'int' => 'Integer',
    'null' => 'nil',
    'path' => '(String | File)',
    'string' => 'String',
    'void' => 'void',
    'Array' => 'Array[untyped]',
    'Buffer' => 'String',
    'Map' => 'Hash[untyped, untyped]',
    'Object' => 'Hash[untyped, untyped]',
    'RegExp' => 'Regexp',
    'Serializable' => 'untyped',
    'AndroidElementInfo' => 'untyped',
    'AndroidSelector' => 'untyped',
    'AndroidKey' => 'untyped',
    'EvaluationArgument' => 'untyped',
    'Video' => 'untyped',
  }.merge((ALL_TYPES + EXPERIMENTAL).map { |t| [t, t] }.to_h)

  def initialize(json)
    @json = json
  end

  def object?
    @json['name'] == 'Object'
  end

  def ruby_signature
    if @json['name'] =~ /\A".*"\z/
      return @json['name']
    end

    if @json['union'].is_a?(Array)
      if @json['union'].all? { |t| t['name'] }
        types = @json['union'].map { |t| JsType.new(t).ruby_signature }
        return "(#{types.join(' | ')})"
      end
    end

    TYPE_MAP[@json['name']] or raise "What's this? -> #{@json}"
  end
end
