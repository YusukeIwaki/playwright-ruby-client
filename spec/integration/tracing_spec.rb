require 'spec_helper'
require 'securerandom'
require 'tmpdir'

# https://github.com/microsoft/playwright/blob/master/tests/chromium/tracing.spec.ts
# https://github.com/microsoft/playwright-python/blob/master/tests/async/test_tracing.py
RSpec.describe 'tracing' do
  before { skip unless chromium? }

  let(:output_trace_file) { "trace-#{SecureRandom.hex(8)}.json" }
  after do
    File.delete(output_trace_file) if File.exist?(output_trace_file)
  end

  it 'should output a trace', sinatra: true do
    with_page do |page|
      browser.start_tracing(page: page, screenshots: true, path: output_trace_file)
      page.goto("#{server_prefix}/grid.html")
      browser.stop_tracing
      expect(File.exist?(output_trace_file)).to eq(true)
    end
  end

  it 'should create directories as needed', sinatra: true do
    with_page do |page|
      Dir.mktmpdir do |dir|
        file_path = File.join(dir, 'these', 'are', 'directories', output_trace_file)
        browser.start_tracing(page: page, screenshots: true, path: file_path)
        page.goto("#{server_prefix}/grid.html")
        browser.stop_tracing
        expect(File.exist?(file_path)).to eq(true)
      end
    end
  end

  it 'should run with custom categories if provided', sinatra: true do
    with_page do |page|
      browser.start_tracing(
        page: page,
        path: output_trace_file,
        categories: ['disabled-by-default-cc.debug'],
      )
      page.goto("#{server_prefix}/grid.html")
      browser.stop_tracing

      trace_json = JSON.parse(File.read(output_trace_file))
      # NOTE: trace-config is deprecated as per http://crrev.com/c/6628182
      expect(trace_json['traceEvents'].map { |e| e['cat'] }).to include('disabled-by-default-cc.debug')
    end
  end

  it 'should throw if tracing on two pages' do
    with_page do |page|
      browser.start_tracing(page: page)

      new_page = browser.new_page
      expect {
          browser.start_tracing(page: new_page)
      }.to raise_error(/Cannot start recording trace while already recording trace./)
    end
  end

  it 'should return a buffer', sinatra: true do
    with_page do |page|
      browser.start_tracing(page: page, screenshots: true, path: output_trace_file)
      page.goto("#{server_prefix}/grid.html")
      trace = browser.stop_tracing
      expect(trace).to eq(File.read(output_trace_file))
    end
  end

  it 'should work without options', sinatra: true do
    with_page do |page|
      browser.start_tracing(page: page)
      page.goto("#{server_prefix}/grid.html")
      trace = browser.stop_tracing
      expect(trace).to be_a(String)
    end
  end

  it 'should support a buffer without a path', sinatra: true do
    with_page do |page|
      browser.start_tracing(page: page, screenshots: true)
      page.goto("#{server_prefix}/grid.html")
      trace = browser.stop_tracing
      expect(trace).to include('screenshot')
    end
  end
end

