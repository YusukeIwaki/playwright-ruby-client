require 'spec_helper'

RSpec.describe 'Page#expect_request_finished' do
  it 'should work', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      request = page.expect_request_finished(predicate: ->(req) { req.url == "#{server_prefix}/digits/2.png"}) do
        page.evaluate(<<~JAVASCRIPT)
        () => {
          fetch('/digits/1.png');
          fetch('/digits/2.png');
          fetch('/digits/3.png');
        }
        JAVASCRIPT
      end
      expect(request.url).to eq("#{server_prefix}/digits/2.png")
    end
  end

  it 'should work without predicate', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      page.content = '<a href="one-style.html">one-style</a>'
      request = page.expect_request_finished do
        page.click('a')
      end
      # one-style.css or one-style.html
      expect(request.url).to start_with("#{server_prefix}/one-style.")
    end
  end

  it 'should respect timeout' do
    with_page do |page|
      expect { page.expect_request_finished(predicate: ->(req) { false }, timeout: 1) }.to raise_error(Playwright::TimeoutError)
    end
  end

  it 'should respect default timeout' do
    with_page do |page|
      page.default_timeout = 1
      expect { page.expect_request_finished(predicate: ->(req) { false }) }.to raise_error(Playwright::TimeoutError)
    end
  end

  it 'should work with no timeout', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      request = page.expect_request_finished(predicate: ->(req) { req.url == "#{server_prefix}/digits/2.png"}) do
        page.evaluate(<<~JAVASCRIPT)
        () => setTimeout(() => {
          fetch('/digits/1.png');
          fetch('/digits/2.png');
          fetch('/digits/3.png');
        }, 500)
        JAVASCRIPT
      end
      expect(request.url).to eq("#{server_prefix}/digits/2.png")
    end
  end
end
