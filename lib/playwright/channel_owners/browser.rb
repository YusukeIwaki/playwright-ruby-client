module Playwright
  define_channel_owner :Browser do
    define_initializer_reader \
      version: 'version'

  end
end
