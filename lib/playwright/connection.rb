# frozen_string_literal: true

module Playwright
  # https://github.com/microsoft/playwright/blob/master/src/client/connection.ts
  # https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_connection.py
  # https://github.com/microsoft/playwright-java/blob/master/playwright/src/main/java/com/microsoft/playwright/impl/Connection.java
  class Connection
    def initialize(playwright_cli_executable_path:)
      @transport = Transport.new(
        playwright_cli_executable_path: playwright_cli_executable_path
      )
      @transport.on_message_received do |message|
        dispatch(message)
      end
      @transport.on_driver_crashed do
        @callbacks.each_value do |callback|
          callback.reject(::Playwright::DriverCrashedError.new)
        end
        raise ::Playwright::DriverCrashedError.new
      end

      @objects = {} # Hash[ guid => ChannelOwner ]
      @waiting_for_object = {} # Hash[ guid => Promise<ChannelOwner> ]
      @callbacks = {} # Hash [ guid => Promise<ChannelOwner> ]
      @root_object = RootChannelOwner.new(self)
    end

    def async_run
      @transport.async_run
    end

    def stop
      @transport.stop
    end

    def wait_for_object_with_known_name(guid)
      if @objects[guid]
        return @objects[guid]
      end

      callback = AsyncValue.new
      @waiting_for_object[guid] = callback
      callback.value!
    end

    def async_send_message_to_server(guid, method, params)
      callback = AsyncValue.new

      with_generated_id do |id|
        # register callback promise object first.
        # @see https://github.com/YusukeIwaki/puppeteer-ruby/pull/34
        @callbacks[id] = callback

        message = {
          id: id,
          guid: guid,
          method: method,
          params: replace_channels_with_guids(params),
        }
        begin
          @transport.send_message(message)
        rescue => err
          @callbacks.delete(id)
          callback.reject(err)
          raise unless err.is_a?(Transport::AlreadyDisconnectedError)
        end
      end

      callback
    end

    def send_message_to_server(guid, method, params)
      async_send_message_to_server(guid, method, params).value!
    end

    private

    # ```usage
    # connection.with_generated_id do |id|
    #   # play with id
    # end
    # ````
    def with_generated_id(&block)
      @last_id ||= 0
      block.call(@last_id += 1)
    end

    # @param guid [String]
    # @param parent [Playwright::ChannelOwner]
    # @note This method should be used internally. Accessed via .send method from Playwright::ChannelOwner, so keep private!
    def update_object_from_channel_owner(guid, parent)
      @objects[guid] = parent
    end

    # @param guid [String]
    # @note This method should be used internally. Accessed via .send method from Playwright::ChannelOwner, so keep private!
    def delete_object_from_channel_owner(guid)
      @objects.delete(guid)
    end

    def dispatch(msg)
      id = msg['id']
      if id
        callback = @callbacks.delete(id)

        unless callback
          raise "Cannot find command to respond: #{id}"
        end

        error = msg['error']
        if error
          callback.reject(::Playwright::Error.parse(error['error']))
        else
          result = replace_guids_with_channels(msg['result'])
          callback.fulfill(result)
        end

        return
      end

      guid = msg['guid']
      method = msg['method']
      params = msg['params']

      if method == "__create__"
        create_remote_object(
          parent_guid: guid,
          type: params["type"],
          guid: params["guid"],
          initializer: params["initializer"],
        )
        return
      end

      if method == "__dispose__"
        object = @objects[guid]
        unless object
          raise "Cannot find object to dispose: #{guid}"
        end
        object.send(:dispose!)
        return
      end

      object = @objects[guid]
      unless object
        raise "Cannot find object to emit \"#{method}\": #{guid}"
      end
      object.channel.emit(method, replace_guids_with_channels(params))
    end

    def replace_channels_with_guids(payload)
      if payload.nil?
        return nil
      end

      if payload.is_a?(Array)
        return payload.map{ |pl| replace_channels_with_guids(pl) }
      end

      if payload.is_a?(Channel)
        return { guid: payload.guid }
      end

      if payload.is_a?(Hash)
        return payload.map { |k, v| [k, replace_channels_with_guids(v)] }.to_h
      end

      payload
    end

    def replace_guids_with_channels(payload)
      if payload.nil?
        return nil
      end

      if payload.is_a?(Array)
        return payload.map{ |pl| replace_guids_with_channels(pl) }
      end

      if payload.is_a?(Hash)
        guid = payload['guid']
        if guid && @objects[guid]
          return @objects[guid].channel
        end

        return payload.map { |k, v| [k, replace_guids_with_channels(v)] }.to_h
      end

      payload
    end

    # @return [Playwright::ChannelOwner|nil]
    def create_remote_object(parent_guid:, type:, guid:, initializer:)
      parent = @objects[parent_guid]
      unless parent
        raise "Cannot find parent object #{parent_guid} to create #{guid}"
      end
      initializer = replace_guids_with_channels(initializer)

      result =
        begin
          ChannelOwners.const_get(type).new(
            parent,
            type,
            guid,
            initializer,
          )
        rescue NameError
          raise "Missing type #{type}"
        end

      callback = @waiting_for_object.delete(guid)
      callback&.fulfill(result)

      result
    end
  end
end
