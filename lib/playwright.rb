# frozen_string_literal: true

# namespace declaration
module Playwright; end

# concurrent-ruby
require 'concurrent'

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
  class Execution
    def initialize(connection, playwright)
      @connection = connection
      @playwright = playwright
    end

    def stop
      @connection.stop
    end

    attr_reader :playwright
  end

  # Recommended to call this method with block.
  #
  # Playwright.create(...) do |playwright|
  #   browser = playwright.chromium.launch
  #   ...
  # end
  #
  # When we use this method without block, an instance of Puppeteer::Execution is returned
  # and we *must* call execution.stop on the end.
  # The instance of playwright is available by calling execution.playwright
  module_function def create(playwright_cli_executable_path:, &block)
    transport = Transport.new(playwright_cli_executable_path: playwright_cli_executable_path)
    connection = Connection.new(transport)
    connection.async_run

    execution =
      begin
        playwright = connection.wait_for_object_with_known_name('Playwright')
        Execution.new(connection, PlaywrightApi.wrap(playwright))
      rescue
        connection.stop
        raise
      end

    if block
      begin
        block.call(execution.playwright)
      ensure
        execution.stop
      end
    else
      execution
    end
  end

  # Connects to Playwright server, launched by `npx playwright run-server` via WebSocket transport.
  #
  # Playwright.connect_to_playwright_server(...) do |playwright|
  #   browser = playwright.chromium.launch
  #   ...
  # end
  #
  # @experimental
  module_function def connect_to_playwright_server(ws_endpoint, &block)
    require 'playwright/web_socket'
    require 'playwright/web_socket_transport'

    transport = WebSocketTransport.new(ws_endpoint: ws_endpoint)
    connection = Connection.new(transport)
    connection.async_run

    execution =
      begin
        playwright = connection.wait_for_object_with_known_name('Playwright')
        Execution.new(connection, PlaywrightApi.wrap(playwright))
      rescue
        connection.stop
        raise
      end

    if block
      begin
        block.call(execution.playwright)
      ensure
        execution.stop
      end
    else
      execution
    end
  end
end
