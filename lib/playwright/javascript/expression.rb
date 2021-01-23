module Playwright
  module JavaScript
    class Expression
      def initialize(expression)
        @expression = expression
        @serialized_arg = ValueSerializer.new(nil).serialize
      end

      def evaluate(channel)
        value = channel.send_message_to_server(
          'evaluateExpression',
          expression: @expression,
          isFunction: false,
          arg: @serialized_arg,
        )
        ValueParser.new(value).parse
      end

      def evaluate_handle(channel)
        resp = channel.send_message_to_server(
          'evaluateExpressionHandle',
          expression: @expression,
          isFunction: false,
          arg: @serialized_arg,
        )
        ::Playwright::ChannelOwner.from(resp)
      end
    end
  end
end
