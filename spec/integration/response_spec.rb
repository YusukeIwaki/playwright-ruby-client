require 'spec_helper'

RSpec.describe 'response' do
  it 'should return server address directly from response', sinatra: true do
    with_page do |page|
      response = page.goto(server_empty_page)
      addr = response.server_addr
      expect(addr['ipAddress']).to match(/^127\.0\.0\.1|\[::1\]/)
      expect(addr['port']).to eq(server_port)
    end
  end
end
