require 'spec_helper'

RSpec.describe 'Page#wait_for_function' do
  it 'should accept a string' do
    with_page do |page|
      watchdog = Playwright::AsyncEvaluation.new { page.wait_for_function('window.__FOO === 1') }
      page.evaluate("() => window['__FOO'] = 1")
      Timeout.timeout(2) { watchdog.value! }
    end
  end

  # it('should work when resolved right before execution context disposal', async ({page}) => {
  #   await page.addInitScript(() => window['__RELOADED'] = true);
  #   await page.waitForFunction(() => {
  #     if (!window['__RELOADED'])
  #       window.location.reload();
  #     return true;
  #   });
  # });

  it 'should poll on interval' do
    polling = 100
    with_page do |page|
      js = <<~JAVASCRIPT
      () => {
        if (!window['__startTime']) {
          window['__startTime'] = Date.now();
          return false;
        }
        return Date.now() - window['__startTime'];
      }
      JAVASCRIPT
      time_delta = page.wait_for_function(js, polling: polling)
      expect(time_delta.json_value).to be >= polling
    end
  end

  # it('should avoid side effects after timeout', async ({page}) => {
  #   let counter = 0;
  #   page.on('console', () => ++counter);

  #   const error = await page.waitForFunction(() => {
  #     window['counter'] = (window['counter'] || 0) + 1;
  #     console.log(window['counter']);
  #   }, {}, { polling: 1, timeout: 1000 }).catch(e => e);

  #   const savedCounter = counter;
  #   await page.waitForTimeout(2000); // Give it some time to produce more logs.

  #   expect(error.message).toContain('page.waitForFunction: Timeout 1000ms exceeded');
  #   expect(counter).toBe(savedCounter);
  # });

  it 'should throw on polling:mutation' do
    with_page do |page|
      expect { page.wait_for_function('() => true', polling: 'mutation') }.to raise_error(/Unknown polling option: mutation/)
    end
  end

  it 'should poll on raf' do
    with_page do |page|
      watchdog = Playwright::AsyncEvaluation.new {
        page.wait_for_function("() => window['__FOO'] === 'hit'", polling: 'raf')
      }
      page.evaluate("() => window['__FOO'] = 'hit'")
      Timeout.timeout(2) { watchdog.value! }
    end
  end

  it 'should fail with predicate throwing on first call' do
    with_page do |page|
      expect { page.wait_for_function("() => { throw new Error('oh my'); }") }.to raise_error(/oh my/)
    end
  end

  # it('should fail with predicate throwing sometimes', async ({page}) => {
  #   const error = await page.waitForFunction(() => {
  #     window['counter'] = (window['counter'] || 0) + 1;
  #     if (window['counter'] === 3)
  #       throw new Error('Bad counter!');
  #     return window['counter'] === 5 ? 'result' : false;
  #   }).catch(e => e);
  #   expect(error.message).toContain('Bad counter!');
  # });

  # it('should fail with ReferenceError on wrong page', async ({page}) => {
  #   // @ts-ignore
  #   const error = await page.waitForFunction(() => globalVar === 123).catch(e => e);
  #   expect(error.message).toContain('globalVar');
  # });

  # it('should work with strict CSP policy', async ({page, server}) => {
  #   server.setCSP('/empty.html', 'script-src ' + server.PREFIX);
  #   await page.goto(server.EMPTY_PAGE);
  #   let error = null;
  #   await Promise.all([
  #     page.waitForFunction(() => window['__FOO'] === 'hit', {}, {polling: 'raf'}).catch(e => error = e),
  #     page.evaluate(() => window['__FOO'] = 'hit')
  #   ]);
  #   expect(error).toBe(null);
  # });

  it 'should throw on bad polling value' do
    with_page do |page|
      expect { page.wait_for_function('() => !!document.body', polling: 'unknown') }.to raise_error(/polling/)
    end
  end

  it 'should throw negative polling interval' do
    with_page do |page|
      expect { page.wait_for_function('() => !!document.body', polling: -10) }.to raise_error(/Cannot poll with non-positive interval/)
    end
  end

  it 'should return the success value as a JSHandle' do
    with_page do |page|
      expect(page.wait_for_function('() => 5').json_value).to eq(5)
    end
  end

  it 'should return the window as a success value' do
    with_page do |page|
      expect(page.wait_for_function('() => window')).not_to be_nil
    end
  end

  it 'should accept ElementHandle arguments' do
    with_page do |page|
      page.content = '<div></div>'
      div = page.query_selector('div')
      resolved = false

      promise = Playwright::AsyncEvaluation.new {
        page.wait_for_function('element => !element.parentElement', arg: div)
        resolved = true
      }
      expect {
        page.evaluate('element => element.remove()', arg: div)
        Timeout.timeout(1) { promise.value! }
      }.to change { resolved }.from(false).to(true)
    end
  end

  it 'should respect timeout' do
    with_page do |page|
      expect { page.wait_for_function('false', timeout: 10) }.to raise_error(/Timeout 10ms exceeded/)
    end
  end

  it 'should respect default timeout' do
    with_page do |page|
      page.default_timeout = 11
      expect { page.wait_for_function('false') }.to raise_error(/Timeout 11ms exceeded/)
    end
  end

  it 'should disable timeout when its set to 0' do
    with_page do |page|
      js = <<~JAVASCRIPT
      () => {
        window['__counter'] = (window['__counter'] || 0) + 1;
        return window['__injected'];
      }
      JAVASCRIPT
      watchdog = Playwright::AsyncEvaluation.new { page.wait_for_function(js, timeout: 0, polling: 10) }
      page.wait_for_function("() => window['__counter'] > 10")
      page.evaluate("() => window['__injected'] = true")
      Timeout.timeout(2) { watchdog.value! }
    end
  end

  # it('should survive cross-process navigation', async ({page, server}) => {
  #   let fooFound = false;
  #   const waitForFunction = page.waitForFunction('window.__FOO === 1').then(() => fooFound = true);
  #   await page.goto(server.EMPTY_PAGE);
  #   expect(fooFound).toBe(false);
  #   await page.reload();
  #   expect(fooFound).toBe(false);
  #   await page.goto(server.CROSS_PROCESS_PREFIX + '/grid.html');
  #   expect(fooFound).toBe(false);
  #   await page.evaluate(() => window['__FOO'] = 1);
  #   await waitForFunction;
  #   expect(fooFound).toBe(true);
  # });

  # it('should survive navigations', async ({page, server}) => {
  #   const watchdog = page.waitForFunction(() => window['__done']);
  #   await page.goto(server.EMPTY_PAGE);
  #   await page.goto(server.PREFIX + '/consolelog.html');
  #   await page.evaluate(() => window['__done'] = true);
  #   await watchdog;
  # });

  # it('should work with multiline body', async ({page}) => {
  #   const result = await page.waitForFunction(`
  #     (() => true)()
  #   `);
  #   expect(await result.jsonValue()).toBe(true);
  # });

  it 'should wait for predicate with arguments' do
    with_page do |page|
      page.wait_for_function('({arg1, arg2}) => arg1 + arg2 === 3', arg: { arg1: 1, arg2: 2})
    end
  end

  # it('should not be called after finishing successfully', async ({page, server}) => {
  #   await page.goto(server.EMPTY_PAGE);

  #   const messages = [];
  #   page.on('console', msg => {
  #     if (msg.text().startsWith('waitForFunction'))
  #       messages.push(msg.text());
  #   });

  #   await page.waitForFunction(() => {
  #     console.log('waitForFunction1');
  #     return true;
  #   });
  #   await page.reload();
  #   await page.waitForFunction(() => {
  #     console.log('waitForFunction2');
  #     return true;
  #   });
  #   await page.reload();
  #   await page.waitForFunction(() => {
  #     console.log('waitForFunction3');
  #     return true;
  #   });

  #   expect(messages.join('|')).toBe('waitForFunction1|waitForFunction2|waitForFunction3');
  # });

  # it('should not be called after finishing unsuccessfully', async ({page, server}) => {
  #   await page.goto(server.EMPTY_PAGE);

  #   const messages = [];
  #   page.on('console', msg => {
  #     if (msg.text().startsWith('waitForFunction'))
  #       messages.push(msg.text());
  #   });

  #   await page.waitForFunction(() => {
  #     console.log('waitForFunction1');
  #     throw new Error('waitForFunction1');
  #   }).catch(e => null);
  #   await page.reload();
  #   await page.waitForFunction(() => {
  #     console.log('waitForFunction2');
  #     throw new Error('waitForFunction2');
  #   }).catch(e => null);
  #   await page.reload();
  #   await page.waitForFunction(() => {
  #     console.log('waitForFunction3');
  #     throw new Error('waitForFunction3');
  #   }).catch(e => null);

  #   expect(messages.join('|')).toBe('waitForFunction1|waitForFunction2|waitForFunction3');
  # });
end
