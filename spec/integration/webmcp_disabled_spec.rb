require 'spec_helper'

# https://github.com/microsoft/playwright/blob/release-1.64/tests/library/webmcp-disabled.spec.ts
RSpec.describe 'WebMCP without browser support' do
  it 'should throw when the browser was launched without WebMCP' do
    skip 'WebKit does not implement WebMCP' if webkit?
    with_page do |page|
      expect { page.webmcp.tools }.to raise_error { |error|
        expect(error.message).to include('WebMCP is not enabled.')
        expect(error.message).to include(firefox? ? 'dom.modelcontext.enabled' : '--enable-features=WebMCP')
      }
    end
  end
end
