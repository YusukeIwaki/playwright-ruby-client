require_relative './doc'

class EventDoc < Doc
  def callback_type
    JsType.new(json_with_python_override['type'])
  end
end
