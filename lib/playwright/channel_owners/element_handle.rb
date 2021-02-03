require_relative './js_handle'

module Playwright
  module ChannelOwners
    class ElementHandle < JSHandle
      def click(
            button: nil,
            clickCount: nil,
            delay: nil,
            force: nil,
            modifiers: nil,
            noWaitAfter: nil,
            position: nil,
            timeout: nil)

        params = {
          button: button,
          clickCount: clickCount,
          delay: delay,
          force: force,
          modifiers: modifiers,
          noWaitAfter: noWaitAfter,
          position: position,
          timeout: timeout,
        }.compact
        @channel.send_message_to_server('click', params)

        nil
      end

      def type(text, delay: nil, noWaitAfter: nil, timeout: nil)
        params = {
          text: text,
          delay: delay,
          noWaitAfter: noWaitAfter,
          timeout: timeout,
        }.compact
        @channel.send_message_to_server('type', params)

        nil
      end

      def press(key, delay: nil, noWaitAfter: nil, timeout: nil)
        params = {
          key: key,
          delay: delay,
          noWaitAfter: noWaitAfter,
          timeout: timeout,
        }.compact
        @channel.send_message_to_server('press', params)

        nil
      end

      def query_selector(selector)
        resp = @channel.send_message_to_server('querySelector', selector: selector)
        ChannelOwners::ElementHandle.from_nullable(resp)
      end

      def query_selector_all(selector)
        @channel.send_message_to_server('querySelectorAll', selector: selector).map do |el|
          ChannelOwners::ElementHandle.from(el)
        end
      end

      def eval_on_selector(selector, pageFunction, arg: nil)
        if JavaScript.function?(pageFunction)
          JavaScript::Function.new(pageFunction, arg).eval_on_selector(@channel, selector)
        else
          JavaScript::Expression.new(pageFunction).eval_on_selector(@channel, selector)
        end
      end

      def eval_on_selector_all(selector, pageFunction, arg: nil)
        if JavaScript.function?(pageFunction)
          JavaScript::Function.new(pageFunction, arg).eval_on_selector_all(@channel, selector)
        else
          JavaScript::Expression.new(pageFunction).eval_on_selector_all(@channel, selector)
        end
      end
    end
  end
end
