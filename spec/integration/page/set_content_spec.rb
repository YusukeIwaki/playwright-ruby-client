require 'spec_helper'

# https://github.com/microsoft/playwright/blob/release-1.64/tests/page/page-set-content.spec.ts
RSpec.describe 'Page#set_content' do
  it 'should include shadow roots' do
    with_page do |page|
      html = '<!DOCTYPE html><html lang="en"><head></head><body><div id="host"><template shadowrootmode="open"><div id="nested"><template shadowrootmode="open"><span>nested</span></template><slot></slot></div></template><span>light</span></div><div id="closed"></div></body></html>'
      page.content = html.sub('<div id="closed">', '<div id="closed"><template shadowrootmode="closed"><span>closed</span></template>')
      expect(page.content).to eq('<!DOCTYPE html><html lang="en"><head></head><body><div id="host"><span>light</span></div><div id="closed"></div></body></html>')
      expect(page.content(includeShadow: true)).to eq(html)
      expect(page.main_frame.content(includeShadow: true)).to eq(html)
    end
  end
end
