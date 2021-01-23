module Playwright
  module JavaScript
    class Function
      def initialize(definition, arg)
        @definition = definition
        @serialized_arg = ValueSerializer.new(arg).serialize
      end

      def evaluate(channel)
        value = channel.send_message_to_server(
          'evaluateExpression',
          expression: @definition,
          isFunction: true,
          arg: @serialized_arg,
        )
        ValueParser.new(value).parse
      end

      def evaluate_handle(channel)
        resp = channel.send_message_to_server(
          'evaluateExpressionHandle',
          expression: @definition,
          isFunction: true,
          arg: @serialized_arg,
        )
        ::Playwright::ChannelOwner.from(resp)
      end
    end
  end
end
