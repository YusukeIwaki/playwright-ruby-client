require 'spec_helper'

# ref: https://github.com/microsoft/playwright/blob/v1.61.1/tests/library/global-fetch.spec.ts
RSpec.describe 'APIResponse#server_addr / #security_details', sinatra: true do
  def asset(path)
    File.join(__dir__, '../', 'assets', path)
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
