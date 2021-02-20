require_relative './doc'

class MethodDoc < Doc
  # @returns [String]
  def return_type_signature
    json_with_python_override['type']['name']
  end

  def arg_docs
    json_with_python_override['args'].
      map { |json| ArgDoc.new(json) }.
      reject { |doc| doc.langs.not_for_python? }
  end
end
