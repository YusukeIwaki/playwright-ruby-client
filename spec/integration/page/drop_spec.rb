require 'spec_helper'
require 'tmpdir'

RSpec.describe 'Locator#drop' do
  # https://github.com/microsoft/playwright/blob/v1.60.0/tests/page/page-drop.spec.ts
  def setup_dropzone(page)
    page.content = <<~HTML
      <style>#dropzone { width: 300px; height: 200px; border: 2px dashed #888; }</style>
      <div id="dropzone"></div>
      <script>
        window.__dropInfo = null;
        const zone = document.getElementById('dropzone');
        zone.addEventListener('dragenter', e => e.preventDefault());
        zone.addEventListener('dragover', e => e.preventDefault());
        zone.addEventListener('drop', async e => {
          e.preventDefault();
          const files = [];
          for (const file of e.dataTransfer.files)
            files.push({ name: file.name, type: file.type, size: file.size, text: await file.text() });
          const data = {};
          for (const t of e.dataTransfer.types) {
            if (t !== 'Files')
              data[t] = e.dataTransfer.getData(t);
          }
          window.__dropInfo = { files, data };
        });
      </script>
    HTML
  end

  def drop_info(page)
    handle = page.wait_for_function('() => window.__dropInfo')
    handle.json_value
  end

  it 'should drop a file payload' do
    with_page do |page|
      setup_dropzone(page)
      page.locator('#dropzone').drop({ files: { name: 'note.txt', mimeType: 'text/plain', buffer: 'hello' } })
      expect(drop_info(page)).to eq({
        'files' => [{ 'name' => 'note.txt', 'type' => 'text/plain', 'size' => 5, 'text' => 'hello' }],
        'data' => {},
      })
    end
  end

  it 'should drop a file by local path' do
    with_page do |page|
      setup_dropzone(page)
      Dir.mktmpdir do |dir|
        file_path = File.join(dir, 'hello.txt')
        File.write(file_path, 'path-content')
        page.locator('#dropzone').drop({ files: file_path })
      end

      info = drop_info(page)
      expect(info['files'].length).to eq(1)
      expect(info['files'][0]['name']).to eq('hello.txt')
      expect(info['files'][0]['text']).to eq('path-content')
    end
  end

  it 'should drop multiple file payloads' do
    with_page do |page|
      setup_dropzone(page)
      page.locator('#dropzone').drop({
        files: [
          { name: 'a.txt', mimeType: 'text/plain', buffer: 'AAA' },
          { name: 'b.txt', mimeType: 'text/plain', buffer: 'BB' },
        ],
      })

      info = drop_info(page)
      expect(info['files'].map { |file| [file['name'], file['text']] }).to eq([['a.txt', 'AAA'], ['b.txt', 'BB']])
    end
  end

  it 'should drop clipboard-like data' do
    with_page do |page|
      setup_dropzone(page)
      page.locator('#dropzone').drop({
        data: {
          'text/plain' => 'hello world',
          'text/uri-list' => 'https://example.com',
        },
      })

      info = drop_info(page)
      expect(info['files']).to eq([])
      expect(info['data']['text/plain']).to eq('hello world')
      expect(info['data']['text/uri-list']).to eq('https://example.com')
    end
  end

  it 'should drop files and data together' do
    with_page do |page|
      setup_dropzone(page)
      page.locator('#dropzone').drop({
        files: { name: 'mix.txt', mimeType: 'text/plain', buffer: 'mix' },
        data: { 'text/plain' => 'label' },
      })

      info = drop_info(page)
      expect(info['files'][0]['text']).to eq('mix')
      expect(info['data']['text/plain']).to eq('label')
    end
  end

  it 'should throw when target does not accept drop' do
    with_page do |page|
      page.content = '<div id="dropzone" style="width: 200px; height: 100px;"></div>'
      expect {
        page.locator('#dropzone').drop({ data: { 'text/plain' => 'nope' } })
      }.to raise_error(/drop target did not accept the drop/i)
    end
  end

  it 'should throw when neither files nor data provided' do
    with_page do |page|
      setup_dropzone(page)
      expect {
        page.locator('#dropzone').drop({})
      }.to raise_error(/At least one of "files" or "data"/)
    end
  end
end
