require 'spec_helper'
require_relative 'video_player_helper'

# https://github.com/microsoft/playwright/blob/release-1.60/tests/library/screencast.spec.ts
RSpec.describe 'screencast', sinatra: true do
  include IntegrationVideoHelpers

  before { skip 'screencast is not available in remote mode' if remote? }

  it 'screencast.start delivers frames via onFrame callback' do
    context = browser.new_context(viewport: { width: 1000, height: 400 })
    page = context.new_page

    frames = []
    size = { width: 500, height: 400 }
    page.screencast.start(size: size) { |frame| frames << frame[:data] }
    page.goto(server_empty_page)
    page.evaluate("() => document.body.style.backgroundColor = 'red'")
    ensure_some_frames(page)
    page.screencast.stop

    expect(frames.length).to be > 0
    frames.each do |frame|
      expect(frame.bytes[0]).to eq(0xff)
      expect(frame.bytes[1]).to eq(0xd8)
      dimensions = jpeg_dimensions(frame)
      expect(dimensions[:width]).to eq(500)
      expect(dimensions[:height]).to eq(200)
    end

    context.close
  end

  it 'onFrame receives viewport size' do
    context = browser.new_context(viewport: { width: 1000, height: 400 })
    page = context.new_page

    frames = []
    page.screencast.start(size: { width: 500, height: 400 }) do |frame|
      frames << {
        timestamp: frame[:timestamp],
        viewportWidth: frame[:viewportWidth],
        viewportHeight: frame[:viewportHeight],
      }
    end
    page.goto(server_empty_page)
    ensure_some_frames(page)
    page.screencast.stop

    expect(frames.length).to be > 0
    frames.each do |frame|
      expect(frame[:viewportWidth]).to eq(1000)
      expect(frame[:viewportHeight]).to eq(400)
      expect(frame[:timestamp]).to be_a(Numeric)
    end

    context.close
  end

  it 'start throws if screencast is already started' do
    context = browser.new_context(viewport: { width: 500, height: 400 })
    page = context.new_page

    page.screencast.start {}
    expect { page.screencast.start {} }.to raise_error(/Screencast is already started/)

    page.screencast.stop
    context.close
  end

  it 'start allows restart with different options after stop' do
    context = browser.new_context(viewport: { width: 500, height: 400 })
    page = context.new_page

    page.screencast.start(size: { width: 500, height: 400 }) {}
    page.screencast.stop
    page.screencast.start(size: { width: 320, height: 240 }) {}
    page.screencast.stop
    context.close
  end

  it 'start returns a disposable that stops screencast' do
    context = browser.new_context(viewport: { width: 500, height: 400 })
    page = context.new_page

    frames = []
    page.screencast.start(size: { width: 500, height: 400 }) { |frame| frames << frame[:data] }
    page.goto(server_empty_page)
    page.evaluate("() => document.body.style.backgroundColor = 'red'")
    ensure_some_frames(page)
    page.screencast.stop

    frame_count_after_dispose = frames.length
    expect(frame_count_after_dispose).to be > 0

    page.evaluate("() => document.body.style.backgroundColor = 'blue'")
    ensure_some_frames(page)
    expect(frames.length).to eq(frame_count_after_dispose)

    context.close
  end

  it 'start/stop twice without path creates two files in artifactsDir' do
    Dir.mktmpdir do |dir|
      artifacts_dir = File.join(dir, 'artifacts')
      browser_type.launch(artifactsDir: artifacts_dir) do |launched_browser|
        size = { width: 800, height: 800 }
        context = launched_browser.new_context(viewport: size)
        page = context.new_page

        page.screencast.start(path: File.join(dir, 'video1.webm'), size: size)
        page.evaluate("() => document.body.style.backgroundColor = 'red'")
        ensure_some_frames(page)
        page.screencast.stop

        page.screencast.start(path: File.join(dir, 'video2.webm'), size: size)
        page.evaluate("() => document.body.style.backgroundColor = 'blue'")
        ensure_some_frames(page)
        page.screencast.stop

        video_files = Dir[File.join(artifacts_dir, '*.webm')]
        expect(video_files.length).to eq(2)

        context.close
      end
    end
  end

  it 'start should work when recordVideo is set' do
    Dir.mktmpdir do |dir|
      auto_dir = File.join(dir, 'auto')
      manual_dir = File.join(dir, 'manual')
      context = browser.new_context(record_video_dir: auto_dir)
      page = context.new_page

      page.screencast.start(path: File.join(manual_dir, 'video.webm'))
      page.evaluate("() => document.body.style.backgroundColor = 'blue'")
      ensure_some_frames(page)
      page.screencast.stop
      video_files1 = Dir[File.join(manual_dir, '*.webm')]
      expect(video_files1.length).to eq(1)

      context.close
      video_files2 = Dir[File.join(auto_dir, '*.webm')]
      expect(video_files2.length).to eq(1)
    end
  end

  it 'start should fail when another recording is in progress' do
    Dir.mktmpdir do |dir|
      with_page do |page|
        page.screencast.start(path: File.join(dir, 'video.webm'))
        expect {
          page.screencast.start(path: File.join(dir, 'video2.webm'))
        }.to raise_error(/Screencast is already started/)
      end
    end
  end

  it 'stop should not fail when no recording is in progress' do
    context = browser.new_context
    page = context.new_page
    page.screencast.stop
    context.close
  end

  it 'start should finish when page is closed' do
    Dir.mktmpdir do |dir|
      context = browser.new_context
      page = context.new_page
      video_path = File.join(dir, 'video.webm')
      page.screencast.start(path: video_path, size: { width: 800, height: 800 })
      page.evaluate("() => document.body.style.backgroundColor = 'red'")
      ensure_some_frames(page)
      page.close
      expect { page.screencast.stop }.to raise_error(/closed/)
      context.close
    end
  end

  it 'empty video' do
    Dir.mktmpdir do |dir|
      size = { width: 800, height: 800 }
      context = browser.new_context(viewport: size)
      page = context.new_page
      video_path = File.join(dir, 'empty-video.webm')
      page.screencast.start(path: video_path, size: size)
      page.screencast.stop
      context.close
      expect_frames(video_path, size, :almost_white?) { |color| almost_white?(color) }
    end
  end

  it 'start dispose stops recording' do
    Dir.mktmpdir do |dir|
      size = { width: 800, height: 800 }
      context = browser.new_context(viewport: size)
      page = context.new_page
      video_path = File.join(dir, 'dispose-video.webm')
      disposable = page.screencast.start(path: video_path, size: size)
      page.evaluate("() => document.body.style.backgroundColor = 'red'")
      ensure_some_frames(page)
      disposable.dispose
      expect_red_frames(video_path, size)
      context.close
    end
  end
end
