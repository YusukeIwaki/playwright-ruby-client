module Playwright
  define_channel_owner :BrowserType do
    define_initializer_reader \
      name: 'name',
      executable_path: 'executablePath'

    def launch
    end
  end
end
