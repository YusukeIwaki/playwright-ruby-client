require 'spec_helper'

RSpec.describe 'Page#workers' do
  it 'Page.workers', sinatra: true do
    with_page do |page|
      worker = page.expect_worker do
        page.goto("#{server_prefix}/worker/worker.html")
      end
      expect(page.workers.first).to eq(worker)
      expect(worker.url).to include('worker.js')
      expect(worker.evaluate("() => self['workerFunction']()")).to eq('worker function result')

      page.goto(server_empty_page)
      expect(page.workers).to be_empty
    end
  end

  it 'should emit created and destroyed events' do
    with_page do |page|
      worker_obj = nil
      worker = page.expect_worker do
        worker_obj = page.evaluate_handle("() => new Worker(URL.createObjectURL(new Blob(['1'], {type: 'application/javascript'})))")
      end
      worker_this = worker.evaluate_handle('() => this')
      worker_destroyed_promise = Concurrent::Promises.resolvable_future
      worker.once('close', ->(w) { worker_destroyed_promise.fulfill(w) })
      page.evaluate('workerObj => workerObj.terminate()', arg: worker_obj)
      expect(worker_destroyed_promise.value!).to eq(worker)
      expect { worker_this.get_property('self') }.to raise_error(/Worker was closed|Target closed/)
    end
  end

  it 'should report console logs' do
    with_page do |page|
      message = page.expect_event('console') do
        page.evaluate("() => new Worker(URL.createObjectURL(new Blob(['console.log(1)'], {type: 'application/javascript'})))")
      end
      expect(message.text).to eq('1')

      # Firefox's juggler had an issue that reported worker blob urls as frame urls.
      expect(page.url).not_to include('blob')
    end
  end

  it 'should have JSHandles for console logs' do
    with_page do |page|
      log = page.expect_event('console') do
        page.evaluate("() => new Worker(URL.createObjectURL(new Blob(['console.log(1,2,3,this)'], {type: 'application/javascript'})))")
      end
      expect(log.text).to eq('1 2 3 DedicatedWorkerGlobalScope')
      expect(log.args.size).to eq(4)
      expect(log.args.last.get_property('origin').json_value).to eq('null')
    end
  end

  it 'should evaluate' do
    with_page do |page|
      worker = page.expect_worker do
        page.evaluate("() => new Worker(URL.createObjectURL(new Blob(['console.log(1)'], {type: 'application/javascript'})))")
      end
      expect(worker.evaluate('1+1')).to eq(2)
    end
  end

  it 'should report errors' do
    with_page do |page|
      error = page.expect_event('pageerror') do
        page.evaluate(<<~JAVASCRIPT)
        () => new Worker(URL.createObjectURL(new Blob([`
          setTimeout(() => {
            // Do a console.log just to check that we do not confuse it with an error.
            console.log('hey');
            throw new Error('this is my error');
          })
        `], {type: 'application/javascript'})))
        JAVASCRIPT
      end
      expect(error.message).to include('this is my error')
    end
  end

  it 'should clear upon navigation', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      worker = page.expect_worker do
        page.evaluate("() => new Worker(URL.createObjectURL(new Blob(['console.log(1)'], {type: 'application/javascript'})))")
      end
      expect(page.workers.size).to eq(1)
      expect(page.workers.first).to eq(worker)

      worker_closed_promise = Concurrent::Promises.resolvable_future
      worker.once('close', ->(w) { worker_closed_promise.fulfill(w) })
      page.goto("#{server_prefix}/one-style.html")
      expect(page.workers).to be_empty
      Timeout.timeout(1) { worker_closed_promise.value! }
    end
  end

  it 'should clear upon cross-process navigation', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      worker = page.expect_worker do
        page.evaluate("() => new Worker(URL.createObjectURL(new Blob(['console.log(1)'], {type: 'application/javascript'})))")
      end
      expect(page.workers.size).to eq(1)
      expect(page.workers.first).to eq(worker)

      worker_closed_promise = Concurrent::Promises.resolvable_future
      worker.once('close', ->(w) { worker_closed_promise.fulfill(w) })
      page.goto("#{server_cross_process_prefix}/empty.html")
      expect(page.workers).to be_empty
      Timeout.timeout(1) { worker_closed_promise.value! }
    end
  end

  it 'should report network activity', sinatra: true do
    with_page do |page|
      worker = page.expect_worker do
        page.goto("#{server_prefix}/worker/worker.html")
      end
      url = "#{server_prefix}/one-style.css"
      response = page.expect_response(url) do
        request = page.expect_request(url) do
          worker.evaluate("url => fetch(url).then(response => response.text()).then(console.log)", arg: url)
        end
        expect(request.url).to eq(url)
      end
      expect(response.url).to eq(url)
      expect(response.ok).to eq(true)
    end
  end

  it 'should report network activity on worker creation', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      url = "#{server_prefix}/one-style.css"
      response = page.expect_response(url) do
        request = page.expect_request(url) do
          page.evaluate(<<~JAVASCRIPT, arg: url)
          url => new Worker(URL.createObjectURL(new Blob([`
            fetch("${url}").then(response => response.text()).then(console.log);
          `], {type: 'application/javascript'})))
          JAVASCRIPT
        end
        expect(request.url).to eq(url)
      end
      expect(response.url).to eq(url)
      expect(response.ok).to eq(true)
    end
  end
end
