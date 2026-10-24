# frozen_string_literal: true

RSpec.describe Playwright do
  it 'does not load mime-types until a MIME type is needed' do
    script = "require 'playwright'; print $LOADED_FEATURES.grep(%r{/mime/types\\.rb\\z}).size"
    output = IO.popen([RbConfig.ruby, '-I', File.expand_path('../lib', __dir__), '-e', script], &:read)

    expect(output).to eq('0')
  end

  it 'has a version number' do
    expect(Playwright::VERSION).not_to be nil
  end

  describe '.connect_to_playwright_server' do
    context 'when Playwright version >= 1.54.0' do
      it 'raises NotImplementedError' do
        # This test assumes COMPATIBLE_PLAYWRIGHT_VERSION >= 1.54.0
        if Gem::Version.new(Playwright::COMPATIBLE_PLAYWRIGHT_VERSION) >= Gem::Version.new('1.54.0')
          expect {
            Playwright.connect_to_playwright_server('ws://localhost:8888')
          }.to raise_error(NotImplementedError, /connect_to_playwright_server is deprecated/)
        end
      end
    end
  end
end
