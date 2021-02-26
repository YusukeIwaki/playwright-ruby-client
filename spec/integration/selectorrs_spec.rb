require 'spec_helper'

RSpec.describe Playwright::Selectors do
  it 'should work' do
    tag_selector = <<~JAVASCRIPT
    {
      query(root, selector) {
        return root.querySelector(selector);
      },
      queryAll(root, selector) {
        return Array.from(root.querySelectorAll(selector));
      }
    }
    JAVASCRIPT
    playwright.selectors.register('tag', script: tag_selector)

    with_page do |page|
      page.content = '<div><span></span></div><div></div>'

      expect(page.eval_on_selector('tag=DIV', '(e) => e.nodeName')).to eq('DIV')
      expect(page.eval_on_selector('tag=SPAN', '(e) => e.nodeName')).to eq('SPAN')
      expect(page.eval_on_selector_all('tag=DIV', '(es) => es.length')).to eq(2)

      # Selector names are case-sensitive.
      expect { page.query_selector('tAG=DIV') }.to raise_error(/Unknown engine "tAG" while parsing selector tAG=DIV/)
    end
  end

  it 'should work with path' do
    playwright.selectors.register('foo', path: File.join('spec', 'assets', 'sectionselectorengine.js'))
    with_page do |page|
      page.content = '<section></section>'
      expect(page.eval_on_selector('foo=whatever', 'e => e.nodeName')).to eq('SECTION')
    end
  end
end