# https://github.com/microsoft/playwright/blob/master/tests/tracing.spec.ts
RSpec.describe 'tracing' do
  before { skip unless chromium? }

  it 'should collect trace with resources, but no js', sinatra: true, tracing: true do
    with_context do |context|
      page = context.new_page

      context.tracing.start(screenshots: true, snapshots: true)
      page.goto("#{server_prefix}/frames/frame.html")
      page.content = '<button>Click</button>'
      page.click('"Click"')
      sleep 2 # Give it some time to produce screenshots.
      page.close
      Dir.mktmpdir do |dir|
        trace = File.join(dir, 'trace.zip')
        context.tracing.stop(path: trace)
      end
    end
  end

  it 'should collect trace', sinatra: true, tracing: true do
    with_context do |context|
      page = context.new_page

      context.tracing.start(name: 'test')
      page.goto(server_empty_page)
      page.content = '<button>Click</button>'
      page.click('"Click"')
      page.close
      Dir.mktmpdir do |dir|
        trace = File.join(dir, 'trace.zip')
        context.tracing.stop(path: trace)
      end
    end
  end

  it 'should collect two trace', sinatra: true, tracing: true do
    Dir.mktmpdir do |trace_dir|
      with_context do |context|
        page = context.new_page

        context.tracing.start(name: 'test1', screenshots: true, snapshots: true)
        page.goto(server_empty_page)
        page.content = '<button>Click</button>'
        page.click('"Click"')
        Dir.mktmpdir do |dir|
          trace = File.join(dir, 'trace1.zip')
          context.tracing.stop(path: trace)
        end

        context.tracing.start(name: 'test2', screenshots: true, snapshots: true)
        page.dblclick('"Click"')
        page.close
        Dir.mktmpdir do |dir|
          trace = File.join(dir, 'trace2.zip')
          context.tracing.stop(path: trace)
        end
      end
    end
  end

  it 'can call tracing.group/groupEnd at any time and auto-close', sinatra: true, tracing: true do
    with_context do |context|
      context.tracing.group('ignored')
      context.tracing.group_end
      context.tracing.group('ignored2')
      context.tracing.start
      context.tracing.group('actual')

      page = context.new_page
      page.goto(server_empty_page)
      Dir.mktmpdir do |dir|
        trace = File.join(dir, 'trace.zip')
        context.tracing.stop_chunk(path: trace)
      end

      context.tracing.group('ignored3')
      context.tracing.group_end
      context.tracing.group_end
      context.tracing.group_end
    end
  end

  it 'should throw when stopping without start', tracing: true do
    with_context do |context|
      Dir.mktmpdir do |dir|
        trace = File.join(dir, 'trace.zip')
        expect { context.tracing.stop(path: trace) }.to raise_error(/Must start tracing before stopping/)
      end
    end
  end

  it 'should not throw when stopping without start but not exporting', tracing: true do
    with_context do |context|
      context.tracing.stop
    end
  end

  it 'should work with multiple chunks', sinatra: true, tracing: true do
    with_context do |context|
      context.tracing.start(screenshots: true, snapshots: true)
      page = context.new_page
      page.goto("#{server_prefix}/frames/frame.html")

      context.tracing.start_chunk
      page.content = '<button>Click</button>'
      page.click('"Click"')
      page.click('"ClickNoButton"', timeout: 10) rescue nil
      Dir.mktmpdir do |dir|
        trace = File.join(dir, 'trace.zip')
        context.tracing.stop_chunk(path: trace)
      end

      context.tracing.start_chunk
      page.hover('"Click"')
      Dir.mktmpdir do |dir|
        trace = File.join(dir, 'trace2.zip')
        context.tracing.stop_chunk(path: trace)
      end

      context.tracing.start_chunk
      page.click('"Click"')
      context.tracing.stop_chunk # Should stop without a path.
    end
  end
end

