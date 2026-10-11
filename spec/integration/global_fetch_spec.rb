require 'spec_helper'
require 'base64'

# https://github.com/microsoft/playwright/blob/v1.63.0/tests/library/global-fetch.spec.ts
RSpec.describe 'APIRequest credentials', sinatra: true do
  it 'should support httpCredentials option' do
    sinatra.use Rack::Auth::Basic do |username, password|
      username == 'user' && password == 'pass'
    end
    request = playwright.request.new_context(httpCredentials: { username: 'user', password: 'pass' })
    begin
      expect(request.get(server_empty_page).status).to eq(200)
    ensure
      request.dispose
    end
  end

  it 'should support multiple httpCredentials' do
    sinatra.use Rack::Auth::Basic do |username, password|
      username == 'user1' && password == 'pass1'
    end
    request = playwright.request.new_context(httpCredentials: [
      { username: 'user1', password: 'pass1', origin: server_prefix },
      { username: 'user2', password: 'pass2', origin: server_cross_process_prefix },
    ])
    begin
      expect(request.get(server_empty_page).status).to eq(200)
      expect(request.get("#{server_cross_process_prefix}/empty.html").status).to eq(401)
    ensure
      request.dispose
    end
  end

  it 'should support HTTPCredentials.send with multiple httpCredentials' do
    authorizations = []
    sinatra.get('/empty.html') do
      authorizations << request.env['HTTP_AUTHORIZATION']
      ''
    end
    request = playwright.request.new_context(httpCredentials: [
      { username: 'user1', password: 'pass1', origin: server_prefix, send: 'always' },
      { username: 'user2', password: 'pass2', origin: server_cross_process_prefix, send: 'unauthorized' },
    ])
    begin
      expect(request.get(server_empty_page).status).to eq(200)
      expect(authorizations).to eq(["Basic #{Base64.strict_encode64('user1:pass1')}"])
      expect(request.get("#{server_cross_process_prefix}/empty.html").status).to eq(200)
      expect(authorizations.last).to be_nil
    ensure
      request.dispose
    end
  end

  # https://github.com/microsoft/playwright/blob/release-1.64/tests/library/global-fetch.spec.ts
  it 'should expose node error code on network errors' do
    # A TCP reset is the Ruby equivalent of the upstream socket.resetAndDestroy().
    tcp_server = TCPServer.new('127.0.0.1', 0)
    server_thread = Thread.new do
      socket = tcp_server.accept
      socket.readpartial(4096)
      socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_LINGER, [1, 0].pack('ii'))
      socket.close
    end
    request = playwright.request.new_context
    begin
      expect { request.get("http://127.0.0.1:#{tcp_server.addr[1]}/reset", maxRetries: 0) }.to raise_error { |error|
        expect(error.message).to include('ECONNRESET')
        expect(error.code).to eq('ECONNRESET')
      }
    ensure
      request.dispose
      tcp_server.close
      server_thread.join
    end
  end

end
