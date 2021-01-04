class MethodName
  def initialize(inflector, js_method_name)
    @inflector = inflector
    @js_method_name = js_method_name
  end

  attr_reader :js_method_name

  # Some method names are already reserved in Ruby,
  # so replace them.
  DANGEROUS_NAME_MAP = {
    "type" => 'type_text',
    "send" => 'send_message',
    "tap" => 'tap_point',
  }.freeze

  def rubyish_name
    name = @inflector.underscore(@js_method_name)
    if name.start_with?("is_")
      "#{name[3..-1]}?"
    else
      DANGEROUS_NAME_MAP[name] || name.gsub('$', 'S')
    end
  end
end
