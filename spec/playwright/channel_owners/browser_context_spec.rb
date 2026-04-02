require 'spec_helper'
require 'tmpdir'

RSpec.describe Playwright::ChannelOwners::BrowserContext do
  private def new_browser_context(channel:)
    context = described_class.allocate
    context.instance_variable_set(:@channel, channel)
    context
  end

  describe '#set_storage_state' do
    it 'sends parsed storage state when given a file path' do
      channel = instance_double('Playwright::Channel')
      context = new_browser_context(channel: channel)

      Dir.mktmpdir do |dir|
        path = File.join(dir, 'storage-state.json')
        File.write(path, JSON.dump({
          cookies: [{ name: 'session', value: 'abc' }],
          origins: [{ origin: 'https://example.com', localStorage: [] }],
        }))

        expect(channel).to receive(:send_message_to_server).with(
          'setStorageState',
          storageState: {
            'cookies' => [{ 'name' => 'session', 'value' => 'abc' }],
            'origins' => [{ 'origin' => 'https://example.com', 'localStorage' => [] }],
          },
        )

        context.set_storage_state(path)
      end
    end

    it 'sends the provided storage state object as-is' do
      channel = instance_double('Playwright::Channel')
      context = new_browser_context(channel: channel)
      storage_state = {
        cookies: [{ name: 'session', value: 'abc' }],
        origins: [{ origin: 'https://example.com', localStorage: [] }],
      }

      expect(channel).to receive(:send_message_to_server).with(
        'setStorageState',
        storageState: storage_state,
      )

      context.set_storage_state(storage_state)
    end

    it 'raises a Playwright::Error when the file cannot be read' do
      channel = instance_double('Playwright::Channel')
      context = new_browser_context(channel: channel)

      expect {
        context.set_storage_state('/path/to/missing-storage-state.json')
      }.to raise_error(Playwright::Error, /Failed to read storage state from/)
    end
  end
end
