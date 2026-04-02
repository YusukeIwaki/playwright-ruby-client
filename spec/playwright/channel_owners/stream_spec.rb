require 'spec_helper'
require 'base64'
require 'tmpdir'

RSpec.describe Playwright::ChannelOwners::Stream do
  private def new_stream(channel:)
    stream = described_class.allocate
    stream.instance_variable_set(:@channel, channel)
    stream
  end

  describe '#save_as' do
    it 'creates parent directories when missing' do
      channel = instance_double('Playwright::Channel')
      stream = new_stream(channel: channel)

      allow(channel).to receive(:send_message_to_server)
        .with('read', size: 1024 * 1024)
        .and_return(
          Base64.strict_encode64('abc'),
          Base64.strict_encode64('def'),
          nil,
        )

      Dir.mktmpdir do |dir|
        path = File.join(dir, 'nested', 'trace', 'trace.zip')
        stream.save_as(path)

        expect(File.exist?(path)).to eq(true)
        expect(File.binread(path)).to eq('abcdef')
      end
    end
  end
end
