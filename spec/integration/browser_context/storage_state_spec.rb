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

  it 'should set storage state from a file path via set_storage_state' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'storage-state.json')
      File.write(path, JSON.dump({
        cookies: [{
          name: 'username',
          value: 'John Doe',
          domain: 'www.example.com',
          path: '/',
          expires: -1,
          httpOnly: false,
          secure: true,
          sameSite: 'Lax',
        }],
        origins: [{
          origin: 'https://www.example.com',
          localStorage: [{
            name: 'name1',
            value: 'value1',
          }],
        }],
      }))

      with_context do |context|
        context.set_storage_state(path)

        page = context.new_page
        page.route('**/*', ->(route, _) {
          route.fulfill(body: '<html></html>')
        })
        page.goto('https://www.example.com')

        expect(page.evaluate('window.localStorage')).to eq({ 'name1' => 'value1' })
        expect(page.evaluate('document.cookie')).to eq('username=John Doe')
      end
    end
  end

  # https://github.com/microsoft/playwright/blob/main/tests/library/browsercontext-storage-state.spec.ts
  it 'should replace storage state mid-context via set_storage_state' do
    with_context do |context|
      context.set_storage_state({
        cookies: [],
        origins: [{
          origin: 'https://www.example.com',
          localStorage: [{ name: 'name1', value: 'value1' }],
        }],
      })

      page = context.new_page
      page.route('**/*', ->(route, _) {
        route.fulfill(body: '<html></html>')
      })
      page.goto('https://www.example.com')
      expect(page.evaluate('window.localStorage')).to eq({ 'name1' => 'value1' })

      # Replace storage state
      context.set_storage_state({
        cookies: [],
        origins: [{
          origin: 'https://www.example.com',
          localStorage: [{ name: 'name2', value: 'value2' }],
        }],
      })
      expect(context.pages.length).to eq(1)
      page.goto('https://www.example.com')
      expect(page.evaluate('window.localStorage')).to eq({ 'name2' => 'value2' })
    end
  end

  it 'should raise a helpful error when set_storage_state file is missing' do
    with_context do |context|
      expect {
        context.set_storage_state('/path/to/missing-storage-state.json')
      }.to raise_error(Playwright::Error, /Failed to read storage state from/)
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

  # https://github.com/microsoft/playwright/blob/v1.62.1/tests/library/browsercontext-storage-state.spec.ts
  it 'should round-trip WebAuthn credentials with storageState' do
    context = browser.new_context
    context2 = nil
    begin
      credential = context.credentials.create('localhost')

      # Credentials are opt-in, omitted by default.
      expect(context.storage_state).to eq('cookies' => [], 'origins' => [])

      storage_state = context.storage_state(credentials: true)
      expect(storage_state).to eq(
        'cookies' => [],
        'origins' => [],
        'credentials' => [credential],
      )

      # A fresh context seeded from the storage state holds the same credential and round-trips equal.
      context2 = browser.new_context(storageState: storage_state)
      expect(context2.credentials.get).to eq([credential])
      expect(context2.storage_state(credentials: true)).to eq(storage_state)
    ensure
      context.close
      context2&.close
    end
  end

  # https://github.com/microsoft/playwright/blob/v1.62.1/tests/library/browsercontext-storage-state.spec.ts
  it 'setStorageState should replace credentials' do
    ctx_a = browser.new_context
    ctx_b = browser.new_context
    context = nil
    begin
      cred_a = ctx_a.credentials.create('a.example.com')
      state_a = ctx_a.storage_state(credentials: true)

      cred_b = ctx_b.credentials.create('b.example.com')
      state_b = ctx_b.storage_state(credentials: true)

      context = browser.new_context(storageState: state_a)
      expect(context.credentials.get).to eq([cred_a])

      # Replacing the storage state swaps in the new credentials.
      context.set_storage_state(state_b)
      expect(context.credentials.get).to eq([cred_b])

      # A storage state without credentials clears them.
      context.set_storage_state('cookies' => [], 'origins' => [])
      expect(context.credentials.get).to eq([])

      # Credentials can be installed again afterwards.
      context.set_storage_state(state_a)
      expect(context.credentials.get).to eq([cred_a])
    ensure
      ctx_a.close
      ctx_b.close
      context&.close
    end
  end
end

