require_relative './doc'

class ClassDoc < Doc
  def initialize(json, root:)
    super(json)
    @root = root
  end

  # @returns [true|false]
  def include_event_emitter?
    @json['extends'] == 'EventEmitter'
  end

  # @returns [ClassDoc|nil]
  def super_class_doc
    json = @root[@json['extends']]
    if json
      ClassDoc.new(json, root: @root)
    else
      nil
    end
  end

  def method_docs
    @json['methods'].map{ |name, json| MethodDoc.new(json) }
  end

  def event_docs
    @json['events'].map{ |name, json| EventDoc.new(json) }
  end

  def property_docs
    @json['properties'].map{ |name, json| PropertyDoc.new(json) }
  end
end
