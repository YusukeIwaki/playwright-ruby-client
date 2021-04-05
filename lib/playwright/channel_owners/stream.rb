require 'base64'

module Playwright
  define_channel_owner :Stream do
    def save_as(path)
      File.open(path, 'wb') do |f|
        loop do
          binary = @channel.send_message_to_server('read')
          break if !binary || binary.length == 0
          f.write(Base64.strict_decode64(binary))
        end
      end
    end
  end
end
