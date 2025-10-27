require 'spec_helper'

RSpec.describe 'pageerror' do
  it 'should fire', sinatra: true do
    url = "#{server_prefix}/error.html"
    with_page do |page|
      error = page.expect_event('pageerror') do
        page.goto(url)
      end
      expect(error.name).to eq('Error')
      expect(error.message).to eq('Fancy error!')
    end
  end

  it 'should not receive console message for pageError', sinatra: true do
    with_page do |page|
      messages = []
      page.on('console', -> (e) { messages << e })
      page.expect_event('pageerror') do
        page.goto("#{server_prefix}/error.html")
      end
      expect(messages.length).to eq(1)
    end
  end

  it 'should contain sourceURL', sinatra: true do
    skip 'fails in webkit' if webkit?
    with_page do |page|
      error = page.expect_event('pageerror') do
        page.goto("#{server_prefix}/error.html")
      end
      expect(error.stack).to include('myscript.js')
    end
  end

  it 'should contain the Error.name property' do
    with_page do |page|
      error = page.expect_event('pageerror') do
        page.evaluate(<<~JS)
          () => {
            setTimeout(() => {
              const error = new Error('my-message');
              error.name = 'my-name';
              throw error;
            }, 0);
          }
        JS
      end
      expect(error.name).to eq('my-name')
      expect(error.message).to eq('my-message')
    end
  end

  it 'should support an empty Error.name property' do
    with_page do |page|
      error = page.expect_event('pageerror') do
        page.evaluate(<<~JS)
          () => {
            setTimeout(() => {
              const error = new Error('my-message');
              error.name = '';
              throw error;
            }, 0);
          }
        JS
      end
      expect(error.name).to eq('')
      expect(error.message).to eq('my-message')
    end
  end

  it 'should handle odd values' do
    with_page do |page|
      error = page.expect_event('pageerror') do
        page.evaluate("() => { setTimeout(() => { throw null; }, 0); }")
      end
      expect(error.message).to eq('null')

      error = page.expect_event('pageerror') do
        page.evaluate("() => { setTimeout(() => { throw undefined; }, 0); }")
      end
      expect(error.message).to eq('undefined')

      error = page.expect_event('pageerror') do
        page.evaluate("() => { setTimeout(() => { throw 0; }, 0); }")
      end
      expect(error.message).to eq('0')

      error = page.expect_event('pageerror') do
        page.evaluate("() => { setTimeout(() => { throw ''; }, 0); }")
      end
      expect(error.message).to eq('')
    end
  end

  it 'should handle object' do
    with_page do |page|
      error = page.expect_event('pageerror') do
        page.evaluate("() => { setTimeout(() => { throw {}; }, 0); }")
      end
      if chromium?
        expect(error.message).to eq('Object')
      else
        expect(error.message).to eq('[object Object]')
      end
    end
  end

  it 'should handle window' do
    with_page do |page|
      error = page.expect_event('pageerror') do
        page.evaluate("() => { setTimeout(() => { throw window; }, 0); }")
      end
      if chromium?
        expect(error.message).to eq('Window')
      else
        expect(error.message).to eq('[object Window]')
      end
    end
  end

  it 'should remove a listener of a non-existing event handler' do
    with_page do |page|
      # Ensure calling remove_listener (no-op)
      page.off('pageerror', -> { })
    end
  end

  it 'pageErrors should work' do
    with_page do |page|
      page.evaluate(<<~JS)
        () => new Promise(resolve => {
          for (let i = 0; i < 301; i++)
            setTimeout(() => { throw new Error('error' + i); }, 0);
          setTimeout(resolve, 100);
        })
      JS

      errors = page.page_errors
      messages = errors.map(&:message)
      expected = (201...301).map { |i| "error#{i}" }

      expect(messages.length).to be >= 100
      expect(messages.last(expected.length)).to eq(expected)
    end
  end
end
