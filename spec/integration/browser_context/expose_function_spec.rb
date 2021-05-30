require 'spec_helper'

RSpec.describe 'expose function' do
  it 'expose binding should work' do
    with_context do |context|
      binding_source = nil
      context.expose_binding('add', ->(source, a, b) {
        binding_source = source
        a + b
      })

      page = context.new_page
      result = page.evaluate('add(5, 6)')
      expect(binding_source[:context]).to eq(context)
      expect(binding_source[:page]).to eq(page)
      expect(binding_source[:frame]).to eq(page.main_frame)
      expect(result).to eq(11)
    end
  end

  it 'should work' do
    with_context do |context|
      context.expose_function('add', ->(a, b) { a + b })
      page = context.new_page
      page.expose_function('mul', ->(a, b) { a * b })
      context.expose_function('sub', ->(a, b) { a - b })
      context.expose_binding('addHandle', ->(source, a, b) {
        # Original implementation uses evaluateHandle, but ElementHandle cannot be parsed.
        # (JS implementation is very special...)
        # source[:frame].evaluate_handle('([a, b]) => a + b', arg: [a, b])
        source[:frame].evaluate('([a, b]) => a + b', arg: [a, b])
      })
      result = page.evaluate('(async () => ({ mul: await mul(9, 4), add: await add(9, 4), sub: await sub(9, 4), addHandle: await addHandle(5, 6) }))()')
      expect(result).to eq({ 'mul' => 36, 'add' => 13, 'sub' => 5, 'addHandle' => 11 })
    end
  end

  it 'should throw for duplicate registrations' do
    with_context do |context|
      context.expose_function('foo', ->(source) {})
      context.expose_function('bar', ->(source) {})
      expect { context.expose_function('foo', ->(source) {}) }.to raise_error(/Function "foo" has been already registered/)

      page = context.new_page
      expect { page.expose_function('foo', ->(source) {}) }.to raise_error(/Function "foo" has been already registered/)

      page.expose_function('baz', ->(source) {})
      expect { context.expose_function('baz', ->(source) {}) }.to raise_error(/Function "baz" has been already registered/)
    end
  end

  it 'should be callable from-inside addInitScript' do
    with_context do |context|
      args = []
      context.expose_function('woof', ->(arg) { args << arg })
      context.add_init_script(script: 'window["woof"]("context")')

      page = context.new_page
      page.evaluate('undefined')
      expect(args).to contain_exactly('context')

      args.clear
      page.add_init_script(script: 'window["woof"]("page")')
      page.reload
      expect(args).to eq(['context', 'page'])
    end
  end

  it 'exposeBindingHandle should work' do
    with_context do |context|
      target = nil
      context.expose_binding('logme', ->(source, t) {
        target = t
        17
      }, handle: true)
      page = context.new_page
      result = page.evaluate('async () => window["logme"]({ foo: 42})')
      expect(target.evaluate('x => x.foo')).to eq(42)
      expect(result).to eq(17)
    end
  end

  # it('should work with CSP', async ({ page, context, server }) => {
  #   server.setCSP('/empty.html', 'default-src "self"');
  #   await page.goto(server.EMPTY_PAGE);
  #   let called = false;
  #   await context.exposeBinding('hi', () => called = true);
  #   await page.evaluate(() => (window as any).hi());
  #   expect(called).toBe(true);
  # });
end
