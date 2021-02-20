module Playwright
  class SelectOptionValues
    def initialize(element: nil, index: nil, value: nil, label: nil)
      @params =
        if element
          convert(elmeent)
        elsif index
          convert(index)
        elsif value
          convert(value)
        elsif label
          convert(label)
        else
          {}
        end
    end

    # @return [Hash]
    def as_params
      @params
    end

    private def convert(values)
      return convert([values]) unless values.is_a?(Enumerable)
      return {} if values.empty?
      values.each_with_index do |value, index|
        unless values
          raise ArgumentError.new("options[#{index}]: expected object, got null")
        end
      end

      case values.first
      when ElementHandle
        { elements: values.map(&:channel) }
      when String
        { options: values.map { |value| { value: value } } }
      else
        { options: values }
      end
    end
  end
end
