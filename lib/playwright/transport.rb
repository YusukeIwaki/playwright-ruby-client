# frozen_string_literal: true

require 'async/io'
require 'json'
require 'open3'
require "stringio"

module Playwright
  # ref: https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_transport.py
  class Transport
    # @param playwright_cli_executable_path [String] path to playwright-cli.
    # @param debug [Boolean]
    def initialize(playwright_cli_executable_path:)
      @driver_executable_path = playwright_cli_executable_path
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
      @stdin.write([msg.size].pack('V')) # unsigned 32bit, little endian
      @stdin.write(msg)
    rescue Errno::EPIPE
      raise AlreadyDisconnectedError.new('send_message failed')
    end

    # Terminate playwright-cli driver.
    def stop
      [@stdin, @stdout, @stderr].each { |io| io.close unless io.closed? }
    end

    # Start `playwright-cli run-driver`
    #
    # @note This method blocks until playwright-cli exited. Consider using Thread or Future.
    def async_run
      stdin, stdout, stderr, _ = Open3.popen3("#{@driver_executable_path} run-driver")

      # convert to non-blocking IO
      @stdin = Async::IO::Generic.new(stdin)
      @stdout = Async::IO::Generic.new(stdout)
      @stderr = Async::IO::Generic.new(stderr)

      Async { handle_stdout }
      Async { handle_stderr }
    end

    private

    def handle_stdout(packet_size: 32_768)
      while chunk = @stdout.read(4)
        length = chunk.unpack1('V') # unsigned 32bit, little endian
        buffer = StringIO.new
        (length / packet_size).to_i.times do
          buffer << @stdout.read(packet_size)
        end
        buffer << @stdout.read(length % packet_size)
        buffer.rewind
        obj = JSON.parse(buffer.read)

        debug_recv_message(obj) if @debug
        @on_message&.call(obj)
      end
    rescue IOError, Async::Wrapper::Cancelled
      # disconnected by remote.
    end

    def handle_stderr
      while err = @stderr.read
        # sometimed driver crashes with the error below.
        # --------
        # undefined:1
        # �
        # ^

        # SyntaxError: Unexpected token � in JSON at position 0
        #     at JSON.parse (<anonymous>)
        #     at Transport.transport.onmessage (/home/runner/work/playwright-ruby-client/playwright-ruby-client/node_modules/playwright/lib/cli/driver.js:42:73)
        #     at Immediate.<anonymous> (/home/runner/work/playwright-ruby-client/playwright-ruby-client/node_modules/playwright/lib/protocol/transport.js:74:26)
        #     at processImmediate (internal/timers.js:461:21)
        if err.include?('undefined:1')
          @on_driver_crashed&.call
          break
        end
        $stderr.write(err)
      end
    rescue IOError, Async::Wrapper::Cancelled
      # disconnected by remote.
    end

    def debug_send_message(message)
      puts "\x1b[33mSEND>\x1b[0m#{message}"
    end

    def debug_recv_message(message)
      puts "\x1b[33mRECV>\x1b[0m#{message}"
    end
  end
end
