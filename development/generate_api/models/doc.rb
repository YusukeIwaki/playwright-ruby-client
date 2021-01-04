class Doc
  def initialize(json)
    @json = json
  end

  # @returns [String]
  def name
    @json['name']
  end

  # @returns [String]
  def comment
    @json['comment']
  end
end
