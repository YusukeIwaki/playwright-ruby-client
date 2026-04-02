module Playwright
  class Screencast
    def initialize(page)
      @page = page
      @started = false
      @save_path = nil
      @artifact = nil
      @on_frame_listener = nil
    end

    def start(path: nil, quality: nil, &on_frame)
      params = {}
      if path
        params[:record] = true
        @save_path = path
      end
      params[:quality] = quality if quality
      if on_frame
        params[:sendFrames] = true
        @on_frame_listener = ->(event) {
          on_frame.call(event['data'])
        }
        @page.send(:channel).on('screencastFrame', @on_frame_listener)
      end
      result = @page.send(:channel).send_message_to_server_result('screencastStart', params)
      if result.is_a?(Hash) && result['artifact']
        @artifact = ChannelOwners::Artifact.from(result['artifact'])
      end
      @started = true
      nil
    end

    def stop
      return unless @started

      if @on_frame_listener
        @page.send(:channel).off('screencastFrame', @on_frame_listener)
        @on_frame_listener = nil
      end
      @page.send(:channel).send_message_to_server('screencastStop')
      @started = false

      if @save_path && @artifact
        @artifact.save_as(@save_path)
        @save_path = nil
      end
      @artifact = nil
      nil
    end

    def show_overlay(html, duration: nil)
      params = { html: html }
      params[:duration] = duration if duration
      result = @page.send(:channel).send_message_to_server_result('screencastShowOverlay', params)
      overlay_id = result['id'] if result.is_a?(Hash)
      if overlay_id
        RemoveOverlayDisposable.new(@page, overlay_id)
      end
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
      nil
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

    class RemoveOverlayDisposable
      def initialize(page, overlay_id)
        @page = page
        @overlay_id = overlay_id
      end

      def dispose
        return unless @overlay_id
        @page.send(:channel).send_message_to_server('screencastRemoveOverlay', id: @overlay_id)
        @overlay_id = nil
      end
    end
  end
end
