# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'
require './development/generate_api/example_codes'

RSpec.describe 'example' do
  it 'should take a screenshot' do
    with_page do |page|
      page.goto('https://github.com/YusukeIwaki')
      tmpdir = Dir.mktmpdir
      begin
        path = File.join(tmpdir, 'YusukeIwaki.png')
        page.screenshot(path: path)
        expect(File.open(path, 'rb').read.size).to be > 1000
      ensure
        FileUtils.remove_entry(tmpdir, true)
      end
    end
  end

  it 'should input text and grab DOM elements', skip: ENV['CI'] do
    with_page do |page|
      page = browser.new_page
      page.viewport_size = { width: 1280, height: 800 }
      page.goto('https://github.com/')

      form = page.query_selector("form.js-site-search-form")
      search_input = form.query_selector("input.header-search-input")
      search_input.click

      expect(page.keyboard).to be_a(::Playwright::Keyboard)

      page.keyboard.type("playwright")
      page.expect_navigation {
        page.keyboard.press("Enter")
      }

      list = page.query_selector("ul.repo-list")
      items = list.query_selector_all("div.f4")
      items.each do |item|
        title = item.eval_on_selector("a", "a => a.innerText")
        puts("==> #{title}")
      end
    end
  end

  it 'should evaluate expression' do
    with_page do |page|
      expect(page.evaluate('2 + 3')).to eq(5)
    end
  end

  it 'should evaluate function returning object' do
    with_page do |page|
      expect(page.evaluate('() => { return { a: 3, b: 4 } }')).to eq({'a' => 3, 'b' => 4})
    end
  end

  it 'exposes guid for Page' do
    with_page do |page|
      expect(browser.contexts.map(&:pages).flatten.map(&:guid)).to include(page.guid)
    end
  end

  it 'returns the same Playwright API instance for the same impl' do
    with_page do |page|
      expect(page.context.pages.last).to equal(page)
      expect(browser.new_page).not_to equal(page)
    end
  end

  context 'with ExampleCodes' do
    include ExampleCodes

    it 'should work with BrowserContext#expose_binding' do
      with_context do |context|
        example_81b90f669e98413d55dfbd74319b8b505b137187a593ed03c46b56125a286201(browser_context: context)
        example_93e847f70b01456eec429a1ebfaa6b8f5334f4c227fd73e62dd6a7facb48dbbd(browser_context: context)
        example_ec3ef36671a002a6e12799fc5321ff60647c20c3f42fbd712d06e1c58cef75f5(browser_context: context)
      end
    end

    it 'should work with BrowserContext#route' do
      example_8bee851cbea1ae0c60fba8361af41cc837666490d20c25552a32f79c4e044721(browser: browser)
      example_aa8a83c2ddd0d9a327cfce8528c61f52cb5d6ec0f0258e03d73fad5481f15360(browser: browser)
    end

    it 'should work with BrowserContext#set_geolocation' do
      with_context do |context|
        example_12142bb78171e322de3049ac91a332da192d99461076da67614b9520b7cd0c6f(browser_context: context)
      end
    end

    it 'should work with JSHandle#properties' do
      with_page do |page|
        example_8292f0e8974d97d20be9bb303d55ccd2d50e42f954e0ada4958ddbef2c6c2977(page: page)
      end
    end

    it 'should work with Page#dispatch_event' do
      with_page do |page|
        example_9220b94fd2fa381ab91448dcb551e2eb9806ad331c83454a710f4d8a280990e8(page: page)
        example_9b4482b7243b7ce304d6ce8454395e23db30f3d1d83229242ab7bd2abd5b72e0(page: page)
      end
    end

    it 'should work with Page#press' do
      with_page do |page|
        example_aa4598bd7dbeb8d2f8f5c0aa3bdc84042eb396de37b49f8ff8c1ea39f080f709(page: page)
      end
    end

    it 'should work with Page#expect_request' do
      with_page do |page|
        example_9246912bc386c2f9310662279b12200ae131f724a1ec1ca99e511568767cb9c8(page: page)
      end
    end

    it 'should work with Page#expect_response' do
      with_page do |page|
        example_d2a76790c0bb59bf5ae2f41d1a29b50954412136de3699ec79dc33cdfd56004b(page: page)
      end
    end

    it 'should work with Page#wait_for_selector' do
      with_page do |page|
        example_0a62ff34b0d31a64dd1597b9dff456e4139b36207d26efdec7109e278dc315a3(page: page)
      end
    end
  end
end
