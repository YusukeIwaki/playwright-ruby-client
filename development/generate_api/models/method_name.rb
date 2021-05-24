class MethodName
  # @param inflector [Dry::Inflector]
  # @param js_method_name [String]
  def initialize(inflector, js_method_name)
    @inflector = inflector
    @js_method_name = js_method_name
  end

  # Some method names are already reserved in Ruby,
  # so replace them.
  DANGEROUS_NAME_MAP = {
    "send" => 'send_message',
    "tap" => 'tap_point',
  }.freeze

  def rubyish_name
    name = @inflector.underscore(@js_method_name)
    if name.start_with?("is_")
      "#{name[3..-1]}?"
    elsif name.end_with?('_')
      name[0...-1]
    else
      DANGEROUS_NAME_MAP[name] || name.gsub('$', 'S')
    end
  end
end
