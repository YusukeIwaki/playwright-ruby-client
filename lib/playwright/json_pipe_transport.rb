# frozen_string_literal: true

module Playwright
  class JsonPipeTransport
    def initialize(local_utils, params)
      @local_utils = local_utils
      @params = params
    end

    def on_message_received(&block)
      @on_message = block
    end

    def on_driver_closed(&block)
      @on_driver_closed = block
    end

    def on_driver_crashed(&block)
      @on_driver_crashed = block
    end

    def send_message(message)
      @pipe.channel.send_message_to_server('send', message: message)
    end

    def stop
      @pipe&.channel&.send_message_to_server('close')
    rescue TargetClosedError
      nil
    ensure
      @pipe = nil
    end

    def async_run
      @pipe = @local_utils.connect(@params)
      @pipe.channel.on('message', ->(params) { @on_message&.call(params['message']) })
      @pipe.channel.on('closed', ->(_params) { @on_driver_closed&.call })
    end
  end
end
