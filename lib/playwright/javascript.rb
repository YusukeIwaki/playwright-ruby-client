require_relative './javascript/expression'
require_relative './javascript/function'
require_relative './javascript/value_parser'
require_relative './javascript/value_serializer'

module Playwright
  module JavaScript
    # Detect if str is likely to be a function
    module_function def function?(str)
      ['async', 'function'].any? { |key| str.strip.start_with?(key) } || str.include?('=>')
    end
  end
end
