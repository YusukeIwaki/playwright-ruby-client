# frozen_string_literal: true

require 'bundler/setup'
require 'playwright'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.define_derived_metadata(file_path: %r(/spec/development/generate_api/)) do |metadata|
    metadata[:type] = :generate_api
  end

  config.before(:context, type: :generate_api) do
    require './development/generate_api'
  end

  config.define_derived_metadata(file_path: %r(/spec/integration/)) do |metadata|
    metadata[:type] = :integration
  end

  browser_type = :chromium
  BROWSER_TYPES = %i(chromium webkit firefox)
  if BROWSER_TYPES.include?(ENV['BROWSER']&.to_sym)
    browser_type = ENV['BROWSER'].to_sym
  end

  config.around(:each, type: :integration) do |example|
    @playwright_browser_type = browser_type
    Playwright.create(playwright_cli_executable_path: ENV['PLAYWRIGHT_CLI_EXECUTABLE_PATH']) do |playwright|
      playwright.send(@playwright_browser_type).launch do |browser|
        @playwright_browser = browser
        example.run
      end
    end
  end

  module IntegrationTestCaseMethods
    def browser
      @playwright_browser or raise NoMethodError.new('undefined method "browser"')
    end

    def with_context(&block)
      unless @playwright_browser
        raise '@playwright_browser must not be null.'
      end
      context = @playwright_browser.new_context
      begin
        block.call(context)
      ensure
        context.close
      end
    end

    def with_page(&block)
      unless @playwright_browser
        raise '@playwright_browser must not be null.'
      end
      page = @playwright_browser.new_page
      begin
        block.call(page)
      ensure
        page.close
      end
    end
  end
  BROWSER_TYPES.each do |type|
    IntegrationTestCaseMethods.define_method("#{type}?") { @playwright_browser_type == type }
  end
  config.include IntegrationTestCaseMethods, type: :integration

  #   it 'can connect to /awesome', sinatra: true do
  #     url = "#{server_prefix}/awesome" # => http://localhost:4567/awesome
  #
  test_with_sinatra = Module.new do
    attr_reader :server_prefix, :server_cross_process_prefix, :server_empty_page, :sinatra
  end
  config.include(test_with_sinatra, sinatra: true)
  config.around(sinatra: true) do |example|
    require 'net/http'
    require 'sinatra/base'
    require 'timeout'

    sinatra_app = Sinatra.new
    sinatra_app.disable(:protection)
    sinatra_app.set(:public_folder, File.join(__dir__, 'assets'))
    @server_prefix = "http://localhost:4567"
    @server_cross_process_prefix = "http://127.0.0.1:4567"
    @server_empty_page = "#{@server_prefix}/empty.html"

    sinatra_app.get('/_ping') { '_pong' }

    # Start server and wait for server ready.
    # FIXME should change port when Errno::EADDRINUSE
    Thread.new { sinatra_app.run!(port: 4567) }
    Timeout.timeout(3) do
      loop do
        Net::HTTP.get(URI("#{server_prefix}/_ping"))
        break
      rescue Errno::EADDRNOTAVAIL
        sleep 1
      rescue Errno::ECONNREFUSED
        sleep 0.1
      end
    end

    begin
      @sinatra = sinatra_app
      example.run
    ensure
      sinatra_app.quit!
    end
  end

  # Every integration test case should spend less than 15sec, in CI.
  if ENV['CI']
    config.around(:each, type: :integration) do |example|
      Timeout.timeout(15) { example.run }
    end
  end
end
