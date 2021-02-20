require_relative './doc'

class EventDoc < Doc
  def callback_type_signature
    json_with_python_override['type']['name']
  end
end
