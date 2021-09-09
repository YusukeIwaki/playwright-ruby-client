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
      headers_array = response.headers_array
      expect(headers_array.find{ |k, v| k == 'foo' }.last).to eq('bar')
      expect(headers_array.find{ |k, v| k == 'BaZ' }.last).to eq('bAz')
      expect(headers_array.any?{ |k, v| k == 'baz' }).to eq(false)
    end
  end
end
