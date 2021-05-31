require 'spec_helper'

RSpec.describe 'Page#expect_response' do
  it 'should work', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      response = page.expect_response("#{server_prefix}/digits/2.png") do
        page.evaluate(<<~JAVASCRIPT)
        () => {
          fetch('/digits/1.png');
          fetch('/digits/2.png');
          fetch('/digits/3.png');
        }
        JAVASCRIPT
      end
      expect(response.url).to eq("#{server_prefix}/digits/2.png")
    end
  end

  it 'should respect timeout' do
    with_page do |page|
      expect { page.expect_response(->(resp) { false }, timeout: 1) }.to raise_error(Playwright::TimeoutError)
    end
  end

  it 'should respect default timeout' do
    with_page do |page|
      page.default_timeout = 1
      expect { page.expect_response(->(resp) { false }) }.to raise_error(Playwright::TimeoutError)
    end
  end

  xit 'should log the url' do
    with_page do |page|
      expect { page.expect_response('foo.css', timeout: 100) }.to raise_error(/waiting for response "foo.css"/)
      expect { page.expect_response(/foo.css/i, timeout: 100) }.to raise_error(/waiting for response \/foo.css\/i/)
    end
  end

  it 'should work with predicate', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      response = page.expect_response(->(resp) { resp.url == "#{server_prefix}/digits/2.png"}) do
        page.evaluate(<<~JAVASCRIPT)
        () => {
          fetch('/digits/1.png');
          fetch('/digits/2.png');
          fetch('/digits/3.png');
        }
        JAVASCRIPT
      end
      expect(response.url).to eq("#{server_prefix}/digits/2.png")
    end
  end

  it 'sync predicate should be only called once', sinatra: true, skip: ENV['CI'] do
    # FIXME: This spec is really flaky.
    # Multi-threading doesn't ensure to call "expect(counter).to eq(1)" during fetch(digits/1) and fetch(digits/2)
    with_page do |page|
      page.goto(server_empty_page)
      counter = 0
      response = page.expect_response(->(resp) { counter += 1 ; resp.url == "#{server_prefix}/digits/1.png"}) do
        page.evaluate(<<~JAVASCRIPT)
        () => {
          fetch('/digits/1.png');
          fetch('/digits/2.png');
          fetch('/digits/3.png');
        }
        JAVASCRIPT
      end
      expect(response.url).to eq("#{server_prefix}/digits/1.png")
      expect(counter).to eq(1)
    end
  end

  it 'should work with no timeout', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      response = page.expect_response("#{server_prefix}/digits/2.png", timeout: 0) do
        page.evaluate(<<~JAVASCRIPT)
        () => setTimeout(() => {
          fetch('/digits/1.png');
          fetch('/digits/2.png');
          fetch('/digits/3.png');
        }, 500)
        JAVASCRIPT
      end
      expect(response.url).to eq("#{server_prefix}/digits/2.png")
    end
  end
end
