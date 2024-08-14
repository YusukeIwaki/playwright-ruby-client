require 'spec_helper'

RSpec.describe Playwright::LocatorAssertionsImpl do
  describe '#to_expected_text_values' do
    let(:instance) { described_class.new(nil, nil, nil, nil) }

    it 'returns an empty array when items do not respond to :each' do
      expect(instance.send(:to_expected_text_values, nil)).to eq([])
    end

    it 'returns an array of hashes for strings' do
      items = %w[test example]
      expected = [
        { string: 'test', matchSubstring: false, normalizeWhiteSpace: false },
        { string: 'example', matchSubstring: false, normalizeWhiteSpace: false }
      ]
      expect(instance.send(:to_expected_text_values, items)).to eq(expected)
    end

    it 'returns an array of hashes for regex patterns' do
      items = [/test/, /example/]
      expected = [
        { regexSource: 'test', regexFlags: '', matchSubstring: false, normalizeWhiteSpace: false, ignoreCase: false },
        { regexSource: 'example', regexFlags: '', matchSubstring: false, normalizeWhiteSpace: false, ignoreCase: false }
      ]
      expect(instance.send(:to_expected_text_values, items)).to eq(expected)
    end

    it 'returns an array of hashes for mixed strings and regex patterns' do
      items = ['test', /example/]
      expected = [
        { string: 'test', matchSubstring: false, normalizeWhiteSpace: false },
        { regexSource: 'example', regexFlags: '', matchSubstring: false, normalizeWhiteSpace: false, ignoreCase: false }
      ]
      expect(instance.send(:to_expected_text_values, items)).to eq(expected)
    end

    it 'handles ignore_case flag correctly' do
      items = ['test', /example/]
      expected = [
        { string: 'test', matchSubstring: false, normalizeWhiteSpace: false, ignoreCase: true },
        { regexSource: 'example', regexFlags: '', matchSubstring: false, normalizeWhiteSpace: false, ignoreCase: true }
      ]
      expect(instance.send(:to_expected_text_values, items, ignore_case: true)).to eq(expected)
    end

    it 'throws an error when an item is not a string or regex' do
      items = [1]
      expect { instance.send(:to_expected_text_values, items) }.to(
        raise_error(ArgumentError, 'Expected value provided to assertion to be a string or regex, got Integer')
      )
    end
  end
end
