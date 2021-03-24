# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

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
end
