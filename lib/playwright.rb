# frozen_string_literal: true

# namespace declaration
module Playwright; end

# socketry/async and wrappers.
require 'async'
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
  module_function def create(playwright_cli_executable_path:, timeout: nil, &block)
    raise ArgumentError.new("block must be provided") unless block

    connection = Connection.new(playwright_cli_executable_path: playwright_cli_executable_path)
    Async do
      connection.async_run

      Async do |task|
        playwright = connection.wait_for_object_with_known_name('Playwright')
        playwright_api = PlaywrightApi.wrap(playwright)
        if timeout
          task.with_timeout(timeout) do
            block.call(playwright_api)
          end
        else
          block.call(playwright_api)
        end
      ensure
        connection.stop
      end
    end
  end
end
