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
end
