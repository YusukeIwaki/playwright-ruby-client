module Playwright
  define_channel_owner :Tracing do
    private def after_initialize
      @har_recorders = {}
      @har_id = nil
    end

    def start(name: nil, title: nil, screenshots: nil, snapshots: nil, sources: nil, live: nil)
      params = {
        name: name,
        screenshots: screenshots,
        snapshots: snapshots,
        sources: sources,
        live: live,
      }.compact
      @include_sources = params[:sources] || false
      @channel.send_message_to_server('tracingStart', params)
      trace_name = @channel.send_message_to_server('tracingStartChunk', { title: title, name: name }.compact)
      start_collecting_stacks(trace_name)
    end

    def start_chunk(title: nil, name: nil)
      trace_name = @channel.send_message_to_server('tracingStartChunk', { title: title, name: name }.compact)
      start_collecting_stacks(trace_name)
    end

    private def start_collecting_stacks(trace_name)
      unless @is_tracing
        @is_tracing = true
        @connection.set_in_tracing(true)
      end
      local_utils = @connection.local_utils
      @stacks_id = local_utils&.tracing_started(@traces_dir, trace_name)
    end

    def stop_chunk(path: nil)
      do_stop_chunk(file_path: path)
    end

    def stop(path: nil)
      do_stop_chunk(file_path: path)
      @channel.send_message_to_server('tracingStop')
    end

    private def do_stop_chunk(file_path:)
      reset_stack_counter
      local_utils = @connection.local_utils

      unless file_path
        # Not interested in any artifacts
        @channel.send_message_to_server('tracingStopChunk', mode: 'discard')
        if @stacks_id
          local_utils.trace_discarded(@stacks_id) if local_utils
        end

        return
      end

      is_local = !@connection.remote?
      if is_local
        unless local_utils
          raise 'Cannot save trace because localUtils is unavailable.'
        end

        result = @channel.send_message_to_server_result('tracingStopChunk', mode: 'entries')
        local_utils.zip(
          zipFile: file_path,
          entries: result['entries'],
          stacksId: @stacks_id,
          mode: 'write',
          includeSources: @include_sources,
        )

        return
      end


      result = @channel.send_message_to_server_result('tracingStopChunk', mode: 'archive')
      # The artifact may be missing if the browser closed while stopping tracing.
      unless result['artifact']
        if @stacks_id
          local_utils.trace_discarded(@stacks_id) if local_utils
        end

        return
      end

      # Save trace to the final local file.
      artifact = ChannelOwners::Artifact.from(result['artifact'])
      artifact.save_as(file_path)
      artifact.delete

      return unless local_utils

      local_utils.zip(
        zipFile: file_path,
        entries: [],
        stacksId: @stacks_id,
        mode: 'append',
        includeSources: @include_sources,
      )
    end

    def start_har(path, content: nil, mode: nil, urlFilter: nil, resourcesDir: nil)
      raise 'HAR recording has already been started' if @har_id
      if resourcesDir && path.end_with?('.zip')
        raise 'resourcesDir option is not compatible with a .zip har file'
      end

      default_content = path.end_with?('.zip') ? 'attach' : 'embed'
      @har_id = record_into_har(path, nil,
        url: urlFilter,
        update_content: content || default_content,
        update_mode: mode || 'full',
        resources_dir: resourcesDir,
      )
      DisposableStub.new { stop_har }
    end

    def stop_har
      har_id = @har_id
      raise 'HAR recording has not been started' unless har_id

      @har_id = nil
      export_har(har_id)
      nil
    end

    private def record_into_har(har, page, url:, update_content:, update_mode:, resources_dir: nil)
      options = {
        content: update_content || 'attach',
        mode: update_mode || 'minimal',
        harPath: har.end_with?('.zip') ? nil : har,
        resourcesDir: resources_dir,
      }.compact

      if url.is_a?(Regexp)
        regex = ::Playwright::JavaScript::Regex.new(url)
        options[:urlRegexSource] = regex.source
        options[:urlRegexFlags] = regex.flag
      elsif url.is_a?(String)
        options[:urlGlob] = url
      end

      params = { options: options }
      params[:page] = page.channel if page

      result = @channel.send_message_to_server_result('harStart', params)
      har_id = result['harId'] || result[:harId]
      @har_recorders[har_id] = { path: har, resources_dir: resources_dir }
      har_id
    end

    private def export_har(har_id)
      har_params = @har_recorders.delete(har_id)
      return unless har_params

      path = har_params[:path]
      is_zip = path.end_with?('.zip')
      local_utils = @connection.local_utils

      if !@connection.remote?
        result = @channel.send_message_to_server_result('harExport', harId: har_id, mode: 'entries')
        return unless is_zip
        raise 'Cannot save zipped HAR because localUtils is unavailable.' unless local_utils

        local_utils.zip(
          zipFile: path,
          entries: result['entries'],
          mode: 'write',
          includeSources: false,
        )
        return
      end

      result = @channel.send_message_to_server_result('harExport', harId: har_id, mode: 'archive')
      artifact = ChannelOwners::Artifact.from(result['artifact'])
      if is_zip
        artifact.save_as(path)
        artifact.delete
        return
      end

      raise 'Uncompressed har is not supported in thin clients' unless local_utils

      tmp_path = "#{path}.tmp"
      artifact.save_as(tmp_path)
      local_utils.har_unzip(tmp_path, path, resources_dir: har_params[:resources_dir])
      artifact.delete
    end

    private def export_all_hars
      @har_recorders.keys.each { |har_id| export_har(har_id) }
    end

    private def reset_stack_counter
      if @is_tracing
        @is_tracing = false
        @connection.set_in_tracing(false)
      end
    end

    private def update_traces_dir(traces_dir)
      @traces_dir = traces_dir
    end

    def group(name, location: nil)
      params = {
        name: name,
        location: location,
      }.compact
      @channel.send_message_to_server('tracingGroup', params)
    end

    def group_end
      @channel.send_message_to_server('tracingGroupEnd')
    end
  end
end
