require 'spec_helper'
require 'tmpdir'

RSpec.describe 'BrowserContext#storage_state' do
  it 'should capture local storage' do
    with_context do |context|
      page1 = context.new_page
      page1.route('**/*', ->(route, _) {
        route.fulfill(body: '<html></html>')
      })
      page1.goto('https://www.example.com')
      page1.evaluate(<<~JAVASCRIPT)
      () => {
        localStorage['name1'] = 'value1';
      }
      JAVASCRIPT
      page1.goto('https://www.domain.com')
      page1.evaluate(<<~JAVASCRIPT)
      () => {
        localStorage['name2'] = 'value2';
      }
      JAVASCRIPT

      expect(context.storage_state['origins']).to eq([
        {
          'origin' => 'https://www.domain.com',
          'localStorage' => [{
            'name' => 'name2',
            'value' => 'value2'
          }],
        },
        {
          'origin' => 'https://www.example.com',
          'localStorage' => [{
            'name' => 'name1',
            'value' => 'value1'
          }],
        },
      ])
    end
  end

  it 'should set local storage' do
    state = {
      origins: [
        {
          origin: 'https://www.example.com',
          localStorage: [{
            name: 'name1',
            value: 'value1'
          }],
        },
      ],
    }

    with_context(storageState: state) do |context|
      page = context.new_page
      page.route('**/*', ->(route, _) {
        route.fulfill(body: '<html></html>')
      })
      page.goto('https://www.example.com')
      local_storage = page.evaluate('window.localStorage')
      expect(local_storage).to eq({ 'name1' => 'value1' })
    end
  end

  it 'should round-trip through the file' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'storage-state.json')

      with_context do |context|
        page = context.new_page
        page.route('**/*', ->(route, _) {
          route.fulfill(body: '<html></html>')
        })
        page.goto('https://www.example.com')
        page.evaluate(<<~JAVASCRIPT)
        () => {
          localStorage['name1'] = 'value1';
          document.cookie = 'username=John Doe';
          return document.cookie;
        }
        JAVASCRIPT

        state = context.storage_state(path: path)
        written = File.read(path)
        expect(state).to eq(JSON.parse(written))
      end

      with_page(storageState: path) do |page|
        page.route('**/*', ->(route, _) {
          route.fulfill(body: '<html></html>')
        })
        page.goto('https://www.example.com')

        local_storage = page.evaluate('window.localStorage')
        expect(local_storage).to eq({ 'name1' => 'value1' })

        cookie = page.evaluate('document.cookie')
        expect(cookie).to eq('username=John Doe')
      end
    end
  end
end
