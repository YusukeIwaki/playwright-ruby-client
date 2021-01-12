require_relative './doc'

class MethodDoc < Doc
  # @returns [String]
  def return_type_signature
    @json['type']['name']
  end

  def arg_docs
    @json['args'].
      map { |json| ArgDoc.new(json) }.
      reject { |doc| doc.langs.only_python? }
  end
end
