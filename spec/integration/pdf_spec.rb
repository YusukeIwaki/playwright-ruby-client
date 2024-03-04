require 'spec_helper'
require 'tmpdir'

RSpec.describe 'Page#pdf' do
  it 'should be able to save file' do
    skip unless chromium?
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'output.pdf')

      with_page do |page|
        page.content = "<h1>It works!</h1>"
        page.pdf(path: path)
      end
      expect(File.read(path).size).to be > 0
    end
  end

  it 'should be able to generate outline', sinatra: true do
    skip unless chromium?
    Dir.mktmpdir do |dir|
      output_file_no_outline = File.join(dir, 'outputNoOutline.pdf')
      output_file_outline = File.join(dir, 'outputOutline.pdf')

      with_page do |page|
        page.goto("#{server_prefix}/headings.html")
        page.pdf(path: output_file_no_outline)
        page.pdf(path: output_file_outline, tagged: true, outline: true)
      end

      file_size_no_outline = File.read(output_file_no_outline).size
      file_size_outline = File.read(output_file_outline).size
      expect(file_size_outline).to be > file_size_no_outline
    end
  end
end
