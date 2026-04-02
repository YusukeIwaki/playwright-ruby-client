require 'spec_helper'

RSpec.describe Playwright::HarRouter do
  describe '#handle' do
    it 'merges duplicate set-cookie headers when fulfilling from HAR' do
      local_utils = instance_double('Playwright::ChannelOwners::LocalUtils')
      route = instance_double('Playwright::Route')
      request = instance_double(
        'Playwright::Request',
        url: 'https://example.com',
        method: 'GET',
        headers_array: [],
        post_data_buffer: nil,
        navigation_request?: false,
      )
      router = described_class.new(
        local_utils: local_utils,
        har_id: 'har-id',
        not_found_action: 'abort',
      )

      expect(local_utils).to receive(:har_lookup).and_return(
        'action' => 'fulfill',
        'status' => 200,
        'headers' => [
          { 'name' => 'set-cookie', 'value' => 'a=b' },
          { 'name' => 'Set-Cookie', 'value' => 'c=d' },
          { 'name' => 'content-type', 'value' => 'text/plain' },
        ],
        'body' => Base64.strict_encode64('ok'),
      )
      expect(route).to receive(:fulfill).with(
        status: 200,
        headers: {
          'set-cookie' => "a=b\nc=d",
          'content-type' => 'text/plain',
        },
        body: 'ok',
      )

      router.send(:handle, route, request)
    end
  end
end
