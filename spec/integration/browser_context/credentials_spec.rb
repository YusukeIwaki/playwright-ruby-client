require 'spec_helper'
require 'base64'

# https://github.com/microsoft/playwright/blob/v1.63.0/tests/library/browsercontext-credentials.spec.ts
RSpec.describe 'HTTP credentials', sinatra: true do
  before do
    sinatra.before('/empty.html') do
      auth = Rack::Auth::Basic::Request.new(request.env)
      unless auth.provided? && auth.basic? && auth.credentials == ['user', 'pass']
        headers 'WWW-Authenticate' => 'Basic realm="test"'
        halt 401
      end
    end
  end

  it 'should work with correct credentials' do
    with_page(httpCredentials: { username: 'user', password: 'pass' }) do |page|
      expect(page.goto(server_empty_page).status).to eq(200)
    end
  end

  it 'should work with a single credential in an array' do
    with_page(httpCredentials: [{ username: 'user', password: 'pass' }]) do |page|
      expect(page.goto(server_empty_page).status).to eq(200)
    end
  end

  it 'should work with multiple credentials for different origins' do
    with_page(httpCredentials: [
      { username: 'user', password: 'pass', origin: server_prefix },
      { username: 'user2', password: 'pass2', origin: server_cross_process_prefix },
    ]) do |page|
      expect(page.goto(server_empty_page).status).to eq(200)
      expect(page.goto("#{server_cross_process_prefix}/empty.html").status).to eq(401)
    end
  end

  it 'should fall back to credentials without origin' do
    with_page(httpCredentials: [
      { username: 'user2', password: 'pass2', origin: server_cross_process_prefix },
      { username: 'user', password: 'pass' },
    ]) do |page|
      expect(page.goto(server_empty_page).status).to eq(200)
      expect(page.goto("#{server_cross_process_prefix}/empty.html").status).to eq(401)
    end
  end

  it 'should use the first matching credential' do
    with_page(httpCredentials: [
      { username: 'wrong', password: 'wrong' },
      { username: 'user', password: 'pass', origin: server_prefix },
    ]) do |page|
      expect(page.goto(server_empty_page).status).to eq(401)
    end
  end

  # https://github.com/microsoft/playwright/pull/42313
  it "should not override Authorization header set by the page" do
    sinatra.get('/echo-auth') { request.env['HTTP_AUTHORIZATION'] || '<none>' }
    with_page(httpCredentials: { username: 'user', password: 'pass' }) do |page|
      expect(page.goto(server_empty_page).status).to eq(200)
      received = page.evaluate(<<~JS)
        async () => {
          const response = await fetch('/echo-auth', { headers: { Authorization: 'Bearer my-own-app-token' } });
          return await response.text();
        }
      JS
      expect(received).to eq('Bearer my-own-app-token')
    end
  end
end
