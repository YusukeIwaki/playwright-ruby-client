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

  # Every integration test case should spend less than 15sec.
  config.around(:each, type: :integration) do |example|
    Timeout.timeout(15) { example.run }
  end

  module IntegrationTestCaseMethods
    def browser
      @playwright_browser or raise NoMethodError.new('undefined method "browser"')
    end
  end
  config.include IntegrationTestCaseMethods, type: :integration
end
