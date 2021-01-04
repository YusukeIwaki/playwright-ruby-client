# frozen_string_literal: true

# namespace declaration
module Playwright; end

# concurrent-ruby
require 'concurrent'

# modules & constants
require 'playwright/errors'
require 'playwright/event_emitter'

require 'playwright/channel'
require 'playwright/channel_owner'
require 'playwright/connection'
require 'playwright/transport'
require 'playwright/version'

# load generated files
Dir[File.join(__dir__, 'playwright_api', '*.rb')].each { |f| require f }

module Playwright
  module_function def method_missing(method, *args, **kwargs, &block)
    @playwright ||= ::Playwright::Playwright.new
    if kwargs.empty? # for Ruby < 2.7
      @playwright.public_send(method, *args, &block)
    else
      @playwright.public_send(method, *args, **kwargs, &block)
    end
  end
end
