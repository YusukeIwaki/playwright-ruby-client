require 'base64'

module Playwright
  define_channel_owner :WebSocket do
    private def after_initialize
      @closed = false

      @channel.on('frameSent', -> (params) {
        on_frame_sent(params['opcode'], params['data'])
      })
      @channel.on('frameReceived', -> (params) {
        on_frame_received(params['opcode'], params['data'])
      })
      @channel.on('socketError', -> (params) {
        emit(Events::WebSocket::Error, params['error'])
      })
      @channel.on('close', -> (_) { on_close })
    end

    def url
      @initializer['url']
    end

    class SocketClosedError < StandardError
      def initialize
        super('Socket closed')
      end
    end

    class SocketError < StandardError
      def initialize
        super('Socket error')
      end
    end

    class PageClosedError < StandardError
      def initialize
        super('Page closed')
      end
    end

    def expect_event(event, predicate: nil, timeout: nil, &block)
      wait_helper = WaitHelper.new
      wait_helper.reject_on_timeout(timeout || @parent.send(:timeout_settings).timeout, "Timeout while waiting for event \"#{event}\"")

      unless event == Events::WebSocket::Close
        wait_helper.reject_on_event(self, Events::WebSocket::Close, SocketClosedError.new)
      end

      unless event == Events::WebSocket::Error
        wait_helper.reject_on_event(self, Events::WebSocket::Error, SocketError.new)
      end

      wait_helper.reject_on_event(@parent, 'close', PageClosedError.new)
      wait_helper.wait_for_event(self, event, predicate: predicate)
      block&.call

      wait_helper.promise.value!
    end
    alias_method :wait_for_event, :expect_event

    private def on_frame_sent(opcode, data)
      if opcode == 2
        emit(Events::WebSocket::FrameSent, Base64.strict_decode64(data))
      else
        emit(Events::WebSocket::FrameSent, data)
      end
    end

    private def on_frame_received(opcode, data)
      if opcode == 2
        emit(Events::WebSocket::FrameReceived, Base64.strict_decode64(data))
      else
        emit(Events::WebSocket::FrameReceived, data)
      end
    end

    def closed?
      @closed
    end

    private def on_close
      @closed = true
      emit(Events::WebSocket::Close)
    end
  end
end
