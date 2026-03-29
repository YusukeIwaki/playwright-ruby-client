require 'spec_helper'

RSpec.describe Playwright::ChannelOwners::Page do
  private def new_page(channel:, main_frame:)
    page = described_class.allocate
    page.instance_variable_set(:@channel, channel)
    page.instance_variable_set(:@main_frame, main_frame)
    page
  end

  describe '#pick_locator' do
    it 'returns a locator for the picked selector' do
      channel = instance_double('Playwright::Channel')
      main_frame = instance_double('Playwright::ChannelOwners::Frame')
      locator = instance_double('Playwright::LocatorImpl')
      page = new_page(channel: channel, main_frame: main_frame)

      expect(channel).to receive(:send_message_to_server_result)
        .with('pickLocator', {})
        .and_return({ 'selector' => 'internal:text=\"Submit\"' })
      expect(main_frame).to receive(:locator)
        .with('internal:text=\"Submit\"')
        .and_return(locator)

      expect(page.pick_locator).to eq(locator)
    end
  end

  describe '#cancel_pick_locator' do
    it 'forwards the protocol message' do
      channel = instance_double('Playwright::Channel')
      main_frame = instance_double('Playwright::ChannelOwners::Frame')
      page = new_page(channel: channel, main_frame: main_frame)

      expect(channel).to receive(:send_message_to_server).with('cancelPickLocator')

      page.cancel_pick_locator
    end
  end
end
