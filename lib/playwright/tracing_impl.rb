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
    def stop
      @channel.send_message_to_server('tracingStop')
    end

    def export(path)
      resp = @channel.send_message_to_server('tracingExport')
      artifact = ChannelOwners::Artifact.from(resp)
      # if self._context._browser:
      #   artifact._is_remote = self._context._browser._is_remote
      artifact.save_as(path)
      artifact.delete
    end
  end
end
