require 'spec_helper'

RSpec.describe 'client certificates', sinatra: true, tls: true do
  before { skip unless chromium? }

  it 'should validate input 1' do
    options = {
      ignoreHTTPSErrors: true,
      clientCertificates: [{ origin: 'test' }]
    }
    expect {
      with_context(**options) do |context|
        context.new_page
      end
    }.to raise_error(/None of cert, key, passphrase or pfx is specified/)
  end

  it 'should validate input 2' do
    kDummyFileName = '__filename'
    options = {
      ignoreHTTPSErrors: true,
      clientCertificates: [{
        origin: 'test',
        certPath: kDummyFileName,
        keyPath: kDummyFileName,
        pfxPath: kDummyFileName,
        passphrase: kDummyFileName,
      }]
    }
    expect {
      with_context(**options) do |context|
        context.new_page
      end
    }.to raise_error(/pfx is specified together with cert, key or passphrase/)
  end

  it 'should fail with no client certificates provided' do
    with_context(ignoreHTTPSErrors: true) do |context|
      page = context.new_page
      expect {
        page.goto(server_empty_page)
      }.to raise_error(/net::ERR_EMPTY_RESPONSE|net::ERR_CONNECTION_RESET|net::ERR_SOCKET_NOT_CONNECTED|The network connection was lost|Connection terminated unexpectedly/)
    end
  end

  def asset(path)
    File.join(__dir__, '../', 'assets', path)
  end

  it 'should throw with untrusted client certs' do
    options = {
      ignoreHTTPSErrors: true,
      clientCertificates: [{
        origin: server_prefix,
        certPath: asset('client-certificates/client/self-signed/cert.pem'),
        keyPath: asset('client-certificates/client/self-signed/key.pem'),
      }]
    }
    with_context(**options) do |context|
      page = context.new_page
      expect {
        page.goto(server_empty_page)
      }.to raise_error(/net::ERR_EMPTY_RESPONSE|The network connection was lost|Connection terminated unexpectedly/)
    end
  end

  it 'should pass with trusted client certificates' do
    options = {
      ignoreHTTPSErrors: true,
      clientCertificates: [{
        origin: server_prefix,
        certPath: asset('client-certificates/client/trusted/cert.pem'),
        keyPath: asset('client-certificates/client/trusted/key.pem'),
      }]
    }
    with_context(**options) do |context|
      page = context.new_page
      page.goto("#{server_prefix}/one-style.html")
      expect(page.content).to include('hello, world!')
    end
  end

  it 'should pass with trusted client certificates in base64 format' do
    options = {
      ignoreHTTPSErrors: true,
      clientCertificates: [{
        origin: server_prefix,
        cert: Base64.encode64(File.read(asset('client-certificates/client/trusted/cert.pem'))),
        key: Base64.encode64(File.read(asset('client-certificates/client/trusted/key.pem'))),
      }]
    }
    with_context(**options) do |context|
      page = context.new_page
      page.goto("#{server_prefix}/one-style.html")
      expect(page.content).to include('hello, world!')
    end
  end

  it 'should pass with trusted client certificates in pfx format' do
    options = {
      ignoreHTTPSErrors: true,
      clientCertificates: [{
        origin: server_prefix,
        pfxPath: asset('client-certificates/client/trusted/cert.pfx'),
        passphrase: 'secure'
      }]
    }
    with_context(**options) do |context|
      page = context.new_page
      page.goto("#{server_prefix}/one-style.html")
      expect(page.content).to include('hello, world!')
    end
  end

  it 'should pass with trusted client certificates in pfx format with base64 encoded' do
    options = {
      ignoreHTTPSErrors: true,
      clientCertificates: [{
        origin: server_prefix,
        pfx: Base64.encode64(File.read(asset('client-certificates/client/trusted/cert.pfx'))),
        passphrase: 'secure'
      }]
    }
    with_context(**options) do |context|
      page = context.new_page
      page.goto("#{server_prefix}/one-style.html")
      expect(page.content).to include('hello, world!')
    end
  end

  it 'should throw a http error if the pfx passphrase is incorect' do
    options = {
      ignoreHTTPSErrors: true,
      clientCertificates: [{
        origin: server_prefix,
        pfxPath: asset('client-certificates/client/trusted/cert.pfx'),
        passphrase: 'this-password-is-incorrect'
      }]
    }

    expect {
      with_context(**options) do |context|
        page = context.new_page
      end
    }.to raise_error(/mac verify failure/)
  end

  it 'should fail with matching certificates in legacy pfx format', skip: ENV['CI'] do
    options = {
      ignoreHTTPSErrors: true,
      clientCertificates: [{
        origin: server_prefix,
        pfxPath: asset('client-certificates/client/trusted/cert-legacy.pfx'),
        passphrase: 'secure'
      }]
    }
    expect {
      with_context(**options) do |context|
        page = context.new_page
      end
    }.to raise_error(/Unsupported TLS certificate/)
  end
end
