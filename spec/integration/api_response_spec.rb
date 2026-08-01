require 'spec_helper'
require 'socket'
require 'openssl'

# ref: https://github.com/microsoft/playwright/blob/v1.61.1/tests/library/global-fetch.spec.ts
RSpec.describe 'APIResponse#server_addr / #security_details', sinatra: true do
  def asset(path)
    File.join(__dir__, '../', 'assets', path)
  end

  def with_fresh_server(tls: false)
    tcp_server = TCPServer.new('127.0.0.1', 0)
    port = tcp_server.addr[1]
    acceptor = tcp_server

    if tls
      ssl_context = OpenSSL::SSL::SSLContext.new
      ssl_context.cert = OpenSSL::X509::Certificate.new(
        File.read(asset('client-certificates/server/server_cert.pem')),
      )
      ssl_context.key = OpenSSL::PKey.read(
        File.read(asset('client-certificates/server/server_key.pem')),
      )
      acceptor = OpenSSL::SSL::SSLServer.new(tcp_server, ssl_context)
    end

    server_thread = Thread.new do
      socket = acceptor.accept
      begin
        while (line = socket.gets)
          break if line == "\r\n"
        end
        body = 'Hello'
        socket.write(<<~HTTP.gsub("\n", "\r\n"))
          HTTP/1.1 200 OK
          Content-Length: #{body.bytesize}
          Connection: close

          #{body}
        HTTP
      ensure
        socket.close
      end
    end

    yield "#{tls ? 'https' : 'http'}://localhost:#{port}/"
  ensure
    tcp_server&.close
    server_thread&.join(2)
  end

  def expect_common_timing_order(timing)
    expect(timing['startTime']).to be_within(5_000).of(Time.now.to_f * 1000)
    expect(timing['domainLookupStart']).to eq(0)
    expect(timing['domainLookupEnd']).to be >= timing['domainLookupStart']
    expect(timing['connectStart']).to eq(timing['domainLookupEnd'])
    expect(timing['requestStart']).to eq(timing['connectEnd'])
    expect(timing['responseStart']).to be >= timing['requestStart']
    expect(timing['responseEnd']).to be >= timing['responseStart']
  end

  it 'should return server address from response' do
    with_context do |context|
      # The second request reuses the keep-alive socket and should report the address as well.
      2.times do
        response = context.request.get(server_empty_page)
        addr = response.server_addr
        expect(addr['ipAddress']).to match(/\A(127\.0\.0\.1|::1)\z/)
        expect(addr['port']).to eq(server_port)
      end
    end
  end

  it 'should return null security details for http response' do
    with_context do |context|
      response = context.request.get(server_empty_page)
      expect(response.security_details).to be_nil
    end
  end

  # https://github.com/microsoft/playwright/blob/v1.62.1/tests/library/browsercontext-fetch.spec.ts
  it 'should return timing' do
    # Use a fresh server to guarantee a new connection, because keep-alive sockets
    # from other tests do not have DNS/connect timings.
    with_fresh_server do |url|
      with_context do |context|
        response = context.request.get(url)
        expect(response).to be_ok
        timing = response.timing
        expect_common_timing_order(timing)
        expect(timing['secureConnectionStart']).to eq(-1)
        expect(timing['connectEnd']).to be >= timing['connectStart']
        expect(timing['responseEnd']).to be < 60_000
      end
    end
  end

  # https://github.com/microsoft/playwright/blob/v1.62.1/tests/library/browsercontext-fetch.spec.ts
  it 'should return timing for https' do
    # Use a fresh server to guarantee a new connection, because keep-alive sockets
    # from other tests do not have DNS/connect timings.
    with_fresh_server(tls: true) do |url|
      with_context do |context|
        response = context.request.get(url, ignoreHTTPSErrors: true)
        expect(response).to be_ok
        timing = response.timing
        expect_common_timing_order(timing)
        expect(timing['secureConnectionStart']).to be >= timing['connectStart']
        expect(timing['connectEnd']).to be >= timing['secureConnectionStart']
      end
    end
  end

  context 'over https', tls: true do
    # The local TLS server requires mutual TLS, so supply trusted client certs.
    it 'should return security details from response' do
      options = {
        ignoreHTTPSErrors: true,
        clientCertificates: [{
          origin: server_prefix,
          certPath: asset('client-certificates/client/trusted/cert.pem'),
          keyPath: asset('client-certificates/client/trusted/key.pem'),
        }],
      }
      with_context(**options) do |context|
        # The second request reuses the keep-alive socket and should report the details as well.
        2.times do
          response = context.request.get(server_empty_page)
          details = response.security_details
          expect(details).not_to be_nil
          expect(details['protocol']).to match(/\ATLSv1\.[23]\z/)
          expect(details['subjectName']).to be_a(String)
          expect(details['subjectName']).not_to be_empty
          expect(details['issuer']).to be_a(String)
          expect(details['issuer']).not_to be_empty
          expect(details['validFrom']).to be_a(Integer)
          expect(details['validTo']).to be_a(Integer)
          expect(details['validFrom']).to be < details['validTo']
        end
      end
    end
  end
end
