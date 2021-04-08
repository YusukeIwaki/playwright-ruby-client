module Playwright
  module Utils
    module PrepareBrowserContextOptions
      # @see https://github.com/microsoft/playwright/blob/5a2cfdbd47ed3c3deff77bb73e5fac34241f649d/src/client/browserContext.ts#L265
      private def prepare_browser_context_options(params)
        params[:sdkLanguage] = 'ruby'
        if params[:noViewport] == 0
          params.delete(:noViewport)
          params[:noDefaultViewport] = true
        end
        if params[:extraHTTPHeaders]
          params[:extraHTTPHeaders] = ::Playwright::HttpHeaders.new(params[:extraHTTPHeaders]).as_serialized
        end
        if params[:record_video_dir]
          params[:recordVideo] = {
            dir: params.delete(:record_video_dir)
          }
          if params[:record_video_size]
            params[:recordVideo][:size] = params.delete(:record_video_size)
          end
        end
        if params[:storageState].is_a?(String)
          params[:storageState] = JSON.parse(File.read(params[:storageState]))
        end

        params
      end
    end

    module Errors
      module SafeCloseError
        # @param err [Exception]
        private def safe_close_error?(err)
          return true if err.is_a?(Transport::AlreadyDisconnectedError)

          [
            'Browser has been closed',
            'Target page, context or browser has been closed',
          ].any? do |closed_message|
            err.message.end_with?(closed_message)
          end
        end
      end
    end
  end
end
