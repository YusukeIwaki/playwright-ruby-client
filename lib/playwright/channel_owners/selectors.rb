module Playwright
  # https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_selectors.py
  define_channel_owner :Selectors do
    def register(name, contentScript: nil, path: nil, script: nil)
      source =
        if path
          File.read(path)
        elsif script
          script
        else
          raise ArgumentError.new('Either path or script parameter must be specified')
        end
      params = { name: name, source: source }
      if contentScript
        params[:contentScript] = true
      end
      @channel.send_message_to_server('register', params)

      nil
    end
  end
end
