class Doc
  def initialize(json)
    @json = json
  end

  # @returns [String]
  def kind
    @json['kind']
  end

  # @returns [String]
  def name
    langs.alias_for_python || @json['name']
  end

  # @returns [String]
  def comment
    @json['comment']
  end

  class Langs
    def initialize(json)
      @json = json
    end

    def only_js?
      @json['only'] && @json['only'].include?('js')
    end

    def only_python?
      @json['only'] && @json['only'].include?('python')
    end

    def alias_for_python
      @json.dig('aliases', 'python')
    end
  end

  def langs
    @langs ||= Langs.new(@json['langs'])
  end
end
