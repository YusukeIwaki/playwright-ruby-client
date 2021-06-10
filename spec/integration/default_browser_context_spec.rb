require 'spec_helper'

RSpec.describe 'default browser context' do
  # https://github.com/microsoft/playwright/blob/master/tests/defaultbrowsercontext-2.spec.ts
  it 'should accept userDataDir' do
    Dir.mktmpdir do |tmpdir|
      browser_type.launch_persistent_context(tmpdir) do |context|
        expect(Dir.glob(File.join(tmpdir, '*/**'))).not_to be_empty
      end
      expect(Dir.glob(File.join(tmpdir, '*/**'))).not_to be_empty
    end
  end

  it 'should restore state from userDataDir', sinatra: true do
    Dir.mktmpdir do |tmpdir|
      browser_type.launch_persistent_context(tmpdir) do |context|
        page = context.new_page
        page.goto(server_empty_page)
        page.evaluate("() => localStorage.hey = 'hello'")
      end

      browser_type.launch_persistent_context(tmpdir) do |context|
        page = context.new_page
        page.goto(server_empty_page)
        expect(page.evaluate("() => localStorage.hey")).to eq('hello')
      end
    end

    Dir.mktmpdir do |tmpdir|
      browser_type.launch_persistent_context(tmpdir) do |context|
        page = context.new_page
        page.goto(server_empty_page)
        expect(page.evaluate("() => localStorage.hey")).not_to eq('hello')
      end
    end
  end
end
