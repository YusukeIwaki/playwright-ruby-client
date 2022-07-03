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

  it 'should report if request was fromServiceWorker', sinatra: true do
    with_page do |page|
      res = page.goto("#{server_prefix}/serviceworkers/fetch/sw.html")
      expect(res.from_service_worker?).to eq(false)

      page.evaluate("() => window['activationPromise']")

      res = page.expect_response(/example\.txt/) do
        page.evaluate("() => fetch('/example.txt')")
      end
      expect(res.from_service_worker?).to eq(true)
    end
  end
end
