class Doc
  def initialize(json)
    @json = json
  end

  # suppress verbose printing.
  def inspect
    "#<Doc name=#{name}>"
  end

  # @returns [String]
  def kind
    json_with_python_override['kind']
  end

  # @returns [String]
  def name
    langs.alias_for_python || @json['name']
  end

  # @returns [String|nil]
  def comment_with_python_codes
    @json['spec'].filter_map do |spec|
      case spec['type']
      when 'text'
        spec['text'].gsub('↵', "\n")
      when 'code'
        case spec['codeLang']
        when 'js', 'js browser', 'java', 'csharp', 'python async'
          nil # ignore.
        else
          code = spec['lines'].join("\n")
          "```#{spec['codeLang']}\n#{code}\n```"
        end
      when 'li'
        case spec['liType']
        when 'bullet'
          "- #{spec['text']}"
        when 'ordinal'
          "1. #{spec['text']}"
        else
          raise "Unknown liType: #{spec['liType']}"
        end
      when 'note'
        "\n**NOTE**: #{spec['text']}"
      else
        raise "Unknown spec type: #{spec['type']}"
      end
    end.join("\n")
  end

  private def json_with_python_override
    langs.overrides_for_python || @json
  end

  class Langs
    def initialize(json)
      @json = json
    end

    def not_for_python?
      @json['only'] && !@json['only'].include?('python')
    end

    def only_python?
      @json['only'] && @json['only'].include?('python') && !@json['only'].include?('js')
    end

    def overrides_for_python
      @json.dig('overrides', 'python')
    end

    def alias_for_python
      @json.dig('aliases', 'python')
    end
  end

  def langs
    @langs ||= Langs.new(@json['langs'])
  end
end
