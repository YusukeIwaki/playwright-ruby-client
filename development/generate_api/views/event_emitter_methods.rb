class EventEmitterMethods
  def initialize(inflector)
    @inflector = inflector
  end

  # @returns Enumerable<String>
  def lines
    Enumerator.new do |data|
      Playwright::EventListenerInterface.public_instance_methods.each do |method_sym|
        method = Playwright::EventListenerInterface.public_instance_method(method_sym)
        method_line_for(method).each(&data)
      end
      event_emitter_proxy_definition.each(&data)
    end
  end

  private

  def method_line_for(method)
    args = UndocumentedMethodArgs.new(@inflector, method.name, method.parameters)
    method_name_and_args = "#{method.name}(#{args.for_method_definition.join(", ")})"

    Enumerator.new do |data|
      data << ''
      data << '    # -- inherited from EventEmitter --'
      data << '    # @nodoc'
      data << "    def #{method_name_and_args}"
      data << "      event_emitter_proxy.#{method_name_and_args}"
      data << '    end'
    end
  end

  def event_emitter_proxy_definition
    Enumerator.new do |data|
      data << ''
      data << '    private def event_emitter_proxy'
      data << '      @event_emitter_proxy ||= EventEmitterProxy.new(self, @impl)'
      data << '    end'
    end
  end
end
