require 'chunky_png'
require 'json'
require 'open3'
require 'tmpdir'

class IntegrationVideoPlayer
  attr_reader :duration, :frames, :video_width, :video_height

  def initialize(file_name)
    @file_name = file_name
    @frames_dir = Dir.mktmpdir('playwright-video-frames')
    extract_frames
    probe_video
  end

  def find_frame(offset: { x: 10, y: 10 }, &predicate)
    (1..frames).each do |frame_number|
      frame = frame(frame_number, offset: offset)
      return frame if predicate.call(frame)
    end
    nil
  end

  def seek_last_frame(offset: { x: 10, y: 10 })
    frame(frames, offset: offset)
  end

  private def extract_frames
    pattern = File.join(@frames_dir, '%04d.png')
    _stdout, stderr, status = Open3.capture3('ffmpeg', '-y', '-i', @file_name, '-r', '25', pattern)
    raise "failed to ffmpeg:\n#{stderr}" unless status.success?

    frame_match = stderr.scan(/frame=\s*(\d+)/).last
    @frames = frame_match ? frame_match.first.to_i : Dir[File.join(@frames_dir, '*.png')].count
    raise "No frame data in the output:\n#{stderr}" if @frames == 0
  end

  private def probe_video
    stdout, stderr, status = Open3.capture3(
      'ffprobe',
      '-v', 'error',
      '-select_streams', 'v:0',
      '-show_entries', 'stream=width,height:format=duration',
      '-of', 'json',
      @file_name,
    )
    raise "failed to ffprobe:\n#{stderr}" unless status.success?

    json = JSON.parse(stdout)
    stream = json.fetch('streams').first
    @video_width = stream.fetch('width')
    @video_height = stream.fetch('height')
    @duration = (json.fetch('format').fetch('duration').to_f * 1000).round
  end

  private def frame(frame_number, offset:)
    image = ChunkyPNG::Image.from_file(File.join(@frames_dir, format('%04d.png', frame_number)))
    pixels = []
    10.times do |dy|
      10.times do |dx|
        pixels << image[offset[:x] + dx, offset[:y] + dy]
      end
    end
    pixels
  end
end

module IntegrationVideoHelpers
  def ensure_some_frames(page)
    5.times do
      page.evaluate('() => new Promise(f => requestAnimationFrame(() => requestAnimationFrame(f)))')
    end
  end

  def find_videos(video_dir)
    Dir[File.join(video_dir, '*.webm')]
  end

  def almost_red?(color)
    ChunkyPNG::Color.r(color) > 185 &&
      ChunkyPNG::Color.g(color) < 70 &&
      ChunkyPNG::Color.b(color) < 70 &&
      ChunkyPNG::Color.a(color) == 255
  end

  def almost_black?(color)
    ChunkyPNG::Color.r(color) < 70 &&
      ChunkyPNG::Color.g(color) < 70 &&
      ChunkyPNG::Color.b(color) < 70 &&
      ChunkyPNG::Color.a(color) == 255
  end

  def almost_gray?(color)
    ChunkyPNG::Color.r(color) > 70 && ChunkyPNG::Color.r(color) < 185 &&
      ChunkyPNG::Color.g(color) > 70 && ChunkyPNG::Color.g(color) < 185 &&
      ChunkyPNG::Color.b(color) > 70 && ChunkyPNG::Color.b(color) < 185 &&
      ChunkyPNG::Color.a(color) == 255
  end

  def almost_white?(color)
    ChunkyPNG::Color.r(color) > 185 &&
      ChunkyPNG::Color.g(color) > 185 &&
      ChunkyPNG::Color.b(color) > 185 &&
      ChunkyPNG::Color.a(color) == 255
  end

  def expect_all(pixels, predicate_name, &predicate)
    bad_pixel = pixels.find { |pixel| !predicate.call(pixel) }
    return unless bad_pixel

    rgba = [
      ChunkyPNG::Color.r(bad_pixel),
      ChunkyPNG::Color.g(bad_pixel),
      ChunkyPNG::Color.b(bad_pixel),
      ChunkyPNG::Color.a(bad_pixel),
    ].join(', ')
    raise "Expected all pixels to satisfy #{predicate_name}, found bad pixel (#{rgba})"
  end

  def expect_red_frames(video_file, size)
    expect_frames(video_file, size, :almost_red?) { |color| almost_red?(color) }
  end

  def expect_frames(video_file, size, predicate_name, &predicate)
    video_player = IntegrationVideoPlayer.new(video_file)
    expect(video_player.duration).to be > 0
    expect(video_player.video_width).to eq(size[:width])
    expect(video_player.video_height).to eq(size[:height])

    expect_all(video_player.seek_last_frame, predicate_name, &predicate)
    expect_all(video_player.seek_last_frame(offset: { x: size[:width] - 20, y: 10 }), predicate_name, &predicate)
  end

  def jpeg_dimensions(buffer)
    i = 2
    while i < buffer.bytesize - 8
      break unless buffer.getbyte(i) == 0xff

      marker = buffer.getbyte(i + 1)
      segment_length = buffer.byteslice(i + 2, 2).unpack1('n')
      if (marker >= 0xc0 && marker <= 0xc3) ||
          (marker >= 0xc5 && marker <= 0xc7) ||
          (marker >= 0xc9 && marker <= 0xcb) ||
          (marker >= 0xcd && marker <= 0xcf)
        height = buffer.byteslice(i + 5, 2).unpack1('n')
        width = buffer.byteslice(i + 7, 2).unpack1('n')
        return { width: width, height: height }
      end
      i += 2 + segment_length
    end
    raise 'Could not parse JPEG dimensions'
  end

  def parse_trace_raw(trace_file)
    entries, status = Open3.capture2('unzip', '-Z1', trace_file)
    raise 'failed to list trace archive' unless status.success?

    trace_entry = entries.lines.map(&:chomp).find { |entry| entry.end_with?('.trace') }
    trace_content, status = Open3.capture2('unzip', '-p', trace_file, trace_entry)
    raise 'failed to read trace archive' unless status.success?

    events = trace_content.lines.map { |line| JSON.parse(line) }
    resources = {}
    entries.lines.map(&:chomp).grep(%r{\Aresources/}).each do |entry|
      content, read_status = Open3.capture2('unzip', '-p', trace_file, entry)
      raise "failed to read #{entry}" unless read_status.success?

      resources[entry] = content
    end
    { events: events, resources: resources }
  end
end
