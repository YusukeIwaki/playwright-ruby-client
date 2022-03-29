require 'spec_helper'

RSpec.describe 'Page#add_init_script',  sinatra: true do
  it 'should evaluate before anything else on the page' do
    with_page do |page|
      page.add_init_script(script: "window['injected'] = 123;")
      page.goto("#{server_prefix}/tamperable.html")
      result = page.evaluate("() => window['result']")
      expect(result).to eq(123)
    end
  end

  it 'should work with a path' do
    with_page do |page|
      page.add_init_script(path: File.join('spec', 'assets', 'injectedfile.js'))
      page.goto("#{server_prefix}/tamperable.html")
      result = page.evaluate("() => window['result']")
      expect(result).to eq(123)
    end
  end

  it 'should throw without path and script' do
    with_page do |page|
      expect {
        page.add_init_script
      }.to raise_error(/Either path or script parameter must be specified/)
    end
  end

  it 'should support multiple scripts' do
    with_page do |page|
      page.add_init_script(script: "window['script1'] = 1")
      page.add_init_script(script: "window['script2'] = 2")
      page.goto("#{server_prefix}/tamperable.html")
      expect(page.evaluate("() => window['script1']")).to eq(1)
      expect(page.evaluate("() => window['script2']")).to eq(2)
    end
  end
end
