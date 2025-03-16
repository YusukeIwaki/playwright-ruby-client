require 'spec_helper'
require 'tmpdir'
require 'playwright/test'

RSpec.describe 'BrowserContext#storage_state' do
  include Playwright::Test::Matchers

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

  it 'should support IndexedDB', sinatra: true do
    storage_state = nil
    with_page do |page|
      page.goto("#{server_prefix}/to-do-notifications/index.html")
      page.get_by_label('Task title').fill('Pet the cat')
      page.get_by_label('Hours').fill('1')
      page.get_by_label('Mins').fill('1')
      page.get_by_text('Add Task').click()

      storage_state = page.context.storage_state(indexedDB: true)
      expect(storage_state['origins']).to eq([
        {
          'origin' => server_prefix,
          'localStorage' => [],
          'indexedDB' => [
            'name' => 'toDoList',
            'version' => 4,
            'stores' => [
              {
                'name' => 'toDoList',
                'autoIncrement' => false,
                'keyPath' => 'taskTitle',
                'records' => [
                  {
                    'value' => {
                      'day' => '01',
                      'hours' => '1',
                      'minutes' => '1',
                      'month' => 'January',
                      'notified' => 'no',
                      'taskTitle' => 'Pet the cat',
                      'year' => '2025',
                    },
                  },
                ],
                'indexes' => [
                  {
                    'name' => 'day',
                    'keyPath' => 'day',
                    'multiEntry' => false,
                    'unique' => false,
                  },
                  {
                    'name' => 'hours',
                    'keyPath' => 'hours',
                    'multiEntry' => false,
                    'unique' => false,
                  },
                  {
                    'name' => 'minutes',
                    'keyPath' => 'minutes',
                    'multiEntry' => false,
                    'unique' => false,
                  },
                  {
                    'name' => 'month',
                    'keyPath' => 'month',
                    'multiEntry' => false,
                    'unique' => false,
                  },
                  {
                    'name' => 'notified',
                    'keyPath' => 'notified',
                    'multiEntry' => false,
                    'unique' => false,
                  },
                  {
                    'name' => 'year',
                    'keyPath' => 'year',
                    'multiEntry' => false,
                    'unique' => false,
                  },
                ],
              },
            ],
          ],
        },
      ])
    end

    with_context(storageState: storage_state) do |context|
      expect(context.storage_state(indexedDB: true)).to eq(storage_state)

      recreated_page = context.new_page
      recreated_page.goto("#{server_prefix}/to-do-notifications/index.html")
      expect(recreated_page.locator('#task-list')).to match_aria_snapshot(<<~YAML)
        - list:
          - listitem:
            - text: /Pet the cat/
      YAML

      expect(context.storage_state).to eq('cookies' => [], 'origins' => [])
    end
  end
end
