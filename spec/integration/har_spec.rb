require 'spec_helper'
require 'open3'
require 'tmpdir'

RSpec.describe 'HAR' do
  def parse_har_file(file)
    har = JSON.parse(File.read(file))
    har['log']
  end

  def parse_har_zip(file)
    content, stderr, status = Open3.capture3('unzip', '-p', file, 'har.har')
    raise "failed to read har archive:\n#{stderr}" unless status.success?

    { 'har.har' => content }
  end

  def with_page_with_har(**options, &block)
    Dir.mktmpdir do |dir|
      har_path = File.join(dir, 'test.har')

      options[:record_har_path] = har_path
      with_context(**options) do |context|
        block.call(context.new_page)
      end
      parse_har_file(har_path)
    end
  end

  it 'should have version and creator', sinatra: true do
    log = with_page_with_har do |page|
      page.goto(server_empty_page)
    end
    expect(log['version']).to eq('1.2')
    expect(log['creator']['name']).to eq('Playwright')
  end

  it 'should omit content', sinatra: true do
    log = with_page_with_har(record_har_content: :omit) do |page|
      page.goto("#{server_prefix}/har.html")
      page.evaluate("() => fetch('/pptr.png').then(r => r.arrayBuffer())")
    end

    entry = log['entries'].first
    expect(entry.dig(*%w(response content text))).to be_nil
  end

  it 'should omit content legacy', sinatra: true do
    log = with_page_with_har(record_har_omit_content: true) do |page|
      page.goto("#{server_prefix}/har.html")
      page.evaluate("() => fetch('/pptr.png').then(r => r.arrayBuffer())")
    end

    entry = log['entries'].first
    expect(entry.dig(*%w(response content text))).to be_nil
  end

  it 'should filter by glob', sinatra: true do
    log = with_page_with_har(baseURL: server_prefix, record_har_url_filter: '/*.css') do |page|
      page.goto('/har.html')
    end
    expect(log['entries'].count).to eq(1)
    expect(log['entries'].first['request']['url']).to end_with('/one-style.css')
  end

  it 'should filter by regexp', sinatra: true do
    log = with_page_with_har(record_har_url_filter: /HAR.X?HTML/i) do |page|
      page.goto("#{server_prefix}/har.html")
    end
    expect(log['entries'].count).to eq(1)
    expect(log['entries'].first['request']['url']).to end_with('/har.html')
  end

  it 'should have different hars for concurrent contexts' do
    log1 = nil
    log0 = with_page_with_har do |page0|
      page0.goto('data:text/html,<title>Zero</title>')
      page0.wait_for_load_state(state: 'domcontentloaded')

      log1 = with_page_with_har do |page1|
        page1.goto('data:text/html,<title>One</title>')
        page1.wait_for_load_state(state: 'domcontentloaded')
      end
    end

    expect(log0['pages'].count).to eq(1)
    expect(log0['pages'].first['title']).to eq('Zero')
    expect(log1['pages'].count).to eq(1)
    expect(log1['pages'].first['title']).to eq('One')
    expect(log0['pages'].first['id']).not_to eq(log1['pages'].first['id'])
  end

  it 'should return server address directly from response', sinatra: true do
    with_page do |page|
      response = page.goto(server_empty_page)
      addr = response.server_addr
      expect(addr['ipAddress']).to match(/^127\.0\.0\.1|\[::1\]/)
      expect(addr['port']).to eq(server_port)
    end
  end

  it 'should return http version from response', sinatra: true do
    with_page do |page|
      response = page.goto(server_empty_page)
      expect(response.http_version).to eq('HTTP/1.1')
    end
  end

  # https://github.com/microsoft/playwright/blob/v1.60.0/tests/library/har.spec.ts
  describe 'tracing.startHar' do
    it 'should record a HAR with options', sinatra: true do
      Dir.mktmpdir do |dir|
        har_path = File.join(dir, 'tracing.har')

        with_context do |context|
          context.tracing.start_har(har_path, mode: 'minimal', urlFilter: '**/one-style.css')
          page = context.new_page
          page.goto("#{server_prefix}/one-style.html")
          context.tracing.stop_har
        end

        log = parse_har_file(har_path)
        urls = log['entries'].map { |entry| entry['request']['url'] }
        expect(urls).to eq(["#{server_prefix}/one-style.css"])
        expect(log['entries'][0]['request']['bodySize']).to eq(-1)
      end
    end

    it 'should record a zipped HAR for APIRequestContext', sinatra: true do
      Dir.mktmpdir do |dir|
        request = playwright.request.new_context
        har_path = File.join(dir, 'tracing.har.zip')
        request.tracing.start_har(har_path, content: 'attach')
        request.get("#{server_prefix}/simple.json")
        request.tracing.stop_har
        request.dispose

        resources = parse_har_zip(har_path)
        log = JSON.parse(resources['har.har'])['log']
        expect(log['entries'].any? { |entry| entry['request']['url'] == "#{server_prefix}/simple.json" }).to eq(true)
      end
    end

    it 'should record a HAR with resourcesDir', sinatra: true do
      pending 'resourcesDir is JS only at this moment'
      Dir.mktmpdir do |dir|
        har_path = File.join(dir, 'tracing.har')
        resources_dir = File.join(dir, 'har-resources')

        with_context do |context|
          context.tracing.start_har(har_path, content: 'attach', resourcesDir: resources_dir)
          page = context.new_page
          page.goto("#{server_prefix}/one-style.html")
          context.tracing.stop_har
        end

        log = parse_har_file(har_path)
        style_entry = log['entries'].find { |entry| entry['request']['url'].end_with?('/one-style.css') }
        sha1 = style_entry.dig('response', 'content', '_file')
        expect(sha1).to be_truthy

        resource_path = File.join(resources_dir, sha1)
        expect(File.exist?(resource_path)).to eq(true)
        expect(File.read(resource_path)).to include('pink')
      end
    end

    it 'should reject resourcesDir together with a .zip har file' do
      pending 'resourcesDir is JS only at this moment'
      Dir.mktmpdir do |dir|
        with_context do |context|
          har_path = File.join(dir, 'tracing.har.zip')
          resources_dir = File.join(dir, 'har-resources')

          expect {
            context.tracing.start_har(har_path, content: 'attach', resourcesDir: resources_dir)
          }.to raise_error(/resourcesDir option is not compatible with a \.zip har file/)
        end
      end
    end
  end
end
