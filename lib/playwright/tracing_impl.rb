module Playwright
  define_api_implementation :TracingImpl do
    def initialize(channel, context)
      @channel = channel
      @context = context
    end

    def start(name: nil, title: nil, screenshots: nil, snapshots: nil)
      params = {
        name: name,
        screenshots: screenshots,
        snapshots: snapshots,
      }.compact
      @channel.send_message_to_server('tracingStart', params)
      @channel.send_message_to_server('tracingStartChunk', { title: title }.compact)
    end

    def start_chunk(title: nil)
      @channel.send_message_to_server('tracingStartChunk', { title: title }.compact)
    end

    def stop_chunk(path: nil)
      do_stop_chunk(path: path)
    end

    def stop(path: nil)
      do_stop_chunk(path: path)
      @channel.send_message_to_server('tracingStop')
    end

    private def do_stop_chunk(path:)
      result = @channel.send_message_to_server_result('tracingStopChunk', save: !path.nil?, skipCompress: false)
      artifact = ChannelOwners::Artifact.from_nullable(result['artifact'])
      return unless artifact

      artifact.save_as(path)
      artifact.delete
    end
  end
end
