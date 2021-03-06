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
  def comment
    json_with_python_override['comment']
  end

  # @returns [String|nil]
  def comment_without_unusable_code_examples
    comment&.gsub(/```(js|js browser|java|python async|csharp)\n.*?```\n+/m, '')
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
