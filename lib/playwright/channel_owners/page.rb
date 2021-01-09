module Playwright
  define_channel_owner :Page do
    attr_writer :owned_context
  end
end
