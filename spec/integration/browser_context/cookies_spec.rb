require 'spec_helper'

# https://github.com/microsoft/playwright/blob/v1.65.1/tests/library/browsercontext-cookies.spec.ts
RSpec.describe 'BrowserContext#cookies' do
  it 'should only return cookies that apply to the url', annotation: { type: 'issue', description: 'https://github.com/microsoft/playwright/issues/43078' } do
    with_context do |context|
      context.add_cookies([
        { name: 'hostonly', value: 'v', domain: 'foo.com', path: '/api' },
        { name: 'subdomains', value: 'v', domain: '.foo.com', path: '/api' },
        { name: 'slash', value: 'v', domain: 'foo.com', path: '/foo/' },
      ])
      names = ->(url) { context.cookies(urls: url).map { |c| c['name'] }.sort }
      expect(names.call('http://foo.com/api')).to eq(%w[hostonly subdomains])
      expect(names.call('http://foo.com/api/x')).to eq(%w[hostonly subdomains])
      expect(names.call('http://foo.com/apiv2')).to eq([])
      expect(names.call('http://sub.foo.com/api')).to eq(['subdomains'])
      expect(names.call('http://notfoo.com/api')).to eq([])
      expect(names.call('http://foo.com/foo')).to eq([])
      expect(names.call('http://foo.com/foo/')).to eq(['slash'])
      expect(names.call('http://foo.com/foo/bar')).to eq(['slash'])
    end
  end
end
