require 'spec_helper'
require 'base64'

RSpec.describe 'response' do
  # https://github.com/microsoft/playwright/blob/v1.63.0/tests/page/page-network-response.spec.ts
  it 'should return body for prefetch script', sinatra: true do
    skip 'No prefetch in WebKit' if webkit?
    with_page do |page|
      response = page.expect_response('**/prefetch.js') do
        page.goto("#{server_prefix}/prefetch.html")
      end
      expect(response.body).to eq('// Scripts will be pre-fetched')
    end
  end

  it 'should return body for image with evicted body', sinatra: true do
    skip 'WebKit on Mac evicts the body and returns empty buffer' if webkit? && RUBY_PLATFORM.include?('darwin')
    image_base64 = 'R0lGODlhAQABAAAAACw='
    sinatra.get('/pixel.gif') do
      content_type 'image/gif'
      Base64.decode64(image_base64)
    end
    sinatra.get('/page.html') do
      content_type 'text/html'
      '<html><body><img src="/pixel.gif"></body></html>'
    end
    with_page do |page|
      response = page.expect_response('**/pixel.gif') do
        page.goto("#{server_prefix}/page.html")
      end
      expect(Base64.strict_encode64(response.body)).to eq(image_base64)
    end
  end

  # https://github.com/microsoft/playwright/blob/v1.63.0/tests/page/page-network-response.spec.ts
  it 'should return text for identity encoding', sinatra: true do
    sinatra.get('/identity.html') do
      headers('Content-Type' => 'text/html; charset=utf-8', 'Content-Encoding' => 'Identity')
      body('<div>hello</div>')
    end

    with_page do |page|
      response = page.goto("#{server_prefix}/identity.html")
      expect(response.headers['content-encoding']).to eq('Identity')
      expect(response.text).to eq('<div>hello</div>')
    end
  end

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
