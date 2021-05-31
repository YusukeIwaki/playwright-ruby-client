require 'spec_helper'

RSpec.describe 'Page#expect_request' do
  it 'should work', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      request = page.expect_request("#{server_prefix}/digits/2.png") do
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

  it 'should work with predicate', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      request = page.expect_request(->(req) { req.url == "#{server_prefix}/digits/2.png"}) do
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

  it 'should respect timeout' do
    with_page do |page|
      expect { page.expect_request(->(req) { false }, timeout: 1) }.to raise_error(Playwright::TimeoutError)
    end
  end

  it 'should respect default timeout' do
    with_page do |page|
      page.default_timeout = 1
      expect { page.expect_request(->(req) { false }) }.to raise_error(Playwright::TimeoutError)
    end
  end

  xit 'should log the url' do
    with_page do |page|
      expect { page.expect_request('long-long-long-long-long-long-long-long-long-long-long-long-long-long.css', timeout: 100) }.to raise_error(/waiting for request "long-long-long-long-long-long-long-long-long-long-…"/)
    end
  end

  it 'should work with no timeout', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      request = page.expect_request("#{server_prefix}/digits/2.png", timeout: 0) do
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

  it 'should work with url match', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      request = page.expect_request(/digits\/\d\.png/) do
        page.evaluate(<<~JAVASCRIPT)
        () => {
          fetch('/digits/1.png');
          fetch('/digits/2.png');
          fetch('/digits/3.png');
        }
        JAVASCRIPT
      end
      expect(request.url).to eq("#{server_prefix}/digits/1.png")
    end
  end
end
