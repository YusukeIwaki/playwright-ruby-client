module Playwright
  # ref: https://github.com/microsoft/playwright/blob/main/packages/playwright-core/src/client/credentials.ts
  define_api_implementation :CredentialsImpl do
    # @param browser_context [ChannelOwners::BrowserContext]
    def initialize(browser_context)
      @browser_context = browser_context
    end

    def install
      @browser_context.channel.send_message_to_server('credentialsInstall')
      nil
    end

    def create(rpId, id: nil, userHandle: nil, privateKey: nil, publicKey: nil)
      params = {
        rpId: rpId,
        id: id,
        userHandle: userHandle,
        privateKey: privateKey,
        publicKey: publicKey,
      }.compact
      @browser_context.channel.send_message_to_server('credentialsCreate', params)
    end

    def get(id: nil, rpId: nil)
      params = { id: id, rpId: rpId }.compact
      @browser_context.channel.send_message_to_server('credentialsGet', params)
    end

    def delete(id)
      @browser_context.channel.send_message_to_server('credentialsDelete', id: id)
      nil
    end
  end
end
