require_relative './doc'

class EventDoc < Doc
  def callback_type_signature
    @json['type']['name']
  end
end
