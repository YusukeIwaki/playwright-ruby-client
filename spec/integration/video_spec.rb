require 'spec_helper'
require_relative 'video_player_helper'

# https://github.com/microsoft/playwright/blob/release-1.60/tests/library/video.spec.ts
RSpec.describe 'video', sinatra: true do
  include IntegrationVideoHelpers

  before do
    skip 'video.path() is not available in remote mode' if remote?
  end

  def default_video_size
    firefox? ? { width: 500, height: 400 } : { width: 320, height: 240 }
  end

  it 'should not have video by default' do
    with_page do |page|
      expect(page.video).to be_nil
    end
  end

  it 'should not throw without recordVideo.dir' do
    skip 'Ruby public API exposes record_video_dir instead of raw recordVideo: {}'
  end

  it 'should capture static page' do
    Dir.mktmpdir do |dir|
      size = default_video_size
      context = browser.new_context(record_video_dir: dir, record_video_size: size, viewport: size)
      page = context.new_page

      page.evaluate("() => document.body.style.backgroundColor = 'red'")
      ensure_some_frames(page)
      context.close

      video_file = page.video.path
      expect_red_frames(video_file, size)
    end
  end

  it 'should continue recording main page after popup closes' do
    Dir.mktmpdir do |dir|
      size = default_video_size
      context = browser.new_context(record_video_dir: dir, record_video_size: size, viewport: size)
      page = context.new_page
      page.set_content('<a target=_blank href="about:blank">clickme</a>')
      popup = page.expect_event('popup') { page.click('a') }
      popup.close

      page.evaluate(<<~JAVASCRIPT)
        () => {
          document.body.textContent = '';
          document.body.style.backgroundColor = 'red';
        }
      JAVASCRIPT
      ensure_some_frames(page)
      context.close

      video_file = page.video.path
      expect_red_frames(video_file, size)
    end
  end

  it 'should expose video path' do
    Dir.mktmpdir do |dir|
      size = { width: 320, height: 240 }
      context = browser.new_context(record_video_dir: dir, record_video_size: size, viewport: size)
      page = context.new_page
      page.evaluate("() => document.body.style.backgroundColor = 'red'")
      path = page.video.path
      expect(path).to include(dir)
      context.close
      expect(File.exist?(path)).to eq(true)
    end
  end

  it 'should delete video' do
    Dir.mktmpdir do |dir|
      size = { width: 320, height: 240 }
      context = browser.new_context(record_video_dir: dir, record_video_size: size, viewport: size)
      page = context.new_page
      delete_promise = Concurrent::Promises.future { page.video.delete }
      page.evaluate("() => document.body.style.backgroundColor = 'red'")
      ensure_some_frames(page)
      context.close

      video_path = page.video.path
      delete_promise.value!
      expect(File.exist?(video_path)).to eq(false)
    end
  end

  it 'should expose video path blank page' do
    Dir.mktmpdir do |dir|
      size = { width: 320, height: 240 }
      context = browser.new_context(record_video_dir: dir, record_video_size: size, viewport: size)
      page = context.new_page
      path = page.video.path
      expect(path).to include(dir)
      context.close
      expect(File.exist?(path)).to eq(true)
    end
  end

  it 'should work with weird screen resolution' do
    Dir.mktmpdir do |dir|
      size = { width: 1904, height: 609 }
      context = browser.new_context(record_video_dir: dir, record_video_size: size, viewport: size)
      page = context.new_page
      path = page.video.path
      expect(path).to include(dir)
      context.close
      expect(File.exist?(path)).to eq(true)
    end
  end

  it 'should work with relative path for recordVideo.dir' do
    Dir.mktmpdir(nil, Dir.pwd) do |dir|
      videos_path = Pathname.new(dir).relative_path_from(Pathname.new(Dir.pwd)).to_s
      size = { width: 320, height: 240 }
      context = browser.new_context(record_video_dir: videos_path, record_video_size: size, viewport: size)
      page = context.new_page
      video_path = page.video.path
      context.close
      expect(File.exist?(video_path)).to eq(true)
    end
  end

  it 'should expose video path blank popup' do
    Dir.mktmpdir do |dir|
      size = { width: 320, height: 240 }
      context = browser.new_context(record_video_dir: dir, record_video_size: size, viewport: size)
      page = context.new_page
      popup = page.expect_event('popup') { page.evaluate('window.open("about:blank")') }
      path = popup.video.path
      expect(path).to include(dir)
      context.close
      expect(File.exist?(path)).to eq(true)
    end
  end

  it 'should capture navigation' do
    Dir.mktmpdir do |dir|
      context = browser.new_context(record_video_dir: dir, record_video_size: { width: 1280, height: 720 })
      page = context.new_page

      page.goto("#{server_prefix}/background-color.html#rgb(0,0,0)")
      ensure_some_frames(page)
      page.goto("#{server_cross_process_prefix}/background-color.html#rgb(100,100,100)")
      ensure_some_frames(page)
      context.close

      video_player = IntegrationVideoPlayer.new(page.video.path)
      expect(video_player.duration).to be > 0
      frame = video_player.find_frame { |pixels| pixels.all? { |color| almost_black?(color) } }
      expect(frame).not_to be_nil
      expect_all(video_player.seek_last_frame, :almost_gray?) { |color| almost_gray?(color) }
    end
  end

  it 'should capture css transformation' do
    Dir.mktmpdir do |dir|
      size = { width: 600, height: 400 }
      context = browser.new_context(record_video_dir: dir, record_video_size: size, viewport: size)
      page = context.new_page

      page.goto("#{server_prefix}/rotate-z.html")
      ensure_some_frames(page)
      context.close

      video_player = IntegrationVideoPlayer.new(page.video.path)
      expect(video_player.duration).to be > 0
      pixels = video_player.seek_last_frame(offset: { x: 95, y: 45 })
      expect_all(pixels, :almost_red?) { |color| almost_red?(color) }
    end
  end

  it 'should work for popups' do
    skip 'https://github.com/microsoft/playwright/issues/14557' if firefox?

    Dir.mktmpdir do |dir|
      size = { width: 600, height: 400 }
      context = browser.new_context(record_video_dir: dir, record_video_size: size, viewport: size)

      page = context.new_page
      page.goto(server_empty_page)
      popup = page.expect_event('popup') { page.evaluate('() => { window.open("about:blank"); }') }
      popup.evaluate("() => document.body.style.backgroundColor = 'red'")
      ensure_some_frames(page)
      ensure_some_frames(popup)
      context.close

      page_video_file = page.video.path
      popup_video_file = popup.video.path
      expect(page_video_file).not_to eq(popup_video_file)
      expect_red_frames(popup_video_file, size)
      expect(find_videos(dir).length).to eq(2)
    end
  end

  it 'should scale frames down to the requested size ' do
    skip 'Chromium headed has a min width issue' if chromium? && ENV['HEADFUL']

    Dir.mktmpdir do |dir|
      context = browser.new_context(
        record_video_dir: dir,
        record_video_size: { width: 320, height: 240 },
        viewport: { width: 640, height: 480 },
      )
      page = context.new_page

      page.goto("#{server_prefix}/checkerboard.html")
      page.eval_on_selector('.container', 'container => container.firstElementChild.classList.remove("red")')
      ensure_some_frames(page)
      page.eval_on_selector('.container', 'container => container.firstElementChild.classList.add("red")')
      ensure_some_frames(page)
      context.close

      video_player = IntegrationVideoPlayer.new(page.video.path)
      expect(video_player.duration).to be > 0
      expect_all(video_player.seek_last_frame(offset: { x: 10, y: 10 }), :almost_red?) { |color| almost_red?(color) }
      expect_all(video_player.seek_last_frame(offset: { x: 300, y: 10 }), :almost_gray?) { |color| almost_gray?(color) }
      expect_all(video_player.seek_last_frame(offset: { x: 10, y: 200 }), :almost_gray?) { |color| almost_gray?(color) }
      expect_all(video_player.seek_last_frame(offset: { x: 300, y: 200 }), :almost_red?) { |color| almost_red?(color) }
    end
  end

  it 'should use viewport scaled down to fit into 800x800 as default size' do
    Dir.mktmpdir do |dir|
      size = { width: 1600, height: 1200 }
      context = browser.new_context(record_video_dir: dir, viewport: size)
      page = context.new_page
      ensure_some_frames(page)
      context.close

      video_player = IntegrationVideoPlayer.new(page.video.path)
      expect(video_player.video_width).to eq(800)
      expect(video_player.video_height).to eq(600)
    end
  end

  it 'should be 800x450 by default' do
    Dir.mktmpdir do |dir|
      context = browser.new_context(record_video_dir: dir)
      page = context.new_page
      ensure_some_frames(page)
      context.close

      video_player = IntegrationVideoPlayer.new(page.video.path)
      expect(video_player.video_width).to eq(800)
      expect(video_player.video_height).to eq(450)
    end
  end

  it 'should be 800x600 with null viewport' do
    skip 'Fails in headless on bots' if firefox?

    Dir.mktmpdir do |dir|
      context = browser.new_context(record_video_dir: dir, noViewport: 0)
      page = context.new_page
      ensure_some_frames(page)
      context.close

      video_player = IntegrationVideoPlayer.new(page.video.path)
      expect(video_player.video_width).to eq(800)
      expect(video_player.video_height).to eq(600)
    end
  end
end
