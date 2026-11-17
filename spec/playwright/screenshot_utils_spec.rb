require 'spec_helper'

RSpec.describe Playwright::ScreenshotUtils do
  describe '.determine_type' do
    it 'prefers the explicit type' do
      expect(described_class.determine_type(path: 'shot.png', type: 'jpeg')).to eq('jpeg')
    end

    it 'returns nil without path nor type' do
      expect(described_class.determine_type(path: nil, type: nil)).to be_nil
    end

    it 'infers the type from the path extension' do
      expect(described_class.determine_type(path: 'shot.png', type: nil)).to eq('png')
      expect(described_class.determine_type(path: 'shot.jpg', type: nil)).to eq('jpeg')
      expect(described_class.determine_type(path: 'shot.webp', type: nil)).to eq('webp')
    end

    it 'raises on an unsupported extension' do
      expect {
        described_class.determine_type(path: 'shot.gif', type: nil)
      }.to raise_error(ArgumentError, /unsupported mime type "image\/gif"/)
    end
  end
end
