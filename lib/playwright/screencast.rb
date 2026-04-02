module Playwright
  class Screencast
    def initialize(page)
      @page = page
      @started = false
      @save_path = nil
      @artifact = nil
      @on_frame = nil
      @page.send(:channel).on('screencastFrame', method(:handle_screencast_frame))
    end

    def start(path: nil, size: nil, quality: nil, &on_frame)
      raise 'Screencast is already started' if @started

      @started = true
      @on_frame = on_frame if on_frame

      params = {}
      params[:record] = true if path
      params[:size] = size if size
      params[:quality] = quality if quality
      params[:sendFrames] = true if on_frame

      result = @page.send(:channel).send_message_to_server_result('screencastStart', params)
      if result.is_a?(Hash) && result['artifact']
        @artifact = ChannelOwners::Artifact.from(result['artifact'])
        @save_path = path
      end

      DisposableStub.new { stop }
    end

    def stop
      return unless @started

      @started = false
      @on_frame = nil
      @page.send(:channel).send_message_to_server('screencastStop')

      if @save_path && @artifact
        @artifact.save_as(@save_path)
      end
      @artifact = nil
      @save_path = nil
    end

    def show_overlay(html, duration: nil)
      params = { html: html }
      params[:duration] = duration if duration
      result = @page.send(:channel).send_message_to_server_result('screencastShowOverlay', params)
      overlay_id = result['id'] if result.is_a?(Hash)
      DisposableStub.new {
        @page.send(:channel).send_message_to_server('screencastRemoveOverlay', id: overlay_id) if overlay_id
      }
    end

    def show_chapter(title, description: nil, duration: nil)
      params = { title: title }
      params[:description] = description if description
      params[:duration] = duration if duration
      @page.send(:channel).send_message_to_server('screencastChapter', params)
    end

    def show_actions(duration: nil, fontSize: nil, position: nil)
      params = {}
      params[:duration] = duration if duration
      params[:fontSize] = fontSize if fontSize
      params[:position] = position if position
      @page.send(:channel).send_message_to_server('screencastShowActions', params)
      DisposableStub.new { hide_actions }
    end

    def hide_actions
      @page.send(:channel).send_message_to_server('screencastHideActions')
    end

    def show_overlays
      @page.send(:channel).send_message_to_server('screencastSetOverlayVisible', visible: true)
    end

    def hide_overlays
      @page.send(:channel).send_message_to_server('screencastSetOverlayVisible', visible: false)
    end

    private def handle_screencast_frame(event)
      @on_frame&.call(event['data'])
    end
  end
end
