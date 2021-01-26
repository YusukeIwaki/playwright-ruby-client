module Playwright
  define_input_type :Keyboard do
    def down(key)
      @channel.send_message_to_server('keyboardDown', key: key)
      nil
    end

    def up(key)
      @channel.send_message_to_server('keyboardDown', key: key)
    end

    def insert_text(text)
      @channel.send_message_to_server('keyboardInsertText', text: text)
    end

    def type_text(text, delay: nil)
      params = {
        text: text,
        delay: delay,
      }.compact
      @channel.send_message_to_server('keyboardType', params)
    end

    def press(key, delay: nil)
      params = {
        key: key,
        delay: delay,
      }.compact
      @channel.send_message_to_server('keyboardPress', params)
    end
  end
end
