module Playwright
  define_channel_owner :Browser do
    define_initializer_reader \
      version: 'version'

      def close
        @channel.send_message_to_server('close', {})
      end
  end
end
