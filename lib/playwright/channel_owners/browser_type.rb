module Playwright
  define_channel_owner :BrowserType do
    define_initializer_reader \
      name: 'name',
      executable_path: 'executablePath'

    def launch(options)
      @channel.send_message_to_server('launch', options)
    end
  end
end
