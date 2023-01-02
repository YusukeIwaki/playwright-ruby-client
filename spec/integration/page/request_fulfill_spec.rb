require 'spec_helper'

RSpec.describe 'Request.fulfill', sinatra: true do
  it 'should work' do
    with_page do |page|
      page.route('**/*', -> (route, _) {
        route.fulfill(
          status: 201,
          headers: { foo: 'bar' },
          contentType: 'text/html',
          body: 'Yo, page!')
      })

      response = page.goto(server_empty_page)
      expect(response.status).to eq(201)
      expect(response.headers['foo']).to eq('bar')
      expect(page.evaluate('() => document.body.textContent')).to eq('Yo, page!')
    end
  end

  it 'should work with status code 422', sinatra: true do
    with_page do |page|
      page.route('**/*', -> (route, _) {
        route.fulfill(
          status: 422,
          body: 'Yo, page!'
        )
      })

      response = page.goto(server_empty_page)
      expect(response.status).to eq(422)
      expect(page.evaluate('() => document.body.textContent')).to eq('Yo, page!')
    end
  end

  it 'should fulfill json' do
    with_page do |page|
      page.route('**/*', -> (route, _) {
        route.fulfill(
          status: 201,
          headers: { foo: 'bar' },
          json: { bar: 'baz' },
        )
      })

      response = page.goto(server_empty_page)
      expect(response.status).to eq(201)
      expect(response.headers['content-type']).to eq('application/json')
      expect(page.evaluate('() => document.body.textContent')).to eq(JSON.generate({ bar: 'baz' }))
    end
  end
end
