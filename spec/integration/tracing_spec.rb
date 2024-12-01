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
        categories: ['disabled-by-default-v8.cpu_profiler.hires'],
      )
      page.goto("#{server_prefix}/grid.html")
      browser.stop_tracing

      trace_json = JSON.parse(File.read(output_trace_file))
      expect(trace_json.dig('metadata', 'trace-config')).to include('disabled-by-default-v8.cpu_profiler.hires')
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
