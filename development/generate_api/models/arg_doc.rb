require_relative './doc'

class ArgDoc < Doc
  def type_signature
    @json['type']['name']
  end

  def required?
    @json['required']
  end
end
