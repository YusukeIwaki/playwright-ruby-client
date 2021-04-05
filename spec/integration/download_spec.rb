require 'spec_helper'
require 'tmpdir'

RSpec.describe 'download', sinatra: true do
  before {
    sinatra.get('/download') do
      headers(
        'Content-Type' => 'application/octet-stream',
        'Content-Disposition' => 'attachment',
      )
      body('Hello world!')
    end

    sinatra.get('/downloadWithFilename') do
      headers(
        'Content-Type' => 'application/octet-stream',
        'Content-Disposition' => 'attachment; filename=file.txt',
      )
      body('It works!')
    end
  }

  it 'should report downloads with acceptDownloads: false' do
    with_page do |page|
      page.content = "<a href=\"#{server_prefix}/downloadWithFilename\">download</a>"
      download = page.expect_download do
        page.click('a')
      end

      expect(download.url).to eq("#{server_prefix}/downloadWithFilename")
      expect(download.suggested_filename).to eq('file.txt')
      expect { download.path }.to raise_error(/acceptDownloads: true/)
      expect(download.failure).to include('acceptDownloads')
    end
  end

  it 'should report downloads with acceptDownloads: true' do
    with_page(acceptDownloads: true) do |page|
      page.content = "<a href=\"#{server_prefix}/download\">download</a>"
      download = page.expect_download do
        page.click('a')
      end

      expect(File.read(download.path)).to eq('Hello world!')
    end
  end

  it 'should save to user-specified path' do
    with_page(acceptDownloads: true) do |page|
      page.content = "<a href=\"#{server_prefix}/download\">download</a>"
      download = page.expect_download do
        page.click('a')
      end
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'download.txt')
        download.save_as(path)
        expect(File.read(path)).to eq('Hello world!')
      end
    end
  end

  it 'should save to user-specified path without updating original path' do
    with_page(acceptDownloads: true) do |page|
      page.content = "<a href=\"#{server_prefix}/download\">download</a>"
      download = page.expect_download do
        page.click('a')
      end
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'download.txt')
        download.save_as(path)
        expect(File.read(path)).to eq('Hello world!')
      end
      original_path = download.path
      expect(File.read(original_path)).to eq('Hello world!')
    end
  end

  # it('should save to two different paths with multiple saveAs calls', async ({testInfo, browser, server}) => {
  #   const page = await browser.newPage({ acceptDownloads: true });
  #   await page.setContent(`<a href="${server.PREFIX}/download">download</a>`);
  #   const [ download ] = await Promise.all([
  #     page.waitForEvent('download'),
  #     page.click('a')
  #   ]);
  #   const userPath = testInfo.outputPath('download.txt');
  #   await download.saveAs(userPath);
  #   expect(fs.existsSync(userPath)).toBeTruthy();
  #   expect(fs.readFileSync(userPath).toString()).toBe('Hello world');

  #   const anotherUserPath = testInfo.outputPath('download (2).txt');
  #   await download.saveAs(anotherUserPath);
  #   expect(fs.existsSync(anotherUserPath)).toBeTruthy();
  #   expect(fs.readFileSync(anotherUserPath).toString()).toBe('Hello world');
  #   await page.close();
  # });

  # it('should save to overwritten filepath', async ({testInfo, browser, server}) => {
  #   const page = await browser.newPage({ acceptDownloads: true });
  #   await page.setContent(`<a href="${server.PREFIX}/download">download</a>`);
  #   const [ download ] = await Promise.all([
  #     page.waitForEvent('download'),
  #     page.click('a')
  #   ]);
  #   const dir = testInfo.outputPath('downloads');
  #   const userPath = path.join(dir, 'download.txt');
  #   await download.saveAs(userPath);
  #   expect((await util.promisify(fs.readdir)(dir)).length).toBe(1);
  #   await download.saveAs(userPath);
  #   expect((await util.promisify(fs.readdir)(dir)).length).toBe(1);
  #   expect(fs.existsSync(userPath)).toBeTruthy();
  #   expect(fs.readFileSync(userPath).toString()).toBe('Hello world');
  #   await page.close();
  # });

  # it('should create subdirectories when saving to non-existent user-specified path', async ({testInfo, browser, server}) => {
  #   const page = await browser.newPage({ acceptDownloads: true });
  #   await page.setContent(`<a href="${server.PREFIX}/download">download</a>`);
  #   const [ download ] = await Promise.all([
  #     page.waitForEvent('download'),
  #     page.click('a')
  #   ]);
  #   const nestedPath = testInfo.outputPath(path.join('these', 'are', 'directories', 'download.txt'));
  #   await download.saveAs(nestedPath);
  #   expect(fs.existsSync(nestedPath)).toBeTruthy();
  #   expect(fs.readFileSync(nestedPath).toString()).toBe('Hello world');
  #   await page.close();
  # });

  # it('should save when connected remotely', (test, { mode }) => {
  #   test.skip(mode !== 'default');
  # }, async ({testInfo, server, browserType, remoteServer}) => {
  #   const browser = await browserType.connect({ wsEndpoint: remoteServer.wsEndpoint() });
  #   const page = await browser.newPage({ acceptDownloads: true });
  #   await page.setContent(`<a href="${server.PREFIX}/download">download</a>`);
  #   const [ download ] = await Promise.all([
  #     page.waitForEvent('download'),
  #     page.click('a')
  #   ]);
  #   const nestedPath = testInfo.outputPath(path.join('these', 'are', 'directories', 'download.txt'));
  #   await download.saveAs(nestedPath);
  #   expect(fs.existsSync(nestedPath)).toBeTruthy();
  #   expect(fs.readFileSync(nestedPath).toString()).toBe('Hello world');
  #   const error = await download.path().catch(e => e);
  #   expect(error.message).toContain('Path is not available when using browserType.connect(). Use download.saveAs() to save a local copy.');
  #   await browser.close();
  # });

  # it('should error when saving with downloads disabled', async ({testInfo, browser, server}) => {
  #   const page = await browser.newPage({ acceptDownloads: false });
  #   await page.setContent(`<a href="${server.PREFIX}/download">download</a>`);
  #   const [ download ] = await Promise.all([
  #     page.waitForEvent('download'),
  #     page.click('a')
  #   ]);
  #   const userPath = testInfo.outputPath('download.txt');
  #   const { message } = await download.saveAs(userPath).catch(e => e);
  #   expect(message).toContain('Pass { acceptDownloads: true } when you are creating your browser context');
  #   await page.close();
  # });

  # it('should error when saving after deletion', async ({testInfo, browser, server}) => {
  #   const page = await browser.newPage({ acceptDownloads: true });
  #   await page.setContent(`<a href="${server.PREFIX}/download">download</a>`);
  #   const [ download ] = await Promise.all([
  #     page.waitForEvent('download'),
  #     page.click('a')
  #   ]);
  #   const userPath = testInfo.outputPath('download.txt');
  #   await download.delete();
  #   const { message } = await download.saveAs(userPath).catch(e => e);
  #   expect(message).toContain('Download already deleted. Save before deleting.');
  #   await page.close();
  # });

  # it('should error when saving after deletion when connected remotely', (test, { mode }) => {
  #   test.skip(mode !== 'default');
  # }, async ({testInfo, server, browserType, remoteServer}) => {
  #   const browser = await browserType.connect({ wsEndpoint: remoteServer.wsEndpoint() });
  #   const page = await browser.newPage({ acceptDownloads: true });
  #   await page.setContent(`<a href="${server.PREFIX}/download">download</a>`);
  #   const [ download ] = await Promise.all([
  #     page.waitForEvent('download'),
  #     page.click('a')
  #   ]);
  #   const userPath = testInfo.outputPath('download.txt');
  #   await download.delete();
  #   const { message } = await download.saveAs(userPath).catch(e => e);
  #   expect(message).toContain('Download already deleted. Save before deleting.');
  #   await browser.close();
  # });

  # it('should report non-navigation downloads', async ({browser, server}) => {
  #   // Mac WebKit embedder does not download in this case, although Safari does.
  #   server.setRoute('/download', (req, res) => {
  #     res.setHeader('Content-Type', 'application/octet-stream');
  #     res.end(`Hello world`);
  #   });

  #   const page = await browser.newPage({ acceptDownloads: true });
  #   await page.goto(server.EMPTY_PAGE);
  #   await page.setContent(`<a download="file.txt" href="${server.PREFIX}/download">download</a>`);
  #   const [ download ] = await Promise.all([
  #     page.waitForEvent('download'),
  #     page.click('a')
  #   ]);
  #   expect(download.suggestedFilename()).toBe(`file.txt`);
  #   const path = await download.path();
  #   expect(fs.existsSync(path)).toBeTruthy();
  #   expect(fs.readFileSync(path).toString()).toBe('Hello world');
  #   await page.close();
  # });

  # it(`should report download path within page.on('download', …) handler for Files`, async ({browser, server}) => {
  #   const page = await browser.newPage({ acceptDownloads: true });
  #   const onDownloadPath = new Promise<string>(res => {
  #     page.on('download', dl => {
  #       dl.path().then(res);
  #     });
  #   });
  #   await page.setContent(`<a href="${server.PREFIX}/download">download</a>`);
  #   await page.click('a');
  #   const path = await onDownloadPath;
  #   expect(fs.readFileSync(path).toString()).toBe('Hello world');
  #   await page.close();
  # });
  # it(`should report download path within page.on('download', …) handler for Blobs`, async ({browser, server}) => {
  #   const page = await browser.newPage({ acceptDownloads: true });
  #   const onDownloadPath = new Promise<string>(res => {
  #     page.on('download', dl => {
  #       dl.path().then(res);
  #     });
  #   });
  #   await page.goto(server.PREFIX + '/download-blob.html');
  #   await page.click('a');
  #   const path = await onDownloadPath;
  #   expect(fs.readFileSync(path).toString()).toBe('Hello world');
  #   await page.close();
  # });
  # it('should report alt-click downloads', (test, { browserName }) => {
  #   test.fixme(browserName === 'firefox' || browserName === 'webkit');
  # }, async ({browser, server}) => {
  #   // Firefox does not download on alt-click by default.
  #   // Our WebKit embedder does not download on alt-click, although Safari does.
  #   server.setRoute('/download', (req, res) => {
  #     res.setHeader('Content-Type', 'application/octet-stream');
  #     res.end(`Hello world`);
  #   });

  #   const page = await browser.newPage({ acceptDownloads: true });
  #   await page.goto(server.EMPTY_PAGE);
  #   await page.setContent(`<a href="${server.PREFIX}/download">download</a>`);
  #   const [ download ] = await Promise.all([
  #     page.waitForEvent('download'),
  #     page.click('a', { modifiers: ['Alt']})
  #   ]);
  #   const path = await download.path();
  #   expect(fs.existsSync(path)).toBeTruthy();
  #   expect(fs.readFileSync(path).toString()).toBe('Hello world');
  #   await page.close();
  # });

  # it('should report new window downloads', (test, { browserName, headful }) => {
  #   test.fixme(browserName === 'chromium' && headful);
  # }, async ({browser, server}) => {
  #   // TODO: - the test fails in headful Chromium as the popup page gets closed along
  #   // with the session before download completed event arrives.
  #   // - WebKit doesn't close the popup page
  #   const page = await browser.newPage({ acceptDownloads: true });
  #   await page.setContent(`<a target=_blank href="${server.PREFIX}/download">download</a>`);
  #   const [ download ] = await Promise.all([
  #     page.waitForEvent('download'),
  #     page.click('a')
  #   ]);
  #   const path = await download.path();
  #   expect(fs.existsSync(path)).toBeTruthy();
  #   await page.close();
  # });

  it 'should delete file' do
    with_page(acceptDownloads: true) do |page|
      page.content = "<a href=\"#{server_prefix}/download\">download</a>"
      download = page.expect_download do
        page.click('a')
      end
      path = download.path
      expect(File.read(path)).to eq('Hello world!')
      download.delete
      expect(File.exist?(path)).to eq(false)
    end
  end

  # it('should expose stream', async ({browser, server}) => {
  #   const page = await browser.newPage({ acceptDownloads: true });
  #   await page.setContent(`<a href="${server.PREFIX}/download">download</a>`);
  #   const [ download ] = await Promise.all([
  #     page.waitForEvent('download'),
  #     page.click('a')
  #   ]);
  #   const stream = await download.createReadStream();
  #   let content = '';
  #   stream.on('data', data => content += data.toString());
  #   await new Promise(f => stream.on('end', f));
  #   expect(content).toBe('Hello world');
  #   await page.close();
  # });

  # it('should delete downloads on context destruction', async ({browser, server}) => {
  #   const page = await browser.newPage({ acceptDownloads: true });
  #   await page.setContent(`<a href="${server.PREFIX}/download">download</a>`);
  #   const [ download1 ] = await Promise.all([
  #     page.waitForEvent('download'),
  #     page.click('a')
  #   ]);
  #   const [ download2 ] = await Promise.all([
  #     page.waitForEvent('download'),
  #     page.click('a')
  #   ]);
  #   const path1 = await download1.path();
  #   const path2 = await download2.path();
  #   expect(fs.existsSync(path1)).toBeTruthy();
  #   expect(fs.existsSync(path2)).toBeTruthy();
  #   await page.context().close();
  #   expect(fs.existsSync(path1)).toBeFalsy();
  #   expect(fs.existsSync(path2)).toBeFalsy();
  # });

  # it('should delete downloads on browser gone', async ({ server, browserType, browserOptions }) => {
  #   const browser = await browserType.launch(browserOptions);
  #   const page = await browser.newPage({ acceptDownloads: true });
  #   await page.setContent(`<a href="${server.PREFIX}/download">download</a>`);
  #   const [ download1 ] = await Promise.all([
  #     page.waitForEvent('download'),
  #     page.click('a')
  #   ]);
  #   const [ download2 ] = await Promise.all([
  #     page.waitForEvent('download'),
  #     page.click('a')
  #   ]);
  #   const path1 = await download1.path();
  #   const path2 = await download2.path();
  #   expect(fs.existsSync(path1)).toBeTruthy();
  #   expect(fs.existsSync(path2)).toBeTruthy();
  #   await browser.close();
  #   expect(fs.existsSync(path1)).toBeFalsy();
  #   expect(fs.existsSync(path2)).toBeFalsy();
  #   expect(fs.existsSync(path.join(path1, '..'))).toBeFalsy();
  # });

  # it('should close the context without awaiting the failed download', (test, { browserName }) => {
  #   test.skip(browserName !== 'chromium', 'Only Chromium downloads on alt-click');
  # }, async ({browser, server, httpsServer, testInfo}) => {
  #   const page = await browser.newPage({ acceptDownloads: true });
  #   await page.goto(server.EMPTY_PAGE);
  #   await page.setContent(`<a href="${httpsServer.PREFIX}/downloadWithFilename" download="file.txt">click me</a>`);
  #   const [download] = await Promise.all([
  #     page.waitForEvent('download'),
  #     // Use alt-click to force the download. Otherwise browsers might try to navigate first,
  #     // probably because of http -> https link.
  #     page.click('a', { modifiers: ['Alt']})
  #   ]);
  #   const [downloadPath, saveError] = await Promise.all([
  #     download.path(),
  #     download.saveAs(testInfo.outputPath('download.txt')).catch(e => e),
  #     page.context().close(),
  #   ]);
  #   expect(downloadPath).toBe(null);
  #   expect(saveError.message).toContain('Download deleted upon browser context closure.');
  # });

  # it('should close the context without awaiting the download', (test, { browserName, platform }) => {
  #   test.skip(browserName === 'webkit' && platform === 'linux', 'WebKit on linux does not convert to the download immediately upon receiving headers');
  # }, async ({browser, server, testInfo}) => {
  #   server.setRoute('/downloadStall', (req, res) => {
  #     res.setHeader('Content-Type', 'application/octet-stream');
  #     res.setHeader('Content-Disposition', 'attachment; filename=file.txt');
  #     res.writeHead(200);
  #     res.flushHeaders();
  #     res.write(`Hello world`);
  #   });

  #   const page = await browser.newPage({ acceptDownloads: true });
  #   await page.goto(server.EMPTY_PAGE);
  #   await page.setContent(`<a href="${server.PREFIX}/downloadStall" download="file.txt">click me</a>`);
  #   const [download] = await Promise.all([
  #     page.waitForEvent('download'),
  #     page.click('a')
  #   ]);
  #   const [downloadPath, saveError] = await Promise.all([
  #     download.path(),
  #     download.saveAs(testInfo.outputPath('download.txt')).catch(e => e),
  #     page.context().close(),
  #   ]);
  #   expect(downloadPath).toBe(null);
  #   expect(saveError.message).toContain('Download deleted upon browser context closure.');
  # });
end
