module Playwright
  define_api_implementation :TracingImpl do
    def initialize(channel, context)
      @channel = channel
      @context = context
    end

    def start(name: nil, screenshots: nil, snapshots: nil)
      params = {
        name: name,
        screenshots: screenshots,
        snapshots: snapshots,
      }.compact
      @channel.send_message_to_server('tracingStart', params)
    end

    # Stop tracing.
    def stop(path: nil)
      export(path: path) if path
      @channel.send_message_to_server('tracingStop')
    end

    private def export(path:)
      resp = @channel.send_message_to_server('tracingExport')
      artifact = ChannelOwners::Artifact.from(resp)
      if @context.browser.send(:remote?)
        artifact.update_as_remote
      end
      artifact.save_as(path)
      artifact.delete
    end
  end
end
