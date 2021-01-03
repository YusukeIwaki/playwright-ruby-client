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
