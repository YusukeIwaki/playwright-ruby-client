module Playwright
  class Channel
    include EventEmitter

    # @param connection [Playwright::Connection]
    # @param guid [String]
    # @param object [Playwright::ChannelOwner]
    def initialize(connection, guid, object:)
      @connection = connection
      @guid = guid
      @object = object
    end

    attr_reader :guid, :object

    # @param method [String]
    # @param params [Hash]
    def send_message_to_server(method, params = {})
      result = @connection.send_message_to_server(@guid, method, params)
      if result.is_a?(Hash)
        _type, channel_owner = result.first
        channel_owner
      else
        nil
      end
    end

    # @param method [String]
    # @param params [Hash]
    # @returns nil
    def async_send_message_to_server(method, params = {})
      @connection.async_send_message_to_server(@guid, method, params)

      nil
    end
  end
end
