require 'spec_helper'

RSpec.describe 'response' do
  it 'should work', sinatra: true do
    sinatra.get('/headers') do
      headers(
        'foo' => 'bar',
        'BaZ' => 'bAz',
      )
      body('OK')
    end

    with_page do |page|
      response = page.goto("#{server_prefix}/headers")
      headers = response.all_headers
      expect(headers['foo']).to eq('bar')
      expect(headers['baz']).to eq('bAz')
      expect(headers['BaZ']).to be_nil
    end
  end
end
