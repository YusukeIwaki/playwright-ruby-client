# https://github.com/microsoft/playwright/blob/main/tests/browsercontext-fetch.spec.ts
RSpec.describe 'fetch', sinatra: true do
  it 'fetch should work' do
    with_context do |context|
      response = context.request.fetch("#{server_prefix}/simple.json")
      expect(response.url).to eq("#{server_prefix}/simple.json")
      expect(response.status).to eq(200)
      expect(response.headers['content-type']).to eq('application/json')
      expect(response.text).to eq("{\"foo\": \"bar\"}\n")
    end
  end

  it 'should add session cookies to request' do
    promise = Concurrent::Promises.resolvable_future
    sinatra.get('/simple.json') do
      promise.fulfill(request.env['HTTP_COOKIE'])
    end

    with_context do |context|
      context.add_cookies([
        {
          name: 'username',
          value: 'John Doe',
          domain: '127.0.0.1',
          path: '/',
          expires: -1,
          httpOnly: false,
          secure: false,
          sameSite: 'Lax',
        },
      ])

      context.request.get("http://127.0.0.1:#{server_port}/simple.json")
    end
    expect(promise.value!).to eq('username=John Doe')
  end

  SINATRA_MAP = {
    fetch: :get,
    delete: :delete,
    get: :get,
    head: :head,
    patch: :patch,
    post: :post,
    put: :put,
  }.freeze
  %i(fetch delete get head patch post put).each do |http_method|
    it "#{http_method} should support queryParams" do
      promise = Concurrent::Promises.resolvable_future
      sinatra.send(SINATRA_MAP[http_method], '/empty.html') do
        promise.fulfill(params.dup)
      end

      with_context do |context|
        context.request.send(
          http_method,
          "#{server_empty_page}?p1=foo",
          params: { p1: 'v1', парам2: 'знач2'},
        )
      end

      params = promise.value!
      expect(params['p1']).to eq('v1')
      expect(params['парам2']).to eq('знач2')
    end

    it "#{http_method} should support failOnStatusCode" do
      with_context do |context|
        expect {
          context.request.send(http_method, "#{server_prefix}/docs-not-exist.html", failOnStatusCode: true)
        }.to raise_error(/404 Not Found/)
      end
    end
  end

  it 'should follow redirects' do
    promise = Concurrent::Promises.resolvable_future
    sinatra.get('/redirect1') { redirect '/redirect2' }
    sinatra.get('/redirect2') { redirect '/simple.json' }
    sinatra.get('/simple.json') do
      promise.fulfill(request.env['HTTP_COOKIE'])
      { foo: :bar }.to_json
    end

    with_context do |context|
      context.add_cookies([
        {
          name: 'username',
          value: 'John Doe',
          domain: '127.0.0.1',
          path: '/',
          expires: -1,
          httpOnly: false,
          secure: false,
          sameSite: 'Lax',
        }
      ])

      response = context.request.get("http://127.0.0.1:#{server_port}/redirect1")
      expect(response.url).to eq("http://127.0.0.1:#{server_port}/simple.json")
      expect(response.json).to eq({ 'foo' => 'bar' })
    end
  end

  it 'should work with http credentials' do
    sinatra.use Rack::Auth::Basic do |username, password|
      username == 'user' && password == 'pass'
    end

    with_context do |context|
      response = context.request.get(server_empty_page)
      expect(response.status).to eq(401)

      auth_header = "Basic #{Base64.strict_encode64('user:pass')}"
      response = context.request.get(server_empty_page, headers: { 'Authorization' => auth_header })
      expect(response.status).to eq(200)
    end
  end

  it 'should return error with wrong credentials' do
    sinatra.use Rack::Auth::Basic do |username, password|
      username == 'user' && password == 'pass'
    end

    with_context do |context|
      auth_header = "Basic #{Base64.strict_encode64('user:wrone')}"
      response = context.request.get(server_empty_page, headers: { 'Authorization' => auth_header })
      expect(response.status).to eq(401)
    end
  end

  %i(delete patch post put).each do |http_method|
    it "#{http_method} should support post data" do
      promise = Concurrent::Promises.resolvable_future
      sinatra.send(http_method, '/simple.json') do
        promise.fulfill([
          request.request_method,
          request.body.read,
          request.url,
        ])
      end

      with_context do |context|
        response = context.request.send(http_method, "#{server_prefix}/simple.json", data: 'My request')
        expect(response.status).to eq(200)
      end

      expect(promise.value!).to eq([
        http_method.to_s.upcase,
        'My request',
        "#{server_prefix}/simple.json",
      ])
     end
  end

  it 'should add default headers' do
    promise = Concurrent::Promises.resolvable_future
    sinatra.get('/empty.html') do
      promise.fulfill(request.env)
      ''
    end

    with_page do |page|
      page.request.get(server_empty_page)
      headers = promise.value!
      expect(headers['HTTP_ACCEPT']).to eq('*/*')
      user_agent = page.evaluate('() => navigator.userAgent')
      expect(headers['HTTP_USER_AGENT']).to eq(user_agent)
      expect(headers['HTTP_ACCEPT_ENCODING']).to eq('gzip,deflate,br')
    end
  end

  it 'should send content-length' do
    promise = Concurrent::Promises.resolvable_future
    sinatra.post('/empty.html') do
      promise.fulfill(request.env)
      ''
    end

    with_context do |context|
      context.request.post(server_empty_page, data: (0..255).to_a.pack('C*'))
    end

    headers = promise.value!
    expect(headers['CONTENT_LENGTH']).to eq('256')
    expect(headers['CONTENT_TYPE']).to eq('application/octet-stream')
  end

  it 'should allow to override default headers' do
    promise = Concurrent::Promises.resolvable_future
    sinatra.post('/empty.html') do
      promise.fulfill(request.env)
      ''
    end

    with_context do |context|
      headers = {
        'User-Agent' => 'Playwright',
        'Accept' => 'text/html',
        'Accept-Encoding' => 'br',
      }
      context.request.post(server_empty_page, headers: headers)
    end

    headers = promise.value!
    expect(headers['HTTP_ACCEPT']).to eq('text/html')
    expect(headers['HTTP_USER_AGENT']).to eq('Playwright')
    expect(headers['HTTP_ACCEPT_ENCODING']).to eq('br')
  end

  it 'should support timeout option' do
    sinatra.get('/slow') do
      sleep 10
      'SLOW'
    end

    with_context do |context|
      expect {
        context.request.get("#{server_prefix}/slow", timeout: 10)
      }.to raise_error(/Request timed out after 10ms/)
    end
  end

  it 'should support a timeout of 0' do
    sinatra.get('/slow') do
      sleep 1
      'done'
    end

    with_context do |context|
      Timeout.timeout(2) do
        response = context.request.get("#{server_prefix}/slow", timeout: 0)
        expect(response.text).to eq('done')
      end
    end
  end

  it 'should dispose' do
    with_context do |context|
      response = context.request.get("#{server_prefix}/simple.json")
      expect(response.json).to eq({ 'foo' => 'bar' })
      response.dispose
      expect {
        response.body
      }.to raise_error(/Response has been disposed/)
    end
  end

  it 'should dispose when context closes' do
    response = with_context do |context|
      context.request.get("#{server_prefix}/simple.json")
    end
    expect {
      response.body
    }.to raise_error(/Response has been disposed/)
  end

  it 'should support application/x-www-form-urlencoded' do
    promise = Concurrent::Promises.resolvable_future
    sinatra.post('/empty.html') do
      promise.fulfill([
        request.request_method,
        request.env['CONTENT_TYPE'],
        request.body.read,
      ])
      ''
    end

    with_context do |context|
      context.request.post(server_empty_page,
        form: {
          first_name: 'John',
          last_name: 'Doe',
          file: 'f.js',
        })
    end

    request_method, content_type, body = promise.value!
    expect(request_method).to eq('POST')
    expect(content_type).to eq('application/x-www-form-urlencoded')
    expect(body.split('&')).to contain_exactly(
      'first_name=John',
      'last_name=Doe',
      'file=f.js',
    )
  end

  it 'should encode to application/json by default' do
    promise = Concurrent::Promises.resolvable_future
    sinatra.post('/empty.html') do
      promise.fulfill([
        request.request_method,
        request.env['CONTENT_TYPE'],
        request.body.read,
      ])
      ''
    end

    with_context do |context|
      context.request.post(server_empty_page,
        data: {
          first_name: 'John',
          last_name: 'Doe',
          file: 'f.js',
        })
    end

    request_method, content_type, body = promise.value!
    expect(request_method).to eq('POST')
    expect(content_type).to eq('application/json')
    json = JSON.parse(body)
    expect(json['first_name']).to eq('John')
    expect(json['last_name']).to eq('Doe')
    expect(json['file']).to eq('f.js')
  end

  it 'should support multipart/form-data' do
    promise = Concurrent::Promises.resolvable_future
    sinatra.post('/empty.html') do
      promise.fulfill([
        request.request_method,
        request.env['CONTENT_TYPE'],
        Rack::Multipart.parse_multipart(request.env),
      ])
      ''
    end

    with_context do |context|
      context.request.post(server_empty_page,
        multipart: {
          first_name: 'John',
          last_name: 'Doe',
          file: {
            name: 'f.js',
            mimeType: 'text/javascript',
            buffer: "var x = 10;\r\n;console.log(x);"
          },
        })

      request_method, content_type, multipart = promise.value!
      expect(request_method).to eq('POST')
      expect(content_type).to start_with('multipart/form-data')
      expect(multipart['first_name']).to eq('John')
      expect(multipart['last_name']).to eq('Doe')
      expect(multipart['file'][:tempfile].read).to eq("var x = 10;\r\n;console.log(x);")
    end
  end

  it 'should throw when data passed for unsupported request' do
    with_context do |context|
      expect {
        context.request.fetch(server_empty_page, method: 'GET', data: { foo: 'bar' })
      }.to raise_error(/Method GET does not accept post data/)
    end
  end
end
