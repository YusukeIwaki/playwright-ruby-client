require 'base64'

module Playwright
  define_channel_owner :WebSocketRoute do
    private def after_initialize
      @on_page_message = nil
      @on_page_close = nil
      @on_server_message = nil
      @on_server_close = nil
      @connected = false
      @server = ServerSide.new(self)

      @channel.on('messageFromPage', ->(params) {
        message = message_from_payload(params)
        if @on_page_message
          @on_page_message.call(message)
        elsif @connected
          send_to_server(params['message'], params['isBase64'])
        end
      })
      @channel.on('messageFromServer', ->(params) {
        message = message_from_payload(params)
        if @on_server_message
          @on_server_message.call(message)
        else
          send_to_page(params['message'], params['isBase64'])
        end
      })
      @channel.on('closePage', ->(params) {
        if @on_page_close
          @on_page_close.call(params['code'], params['reason'])
        else
          close_server(code: params['code'], reason: params['reason'], was_clean: params['wasClean'])
        end
      })
      @channel.on('closeServer', ->(params) {
        if @on_server_close
          @on_server_close.call(params['code'], params['reason'])
        else
          close_page(code: params['code'], reason: params['reason'], was_clean: params['wasClean'])
        end
      })
    end

    def url
      @initializer['url']
    end

    def protocols
      (@initializer['protocols'] || []).dup
    end

    def connect_to_server
      raise ::Playwright::Error.new('Already connected to the server') if @connected

      @connected = true
      @channel.async_send_message_to_server('connect').rescue { nil }
      @server
    end

    def send(*args, **kwargs)
      return __send__(*args, **kwargs) if args.first.is_a?(Symbol)

      message = args.first
      payload = payload_from_message(message)
      send_to_page(payload[:message], payload[:isBase64])
    end

    def close(code: nil, reason: nil)
      close_page(code: code, reason: reason, was_clean: true)
      nil
    end

    def on_message(handler)
      @on_page_message = handler
      nil
    end

    def on_close(handler)
      @on_page_close = handler
      nil
    end

    private def after_handle
      return if @connected

      @channel.async_send_message_to_server('ensureOpened').rescue { nil }
      nil
    end

    private def message_from_payload(params)
      if params['isBase64']
        Base64.strict_decode64(params['message'])
      else
        params['message']
      end
    end

    private def payload_from_message(message)
      if message.encoding == Encoding::BINARY
        {
          message: Base64.strict_encode64(message),
          isBase64: true,
        }
      else
        {
          message: message,
          isBase64: false,
        }
      end
    end

    private def send_to_page(message, is_base64)
      @channel.async_send_message_to_server('sendToPage', message: message, isBase64: is_base64).rescue { nil }
      nil
    end

    private def send_to_server(message, is_base64)
      @channel.async_send_message_to_server('sendToServer', message: message, isBase64: is_base64).rescue { nil }
      nil
    end

    private def close_page(code:, reason:, was_clean:)
      @channel.async_send_message_to_server('closePage', { code: code, reason: reason, wasClean: was_clean }.compact).rescue { nil }
      nil
    end

    private def close_server(code:, reason:, was_clean:)
      @channel.async_send_message_to_server('closeServer', { code: code, reason: reason, wasClean: was_clean }.compact).rescue { nil }
      nil
    end

    class ServerSide
      def initialize(route)
        @route = route
      end

      def url
        @route.url
      end

      def protocols
        @route.protocols
      end

      def connect_to_server
        raise ::Playwright::Error.new('connect_to_server must be called on the page-side WebSocketRoute')
      end

      def send(message)
        payload = @route.send(:payload_from_message, message)
        @route.send(:send_to_server, payload[:message], payload[:isBase64])
      end

      def close(code: nil, reason: nil)
        @route.send(:close_server, code: code, reason: reason, was_clean: true)
        nil
      end

      def on_message(handler)
        @route.instance_variable_set(:@on_server_message, handler)
        nil
      end

      def on_close(handler)
        @route.instance_variable_set(:@on_server_close, handler)
        nil
      end
    end
  end
end
