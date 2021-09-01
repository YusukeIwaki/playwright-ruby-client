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
      @channel.send_message_to_server('tracingStartChunk')
    end

    def start_chunk
      @channel.send_message_to_server('tracingStartChunk')
    end

    def stop_chunk(path: nil)
      do_stop_chunk(path: path)
    end

    def stop(path: nil)
      do_stop_chunk(path: path)
      @channel.send_message_to_server('tracingStop')
    end

    private def do_stop_chunk(path:)
      resp = @channel.send_message_to_server('tracingStopChunk', save: !path.nil?)
      artifact = ChannelOwners::Artifact.from_nullable(resp)
      return unless artifact

      if @context.browser.send(:remote?)
        artifact.update_as_remote
      end
      artifact.save_as(path)
      artifact.delete
    end
  end
end
