require 'spec_helper'

require 'chunky_png'
require 'open3'
require 'tmpdir'

# https://github.com/microsoft/playwright/blob/master/tests/screencast.spec.ts
# https://github.com/microsoft/playwright-python/blob/master/tests/async/test_video.py
RSpec.describe 'screencast' do
  def most_frequest_color_in_last_frame(dir, video_file)
    _, stderr, status = Open3.capture3("ffmpeg -i #{video_file} -r 25 #{video_file}-%03d.png", chdir: dir)
    raise 'failed to ffmpeg' unless status.success?

    lines = stderr.split("\n")
    frames_line = lines.find{ |l| l.start_with?('frame=') }
    raise "No frame data in the output:\n#{stderr}" unless frames_line

    stdout, status = Open3.capture2("ls #{video_file}-*.png", chdir: dir)
    raise 'failed to ls' unless status.success?
    last_png_filename = stdout.split("\n").last

    image = ChunkyPNG::Image.from_file(last_png_filename)
    pixel_stat = image.pixels.each_with_object({}) do |pix, h|
      h[pix] ||= 0
      h[pix]+=1
    end
    pixel_stat.max_by(&:last).first
  end

  def almost_red?(color)
    [
      ChunkyPNG::Color.r(color) > 185,
      ChunkyPNG::Color.g(color) < 70,
      ChunkyPNG::Color.b(color) < 70,
      ChunkyPNG::Color.a(color) == 255,
    ].all?
  end

  it 'should capture static page' do
    size = { width: 450, height: 240 }

    Dir.mktmpdir do |dir|
      video_file = nil
      with_context(record_video_size: size, record_video_dir: dir) do |context|
        page = context.new_page
        page.evaluate("() => document.body.style.backgroundColor = 'red'")
        sleep 1
        video_file = page.video.path
      end
      expect(File.read(video_file).size).to be > 100

      color = most_frequest_color_in_last_frame(dir, video_file)
      expect(almost_red?(color)).to eq(true)
    end
  end

  it 'should saveAs video' do
    size = { width: 320, height: 240 }

    Dir.mktmpdir do |dir|
      save_as_path = File.join(dir, 'my-video.webm')
      page = nil
      with_context(record_video_size: size, record_video_dir: dir, viewport: size) do |context|
        page = context.new_page
        page.evaluate("() => document.body.style.backgroundColor = 'red'")
        sleep 1
      end
      page.video.save_as(save_as_path)
      expect(File.read(save_as_path).size).to be > 100

      color = most_frequest_color_in_last_frame(dir, save_as_path)
      expect(almost_red?(color)).to eq(true)
    end
  end

  # it('saveAs should throw when no video frames', async ({browser, browserName, testInfo}) => {
  #   const videosPath = testInfo.outputPath('');
  #   const size = { width: 320, height: 240 };
  #   const context = await browser.newContext({
  #     recordVideo: {
  #       dir: videosPath,
  #       size
  #     },
  #     viewport: size,
  #   });

  #   const page = await context.newPage();
  #   const [popup] = await Promise.all([
  #     page.context().waitForEvent('page'),
  #     page.evaluate(() => {
  #       const win = window.open('about:blank');
  #       win.close();
  #     }),
  #   ]);
  #   await page.close();

  #   const saveAsPath = testInfo.outputPath('my-video.webm');
  #   const error = await popup.video().saveAs(saveAsPath).catch(e => e);
  #   // WebKit pauses renderer before win.close() and actually writes something.
  #   if (browserName === 'webkit')
  #     expect(fs.existsSync(saveAsPath)).toBeTruthy();
  #   else
  #     expect(error.message).toContain('Page did not produce any video frames');
  # });

  it 'should delete video' do
    size = { width: 320, height: 240 }

    Dir.mktmpdir do |dir|
      video_file = nil
      save_as_path = File.join(dir, 'my-video.webm')
      with_context(record_video_size: size, record_video_dir: dir, viewport: size) do |context|
        page = context.new_page
        Async { page.video.delete }
        Async do |task|
          page.evaluate("() => document.body.style.backgroundColor = 'red'")
          task.sleep 1
        end.wait
        video_file = page.video.path
      end
      expect(File.exist?(video_file)).to eq(false)
    end
  end

  # it('should expose video path blank page', async ({browser, testInfo}) => {
  #   const videosPath = testInfo.outputPath('');
  #   const size = { width: 320, height: 240 };
  #   const context = await browser.newContext({
  #     recordVideo: {
  #       dir: videosPath,
  #       size
  #     },
  #     viewport: size,
  #   });
  #   const page = await context.newPage();
  #   const path = await page.video()!.path();
  #   expect(path).toContain(videosPath);
  #   await context.close();
  #   expect(fs.existsSync(path)).toBeTruthy();
  # });

  # it('should expose video path blank popup', async ({browser, testInfo}) => {
  #   const videosPath = testInfo.outputPath('');
  #   const size = { width: 320, height: 240 };
  #   const context = await browser.newContext({
  #     recordVideo: {
  #       dir: videosPath,
  #       size
  #     },
  #     viewport: size,
  #   });
  #   const page = await context.newPage();
  #   const [popup] = await Promise.all([
  #     page.waitForEvent('popup'),
  #     page.evaluate('window.open("about:blank")')
  #   ]);
  #   const path = await popup.video()!.path();
  #   expect(path).toContain(videosPath);
  #   await context.close();
  #   expect(fs.existsSync(path)).toBeTruthy();
  # });

  # it('should capture navigation', async ({browser, server, testInfo}) => {
  #   const context = await browser.newContext({
  #     recordVideo: {
  #       dir: testInfo.outputPath(''),
  #       size: { width: 1280, height: 720 }
  #     },
  #   });
  #   const page = await context.newPage();

  #   await page.goto(server.PREFIX + '/background-color.html#rgb(0,0,0)');
  #   await new Promise(r => setTimeout(r, 1000));
  #   await page.goto(server.CROSS_PROCESS_PREFIX + '/background-color.html#rgb(100,100,100)');
  #   await new Promise(r => setTimeout(r, 1000));
  #   await context.close();

  #   const videoFile = await page.video().path();
  #   const videoPlayer = new VideoPlayer(videoFile);
  #   const duration = videoPlayer.duration;
  #   expect(duration).toBeGreaterThan(0);

  #   {
  #     const pixels = videoPlayer.seekFirstNonEmptyFrame().data;
  #     expectAll(pixels, almostBlack);
  #   }

  #   {
  #     const pixels = videoPlayer.seekLastFrame().data;
  #     expectAll(pixels, almostGray);
  #   }
  # });

  # it('should capture css transformation', (test, { headful, browserName, platform }) => {
  #   test.fixme(headful, 'Fails on headful');
  #   test.fixme(browserName === 'webkit' && platform === 'win32', 'Fails on headful');
  # }, async ({browser, server, testInfo}) => {
  #   const size = { width: 320, height: 240 };
  #   // Set viewport equal to screencast frame size to avoid scaling.
  #   const context = await browser.newContext({
  #     recordVideo: {
  #       dir: testInfo.outputPath(''),
  #       size,
  #     },
  #     viewport: size,
  #   });
  #   const page = await context.newPage();

  #   await page.goto(server.PREFIX + '/rotate-z.html');
  #   await new Promise(r => setTimeout(r, 1000));
  #   await context.close();

  #   const videoFile = await page.video().path();
  #   const videoPlayer = new VideoPlayer(videoFile);
  #   const duration = videoPlayer.duration;
  #   expect(duration).toBeGreaterThan(0);

  #   {
  #     const pixels = videoPlayer.seekLastFrame({ x: 95, y: 45 }).data;
  #     expectAll(pixels, almostRed);
  #   }
  # });

  # it('should work for popups', async ({browser, testInfo, server}) => {
  #   const videosPath = testInfo.outputPath('');
  #   const size = { width: 450, height: 240 };
  #   const context = await browser.newContext({
  #     recordVideo: {
  #       dir: videosPath,
  #       size,
  #     },
  #     viewport: size,
  #   });

  #   const page = await context.newPage();
  #   await page.goto(server.EMPTY_PAGE);
  #   const [popup] = await Promise.all([
  #     page.waitForEvent('popup'),
  #     page.evaluate(() => { window.open('about:blank'); }),
  #   ]);
  #   await popup.evaluate(() => document.body.style.backgroundColor = 'red');
  #   await new Promise(r => setTimeout(r, 1000));
  #   await context.close();

  #   const pageVideoFile = await page.video().path();
  #   const popupVideoFile = await popup.video().path();
  #   expect(pageVideoFile).not.toEqual(popupVideoFile);
  #   expectRedFrames(popupVideoFile, size);

  #   const videoFiles = findVideos(videosPath);
  #   expect(videoFiles.length).toBe(2);
  # });

  # it('should scale frames down to the requested size ', (test, parameters) => {
  #   test.fixme(parameters.headful, 'Fails on headful');
  # }, async ({browser, testInfo, server}) => {
  #   const context = await browser.newContext({
  #     recordVideo: {
  #       dir: testInfo.outputPath(''),
  #       // Set size to 1/2 of the viewport.
  #       size: { width: 320, height: 240 },
  #     },
  #     viewport: {width: 640, height: 480},
  #   });
  #   const page = await context.newPage();

  #   await page.goto(server.PREFIX + '/checkerboard.html');
  #   // Update the picture to ensure enough frames are generated.
  #   await page.$eval('.container', container => {
  #     container.firstElementChild.classList.remove('red');
  #   });
  #   await new Promise(r => setTimeout(r, 300));
  #   await page.$eval('.container', container => {
  #     container.firstElementChild.classList.add('red');
  #   });
  #   await new Promise(r => setTimeout(r, 1000));
  #   await context.close();

  #   const videoFile = await page.video().path();
  #   const videoPlayer = new VideoPlayer(videoFile);
  #   const duration = videoPlayer.duration;
  #   expect(duration).toBeGreaterThan(0);

  #   {
  #     const pixels = videoPlayer.seekLastFrame({x: 0, y: 0}).data;
  #     expectAll(pixels, almostRed);
  #   }
  #   {
  #     const pixels = videoPlayer.seekLastFrame({x: 300, y: 0}).data;
  #     expectAll(pixels, almostGray);
  #   }
  #   {
  #     const pixels = videoPlayer.seekLastFrame({x: 0, y: 200}).data;
  #     expectAll(pixels, almostGray);
  #   }
  #   {
  #     const pixels = videoPlayer.seekLastFrame({x: 300, y: 200}).data;
  #     expectAll(pixels, almostRed);
  #   }
  # });

  # it('should use viewport scaled down to fit into 800x800 as default size', async ({browser, testInfo}) => {
  #   const size = {width: 1600, height: 1200};
  #   const context = await browser.newContext({
  #     recordVideo: {
  #       dir: testInfo.outputPath(''),
  #     },
  #     viewport: size,
  #   });

  #   const page = await context.newPage();
  #   await new Promise(r => setTimeout(r, 1000));
  #   await context.close();

  #   const videoFile = await page.video().path();
  #   const videoPlayer = new VideoPlayer(videoFile);
  #   expect(videoPlayer.videoWidth).toBe(800);
  #   expect(videoPlayer.videoHeight).toBe(600);
  # });

  # it('should be 800x450 by default', async ({ browser, testInfo }) => {
  #   const context = await browser.newContext({
  #     recordVideo: {
  #       dir: testInfo.outputPath(''),
  #     },
  #   });

  #   const page = await context.newPage();
  #   await new Promise(r => setTimeout(r, 1000));
  #   await context.close();

  #   const videoFile = await page.video().path();
  #   const videoPlayer = new VideoPlayer(videoFile);
  #   expect(videoPlayer.videoWidth).toBe(800);
  #   expect(videoPlayer.videoHeight).toBe(450);
  # });

  # it('should be 800x600 with null viewport', (test, { headful, browserName }) => {
  #   test.fixme(browserName === 'firefox' && !headful, 'Fails in headless on bots');
  # }, async ({ browser, testInfo }) => {
  #   const context = await browser.newContext({
  #     recordVideo: {
  #       dir: testInfo.outputPath(''),
  #     },
  #     viewport: null
  #   });

  #   const page = await context.newPage();
  #   await new Promise(r => setTimeout(r, 1000));
  #   await context.close();

  #   const videoFile = await page.video().path();
  #   const videoPlayer = new VideoPlayer(videoFile);
  #   expect(videoPlayer.videoWidth).toBe(800);
  #   expect(videoPlayer.videoHeight).toBe(600);
  # });

  # it('should capture static page in persistent context', async ({launchPersistent, testInfo}) => {
  #   const size = { width: 320, height: 240 };
  #   const { context, page } = await launchPersistent({
  #     recordVideo: {
  #       dir: testInfo.outputPath(''),
  #       size,
  #     },
  #     viewport: size,
  #   });

  #   await page.evaluate(() => document.body.style.backgroundColor = 'red');
  #   await new Promise(r => setTimeout(r, 1000));
  #   await context.close();

  #   const videoFile = await page.video().path();
  #   const videoPlayer = new VideoPlayer(videoFile);
  #   const duration = videoPlayer.duration;
  #   expect(duration).toBeGreaterThan(0);

  #   expect(videoPlayer.videoWidth).toBe(320);
  #   expect(videoPlayer.videoHeight).toBe(240);

  #   {
  #     const pixels = videoPlayer.seekLastFrame().data;
  #     expectAll(pixels, almostRed);
  #   }
  # });

  # it('should emulate an iphone', (test, { browserName }) => {
  #   test.skip(browserName === 'firefox', 'isMobile is not supported in Firefox');
  # }, async ({contextFactory, playwright, contextOptions, testInfo}) => {
  #   const device = playwright.devices['iPhone 6'];
  #   const context = await contextFactory({
  #     ...contextOptions,
  #     ...device,
  #     recordVideo: {
  #       dir: testInfo.outputPath(''),
  #     },
  #   });

  #   const page = await context.newPage();
  #   await new Promise(r => setTimeout(r, 1000));
  #   await context.close();

  #   const videoFile = await page.video().path();
  #   const videoPlayer = new VideoPlayer(videoFile);
  #   expect(videoPlayer.videoWidth).toBe(374);
  #   expect(videoPlayer.videoHeight).toBe(666);
  # });
end
