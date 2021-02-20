require_relative './doc'

class ClassDoc < Doc
  def initialize(json, root:)
    super(json)
    @root = root
  end

  # @returns [ClassDoc|nil]
  def super_class_doc
    json = @root.find { |json| json['name'] == @json['extends'] }
    if json
      ClassDoc.new(json, root: @root)
    else
      nil
    end
  end

  def method_docs
    json_with_python_override['members'].
      select { |json| json['kind'] == 'method' }.
      map{ |json| MethodDoc.new(json) }.
      reject { |doc| doc.langs.not_for_python? }
  end

  def event_docs
    json_with_python_override['members'].
      select { |json| json['kind'] == 'event' }.
      map{ |json| MethodDoc.new(json) }.
      reject { |doc| doc.langs.not_for_python? }
  end

  def property_docs
    json_with_python_override['members'].
      select { |json| json['kind'] == 'property' }.
      map{ |json| MethodDoc.new(json) }.
      reject { |doc| doc.langs.not_for_python? }
  end
end
