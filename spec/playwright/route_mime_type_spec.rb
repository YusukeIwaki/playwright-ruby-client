require 'spec_helper'

RSpec.describe Playwright::ChannelOwners::Route do
  describe '#mime_type_for' do
    let(:route) { described_class.allocate }

    it 'infers the MIME type from the path extension' do
      expect(route.send(:mime_type_for, 'index.html')).to eq('text/html')
    end

    it 'falls back to application/octet-stream on an unknown extension' do
      expect(route.send(:mime_type_for, 'payload.unknownext')).to eq('application/octet-stream')
    end
  end
end
