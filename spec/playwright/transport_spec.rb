require 'spec_helper'

# Regression tests for https://github.com/YusukeIwaki/playwright-ruby-client/issues/392
#
# 1. Transport#send_message must write each protocol frame atomically, so that an
#    asynchronous exception (Timeout.timeout delivers Timeout::Error via Thread#raise)
#    can never tear a frame and crash the driver.
# 2. A crashed/dead driver must be detected (Node >= 16 crash banner, clean EOF on
#    stdout) instead of hanging forever on promises that will never resolve.
RSpec.describe Playwright::Transport do
  let(:transport) { Playwright::Transport.new(playwright_cli_executable_path: 'dummy') }

  class RecordingStdin
    attr_reader :writes

    def initialize
      @writes = []
    end

    def write(chunk)
      @writes << chunk.dup
      chunk.bytesize
    end
  end

  # Fake stdin that lets a raiser thread deliver an asynchronous exception
  # deterministically while #write is in flight: it notifies via `entered`,
  # then blocks on `release` until the raiser has called Thread#raise.
  class RacyStdin < RecordingStdin
    def initialize(entered:, release:)
      super()
      @entered = entered
      @release = release
    end

    def write(chunk)
      @writes << chunk.dup
      @entered.push(:entered)
      @release.pop
      chunk.bytesize
    end
  end

  # Parses length-prefixed frames. Returns [frames, trailing_bytes].
  def parse_frames(bytes)
    frames = []
    rest = bytes.dup.force_encoding(Encoding::BINARY)
    until rest.empty?
      break if rest.bytesize < 4
      length = rest[0, 4].unpack1('V')
      payload = rest[4, length]
      break if payload.nil? || payload.bytesize != length
      frames << JSON.parse(payload)
      rest = (rest[(4 + length)..-1] || '').b
    end
    [frames, rest]
  end

  describe '#send_message' do
    it 'writes a single length-prefixed JSON frame' do
      stdin = RecordingStdin.new
      transport.instance_variable_set(:@stdin, stdin)
      message = { id: 1, guid: 'guid', method: 'method', params: { foo: 'bar', multibyte: 'あいう' }, metadata: {} }

      transport.send_message(message)

      expect(stdin.writes.count).to eq(1)
      frames, rest = parse_frames(stdin.writes.join.b)
      expect(rest).to eq(''.b)
      expect(frames).to eq([JSON.parse(JSON.dump(message))])
    end

    it 'writes the frame atomically even when an asynchronous Timeout::Error arrives mid-write' do
      entered = Queue.new
      release = Queue.new
      stdin = RacyStdin.new(entered: entered, release: release)
      transport.instance_variable_set(:@stdin, stdin)
      message = { id: 7, guid: 'guid', method: 'evaluate', params: { expression: '1 + 1' }, metadata: {} }

      main = Thread.current
      raiser = Thread.new do
        entered.pop
        main.raise(Timeout::Error, 'simulated Timeout.timeout')
        release.push(:go)
      end

      begin
        expect {
          Timeout.timeout(10) { transport.send_message(message) }
        }.to raise_error(Timeout::Error, 'simulated Timeout.timeout')
        raiser.join(10)
        expect(raiser.alive?).to eq(false)
      ensure
        raiser.kill
        raiser.join
      end

      # The deferred error must still reach the caller, but only after the
      # complete frame is on the wire. A torn frame crashes the driver.
      frames, rest = parse_frames(stdin.writes.join.b)
      expect(rest).to eq(''.b)
      expect(frames).to eq([JSON.parse(JSON.dump(message))])
    end
  end

  describe 'driver crash detection' do
    # Node >= 16 prints <anonymous_script>:1 instead of undefined:1.
    NODE16_CRASH = <<~CRASH
      <anonymous_script>:1
      p
      ^

      SyntaxError: Unexpected token 'p', "p..." is not valid JSON
          at JSON.parse (<anonymous>)
          at transport.onmessage (/path/to/playwright-core/lib/coreBundle.js:69939:73)
      Node.js v22.22.0
    CRASH

    NODE14_CRASH = <<~CRASH
      undefined:1
      \uFFFD
      ^

      SyntaxError: Unexpected token \uFFFD in JSON at position 0
          at JSON.parse (<anonymous>)
          at Transport.transport.onmessage (/path/to/playwright/lib/cli/driver.js:42:73)
    CRASH

    def with_stderr(content)
      reader, writer = IO.pipe
      writer.write(content)
      writer.close
      transport.instance_variable_set(:@stderr, reader)
      yield
    ensure
      reader.close unless reader.closed?
    end

    def silence_stderr
      orig = $stderr
      $stderr = StringIO.new
      yield
    ensure
      $stderr = orig
    end

    it 'detects a driver crash from the Node >= 16 error banner' do
      crashed = false
      transport.on_driver_crashed { crashed = true }
      with_stderr(NODE16_CRASH) { silence_stderr { transport.send(:handle_stderr) } }
      expect(crashed).to eq(true)
    end

    it 'detects a driver crash from the Node <= 14 error banner' do
      crashed = false
      transport.on_driver_crashed { crashed = true }
      with_stderr(NODE14_CRASH) { silence_stderr { transport.send(:handle_stderr) } }
      expect(crashed).to eq(true)
    end

    it 'does not report a crash for ordinary stderr output' do
      crashed = false
      transport.on_driver_crashed { crashed = true }
      with_stderr("some log line\n") { silence_stderr { transport.send(:handle_stderr) } }
      expect(crashed).to eq(false)
    end
  end

  describe 'driver stdout handling' do
    it 'notifies driver closed on clean EOF instead of hanging' do
      reader, writer = IO.pipe
      writer.close
      transport.instance_variable_set(:@stdout, reader)
      closed = false
      transport.on_driver_closed { closed = true }
      begin
        transport.send(:handle_stdout)
      ensure
        reader.close unless reader.closed?
      end
      expect(closed).to eq(true)
    end

    it 'dispatches received messages' do
      reader, writer = IO.pipe
      payload = JSON.dump({ 'id' => 1, 'result' => { 'ok' => true } })
      writer.write([payload.bytesize].pack('V') + payload)
      writer.close
      transport.instance_variable_set(:@stdout, reader)
      received = []
      transport.on_message_received { |msg| received << msg }
      begin
        transport.send(:handle_stdout)
      ensure
        reader.close unless reader.closed?
      end
      expect(received).to eq([{ 'id' => 1, 'result' => { 'ok' => true } }])
    end
  end
end
