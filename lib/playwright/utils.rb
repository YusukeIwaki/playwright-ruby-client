module Playwright
  module Utils
    module PrepareBrowserContextOptions
      private def prepare_record_har_options(params)
        out_params = {
          path: params.delete(:record_har_path)
        }
        if params[:record_har_url_filter]
          opt = params.delete(:record_har_url_filter)
          if opt.is_a?(Regexp)
            regex = ::Playwright::JavaScript::Regex.new(opt)
            out_params[:urlRegexSource] = regex.source
            out_params[:urlRegexFlags] = regex.flag
          elsif opt.is_a?(String)
            out_params[:urlGlob] = opt
          end
        end
        if params[:record_har_mode]
          out_params[:mode] = params.delete(:record_har_mode)
        end
        if params[:record_har_content]
          out_params[:content] = params.delete(:record_har_content)
        end
        if params[:record_har_omit_content]
          old_api_omit_content = params.delete(:record_har_omit_content)
          if old_api_omit_content
            out_params[:content] ||= 'omit'
          end
        end

        out_params
      end

      # @see https://github.com/microsoft/playwright/blob/5a2cfdbd47ed3c3deff77bb73e5fac34241f649d/src/client/browserContext.ts#L265
      private def prepare_browser_context_options(params)
        if params[:noViewport] == 0
          params.delete(:noViewport)
          params[:noDefaultViewport] = true
        end
        if params[:extraHTTPHeaders]
          params[:extraHTTPHeaders] = ::Playwright::HttpHeaders.new(params[:extraHTTPHeaders]).as_serialized
        end
        if params[:record_har_path]
          params[:recordHar] = prepare_record_har_options(params)
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

        %i[colorScheme reducedMotion forcedColors].each do |key|
          if params[key] == 'null'
            params[key] = 'no-override'
          end
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
