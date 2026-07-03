module Playwright
  # ref: https://github.com/microsoft/playwright/blob/main/packages/playwright-core/src/client/webStorage.ts
  define_api_implementation :WebStorageImpl do
    # @param page [ChannelOwners::Page]
    # @param kind [String] 'local' or 'session'
    def initialize(page, kind)
      @page = page
      @kind = kind
    end

    def items
      @page.channel.send_message_to_server('webStorageItems', kind: @kind)
    end

    def get_item(name)
      @page.channel.send_message_to_server('webStorageGetItem', kind: @kind, name: name)
    end

    def set_item(name, value)
      @page.channel.send_message_to_server('webStorageSetItem', kind: @kind, name: name, value: value)
      nil
    end

    def remove_item(name)
      @page.channel.send_message_to_server('webStorageRemoveItem', kind: @kind, name: name)
      nil
    end

    def clear
      @page.channel.send_message_to_server('webStorageClear', kind: @kind)
      nil
    end
  end
end
