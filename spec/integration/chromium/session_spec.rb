require 'spec_helper'

# https://github.com/microsoft/playwright/blob/master/tests/chromium/session.spec.ts
RSpec.describe 'CDPSession' do
  before { skip unless chromium? }

  it 'should work' do
    with_page do |page|
      client = page.context.new_cdp_session(page)

      client.send_message('Runtime.enable')
      client.send_message('Runtime.evaluate', params: { expression: 'window.foo = "bar"' })
      foo = page.evaluate('() => window["foo"]')
      expect(foo).to eq('bar')
    end
  end

  it 'should send events', sinatra: true do
    with_page do |page|
      client = page.context.new_cdp_session(page)

      client.send_message('Network.enable')
      events = []
      client.on('Network.requestWillBeSent', ->(event) { events << event })
      page.goto(server_empty_page)
      expect(events.size).to eq(1)
    end
  end

  it 'should only accept a page' do
    with_page do |page|
      expect { page.context.new_cdp_session(page.context) }.to raise_error(/expected Page/)
    end
  end

  # it('should enable and disable domains independently', async function({page}) {
  #   const client = await page.context().newCDPSession(page);
  #   await client.send('Runtime.enable');
  #   await client.send('Debugger.enable');
  #   // JS coverage enables and then disables Debugger domain.
  #   await page.coverage.startJSCoverage();
  #   await page.coverage.stopJSCoverage();
  #   page.on('console', console.log);
  #   // generate a script in page and wait for the event.
  #   await Promise.all([
  #     new Promise<void>(f => client.on('Debugger.scriptParsed', event => {
  #       if (event.url === 'foo.js')
  #         f();
  #     })),
  #     page.evaluate('//# sourceURL=foo.js')
  #   ]);
  # });

  it 'should be able to detach session' do
    with_page do |page|
      client = page.context.new_cdp_session(page)

      client.send_message('Runtime.enable')
      resp = client.send_message('Runtime.evaluate', params: { expression: '1 + 2', returnByValue: true })
      expect(resp['result']['value']).to eq(3)
      client.detach

      expect {
        client.send_message('Runtime.evaluate', params: { expression: '3 + 2', returnByValue: true })
      }.to raise_error(/Target page, context or browser has been closed/)
    end
  end

  # it('should throw nice errors', async function({page}) {
  #   const client = await page.context().newCDPSession(page);
  #   const error = await theSourceOfTheProblems().catch(error => error);
  #   expect(error.stack).toContain('theSourceOfTheProblems');
  #   expect(error.message).toContain('ThisCommand.DoesNotExist');

  #   async function theSourceOfTheProblems() {
  #     // @ts-expect-error invalid command
  #     await client.send('ThisCommand.DoesNotExist');
  #   }
  # });

  it 'should not break page.close()' do
    with_page do |page|
      session = page.context.new_cdp_session(page)
      session.detach
    end
  end

  # browserTest('should detach when page closes', async function({browser}) {
  #   const context = await browser.newContext();
  #   const page = await context.newPage();
  #   const session = await context.newCDPSession(page);
  #   await page.close();
  #   let error;
  #   await session.detach().catch(e => error = e);
  #   expect(error).toBeTruthy();
  #   await context.close();
  # });

  it 'should work with newBrowserCDPSession' do
    session = browser.new_browser_cdp_session
    version = session.send_message('Browser.getVersion')
    expect(version['userAgent']).to include('Chrome')

    got_event = false
    session.on('Target.targetCreated', -> (target) { got_event = true })
    session.send_message('Target.setDiscoverTargets', params: { discover: true })
    expect(got_event).to eq(true)
    session.detach
  end
end
