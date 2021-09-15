require 'spec_helper'

RSpec.describe 'Request' do
  it 'should return headers', sinatra: true do
    with_page do |page|
      response = page.goto(server_empty_page)
      expect(response.request.headers['user-agent']).to start_with('Mozilla/5.0')
    end
  end

  it 'should return navigation bit when navigating to image', sinatra: true do
    with_page do |page|
      requests = []
      page.on('request', ->(req) { requests << req })
      page.goto("#{server_prefix}/pprt.png")

      expect(requests.first.navigation_request?).to eq(true)
    end
  end

  it 'should report raw headers', sinatra: true do
    sinatra.get('/headers') { 'OK' }

    with_page do |page|
      page.goto(server_empty_page)
      request = page.expect_request('**/*') do
        page.evaluate(<<~JAVASCRIPT)
        () => fetch('/headers', {
          headers: [
            ['header-a', 'value-a'],
            ['header-b', 'value-b'],
            ['header-a', 'value-a-1'],
            ['header-a', 'value-a-2'],
          ]
        })
        JAVASCRIPT
      end
      headers = request.headers_array
      expect(request.header_value('header-a')).to eq('value-a, value-a-1, value-a-2')
      expect(request.header_value('header-b')).to eq('value-b')
      expect(request.header_value('not-there')).to be_nil
      expect(request.header_values('not-there')).to eq([])
    end
  end

  it 'should report all cookies in one header', sinatra: true do
    sinatra.get('/headers') { 'OK' }

    with_page do |page|
      page.goto(server_empty_page)
      page.evaluate(<<~JAVASCRIPT)
      () => {
        document.cookie = 'myCookie=myValue';
        document.cookie = 'myOtherCookie=myOtherValue';
      }
      JAVASCRIPT
      response = page.goto(server_empty_page)
      headers = response.request.all_headers
      expect(headers['cookie']).to eq('myCookie=myValue; myOtherCookie=myOtherValue')
    end
  end
end