# https://github.com/microsoft/playwright/blob/v1.63.0/tests/library/tracing.spec.ts
RSpec.describe 'tracing snapshots and failure recovery', sinatra: true do
  require 'open3'
  require 'chunky_png'

  def read_trace(path)
    names, error, status = Open3.capture3('unzip', '-Z1', path)
    raise error unless status.success?
    resources = names.lines.map(&:strip).reject { |name| name.end_with?('/') }.to_h do |name|
      content, error, status = Open3.capture3('unzip', '-p', path, name)
      raise error unless status.success?
      [name, content]
    end
    events = resources.select { |name, _| name.end_with?('.trace', '.network') }.values.flat_map do |data|
      data.lines.reject { |line| line.strip.empty? }.map { |line| JSON.parse(line) }
    end
    [events, resources]
  end

  it 'should not collect action screenshots and aria snapshots by default' do
    with_context do |context|
      context.tracing.start(snapshots: true)
      page = context.new_page
      page.goto("#{server_prefix}/input/button.html")
      page.click('button')
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'trace.zip')
        context.tracing.stop(path: path)
        events, = read_trace(path)
        expect(events.map { |event| event['type'] }).not_to include('screenshot', 'aria-snapshot')
        expect(events.map { |event| event['type'] }).to include('frame-snapshot', 'resource-snapshot')
      end
    end
  end

  it 'should collect action screenshots' do
    with_context do |context|
      context.tracing.start(screenSnapshots: true)
      page = context.new_page
      page.goto("#{server_prefix}/input/button.html")
      page.click('button')
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'trace.zip')
        context.tracing.stop(path: path)
        events, resources = read_trace(path)
        call_id = events.find { |event| event['type'] == 'before' && event['method'] == 'click' }['callId']
        screenshots = events.select { |event| event['type'] == 'screenshot' && event['callId'] == call_id }
        expect(screenshots.map { |event| event['phase'] }).to eq(%w[before action after])
        screenshots.each do |event|
          expect(event['file']).to eq("screenshots/#{call_id}-#{event['phase']}.png")
          expect(ChunkyPNG::Image.from_blob(resources[event['file']]).width).to be > 0
        end
      end
    end
  end

  it 'should collect aria snapshots' do
    with_context do |context|
      context.tracing.start(ariaSnapshots: true)
      page = context.new_page
      page.goto("#{server_prefix}/input/button.html")
      page.click('button')
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'trace.zip')
        context.tracing.stop(path: path)
        events, resources = read_trace(path)
        call_id = events.find { |event| event['type'] == 'before' && event['method'] == 'click' }['callId']
        snapshots = events.select { |event| event['type'] == 'aria-snapshot' && event['callId'] == call_id }
        expect(snapshots.map { |event| event['phase'] }).to eq(%w[before action after])
        has_button = lambda do |nodes|
          nodes.any? do |node|
            node.is_a?(Hash) && ((node['role'] == 'button' && node['name'] == 'Click target') || has_button.call(node['children'] || []))
          end
        end
        snapshots.each do |event|
          expect(event['file']).to eq("aria/#{call_id}-#{event['phase']}.json")
          expect(has_button.call(JSON.parse(resources[event['file']]))).to eq(true)
        end
      end
    end
  end

  it 'should record context API request trace independently' do
    sinatra.post('/simple.json') do
      content_type :json
      '{"foo":"bar"}'
    end
    with_context do |context|
      expect(context.request.tracing).not_to eq(context.tracing)
      context.tracing.start(snapshots: true)
      context.request.tracing.start(snapshots: true)
      page = context.new_page
      page.goto("#{server_prefix}/one-style.html")
      api_url = "#{server_prefix}/simple.json"
      page.request.post(api_url, data: { foo: 'bar' })
      Dir.mktmpdir do |dir|
        browser_path = File.join(dir, 'browser.zip')
        api_path = File.join(dir, 'api.zip')
        context.tracing.stop(path: browser_path)
        context.request.tracing.stop(path: api_path)
        browser_events, = read_trace(browser_path)
        api_events, api_resources = read_trace(api_path)
        browser_urls = browser_events.select { |event| event['type'] == 'resource-snapshot' }.map { |event| event.dig('snapshot', 'request', 'url') }
        expect(browser_urls).to include("#{server_prefix}/one-style.html")
        expect(browser_urls).not_to include(api_url)
        requests = api_events.select { |event| event['type'] == 'resource-snapshot' }
        expect(requests.map { |event| event.dig('snapshot', 'request', 'url') }).to eq([api_url])
        expect(requests.first['snapshot']['_apiRequestRef']).to match(/^request-context@/)
        api_action = api_events.find { |event| event['type'] == 'before' && event['method'] == 'fetch' }
        expect(api_action).not_to be_nil
        expect(api_events.any? { |event| event['type'] == 'before' && event['method'] == 'goto' }).to eq(false)
        unless remote?
          stacks = JSON.parse(api_resources.fetch('trace.stacks'))
          call_stack = stacks['stacks'].find { |id, _| "call@#{id}" == api_action['callId'] }
          expect(call_stack).not_to be_nil
          first_frame = call_stack[1].first
          expect(stacks['files'][first_frame[0]]).to eq(File.expand_path(__FILE__))
          expect(first_frame[2]).to eq(0)
        end
      end
    end
  end

  it 'should recover tracing after a failed stop' do
    with_context do |context|
      Dir.mktmpdir do |dir|
        blocker = File.join(dir, 'blocker')
        File.write(blocker, '')
        context.tracing.start
        expect { context.tracing.stop(path: File.join(blocker, 'trace.zip')) }.to raise_error(/ENOTDIR|ENOENT|EEXIST|Not a directory|File exists/)
        context.tracing.start
        page = context.new_page
        page.goto("#{server_prefix}/input/button.html")
        page.click('button')
        path = File.join(dir, 'trace.zip')
        context.tracing.stop(path: path)
        events, = read_trace(path)
        expect(events.first['type']).to eq('context-options')
        expect(events.any? { |event| event['type'] == 'before' && event['method'] == 'click' }).to eq(true)
      end
    end
  end

  it 'should release the stack session when saving the trace fails' do
    skip 'Remote clients do not own a local stack session' if remote?
    with_context do |context|
      context.tracing.start
      stacks_id = Playwright::PlaywrightApi.unwrap(context.tracing).instance_variable_get(:@stacks_id)
      stacks_dir = File.dirname(stacks_id)
      expect(File.directory?(stacks_dir)).to eq(true)
      Dir.mktmpdir do |dir|
        blocker = File.join(dir, 'blocker')
        File.write(blocker, '')
        expect { context.tracing.stop(path: File.join(blocker, 'trace.zip')) }.to raise_error(/ENOTDIR|ENOENT|EEXIST/)
        expect(File.exist?(stacks_dir)).to eq(false)
      end
    end
  end
end
