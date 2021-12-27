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
      do_stop_chunk(file_path: path)
    end

    def stop(path: nil)
      do_stop_chunk(file_path: path)
      @channel.send_message_to_server('tracingStop')
    end

    private def do_stop_chunk(file_path:)
      mode = 'doNotSave'
      if file_path
        if @context.send(:remote_connection?)
          mode = 'compressTrace'
        else
          mode = 'compressTraceAndSources'
        end
      end

      result = @channel.send_message_to_server_result('tracingStopChunk', mode: mode)
      return unless file_path # Not interested in artifacts.
      return unless result['artifact'] # The artifact may be missing if the browser closed while stopping tracing.

      artifact = ChannelOwners::Artifact.from(result['artifact'])
      artifact.save_as(file_path)
      artifact.delete

      # // Add local sources to the remote trace if necessary.
      # if (result.sourceEntries?.length)
      #   await this._context._localUtils.zip(filePath, result.sourceEntries);
    end
  end
end
