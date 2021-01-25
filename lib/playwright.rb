# frozen_string_literal: true

# namespace declaration
module Playwright; end

# concurrent-ruby
require 'concurrent'

# modules & constants
require 'playwright/errors'
require 'playwright/events'
require 'playwright/event_emitter'
require 'playwright/javascript'
require 'playwright/utils'

require 'playwright/channel'
require 'playwright/channel_owner'
require 'playwright/connection'
require 'playwright/timeout_settings'
require 'playwright/transport'
require 'playwright/url_matcher'
require 'playwright/version'
require 'playwright/wait_helper'

require 'playwright/playwright_api'
# load generated files
Dir[File.join(__dir__, 'playwright_api', '*.rb')].each { |f| require f }

module Playwright
  module_function def create(playwright_cli_executable_path:, &block)
    raise ArgumentError.new("block must be provided") unless block

    connection = Connection.new(playwright_cli_executable_path: playwright_cli_executable_path)

    playwright_promise = connection.async_wait_for_object_with_known_name('Playwright')
    Thread.new { connection.run }
    playwright = PlaywrightApi.from_channel_owner(playwright_promise.value!)
    begin
      block.call(playwright)
    ensure
      connection.stop
    end
  end
end
