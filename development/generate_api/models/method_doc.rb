require_relative './doc'

class MethodDoc < Doc
  # @returns [String]
  def return_type
    JsType.new(json_with_python_override['type'])
  end

  def arg_docs
    json_with_python_override['args'].
      map { |json| ArgDoc.new(json) }.
      reject { |doc| doc.langs.not_for_python? }
  end
end
