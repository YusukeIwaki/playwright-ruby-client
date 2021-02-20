require_relative './js_handle'

module Playwright
  module ChannelOwners
    class ElementHandle < JSHandle
      def as_element
        self
      end

      def owner_frame
        resp = @channel.send_message_to_server('ownerFrame')
        ChannelOwners::Frame.from_nullable(resp)
      end

      def content_frame
        resp = @channel.send_message_to_server('contentFrame')
        ChannelOwners::Frame.from_nullable(resp)
      end

      def get_attribute(name)
        @channel.send_message_to_server('getAttribute', name: name)
      end

      def text_content
        @channel.send_message_to_server('textContent')
      end

      def inner_text
        @channel.send_message_to_server('innerText')
      end

      def inner_html
        @channel.send_message_to_server('innerHTML')
      end

      def checked?
        @channel.send_message_to_server('isChecked')
      end

      def disabled?
        @channel.send_message_to_server('isDisabled')
      end

      def editable?
        @channel.send_message_to_server('isEditable')
      end

      def enabled?
        @channel.send_message_to_server('isEnabled')
      end

      def hidden?
        @channel.send_message_to_server('isHidden')
      end

      def visible?
        @channel.send_message_to_server('isVisible')
      end

      def dispatch_event(type, eventInit: nil)
        params = {
          type: type,
          eventInit: JavaScript::ValueSerializer.new(eventInit).serialize,
        }.compact
        @channel.send_message_to_server('dispatchEvent', params)

        nil
      end

      def scroll_into_view_if_needed(timeout: nil)
        params = {
          timeout: timeout,
        }.compact
        @channel.send_message_to_server('scrollIntoViewIfNeeded', params)

        nil
      end

      def hover(force: nil, modifiers: nil, position: nil, timeout: nil)
        params = {
          force: force,
          modifiers: modifiers,
          position: position,
          timeout: timeout,
        }
        @channel.send_message_to_server('hover', params)

        nil
      end

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

      def dblclick(
            button: nil,
            delay: nil,
            force: nil,
            modifiers: nil,
            noWaitAfter: nil,
            position: nil,
            timeout: nil)

        params = {
          button: button,
          delay: delay,
          force: force,
          modifiers: modifiers,
          noWaitAfter: noWaitAfter,
          position: position,
          timeout: timeout,
        }.compact
        @channel.send_message_to_server('dblclick', params)

        nil
      end

      def select_option(
            element: nil,
            index: nil,
            value: nil,
            label: nil,
            noWaitAfter: nil,
            timeout: nil)
        base_params = SelectOptionValues.new(
          element: element,
          index: index,
          value: value,
          label: label,
        ).as_params
        params = base_params + { noWaitAfter: noWaitAfter, timeout: timeout }.compact
        @channel.send_message_to_server('selectOption', params)

        nil
      end

      def tap_point(
            force: nil,
            modifiers: nil,
            noWaitAfter: nil,
            position: nil,
            timeout: nil)

        params = {
          force: force,
          modifiers: modifiers,
          noWaitAfter: noWaitAfter,
          position: position,
          timeout: timeout,
        }.compact
        @channel.send_message_to_server('tap', params)

        nil
      end

      def fill(value, noWaitAfter: nil, timeout: nil)
        params = {
          value: value,
          noWaitAfter: noWaitAfter,
          timeout: timeout,
        }
        @channel.send_message_to_server('fill', params)

        nil
      end

      def select_text(timeout: nil)
        params = { timeout: timeout }.compact
        @channel.send_message_to_server('selectText', params)

        nil
      end

      def set_input_files(files, noWaitAfter: nil, timeout: nil)
        file_payloads = InputFiles.new(files).as_params
        params = { files: file_payloads, noWaitAfter: noWaitAfter, timeout: timeout }.compact
        @channel.send_message_to_server('setInputFiles', params)

        nil
      end

      def focus
        @channel.send_message_to_server('focus')

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

      def check(force: nil, noWaitAfter: nil, timeout: nil)
        params = {
          force: force,
          noWaitAfter:  noWaitAfter,
          timeout: timeout,
        }.compact
        @channel.send_message_to_server('check', params)

        nil
      end

      def uncheck(force: nil, noWaitAfter: nil, timeout: nil)
        params = {
          force: force,
          noWaitAfter:  noWaitAfter,
          timeout: timeout,
        }.compact
        @channel.send_message_to_server('uncheck', params)

        nil
      end

      def bounding_box
        @channel.send_message_to_server('boundingBox')
      end

      def screenshot(
        omitBackground: nil,
        path: nil,
        quality: nil,
        timeout: nil,
        type: nil)

        params = {
          omitBackground: omitBackground,
          path: path,
          quality: quality,
          timeout: timeout,
          type: type,
        }.compact
        encoded_binary = @channel.send_message_to_server('screenshot', params)
        decoded_binary = Base64.strict_decode64(encoded_binary)
        if path
          File.open(path, 'wb') do |f|
            f.write(decoded_binary)
          end
        end
        decoded_binary
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

      def wait_for_element_state(state, timeout: nil)
        params = { state: state, timeout: timeout }.compact
        @channel.send_message_to_server('waitForElementState', params)

        nil
      end

      def wait_for_selector(selector, state: nil, timeout: nil)
        params = { selector: selector, state: state, timeout: timeout }.compact
        resp = @channel.send_message_to_server('waitForSelector', params)

        ChannelOwners::ElementHandle.from_nullable(resp)
      end
    end
  end
end
