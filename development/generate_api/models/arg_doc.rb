require_relative './doc'

class ArgDoc < Doc
  def arg_type
    JsType.new(json_with_python_override['type'])
  end

  def required?
    json_with_python_override['required']
  end

  def properties
    json_with_python_override['type']['properties']&.
      map { |json| ArgDoc.new(json) }.
      reject { |doc| doc.langs.not_for_python? }
  end
end
