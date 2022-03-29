require 'spec_helper'

RSpec.describe 'BrowserContext#add_init_script',  sinatra: true do
  it 'should work with browser context scripts' do
    with_context do |context|
      context.add_init_script(script: "window['injected'] = 123;")
      page = context.new_page
      page.goto("#{server_prefix}/tamperable.html")
      result = page.evaluate("() => window['result']")
      expect(result).to eq(123)
    end
  end

  it 'should work without navigation in popup' do
    with_context do |context|
      context.add_init_script(script: "window['temp'] = 123")
      page = context.new_page
      popup = page.expect_popup do
        page.evaluate("() => window['win'] = window.open()")
      end
      expect(popup.evaluate("() => window['temp']")).to eq(123)
    end
  end

  it 'should work with browser context scripts with a path ' do
    with_context do |context|
      context.add_init_script(path: File.join('spec', 'assets', 'injectedfile.js'))
      page = context.new_page
      page.goto("#{server_prefix}/tamperable.html")
      result = page.evaluate("() => window['result']")
      expect(result).to eq(123)
    end
  end

  it 'should work with browser context scripts for already created pages' do
    with_context do |context|
      page = context.new_page
      context.add_init_script(script: "window['temp'] = 123")
      page.add_init_script(script: "window['injected'] = window['temp']")
      page.goto("#{server_prefix}/tamperable.html")
      result = page.evaluate("() => window['result']")
      expect(result).to eq(123)
    end
  end
end
