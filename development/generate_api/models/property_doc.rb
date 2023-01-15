require_relative './doc'

class PropertyDoc < Doc
  def property_type
    JsType.new(json_with_python_override['type'])
  end
end
