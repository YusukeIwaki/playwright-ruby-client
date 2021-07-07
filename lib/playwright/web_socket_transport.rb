# frozen_string_literal: true

require 'json'

module Playwright
  # ref: https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_transport.py
  class WebSocketTransport
    # @param ws_endpoint [String] EndpointURL of WebSocket
    def initialize(ws_endpoint:)
      @ws_endpoint = ws_endpoint
      @debug = ENV['DEBUG'].to_s == 'true' || ENV['DEBUG'].to_s == '1'
    end

    def on_message_received(&block)
      @on_message = block
    end

    def on_driver_crashed(&block)
      @on_driver_crashed = block
    end

    class AlreadyDisconnectedError < StandardError ; end

    # @param message [Hash]
    def send_message(message)
      debug_send_message(message) if @debug
      msg = JSON.dump(message)

      @ws.send_text(msg)
    rescue Errno::EPIPE, IOError
      raise AlreadyDisconnectedError.new('send_message failed')
    end

    # Terminate playwright-cli driver.
    def stop
      @ws&.close
    rescue EOFError => err
      # ignore EOLError. The connection is already closed.
    end

    # Start `playwright-cli run-driver`
    #
    # @note This method blocks until playwright-cli exited. Consider using Thread or Future.
    def async_run
      ws = ::Playwright::WebSocket.new(
        url: @ws_endpoint,
        max_payload_size: 256 * 1024 * 1024, # 256MB
      )
      promise = Concurrent::Promises.resolvable_future
      ws.on_open do
        promise.fulfill(ws)
      end
      ws.on_error do |error_message|
        promise.reject(::Playwright::WebSocket::TransportError.new(error_message))
      end
      ws.start
      @ws = promise.value!
      @ws.on_message do |data|
        handle_on_message(data)
      end
      @ws.on_error do |error|
        puts "[WebSocketTransport] error: #{error}"
        @on_driver_crashed&.call
      end
    rescue Errno::ECONNREFUSED => err
      raise ::Playwright::WebSocket::TransportError.new(err)
    end

    private

    def handle_on_message(data)
      obj = JSON.parse(data)

      debug_recv_message(obj) if @debug
      @on_message&.call(obj)
    end

    def debug_send_message(message)
      puts "\x1b[33mSEND>\x1b[0m#{message}"
    end

    def debug_recv_message(message)
      puts "\x1b[33mRECV>\x1b[0m#{message}"
    end
  end
end
