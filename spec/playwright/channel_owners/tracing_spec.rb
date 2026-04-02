require 'spec_helper'

RSpec.describe Playwright::ChannelOwners::Tracing do
  private def new_tracing(connection:, channel:, is_tracing: false, include_sources: false, stacks_id: nil)
    tracing = described_class.allocate
    tracing.instance_variable_set(:@connection, connection)
    tracing.instance_variable_set(:@channel, channel)
    tracing.instance_variable_set(:@is_tracing, is_tracing)
    tracing.instance_variable_set(:@include_sources, include_sources)
    tracing.instance_variable_set(:@stacks_id, stacks_id)
    tracing
  end

  describe '#start_collecting_stacks' do
    it 'does not fail when local utils is unavailable' do
      connection = instance_double('Playwright::Connection', local_utils: nil)
      channel = instance_double('Playwright::Channel')
      tracing = new_tracing(connection: connection, channel: channel)
      tracing.instance_variable_set(:@traces_dir, '/tmp/trace')

      expect(connection).to receive(:set_in_tracing).with(true)

      expect { tracing.send(:start_collecting_stacks, 'trace-name') }.not_to raise_error
      expect(tracing.instance_variable_get(:@stacks_id)).to be_nil
    end
  end

  describe '#do_stop_chunk' do
    it 'saves archive artifact as-is on remote connection without local utils' do
      artifact = instance_double('Playwright::ChannelOwners::Artifact')
      artifact_channel = instance_double('Playwright::Channel', object: artifact)
      channel = instance_double('Playwright::Channel')
      connection = instance_double('Playwright::Connection', remote?: true, local_utils: nil)
      tracing = new_tracing(
        connection: connection,
        channel: channel,
        is_tracing: true,
        include_sources: true,
      )

      expect(connection).to receive(:set_in_tracing).with(false)
      expect(channel).to receive(:send_message_to_server_result)
        .with('tracingStopChunk', mode: 'archive')
        .and_return({ 'artifact' => artifact_channel })
      expect(artifact).to receive(:save_as).with('/tmp/trace.zip')
      expect(artifact).to receive(:delete)

      expect { tracing.send(:do_stop_chunk, file_path: '/tmp/trace.zip') }.not_to raise_error
    end

    it 'does not fail when archive artifact is missing on remote connection without local utils' do
      channel = instance_double('Playwright::Channel')
      connection = instance_double('Playwright::Connection', remote?: true, local_utils: nil)
      tracing = new_tracing(connection: connection, channel: channel, is_tracing: true)

      expect(connection).to receive(:set_in_tracing).with(false)
      expect(channel).to receive(:send_message_to_server_result)
        .with('tracingStopChunk', mode: 'archive')
        .and_return({ 'artifact' => nil })

      expect { tracing.send(:do_stop_chunk, file_path: '/tmp/trace.zip') }.not_to raise_error
    end
  end
end
