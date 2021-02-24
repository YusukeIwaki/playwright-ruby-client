module Playwright
  define_channel_owner :Dialog do
    def type
      @initializer['type']
    end

    def message
      @initializer['message']
    end

    def default_value
      @initializer['defaultValue']
    end

    def accept(promptText: nil)
      accept_async(prompt_text: promptText).value!
    end

    def accept_async(promptText: nil)
      params = { promptText: promptText }.compact
      @channel.async_send_message_to_server('accept', params)
    end

    def dismiss
      @channel.async_send_message_to_server('dismiss')
    end
  end
end
