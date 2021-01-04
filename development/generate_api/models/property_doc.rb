require_relative './doc'

class PropertyDoc < Doc
  def type_signature
    @json['type']['name']
  end
end
