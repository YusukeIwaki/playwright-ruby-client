require 'spec_helper'

RSpec.describe 'request interception', sinatra: true do
  it 'should fulfill intercepted response' do
    with_page do |page|
      page.route('**/*', -> (route, _) {
        response = page.request.fetch(route.request)
        route.fulfill(
          response: response,
          status: 201,
          headers: { foo: 'bar' },
          contentType: 'text/plain',
          body: 'Yo, page!',
        )
      })

      response = page.goto(server_empty_page)
      expect(response.status).to eq(201)
      expect(response.headers['foo']).to eq('bar')
      expect(response.headers['content-type']).to eq('text/plain')
      expect(page.evaluate('() => document.body.textContent')).to eq('Yo, page!')
    end
  end

  it 'should fulfill response with empty body' do
    with_page do |page|
      page.route('**/*', -> (route, _) {
        response = page.request.fetch(route.request)
        route.fulfill(
          response: response,
          status: 201,
          body: '',
        )
      })

      response = page.goto(server_empty_page)
      expect(response.status).to eq(201)
      expect(response.text).to eq('')
    end
  end

  it 'should override with defaults when intercepted response not provided' do
    sinatra.get('/empty.html') do
      headers({ 'foo' => 'bar' })
      body('my content')
    end

    with_page do |page|
      page.route('**/*', -> (route, _) {
        route.fulfill(status: 201)
      })

      response = page.goto(server_empty_page)
      expect(response.status).to eq(201)
      expect(response.headers['foo']).to be_nil
      expect(response.text).to eq('')
    end
  end

  it 'should fulfill with any response' do
    sinatra.get('/empty.html') do
      headers({ 'foo' => 'bar' })
      body('Woo-hoo')
    end

    with_page do |page|
      sample_response = page.request.get("#{server_prefix}/sample")

      page.route('**/*', -> (route, _) {
        route.fulfill(
          response: sample_response,
          status: 201,
          contentType: 'text/plain',
        )
      })

      response = page.goto(server_empty_page)
      expect(response.status).to eq(201)
      expect(response.headers['foo']).to be_nil
      expect(response.text).to eq('')
    end
  end
end
