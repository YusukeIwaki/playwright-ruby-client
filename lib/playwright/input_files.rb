require 'base64'
require 'mime/types'

module Playwright
  class InputFiles
    def initialize(files)
      @params = convert(files)
    end

    def as_params
      @params
    end

    private def convert(files)
      return convert([files]) unless files.is_a?(Array)

      files.map do |file|
        case file
        when String
          {
            name: File.basename(file),
            mimeType: mime_type_for(file),
            buffer: Base64.strict_encode64(File.read(file)),
          }
        when File
          {
            name: File.basename(file.path),
            mimeType: mime_type_for(file.path),
            buffer: Base64.strict_encode64(file.read),
          }
        else
          raise ArgumentError.new('file must be a String or File.')
        end
      end
    end

    private def mime_type_for(filepath)
      mime_types = MIME::Types.type_for(filepath)
      mime_types.first.to_s || 'application/octet-stream'
    end
  end
end
