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
