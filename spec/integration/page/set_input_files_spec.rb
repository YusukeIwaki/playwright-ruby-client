require 'spec_helper'
require 'tmpdir'

RSpec.describe 'Page#set_input_files' do
  let(:file_to_upload) { File.join('spec', 'assets', 'file-to-upload.txt') }

  it 'should upload the file', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/fileupload.html")
      input = page.query_selector('input')
      input.input_files = file_to_upload
      expect(page.evaluate('e => e.files[0].name', arg: input)).to eq('file-to-upload.txt')
      js = <<~JAVASCRIPT
      e => {
        const reader = new FileReader();
        const promise = new Promise(fulfill => reader.onload = fulfill);
        reader.readAsText(e.files[0]);
        return promise.then(() => reader.result);
      }
      JAVASCRIPT
      expect(page.evaluate(js, arg: input)).to eq('contents of the file')
    end
  end

  it 'should upload a folder', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/folderupload.html")
      input = page.query_selector('input')

      Dir.mktmpdir do |tmpdir|
        FileUtils.mkdir_p(File.join(tmpdir, 'file-upload-test', 'sub-dir'))
        File.write(File.join(tmpdir, 'file-upload-test', 'file1.txt'), 'file1 content')
        File.write(File.join(tmpdir, 'file-upload-test', 'file2'), 'file2 content')
        File.write(File.join(tmpdir, 'file-upload-test', 'sub-dir', 'really.txt'), 'sub-dir file content')

        input.input_files = File.join(tmpdir, 'file-upload-test')

        webkit_relative_paths = input.evaluate('e => [...e.files].map(f => f.webkitRelativePath)')
        expect(webkit_relative_paths.size).to eq(3)
        contents = webkit_relative_paths.map.with_index do |webkit_relative_path, i|
          input.evaluate(<<~JAVASCRIPT, arg: i)
          (e, i) => {
            const reader = new FileReader();
            const promise = new Promise(fulfill => reader.onload = fulfill);
            reader.readAsText(e.files[i]);
            return promise.then(() => reader.result);
          }
          JAVASCRIPT
        end
        expect(contents).to eq([
          'file1 content',
          'file2 content',
          'sub-dir file content',
        ])
      end
    end
  end

  it 'should upload a folder and throw for multiple directories', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/folderupload.html")
      input = page.query_selector('input')
      Dir.mktmpdir do |tmpdir|
        FileUtils.mkdir_p(File.join(tmpdir, 'file-upload-test', 'folder1'))
        File.write(File.join(tmpdir, 'file-upload-test', 'folder1', 'file1.txt'), 'file1 content')
        FileUtils.mkdir_p(File.join(tmpdir, 'file-upload-test', 'folder2'))
        File.write(File.join(tmpdir, 'file-upload-test', 'folder2', 'file2.txt'), 'file2 content')
        expect {
          input.input_files = [
            File.join(tmpdir, 'file-upload-test', 'folder1'),
            File.join(tmpdir, 'file-upload-test', 'folder2'),
          ]
        }.to raise_error(/Multiple directories are not supported/)
      end
    end
  end

  it 'should throw if a directory and files are passed', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/folderupload.html")
      input = page.query_selector('input')
      Dir.mktmpdir do |tmpdir|
        FileUtils.mkdir_p(File.join(tmpdir, 'file-upload-test', 'folder1'))
        File.write(File.join(tmpdir, 'file-upload-test', 'folder1', 'file1.txt'), 'file1 content')
        expect {
          input.input_files = [
            File.join(tmpdir, 'file-upload-test', 'folder1'),
            File.join(tmpdir, 'file-upload-test', 'folder1', 'file1.txt'),
          ]
        }.to raise_error(/File paths must be all files or a single directory/)
      end
    end
  end

  it 'should throw when uploading a folder in a normal file upload input', sinatra: true do
    with_page do |page|
      page.goto("#{server_prefix}/input/fileupload.html")
      input = page.query_selector('input')
      Dir.mktmpdir do |dir|
        FileUtils.mkdir_p(File.join(dir))
        File.write(File.join(dir, 'file1.txt'), 'file1 content')
        expect {
          input.input_files = dir
        }.to raise_error(/File input does not support directories, pass individual files instead/)
      end
    end
  end

  it 'should upload large file', sinatra: true do
    skip if webkit?
    if ENV['CI']
      # suppress logging for avoiding timeout exceeded.
      allow_any_instance_of(Playwright::Transport).to receive(:debug_send_message)
    end

    with_page do |page|
      page.goto("#{server_prefix}/input/fileupload.html")

      Dir.mktmpdir do |dir|
        upload_file = File.join(dir, '200MB.not.zip')
        open(upload_file, 'w') do |f|
          200.times do |i|
            f.write('A' * 1024 * 1024)
          end
        end
        input = page.locator('input[type="file"]')

        events = input.evaluate_handle(<<~JAVASCRIPT)
          (e) => {
            const events = [];
            e.addEventListener('input', () => events.push('input'));
            e.addEventListener('change', () => events.push('change'));
            return events;
          }
        JAVASCRIPT
        Timeout.timeout(30) { input.set_input_files(upload_file) }
        expect(input.evaluate('e => e.files[0].name')).to eq('200MB.not.zip')
        expect(events.evaluate('e => e')).to contain_exactly('input', 'change')

        future = Concurrent::Promises.resolvable_future
        sinatra.post('/upload') do
          future.fulfill({
            filename: params[:file1][:filename],
            filesize: File::Stat.new(params[:file1][:tempfile]).size,
          })
          'OK'
        end

        page.click('input[type=submit]')
        result = future.value!
        expect(result[:filename]).to eq('200MB.not.zip')
        expect(result[:filesize]).to eq(200 * 1024 * 1024)
      end
    end
  end

  it 'should work' do
    with_page do |page|
      page.content = '<input type=file>'
      page.set_input_files('input', file_to_upload)
      expect(page.eval_on_selector('input', 'input => input.files.length')).to eq(1)
      expect(page.eval_on_selector('input', 'input => input.files[0].name')).to eq('file-to-upload.txt')
    end
  end

  # it('should set from memory', async ({page}) => {
  #   await page.setContent(`<input type=file>`);
  #   await page.setInputFiles('input', {
  #     name: 'test.txt',
  #     mimeType: 'text/plain',
  #     buffer: Buffer.from('this is a test')
  #   });
  #   expect(await page.$eval('input', input => input.files.length)).toBe(1);
  #   expect(await page.$eval('input', input => input.files[0].name)).toBe('test.txt');
  # });

  it 'should emit event once' do
    with_page do |page|
      page.content = '<input type=file>'
      promise = Concurrent::Promises.resolvable_future
      page.once('filechooser', -> (chooser) { promise.fulfill(chooser) })
      sleep_a_bit_for_race_condition
      page.click('input')
      Timeout.timeout(2) do
        expect(promise.value!).to be_a(Playwright::FileChooser)
      end
    end
  end

  it 'should emit event on/off' do
    with_page do |page|
      page.content = '<input type=file>'
      promise = Concurrent::Promises.resolvable_future
      listener = ->(chooser) {
        page.off(Playwright::Events::Page::FileChooser, listener)
        promise.fulfill(chooser)
      }
      page.on(Playwright::Events::Page::FileChooser, listener)
      page.click('input')
      expect(promise.value!).to be_a(Playwright::FileChooser)
    end
  end

  it 'should work when file input is attached to DOM' do
    with_page do |page|
      page.content = '<input type=file>'
      chooser = page.expect_file_chooser do
        page.click('input')
      end
      expect(chooser).to be_a(Playwright::FileChooser)
    end
  end

  it 'should work when file input is not attached to DOM' do
    js = <<~JAVASCRIPT
    () => {
      const el = document.createElement('input');
      el.type = 'file';
      el.click();
    }
    JAVASCRIPT

    with_page do |page|
      chooser = page.expect_file_chooser do
        page.evaluate(js)
      end
      expect(chooser).to be_a(Playwright::FileChooser)
    end
  end

  # it('should not throw when filechooser belongs to iframe', (test, { browserName }) => {
  #   test.skip(browserName === 'firefox', 'Firefox ignores filechooser from child frame');
  # }, async ({page, server}) => {
  #   await page.goto(server.PREFIX + '/frames/one-frame.html');
  #   const frame = page.mainFrame().childFrames()[0];
  #   await frame.setContent(`
  #     <div>Click me</div>
  #     <script>
  #       document.querySelector('div').addEventListener('click', () => {
  #         const input = document.createElement('input');
  #         input.type = 'file';
  #         input.click();
  #         window.parent.__done = true;
  #       });
  #     </script>
  #   `);
  #   await Promise.all([
  #     page.waitForEvent('filechooser'),
  #     frame.click('div')
  #   ]);
  #   await page.waitForFunction(() => (window as any).__done);
  # });

  # it('should not throw when frame is detached immediately', async ({page, server}) => {
  #   await page.goto(server.PREFIX + '/frames/one-frame.html');
  #   const frame = page.mainFrame().childFrames()[0];
  #   await frame.setContent(`
  #     <div>Click me</div>
  #     <script>
  #       document.querySelector('div').addEventListener('click', () => {
  #         const input = document.createElement('input');
  #         input.type = 'file';
  #         input.click();
  #         window.parent.__done = true;
  #         const iframe = window.parent.document.querySelector('iframe');
  #         iframe.remove();
  #       });
  #     </script>
  #   `);
  #   page.on('filechooser', () => {});  // To ensure we handle file choosers.
  #   await frame.click('div');
  #   await page.waitForFunction(() => (window as any).__done);
  # });

  # it('should work with CSP', async ({page, server}) => {
  #   server.setCSP('/empty.html', 'default-src "none"');
  #   await page.goto(server.EMPTY_PAGE);
  #   await page.setContent(`<input type=file>`);
  #   await page.setInputFiles('input', path.join(__dirname, '/assets/file-to-upload.txt'));
  #   expect(await page.$eval('input', input => input.files.length)).toBe(1);
  #   expect(await page.$eval('input', input => input.files[0].name)).toBe('file-to-upload.txt');
  # });

  it 'should respect timeout' do
    with_page do |page|
      expect {
        Timeout.timeout(2) do
          page.expect_file_chooser(timeout: 10)
        end
      }.to raise_error(Playwright::TimeoutError)
    end
  end

  it 'should respect default timeout when there is no custom timeout' do
    with_page do |page|
      page.default_timeout = 10
      expect {
        Timeout.timeout(2) do
          page.expect_file_chooser
        end
      }.to raise_error(Playwright::TimeoutError)
    end
  end

  it 'should prioritize exact timeout over default timeout' do
    with_page do |page|
      page.default_timeout = 0
      expect {
        Timeout.timeout(2) do
          page.expect_file_chooser(timeout: 10)
        end
      }.to raise_error(Playwright::TimeoutError)
    end
  end

  it 'should work with no timeout' do
    js = <<~JAVASCRIPT
    () => setTimeout(() => {
      const el = document.createElement('input');
      el.type = 'file';
      el.click();
    }, 50)
    JAVASCRIPT

    with_page do |page|
      chooser = Timeout.timeout(2) do
        page.expect_file_chooser(timeout: 0) do
          page.evaluate(js)
        end
      end
      expect(chooser).to be_a(Playwright::FileChooser)
    end
  end

  # it('should return the same file chooser when there are many watchdogs simultaneously', async ({page, server}) => {
  #   await page.setContent(`<input type=file>`);
  #   const [fileChooser1, fileChooser2] = await Promise.all([
  #     page.waitForEvent('filechooser'),
  #     page.waitForEvent('filechooser'),
  #     page.$eval('input', input => input.click()),
  #   ]);
  #   expect(fileChooser1 === fileChooser2).toBe(true);
  # });

  # it('should accept single file', async ({page, server}) => {
  #   await page.setContent(`<input type=file oninput='javascript:console.timeStamp()'>`);
  #   const [fileChooser] = await Promise.all([
  #     page.waitForEvent('filechooser'),
  #     page.click('input'),
  #   ]);
  #   expect(fileChooser.page()).toBe(page);
  #   expect(fileChooser.element()).toBeTruthy();
  #   await fileChooser.setFiles(FILE_TO_UPLOAD);
  #   expect(await page.$eval('input', input => input.files.length)).toBe(1);
  #   expect(await page.$eval('input', input => input.files[0].name)).toBe('file-to-upload.txt');
  # });

  # it('should detect mime type', async ({page, server}) => {
  #   let files;
  #   server.setRoute('/upload', async (req, res) => {
  #     const form = new formidable.IncomingForm();
  #     form.parse(req, function(err, fields, f) {
  #       files = f;
  #       res.end();
  #     });
  #   });
  #   await page.goto(server.EMPTY_PAGE);
  #   await page.setContent(`
  #     <form action="/upload" method="post" enctype="multipart/form-data" >
  #       <input type="file" name="file1">
  #       <input type="file" name="file2">
  #       <input type="submit" value="Submit">
  #     </form>`);
  #   await (await page.$('input[name=file1]')).setInputFiles(path.join(__dirname, '/assets/file-to-upload.txt'));
  #   await (await page.$('input[name=file2]')).setInputFiles(path.join(__dirname, '/assets/pptr.png'));
  #   await Promise.all([
  #     page.click('input[type=submit]'),
  #     server.waitForRequest('/upload'),
  #   ]);
  #   const { file1, file2 } = files;
  #   expect(file1.name).toBe('file-to-upload.txt');
  #   expect(file1.type).toBe('text/plain');
  #   expect(fs.readFileSync(file1.path).toString()).toBe(
  #       fs.readFileSync(path.join(__dirname, '/assets/file-to-upload.txt')).toString());
  #   expect(file2.name).toBe('pptr.png');
  #   expect(file2.type).toBe('image/png');
  #   expect(fs.readFileSync(file2.path).toString()).toBe(
  #       fs.readFileSync(path.join(__dirname, '/assets/pptr.png')).toString());
  # });

  # it('should be able to read selected file', async ({page, server}) => {
  #   await page.setContent(`<input type=file>`);
  #   const [, content] = await Promise.all([
  #     page.waitForEvent('filechooser').then(fileChooser => fileChooser.setFiles(FILE_TO_UPLOAD)),
  #     page.$eval('input', async picker => {
  #       picker.click();
  #       await new Promise(x => picker.oninput = x);
  #       const reader = new FileReader();
  #       const promise = new Promise(fulfill => reader.onload = fulfill);
  #       reader.readAsText(picker.files[0]);
  #       return promise.then(() => reader.result);
  #     }),
  #   ]);
  #   expect(content).toBe('contents of the file');
  # });

  # it('should be able to reset selected files with empty file list', async ({page, server}) => {
  #   await page.setContent(`<input type=file>`);
  #   const [, fileLength1] = await Promise.all([
  #     page.waitForEvent('filechooser').then(fileChooser => fileChooser.setFiles(FILE_TO_UPLOAD)),
  #     page.$eval('input', async picker => {
  #       picker.click();
  #       await new Promise(x => picker.oninput = x);
  #       return picker.files.length;
  #     }),
  #   ]);
  #   expect(fileLength1).toBe(1);
  #   const [, fileLength2] = await Promise.all([
  #     page.waitForEvent('filechooser').then(fileChooser => fileChooser.setFiles([])),
  #     page.$eval('input', async picker => {
  #       picker.click();
  #       await new Promise(x => picker.oninput = x);
  #       return picker.files.length;
  #     }),
  #   ]);
  #   expect(fileLength2).toBe(0);
  # });

  # it('should not accept multiple files for single-file input', async ({page, server}) => {
  #   await page.setContent(`<input type=file>`);
  #   const [fileChooser] = await Promise.all([
  #     page.waitForEvent('filechooser'),
  #     page.click('input'),
  #   ]);
  #   let error = null;
  #   await fileChooser.setFiles([
  #     path.relative(process.cwd(), __dirname + '/assets/file-to-upload.txt'),
  #     path.relative(process.cwd(), __dirname + '/assets/pptr.png')
  #   ]).catch(e => error = e);
  #   expect(error).not.toBe(null);
  # });

  # it('should emit input and change events', async ({page, server}) => {
  #   const events = [];
  #   await page.exposeFunction('eventHandled', e => events.push(e));
  #   await page.setContent(`
  #   <input id=input type=file></input>
  #   <script>
  #     input.addEventListener('input', e => eventHandled({ type: e.type }));
  #     input.addEventListener('change', e => eventHandled({ type: e.type }));
  #   </script>`);
  #   await (await page.$('input')).setInputFiles(FILE_TO_UPLOAD);
  #   expect(events.length).toBe(2);
  #   expect(events[0].type).toBe('input');
  #   expect(events[1].type).toBe('change');
  # });

  it 'should work for single file pick' do
    with_page do |page|
      page.content = '<input type=file>'
      chooser = page.expect_file_chooser do
        page.click('input')
      end
      expect(chooser).not_to be_multiple
    end
  end

  it 'should work for "multiple"' do
    with_page do |page|
      page.content = '<input multiple type=file>'
      chooser = page.expect_file_chooser do
        page.click('input')
      end
      expect(chooser).to be_multiple
    end
  end

  it 'should work for "webkitdirectory"' do
    with_page do |page|
      page.content = '<input multiple webkitdirectory type=file>'
      chooser = page.expect_file_chooser do
        page.click('input')
      end
      expect(chooser).to be_multiple
    end
  end
end
