require 'spec_helper'

# https://github.com/microsoft/playwright/blob/release-1.64/tests/library/global-fetch-cookie.spec.ts
RSpec.describe 'APIRequestContext cookies', sinatra: true do
  before do
    @request_context = playwright.request.new_context
  end

  after { @request_context.dispose }

  it 'addCookies should add cookies to the cookie jar' do
    @request_context.add_cookies([
      { name: 'a', value: 'b', url: server_empty_page },
      { name: 'c', value: 'd', domain: 'localhost', path: '/input', httpOnly: true, sameSite: 'Strict' },
      { name: 'e', value: 'f', domain: 'other.com', path: '/' },
    ])
    sinatra.get('/input/echo-cookie') { request.env['HTTP_COOKIE'] }
    expect(@request_context.get("#{server_prefix}/input/echo-cookie").text).to eq('a=b; c=d')
    expect(@request_context.cookies).to eq([
      { 'name' => 'a', 'value' => 'b', 'domain' => 'localhost', 'path' => '/', 'expires' => -1, 'httpOnly' => false, 'secure' => false, 'sameSite' => 'Lax' },
      { 'name' => 'c', 'value' => 'd', 'domain' => 'localhost', 'path' => '/input', 'expires' => -1, 'httpOnly' => true, 'secure' => false, 'sameSite' => 'Strict' },
      { 'name' => 'e', 'value' => 'f', 'domain' => 'other.com', 'path' => '/', 'expires' => -1, 'httpOnly' => false, 'secure' => false, 'sameSite' => 'Lax' },
    ])
  end

  it 'addCookies should validate cookies' do
    expect { @request_context.add_cookies([{ name: 'a', value: 'b' }]) }.to raise_error(/Cookie should have a url or a domain\/path pair/)
  end

  it 'cookies should return cookies filtered by urls' do
    @request_context.add_cookies([
      { name: 'a', value: 'b', domain: 'localhost', path: '/' },
      { name: 'c', value: 'd', domain: 'localhost', path: '/input' },
      { name: 'e', value: 'f', domain: 'one.com', path: '/' },
      { name: 'g', value: 'h', domain: 'two.com', path: '/', secure: true },
    ])
    expect(@request_context.cookies.map { |c| c['name'] }).to eq(%w[a c e g])
    expect(@request_context.cookies(urls: server_empty_page).map { |c| c['name'] }).to eq(['a'])
    expect(@request_context.cookies(urls: "#{server_prefix}/input/button.html").map { |c| c['name'] }).to eq(%w[a c])
    expect(@request_context.cookies(urls: ['http://sub.one.com/', 'http://two.com/']).map { |c| c['name'] }).to eq(['e'])
    expect(@request_context.cookies(urls: ['http://sub.one.com/', 'https://two.com/']).map { |c| c['name'] }).to eq(%w[e g])
    expect(@request_context.cookies(urls: 'http://other.com/')).to eq([])
  end

  it 'cookies should include cookies from Set-Cookie header' do
    sinatra.get('/setcookie.html') do
      headers 'Set-Cookie' => ['a=b; HttpOnly; SameSite=Strict', 'c=d; path=/input']
      ''
    end
    @request_context.get("#{server_prefix}/setcookie.html")
    expect(@request_context.cookies).to eq([
      { 'name' => 'a', 'value' => 'b', 'domain' => 'localhost', 'path' => '/', 'expires' => -1, 'httpOnly' => true, 'secure' => false, 'sameSite' => 'Strict' },
      { 'name' => 'c', 'value' => 'd', 'domain' => 'localhost', 'path' => '/input', 'expires' => -1, 'httpOnly' => false, 'secure' => false, 'sameSite' => 'Lax' },
    ])
  end

  it 'clearCookies should remove all cookies' do
    @request_context.add_cookies([
      { name: 'a', value: 'b', url: server_empty_page },
      { name: 'c', value: 'd', domain: 'one.com', path: '/' },
    ])
    @request_context.clear_cookies
    expect(@request_context.cookies).to eq([])
    sinatra.get('/echo-cookie') { request.env['HTTP_COOKIE'] || '<none>' }
    expect(@request_context.get("#{server_prefix}/echo-cookie").text).to eq('<none>')
  end

  it 'clearCookies should filter by name, domain and path' do
    @request_context.add_cookies([
      { name: 'session', value: '1', domain: 'one.com', path: '/' },
      { name: 'session', value: '2', domain: 'two.com', path: '/' },
      { name: 'session', value: '3', domain: 'two.com', path: '/api' },
      { name: 'other', value: '4', domain: 'one.com', path: '/' },
    ])
    values = -> { @request_context.cookies.map { |c| c['value'] }.sort }
    @request_context.clear_cookies(name: 'session', domain: 'two.com', path: '/api')
    expect(values.call).to eq(%w[1 2 4])
    @request_context.clear_cookies(domain: /one\.com$/)
    expect(values.call).to eq(['2'])
    @request_context.clear_cookies(name: /^sess/)
    expect(values.call).to eq([])
  end

  it 'clearCookies should remove nameless cookies by empty name' do
    @request_context.add_cookies([
      { name: '', value: 'nameless', domain: 'one.com', path: '/' },
      { name: 'session', value: 'secret', domain: 'one.com', path: '/' },
    ])
    @request_context.clear_cookies(name: '')
    expect(@request_context.cookies.map { |c| c['name'] }).to eq(['session'])
  end
end
