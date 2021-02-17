module Playwright
  define_channel_owner :Download do
    def url
      @initializer['url']
    end

    def suggested_filename
      @initializer['suggestedFilename']
    end

    def delete
      @channel.send_message_to_server('delete')
    end

    def failure
      @channel.send_message_to_server('failure')
    end

    def path
      @channel.send_message_to_server('path')
    end

    def save_as(path)
      @channel.send_message_to_server('saveAs', path: path)
    end
  end
end
