require 'spec_helper'

RSpec.describe 'console message' do
  it 'should work @smoke' do
    with_page do |page|
      observed_message = nil
      page.on('console', -> (msg) {
        observed_message ||= msg
      })

      message = page.expect_event('console') do
        page.evaluate('() => console.log("hello", 5, { foo: "bar" })')
      end

      expect(message.text).to start_with('hello 5 ')
      expect(message.type).to eq('log')
      expect(message.args[0].json_value).to eq('hello')
      expect(message.args[1].json_value).to eq(5)
      expect(message.args[2].json_value).to eq({ 'foo' => 'bar' })

      expect(observed_message.text).to start_with('hello 5 ')
      expect(observed_message.type).to eq('log')
      expect(observed_message.args[0].json_value).to eq('hello')
      expect(observed_message.args[1].json_value).to eq(5)
      expect(observed_message.args[2].json_value).to eq({ 'foo' => 'bar' })
    end
  end

  it 'should emit same log twice' do
    with_page do |page|
      messages = []
      page.on('console', -> (msg) {
        messages << msg.text
      })

      page.evaluate('() => { for (let i = 0; i < 2; ++i) console.log("hello"); }')
      expect(messages).to eq(['hello', 'hello'])
    end
  end

  it 'should use text() for inspection' do
    with_page do |page|
      observed = nil
      page.on('console', -> (msg) { observed = msg.text })
      page.evaluate("() => console.log('Hello world')")
      expect(observed).to eq('Hello world')
    end
  end

  it 'should work for different console API calls' do
    with_page do |page|
      messages = []
      page.on('console', -> (msg) { messages << msg })

      page.evaluate(<<~JAVASCRIPT)
        () => {
          console.time('calling console.time');
          console.timeEnd('calling console.time');
          console.trace('calling console.trace');
          console.dir('calling console.dir');
          console.warn('calling console.warn');
          console.error('calling console.error');
          console.info('calling console.info');
          console.debug('calling console.debug');
          console.log(Promise.resolve('should not wait until resolved!'));
        }
      JAVASCRIPT

      page.expose_binding('foobar', ->(_source, value) do
        page.evaluate("v => console.log(v)", arg: value)
      end)
      page.evaluate("() => window['foobar']('Using bindings')")

      expect(messages.map { |m| m.type }).to eq(%w[timeEnd trace dir warning error info debug log log])
      expect(messages.first.text).to include('calling console.time')
      expect(messages[1..].map { |m| m.text }).to eq([
        'calling console.trace',
        'calling console.dir',
        'calling console.warn',
        'calling console.error',
        'calling console.info',
        'calling console.debug',
        'Promise',
        'Using bindings',
      ])
    end
  end

  it 'consoleMessages should work' do
    with_page do |page|
      page.evaluate(<<~JAVASCRIPT)
        () => {
          for (let i = 0; i < 301; i++)
            console.log('message' + i);
        }
      JAVASCRIPT

      messages = page.console_messages
      expect(messages.length).to be >= 100

      last_texts = messages.last(100).map(&:text)
      expected_texts = (201...301).map { |i| "message#{i}" }
      expect(last_texts).to eq(expected_texts)
      expect(messages.last(100).all? { |m| m.type == 'log' }).to be true
      expect(messages.last(100).all? { |m| m.page == page }).to be true
    end
  end
end
