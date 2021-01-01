# frozen_string_literal: true

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
      @debug = true
    end

    def on_message_received(&block)
      @on_message = block
    end

    # @param message [Hash]
    def send_message(message)
      debug_send_message(message) if @debug
      msg = JSON.dump(message)
      @stdin.write([msg.size].pack('V')) # unsigned 32bit, little endian
      @stdin.write(msg)
    end

    # Terminate playwright-cli driver.
    def stop
      [@stdin, @stdout, @stderr].each { |io| io.close unless io.closed? }
    end

    # Start `playwright-cli run-driver`
    #
    # @note This method blocks until playwright-cli exited. Consider using Thread or Future.
    def run
      @stdin, @stdout, @stderr, @thread = Open3.popen3(@driver_executable_path, 'run-driver')

      Thread.new { handle_stdout }
      Thread.new { handle_stderr }

      @thread.join
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
    rescue IOError
      # disconnected by remote.
    end

    def handle_stderr
      while err = @stderr.read
        $stderr.write(err)
      end
    rescue IOError
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
