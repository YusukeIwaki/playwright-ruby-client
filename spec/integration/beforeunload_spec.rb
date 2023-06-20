require 'spec_helper'

RSpec.describe 'beforeunload', sinatra: true do
  it 'should close browser with beforeunload page' do
    page = browser.new_page
    page.goto("#{server_prefix}/beforeunload.html")
    # We have to interact with a page so that 'beforeunload' handlers
    # fire.
    page.click('body')
  end

  it 'should close browsercontext with beforeunload page' do
    with_context do |context|
      page = context.new_page
      page.goto("#{server_prefix}/beforeunload.html")
      # We have to interact with a page so that 'beforeunload' handlers
      # fire.
      page.click('body')
    end
  end

  it 'should be able to navigate away from page with beforeunload' do
    with_page do |page|
      page.goto("#{server_prefix}/beforeunload.html")
      # We have to interact with a page so that 'beforeunload' handlers
      # fire.
      page.click('body')
      page.goto(server_empty_page)
    end
  end

  it 'should close page with beforeunload listener' do
    with_page do |page|
      page.goto("#{server_prefix}/beforeunload.html")
      # We have to interact with a page so that 'beforeunload' handlers
      # fire.
      page.click('body')
      page.close
    end
  end

  it 'should run beforeunload if asked for @smoke', pending: true do
    with_page do |page|
      page.goto("#{server_prefix}/beforeunload.html")
      # We have to interact with a page so that 'beforeunload' handlers
      # fire.
      page.click('body')
      dialog = page.expect_event('dialog') do
        page.close(runBeforeUnload: true)
      end
      expect(dialog.type).to eq('beforeunload')
      expect(dialog.default_value).to eq('')
      page.expect_event('close') do
        dialog.accept
      end
    end
  end

  it 'should access page after beforeunload', pending: true do
    with_page do |page|
      page.goto("#{server_prefix}/beforeunload.html")
      # We have to interact with a page so that 'beforeunload' handlers
      # fire.
      page.click('body')
      dialog = page.expect_event('dialog') do
        page.close(runBeforeUnload: true)
      end
      dialog.dismiss
      page.evaluate('() => document.title')
    end
  end

  it 'should not stall on evaluate when dismissing beforeunload' do
    with_page do |page|
      page.goto("#{server_prefix}/beforeunload.html")
      # We have to interact with a page so that 'beforeunload' handlers
      # fire.
      page.click('body')
      dialog = page.expect_event('dialog') do
        Concurrent::Promises.future do
          page.evaluate('() => { window.location.reload(); }')
        end
      end
      dialog.dismiss
    end
  end
end
