require_relative './doc'

class ArgDoc < Doc
  def type_signature
    @json['type']['name']
  end

  def required?
    @json['required']
  end

  def properties
    @json['type']['properties']&.map { |prop_name, json| ArgDoc.new(json) }
  end
end
