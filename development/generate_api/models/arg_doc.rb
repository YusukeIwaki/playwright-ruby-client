require_relative './doc'

class ArgDoc < Doc
  def type_signature
    @json['type']['name']
  end

  def required?
    @json['required']
  end

  def properties
    @json['type']['properties']&.
      map { |json| ArgDoc.new(json) }.
      reject { |doc| doc.langs.only_python? }
  end
end
