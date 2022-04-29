require 'base64'

module Playwright
  class InputFiles
    def initialize(context, files)
      @context = context
      if files.is_a?(Enumerable)
        @files = files
      else
        @files = [files]
      end
    end

    def as_method_and_params
      if has_large_file?
        ['setInputFilePaths', params_for_set_input_file_paths]
      else
        ['setInputFiles', params_for_set_input_files]
      end
    end

    private def has_large_file?
      max_bufsize = 1024 * 1024 # 1MB

      @files.any? do |file|
        case file
        when String
          File::Stat.new(file).size > max_bufsize
        when File
          file.stat.size > max_bufsize
        else
          raise_argument_error
        end
      end
    end

    private def params_for_set_input_file_paths
      writable_streams = @files.map do |file|
        case file
        when String
          writable_stream = @context.send(:create_temp_file, File.basename(file))

          File.open(file, 'rb') do |file|
            writable_stream.write(file)
          end

          writable_stream.channel
        when File
          writable_stream = @context.send(:create_temp_file, File.basename(file.path))
          writable_stream.write(file)

          writable_stream.channel
        else
          raise_argument_error
        end
      end

      { streams: writable_streams }
    end

    private def params_for_set_input_files
      file_payloads = @files.map do |file|
        case file
        when String
          {
            name: File.basename(file),
            buffer: Base64.strict_encode64(File.read(file)),
          }
        when File
          {
            name: File.basename(file.path),
            buffer: Base64.strict_encode64(file.read),
          }
        else
          raise_argument_error
        end
      end

      { files: file_payloads }
    end

    private def raise_argument_error
      raise ArgumentError.new('file must be a String or File.')
    end
  end
end
