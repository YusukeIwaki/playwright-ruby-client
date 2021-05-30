module Playwright
  define_channel_owner :BindingCall do
    def name
      @initializer['name']
    end

    # @param callback [Proc]
    def call(callback)
      frame = ChannelOwners::Frame.from(@initializer['frame'])
      # It is not desired to use PlaywrightApi.wrap directly.
      # However it is a little difficult to define wrapper for `source` parameter in generate_api.
      # Just a workaround...
      source = {
        context: PlaywrightApi.wrap(frame.page.context),
        page: PlaywrightApi.wrap(frame.page),
        frame: PlaywrightApi.wrap(frame),
      }
      result =
        if @initializer['handle']
          handle = ChannelOwners::ElementHandle.from(@initializer['handle'])
          callback.call(source, handle)
        else
          args = @initializer['args'].map do |arg|
            JavaScript::ValueParser.new(arg).parse
          end
          callback.call(source, *args)
        end

      @channel.send_message_to_server('resolve', result: JavaScript::ValueSerializer.new(result).serialize)
    rescue => err
      @channel.send_message_to_server('reject', error: { error: { message: err.message, name: 'Error' }})
    end
  end
end
