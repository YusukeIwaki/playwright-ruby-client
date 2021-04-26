# frozen_string_literal: true

# namespace declaration
module Playwright; end

# concurrent-ruby and its wrappers
require 'concurrent'
require 'playwright/async_evaluation'
require 'playwright/async_value'

# modules & constants
require 'playwright/errors'
require 'playwright/events'
require 'playwright/event_emitter'
require 'playwright/event_emitter_proxy'
require 'playwright/javascript'
require 'playwright/utils'

require 'playwright/api_implementation'
require 'playwright/channel'
require 'playwright/channel_owner'
require 'playwright/download'
require 'playwright/http_headers'
require 'playwright/input_files'
require 'playwright/connection'
require 'playwright/route_handler_entry'
require 'playwright/select_option_values'
require 'playwright/timeout_settings'
require 'playwright/transport'
require 'playwright/url_matcher'
require 'playwright/version'
require 'playwright/video'
require 'playwright/wait_helper'

require 'playwright/playwright_api'
# load generated files
Dir[File.join(__dir__, 'playwright_api', '*.rb')].each { |f| require f }

module Playwright
  # Recommended to call this method with block.
  #
  # Playwright.create(...) do |playwright|
  #   browser = playwright.chromium.launch
  #   ...
  # end
  #
  # When we use this method without block, an instance of Puppeteer::Connection is returned
  # and we *must* call connection.stop on the end.
  # The instance of playwright is available by calling Playwright.instance
  module_function def create(playwright_cli_executable_path:, &block)
    raise ArgumentError.new("block must be provided") unless block

    connection = Connection.new(playwright_cli_executable_path: playwright_cli_executable_path)
    connection.async_run

    begin
      playwright = connection.wait_for_object_with_known_name('Playwright')
      ::Playwright.instance_variable_set(:@playwright_instance, PlaywrightApi.wrap(playwright))
    rescue
      connection.stop
      ::Playwright.instance_variable_set(:@playwright_instance, nil)
      raise
    end

    if block
      begin
        block.call(::Playwright.instance)
      ensure
        connection.stop
        ::Playwright.instance_variable_set(:@playwright_instance, nil)
      end
    else
      connection
    end
  end

  module_function def instance
    @playwright_instance
  end
end
