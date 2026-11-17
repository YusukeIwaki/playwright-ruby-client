require 'spec_helper'

# https://github.com/microsoft/playwright/blob/v1.65.1/tests/page/page-fill.spec.ts
RSpec.describe 'page-fill' do
  it 'should retry on inert element', annotation: { type: 'issue', description: 'https://github.com/microsoft/playwright/issues/42967' } do
    with_page do |page|
      page.set_content(<<~HTML)
        <div inert id=container>
          <input id=target>
        </div>
        <input id=outside>
      HTML
      page.focus('#outside')

      promise = Concurrent::Promises.future { page.fill('#target', 'some value') }
      give_it_a_chance_to_resolve(page)
      expect(promise).not_to be_resolved
      expect(page.eval_on_selector('#target', 'i => i.value')).to eq('')
      expect(page.eval_on_selector('#outside', 'i => i.value')).to eq('')

      page.eval_on_selector('#container', "e => e.removeAttribute('inert')")
      Timeout.timeout(5) { promise.value! }
      expect(page.eval_on_selector('#target', 'i => i.value')).to eq('some value')
      expect(page.eval_on_selector('#outside', 'i => i.value')).to eq('')
    end
  end

  it 'should fail with a nice error on inert element' do
    with_page do |page|
      page.set_content('<div inert><input></div>')
      expect {
        page.fill('input', 'some value', timeout: 1000)
      }.to raise_error(/Timeout 1000ms exceeded.*element is inert/m)
    end
  end
end
