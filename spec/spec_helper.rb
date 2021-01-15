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

  config.around(:each, type: :integration) do |example|
    Playwright.create(playwright_cli_executable_path: ENV['PLAYWRIGHT_CLI_EXECUTABLE_PATH']) do |playwright|
      playwright.chromium.launch do |browser|
        @playwright_browser = browser
        example.run
      end
    end
  end

  module IntegrationTestCaseMethods
    def browser
      @playwright_browser or raise NoMethodError.new('undefined method "browser"')
    end
  end
  config.include IntegrationTestCaseMethods, type: :integration

  module SinatraRouting
    #
    # describe 'something awesome' do
    #   sinatra do
    #     get('/awesome') { 'Awesome!' }
    #   end
    #
    #   it 'can connect to /awesome' do
    #     url = "#{server_prefix}/awesome" # => http://localhost:4567/awesome
    #
    def sinatra(port: 4567, &block)
      require 'net/http'
      require 'sinatra/base'
      require 'timeout'

      sinatra_app = Sinatra.new(&block)
      sinatra_app.set(:public_folder, File.join(__dir__, 'assets'))

      let(:sinatra) { sinatra_app }
      let(:server_prefix) { "http://localhost:#{port}" }
      around do |example|
        sinatra_app.get('/_ping') { '_pong' }

        # Start server and wait for server ready.
        Thread.new { sinatra_app.run!(port: port) }
        Timeout.timeout(3) do
          loop do
            Net::HTTP.get(URI("#{server_prefix}/_ping"))
            break
          rescue Errno::ECONNREFUSED
            sleep 0.1
          end
        end

        begin
          example.run
        ensure
          sinatra.quit!
        end
      end
    end
  end
  RSpec::Core::ExampleGroup.extend(SinatraRouting)

  # Every integration test case should spend less than 15sec.
  config.around(:each, type: :integration) do |example|
    Timeout.timeout(15) { example.run }
  end
end