# https://github.com/microsoft/playwright/blob/v1.63.0/tests/library/browsercontext-storage-state.spec.ts
RSpec.describe 'OPFS storage state', sinatra: true do
  it 'should round-trip OPFS' do
    skip 'OPFS is unavailable in non-persistent WebKit contexts' if webkit?
    with_context do |context|
      page = context.new_page
      page.goto(server_empty_page)
      page.evaluate(<<~JS)
        async () => {
          const root = await navigator.storage.getDirectory();
          const nested = await root.getDirectoryHandle('nested', { create: true });
          await nested.getDirectoryHandle('empty', { create: true });
          const binary = await nested.getFileHandle('data.bin', { create: true });
          const binaryWritable = await binary.createWritable();
          await binaryWritable.write(new Uint8Array([0, 1, 2, 255]));
          await binaryWritable.close();
          const text = await root.getFileHandle('hello.txt', { create: true });
          const textWritable = await text.createWritable();
          await textWritable.write('Hello, world!');
          await textWritable.close();
        }
      JS
      expect(context.storage_state).to eq({ 'cookies' => [], 'origins' => [] })
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'storage-state.json')
        state = context.storage_state(path: path, opfs: true)
        expect(state['origins']).to eq([{
          'origin' => server_prefix,
          'localStorage' => [],
          'opfs' => [
            { 'path' => 'hello.txt', 'type' => 'file', 'base64' => 'SGVsbG8sIHdvcmxkIQ==' },
            { 'path' => 'nested', 'type' => 'directory' },
            { 'path' => 'nested/data.bin', 'type' => 'file', 'base64' => 'AAEC/w==' },
            { 'path' => 'nested/empty', 'type' => 'directory' },
          ],
        }])
        expect(JSON.parse(File.read(path))).to eq(state)
        # APIRequestContext#storage_state is not yet implemented by this Ruby client.
        check_context = lambda do |restored|
          expect(restored.storage_state(opfs: true)).to eq(state)
          check_page = restored.new_page
          check_page.goto(server_empty_page)
          result = check_page.evaluate(<<~JS)
            async () => {
              const root = await navigator.storage.getDirectory();
              const hello = await (await root.getFileHandle('hello.txt')).getFile();
              const nested = await root.getDirectoryHandle('nested');
              const data = await (await nested.getFileHandle('data.bin')).getFile();
              const empty = await nested.getDirectoryHandle('empty');
              const emptyEntries = [];
              for await (const name of empty.keys()) emptyEntries.push(name);
              return { text: await hello.text(), bytes: [...new Uint8Array(await data.arrayBuffer())], empty: emptyEntries };
            }
          JS
          expect(result).to eq({ 'text' => 'Hello, world!', 'bytes' => [0, 1, 2, 255], 'empty' => [] })
        end
        with_context(storageState: path) { |restored| check_context.call(restored) }
        with_context do |restored|
          stale_page = restored.new_page
          stale_page.goto(server_empty_page)
          stale_page.evaluate(<<~JS)
            async () => {
              const root = await navigator.storage.getDirectory();
              await root.getFileHandle('stale.txt', { create: true });
            }
          JS
          restored.set_storage_state(state)
          check_context.call(restored)
        end
      end
    end
  end

  it 'should round-trip OPFS in a persistent WebKit context' do
    skip unless webkit?
    skip 'Persistent contexts require a local browser type' if remote?
    Dir.mktmpdir do |dir|
      browser_type.launch_persistent_context(dir) do |context|
        page = context.pages.first
        page.goto(server_empty_page)
        page.evaluate(<<~JS)
          async () => {
            const root = await navigator.storage.getDirectory();
            await root.getDirectoryHandle('empty', { create: true });
            const file = await root.getFileHandle('hello.txt', { create: true });
            const writable = await file.createWritable();
            await writable.write('Hello, world!');
            await writable.close();
          }
        JS
        state = context.storage_state(opfs: true)
        expect(state['origins']).to eq([{
          'origin' => server_prefix,
          'localStorage' => [],
          'opfs' => [
            { 'path' => 'empty', 'type' => 'directory' },
            { 'path' => 'hello.txt', 'type' => 'file', 'base64' => 'SGVsbG8sIHdvcmxkIQ==' },
          ],
        }])
        page.evaluate(<<~JS)
          async () => {
            const root = await navigator.storage.getDirectory();
            await root.removeEntry('empty', { recursive: true });
            await root.removeEntry('hello.txt');
            await root.getFileHandle('stale.txt', { create: true });
          }
        JS
        context.set_storage_state(state)
        expect(context.storage_state(opfs: true)).to eq(state)
      end
    end
  end
end

# https://github.com/microsoft/playwright/blob/v1.63.0/tests/library/browsercontext-storage-state.spec.ts
RSpec.describe 'IndexedDB connection cleanup', sinatra: true do
  it 'should not leave IndexedDB connections open' do
    with_context do |context|
      page = context.new_page
      page.goto("#{server_prefix}/empty.html")
      page.evaluate(<<~JS)
        async () => {
          const openRequest = indexedDB.open('db', 1);
          openRequest.onupgradeneeded = () => openRequest.result.createObjectStore('store');
          await new Promise((resolve, reject) => {
            openRequest.onsuccess = () => {
              const db = openRequest.result;
              const transaction = db.transaction('store', 'readwrite');
              transaction.objectStore('store').put('value', 'key');
              transaction.oncomplete = () => {
                db.close();
                resolve();
              };
              transaction.onerror = () => reject(transaction.error);
            };
            openRequest.onerror = () => reject(openRequest.error);
          });
        }
      JS
      state = context.storage_state(indexedDB: true)
      page.evaluate(<<~JS)
        () => new Promise((resolve, reject) => {
          const request = indexedDB.deleteDatabase('db');
          request.onsuccess = () => resolve();
          request.onerror = () => reject(request.error);
          request.onblocked = () => reject(new Error('deleteDatabase was blocked'));
        })
      JS
      context.set_storage_state(state)
      expect(context.storage_state(indexedDB: true)).to eq(state)
    end
  end
end
