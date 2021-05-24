module EventEmitterMethods
  def implement_event_emitter?
    !(@klass.public_instance_methods & Playwright::EventListenerInterface.public_instance_methods).empty?
  end

  def event_emitter_methods
    return [] unless implement_event_emitter?

    Playwright::EventListenerInterface.public_instance_methods.map do |method_sym|
      method = Playwright::EventListenerInterface.public_instance_method(method_sym)
      ImplementedMethodWithoutDoc.new(method, @inflector)
    end
  end
end
