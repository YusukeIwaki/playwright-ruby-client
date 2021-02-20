require_relative './doc'

class PropertyDoc < Doc
  def type_signature
    json_with_python_override['type']['name']
  end
end
