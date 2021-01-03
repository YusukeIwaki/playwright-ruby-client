module Playwright
  class Channel
    include Playwright::EventEmitter

    # @param connection [Playwright::Connection]
    # @param guid [String]
    # @param object [Playwright::ChannelOwner]
    def initialize(connection, guid, object:)
      @connection = connection
      @guid = guid
      @object = object
    end

    attr_reader :guid, :object
  end
end
