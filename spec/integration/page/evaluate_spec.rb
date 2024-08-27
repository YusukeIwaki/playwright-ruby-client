require 'spec_helper'

RSpec.describe 'Page#evaluate' do
  it 'should transfer bigint' do
    with_page do |page|
      expect(page.evaluate('() => 42n')).to eq(42)
      expect(page.evaluate('(a) => a', arg: 9007199254740991)).to eq(9007199254740991)
      expect(page.evaluate('(a) => a', arg: 9007199254740992)).to eq(9007199254740992)
    end
  end

  it 'should transfer maps' do
    pending 'REMOVED functionality from Playwright 1.39.0'
    with_page do |page|
      expect(page.evaluate('() => new Map([[1, { test: 42n }]])')).to eq({1 => { 'test' => 42 }})
      expect(page.evaluate('(a) => a', arg: { 1 => { test: 17 } })).to eq({1 => { 'test' => 17 }})
    end
  end

  it 'should transfer sets' do
    pending 'REMOVED functionality from Playwright 1.39.0'
    with_page do |page|
      expect(page.evaluate('() => new Set([1, { test: 42 }])')).to eq(Set.new([1, { 'test' => 42 }]))
      expect(page.evaluate('(a) => a', arg: Set.new([1, { test: 17 }]))).to eq(Set.new([1, { 'test' => 17 }]))
    end
  end

  it 'should return undefined for non-serializable objects' do
    with_page do |page|
      expect(page.evaluate('() => function() {}')).to be_nil
    end
  end

  it 'should alias Window, Document and Node' do
    with_page do |page|
      expect(page.evaluate('() => window')).to eq('ref: <Window>')
      expect(page.evaluate('() => document')).to eq('ref: <Document>')
      expect(page.evaluate('() => document.body')).to eq('ref: <Node>')
    end
  end

  it 'should serialize circular object' do
    with_page do |page|
      a = {}
      a['b'] = a
      result = page.evaluate('(x) => x', arg: a)
      expect(result['b']).to eq(result)
    end
  end

  it 'should work for circular object' do
    with_page do |page|
      result = page.evaluate <<~JAVASCRIPT
      () => {
        const a = {};
        a.b = a;
        return a;
      };
      JAVASCRIPT
      expect(result['b']).to eq(result)
    end
  end

  it 'should evaluate exception' do
    with_page do |page|
      err = page.evaluate(<<~JAVASCRIPT)
        () => {
          function innerFunction() {
            const e = new Error('error message');
            e.name = 'foobar';
            return e;
          }
          return innerFunction();
        }
      JAVASCRIPT

      expect(err).to be_a(Playwright::Error)
      expect(err.message).to eq('error message')
      expect(err.name).to eq('foobar')
      expect(err.stack.join("\n")).to include('innerFunction')
    end
  end

  it 'should pass exception argument' do
    with_page do |page|
      err = page.evaluate(<<~JAVASCRIPT)
        () => {
          function innerFunction() {
            const e = new Error('error message');
            e.name = 'foobar';
            return e;
          }
          return innerFunction();
        }
      JAVASCRIPT

      js = <<~JAVASCRIPT
        e => {
          return { message: e.message, name: e.name, stack: e.stack };
        }
      JAVASCRIPT
      received = page.evaluate(js, arg: err)

      expect(received['message']).to eq('error message')
      expect(received['name']).to eq('foobar')
      expect(received['stack']).to include('innerFunction')
    end
  end

  it 'should evaluate date' do
    with_page do |page|
      result = page.evaluate('() => new Date("2017-09-26T00:00:00.000Z")')
      expect(result).to be_a(Date)
      expect(result).to eq(Date.parse('2017-09-26 00:00:00'))
    end
  end

  it 'should jsonValue() date' do
    with_page do |page|
      result_handle = page.evaluate_handle('() => new Date("2017-09-26T00:00:00.000Z")')
      date = result_handle.json_value
      expect(date).to be_a(Date)
      expect(date).to eq(Date.parse('2017-09-26 00:00:00'))
    end
  end

  it 'should evaluate url' do
    with_page do |page|
      result = page.evaluate("() => ({ url: new URL('https://example.com') })")
      expect(result['url']).to be_a(URI)
      expect(result['url']).to eq(URI('https://example.com'))
    end
  end

  it 'should roundtrip url' do
    with_page do |page|
      url = URI('https://example.com/search?q=123')
      result = page.evaluate('url => url', arg: url)
      expect(result).to eq(url)
    end
  end

  it 'should jsonValue() url' do
    with_page do |page|
      result_handle = page.evaluate_handle("() => ({ url: new URL('https://example.com/search?q=123') })")
      result = result_handle.json_value
      expect(result['url']).to be_a(URI)
      expect(result['url']).to eq(URI('https://example.com/search?q=123'))
    end
  end

  it 'should not use toJSON when evaluating' do
    with_page do |page|
      result = page.evaluate("() => ({ toJSON: () => 'string', data: 'data' })")
      expect(result['data']).to eq('data')
      expect(result['toJSON']).to eq({})
    end
  end
end
