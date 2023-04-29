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
    sinatra.get('/sample') do
      status 200
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
      expect(response.headers['foo']).to eq('bar')
      expect(response.text).to eq('Woo-hoo')
    end
  end

  it 'should support fulfill after intercept', sinatra: true do
    with_page do |page|
      page.route('**', -> (route, request) {
        response = page.request.fetch(request)
        route.fulfill(response: response)
      })

      response = page.goto("#{server_prefix}/title.html")
      original = File.read(File.join('spec', 'assets', 'title.html'))
      expect(response.text).to eq(original)
    end
  end

  it 'should give access to the intercepted response', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)

      route_promise = Concurrent::Promises.resolvable_future
      page.route('**/title.html', -> (route, _) {
        route_promise.fulfill(route)
      })

      eval_promise = Concurrent::Promises.future {
        page.evaluate("url => fetch(url)", arg: "#{server_prefix}/title.html")
      }

      route = route_promise.value!
      response = page.request.fetch(route.request)

      expect(response.status).to eq(200)
      expect(response.url).to end_with('/title.html')
      expect(response.headers['content-type']).to eq('text/html;charset=utf-8')

      route.fulfill(response: response)
      eval_promise.value!
    end
  end

  it 'should give access to the intercepted response body', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)

      route_promise = Concurrent::Promises.resolvable_future
      page.route('**/simple.json', -> (route, _) {
        route_promise.fulfill(route)
      })

      eval_promise = Concurrent::Promises.future {
        page.evaluate("url => fetch(url)", arg: "#{server_prefix}/simple.json")
      }

      route = route_promise.value!
      response = page.request.fetch(route.request)

      expect(response.text).to eq("{\"foo\": \"bar\"}\n")

      route.fulfill(response: response)
      eval_promise.value!
    end
  end

  it 'should intercept multipart/form-data request body', sinatra: true do
    pending 'https://github.com/microsoft/playwright/issues/14624'
    with_page do |page|
      page.goto("#{server_prefix}/input/fileupload.html")

      filepath = File.join('spec', 'assets', 'file-to-upload.txt')
      page.locator('input[type=file]').set_input_files(filepath)
      request_promise = Concurrent::Promises.resolvable_future
      page.route('**/upload', -> (route, request) {
        request_promise.fulfill(request)
      })

      page.click('input[type=submit]', noWaitAfter: true)
      request = request_promise.value!
      expect(request.method).to eq('POST')
      expect(request.post_data).to include(File.read(filepath))
    end
  end

  it 'should fulfill intercepted response using alias', sinatra: true do
    with_page do |page|
      page.route('**/*', -> (route, _) {
        response = route.fetch
        route.fulfill(response: response)
      })

      response = page.goto(server_empty_page)
      expect(response.status).to eq(200)
      expect(response.headers['content-type']).to include('text/html')
    end
  end

  it 'should not follow redirects when maxRedirects is set to 0 in route.fetch' do
    sinatra.get('/foo') { redirect '/empty.html' }

    with_page do |page|
      page.route('**/*', -> (route, _) {
        response = route.fetch(maxRedirects: 0)
        route.fulfill(body: 'Hello maxRedirects=0')
      })
      page.goto("#{server_prefix}/foo")
      expect(page.content).to include('Hello maxRedirects=0')
    end
  end

  it 'should support timeout option in route.fetch' do
    sinatra.get('/slow') { sleep 2; 'OK' }

    with_page do |page|
      page.route('**/*', -> (route, _) {
        begin
          response = route.fetch(timeout: 10)
          route.fulfill(response: response)
        rescue => e
          route.fulfill(status: 200, body: e.message.split("\n").first)
        end
      })
      response = page.goto("#{server_prefix}/slow", timeout: 20000)
      expect(response.body).to eq('Error: Request timed out after 10ms')
    end
  end


  it 'should intercept with url override', sinatra: true do
    with_page do |page|
      page.route('**/*', -> (route, _) {
        response = route.fetch(url: "#{server_prefix}/one-style.html")
        route.fulfill(response: response)
      })

      response = page.goto(server_empty_page)
      expect(response.status).to eq(200)
      expect(response.body).to include('one-style.css')
    end
  end

  it 'should intercept with post data override', sinatra: true do
    request_promise = Concurrent::Promises.resolvable_future
    sinatra.get('/empty.html') do
      request_promise.fulfill(request.body.read)
      ''
    end

    with_page do |page|
      page.route('**/*', -> (route, _) {
        response = route.fetch(postData: { foo: :bar })
        route.fulfill(response: response)
      })

      response = page.goto(server_empty_page)
      expect(response.status).to eq(200)
      expect(request_promise.value!).to eq('{"foo":"bar"}')
    end
  end
end
