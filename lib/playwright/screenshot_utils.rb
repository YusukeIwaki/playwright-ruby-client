require 'mime/types'

module Playwright
  module ScreenshotUtils
    module_function

    def determine_type(path:, type:)
      return type if type
      return nil unless path

      mime_type = MIME::Types.type_for(path).first
      case mime_type&.content_type
      when 'image/png'
        'png'
      when 'image/jpeg'
        'jpeg'
      when 'image/webp'
        'webp'
      else
        raise ArgumentError.new("path: unsupported mime type \"#{mime_type}\"")
      end
    end
  end
end
