require 'spec_helper'

# ref: https://github.com/microsoft/playwright/blob/v1.61.1/tests/library/browsercontext-webauthn.spec.ts
RSpec.describe 'BrowserContext#credentials (WebAuthn virtual authenticator)', sinatra: true do
  # localhost is a secure context, so navigator.credentials is available.
  let(:hostname) { 'localhost' }

  # Shared JS helper: WebAuthn assertion (sign-in) ceremony.
  GET_ASSERTION_JS = <<~JS
    async ({ rpId, credentialId }) => {
      const b64UrlToBytes = (s) => {
        let str = s.replace(/-/g, '+').replace(/_/g, '/');
        while (str.length % 4)
          str += '=';
        const bin = atob(str);
        const u8 = new Uint8Array(bin.length);
        for (let i = 0; i < bin.length; i++)
          u8[i] = bin.charCodeAt(i);
        return u8;
      };
      const challenge = crypto.getRandomValues(new Uint8Array(32));
      const allowCredentials = credentialId
        ? [{ type: 'public-key', id: b64UrlToBytes(credentialId) }]
        : undefined;
      const cred = await navigator.credentials.get({
        publicKey: { challenge, rpId, allowCredentials, userVerification: 'preferred' },
      });
      const resp = cred.response;
      return {
        id: cred.id,
        type: cred.type,
        hasClientData: resp.clientDataJSON.byteLength > 0,
        hasAuthData: resp.authenticatorData.byteLength > 0,
        hasSignature: resp.signature.byteLength > 0,
        authDataFlags: new Uint8Array(resp.authenticatorData)[32],
      };
    }
  JS

  it 'should not intercept navigator.credentials without install()' do
    context = browser.new_context
    begin
      # Seed a credential, but do not install the interceptor.
      context.credentials.create(hostname)
      page = context.new_page
      page.goto(server_empty_page)

      intercepted = page.evaluate("() => globalThis.__pwWebAuthnInstalled === true")
      expect(intercepted).to eq(false)
    ensure
      context.close
    end
  end

  it 'should seed a known credential and authenticate' do
    source = browser.new_context
    context = browser.new_context
    begin
      # The easiest way to create credentials; in practice this comes from the environment.
      known = source.credentials.create(hostname)

      # A fresh context imports the known credential and signs in with it.
      context.credentials.create(
        known['rpId'],
        id: known['id'],
        userHandle: known['userHandle'],
        privateKey: known['privateKey'],
        publicKey: known['publicKey'],
      )
      context.credentials.install
      page = context.new_page
      page.goto(server_empty_page)

      result = page.evaluate(GET_ASSERTION_JS, arg: { rpId: hostname, credentialId: known['id'] })

      expect(result['id']).to eq(known['id'])
      expect(result['type']).to eq('public-key')
      expect(result['hasClientData']).to eq(true)
      expect(result['hasAuthData']).to eq(true)
      expect(result['hasSignature']).to eq(true)
      # UP (0x01) | UV (0x04) = 0x05
      expect(result['authDataFlags'] & 0x05).to eq(0x05)

      # After the credential is deleted, the page can no longer authenticate with it.
      context.credentials.delete(known['id'])
      expect(context.credentials.get).to be_empty

      error = page.evaluate(<<~JS, arg: { rpId: hostname, credentialId: known['id'] })
        async ({ rpId, credentialId }) => {
          const b64UrlToBytes = (s) => {
            let str = s.replace(/-/g, '+').replace(/_/g, '/');
            while (str.length % 4)
              str += '=';
            const bin = atob(str);
            const u8 = new Uint8Array(bin.length);
            for (let i = 0; i < bin.length; i++)
              u8[i] = bin.charCodeAt(i);
            return u8;
          };
          const challenge = crypto.getRandomValues(new Uint8Array(32));
          try {
            await navigator.credentials.get({
              publicKey: {
                challenge,
                rpId,
                allowCredentials: [{ type: 'public-key', id: b64UrlToBytes(credentialId) }],
              },
            });
            return 'no-error';
          } catch (e) {
            return e.name;
          }
        }
      JS
      expect(error).to eq('NotAllowedError')
    ensure
      source.close
      context.close
    end
  end

  it 'should capture a page-created credential and reuse it in another context' do
    setup_context = browser.new_context
    context = browser.new_context
    begin
      # Setup context: the app registers a passkey via navigator.credentials.create().
      setup_context.credentials.install
      setup_page = setup_context.new_page
      setup_page.goto(server_empty_page)

      created_id = setup_page.evaluate(<<~JS, arg: { rpId: hostname })
        async ({ rpId }) => {
          const challenge = crypto.getRandomValues(new Uint8Array(32));
          const created = await navigator.credentials.create({
            publicKey: {
              challenge,
              rp: { id: rpId, name: 'Test RP' },
              user: { id: new Uint8Array([1, 2, 3, 4]), name: 'u', displayName: 'User' },
              pubKeyCredParams: [{ type: 'public-key', alg: -7 }],
              authenticatorSelection: { residentKey: 'required', userVerification: 'preferred' },
            },
          });
          return created.id;
        }
      JS

      captured = setup_context.credentials.get(rpId: hostname).first
      expect(captured['id']).to eq(created_id)
      expect(captured['privateKey']).to match(/\A[A-Za-z0-9_-]+\z/)
      expect(captured['publicKey']).to match(/\A[A-Za-z0-9_-]+\z/)

      # Reuse the captured passkey in a fresh context and sign in with it.
      context.credentials.create(
        captured['rpId'],
        id: captured['id'],
        userHandle: captured['userHandle'],
        privateKey: captured['privateKey'],
        publicKey: captured['publicKey'],
      )
      context.credentials.install
      page = context.new_page
      page.goto(server_empty_page)

      # No allowCredentials - relies on the re-seeded credential being discoverable.
      got_id = page.evaluate(GET_ASSERTION_JS, arg: { rpId: hostname, credentialId: nil })
      expect(got_id['id']).to eq(created_id)
    ensure
      setup_context.close
      context.close
    end
  end
end
