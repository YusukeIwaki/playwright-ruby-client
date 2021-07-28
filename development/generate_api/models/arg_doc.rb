require_relative './doc'

class ArgDoc < Doc
  def type_signature
    json_with_python_override['type']['name']
  end

  def required?
    json_with_python_override['required']
  end

  def properties
    json_with_python_override['type']['properties']&.
      map { |json| ArgDoc.new(json) }.
      reject { |doc| doc.langs.not_for_python? }.
      uniq { |doc| doc.name } # TEMPORARY WORKAROUND for Locator#elementHandle(timeout, timeout)
  end
end
