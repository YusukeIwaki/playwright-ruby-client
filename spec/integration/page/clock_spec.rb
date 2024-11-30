require 'spec_helper'

RSpec.describe 'Clock API' do
  around do |example|
    with_page do |page|
      @calls = []
      page.expose_function('stub', ->(*args) { @calls << args })
      @page = page
      example.run
    end
  end
  attr_reader :calls, :page

  def wait_for_async_evaluation
    sleep 0.20
  end

  describe 'run_for' do
    before do
      page.clock.install(time: 0)
      page.clock.pause_at(1000)
    end

    it 'triggers immediately without specified delay' do
      page.evaluate('async () => { setTimeout(window.stub) }')
      page.clock.run_for(0)
      wait_for_async_evaluation
      expect(calls.size).to eq(1)
    end

    it 'does not trigger without sufficient delay' do
      page.evaluate('async () => { setTimeout(window.stub, 100) }')
      page.clock.run_for(10)
      wait_for_async_evaluation
      expect(calls).to be_empty
    end

    it 'triggers after sufficient delay' do
      page.evaluate('async () => { setTimeout(window.stub, 100) }')
      page.clock.run_for(100)
      wait_for_async_evaluation
      expect(calls.size).to eq(1)
    end

    it 'triggers simultaneous timers' do
      page.evaluate('async () => { setTimeout(window.stub, 100); setTimeout(window.stub, 100) }')
      page.clock.run_for(100)
      wait_for_async_evaluation
      expect(calls.size).to eq(2)
    end

    it 'triggers multiple simultaneous timers' do
      page.evaluate('async () => { setTimeout(window.stub, 100); setTimeout(window.stub, 100); setTimeout(window.stub, 99); setTimeout(window.stub, 100) }')
      page.clock.run_for(100)
      wait_for_async_evaluation
      expect(calls.size).to eq(4)
    end

    it 'waits after setTimeout was called' do
      page.evaluate('async () => { setTimeout(window.stub, 150) }')
      page.clock.run_for(50)
      expect(calls).to be_empty
      page.clock.run_for(100)
      wait_for_async_evaluation
      expect(calls.size).to eq(1)
    end

    it 'triggers event when some throw' do
      page.evaluate('async () => { setTimeout(() => { throw new Error("Hoge") }, 100); setTimeout(window.stub, 120) }')
      expect { page.clock.run_for(120) }.to raise_error(/Error: Hoge/)
      expect(calls.size).to eq(1)
    end

    it 'created updated Date while ticking' do
      page.clock.set_system_time(0)
      page.evaluate('async () => { setInterval(() => { window.stub(new Date().getTime()) }, 10) }')
      page.clock.run_for(100)

      wait_for_async_evaluation
      expect(calls).to eq([
        [10],
        [20],
        [30],
        [40],
        [50],
        [60],
        [70],
        [80],
        [90],
        [100],
      ])
    end

    it 'passes 8 seconds' do
      page.evaluate('async () => { setInterval(window.stub, 4000) }')
      page.clock.run_for('08')
      wait_for_async_evaluation
      expect(calls.size).to eq(2)
    end

    it 'passes 1 minute' do
      page.evaluate('async () => { setInterval(window.stub, 6000) }')
      page.clock.run_for('01:00')
      wait_for_async_evaluation
      expect(calls.size).to eq(10)
    end

    it 'passes 2 hours, 34 minutes and 10 seconds' do
      page.evaluate('async () => { setInterval(window.stub, 10000) }')
      page.clock.run_for('02:34:10')
      wait_for_async_evaluation
      expect(calls.size).to eq(925)
    end

    it 'throws for invalid format' do
      page.evaluate('async () => { setInterval(window.stub, 10000) }')
      expect { page.clock.run_for('12:02:34:10') }.to raise_error(/numbers, 'mm:ss' and 'hh:mm:ss'/)
      expect(calls).to be_empty
    end

    it 'returns the current now value' do
      page.clock.set_system_time(0)
      value = 200
      page.clock.run_for(value)
      expect(page.evaluate('Date.now()')).to eq(value)
    end
  end

  describe 'fast_forward' do
    before do
      page.clock.install(time: 0)
      page.clock.pause_at(1000)
    end

    it 'ignores timers which wouldn\'t be run' do
      page.evaluate('async () => { setTimeout(() => { window.stub("should not be logged") }, 1000) }')
      page.clock.fast_forward(500)
      expect(calls).to be_empty
    end

    it 'pushes back execution time for skipped timers' do
      page.evaluate('async () => { setTimeout(() => { window.stub(Date.now()) }, 1000) }')
      page.clock.fast_forward(2000)
      wait_for_async_evaluation
      expect(calls).to eq([[1000 + 2000]])
    end

    it 'supports string time arguments' do
      page.evaluate('async () => { setTimeout(() => { window.stub(Date.now()) }, 100000) }') # 1:40
      page.clock.fast_forward('01:50')
      wait_for_async_evaluation
      expect(calls).to eq([[1000 + 110000]])
    end
  end

  describe 'stubTimers' do
    before do
      page.clock.install(time: 0)
      page.clock.pause_at(1000)
    end

    it 'sets initial timestamp' do
      page.clock.set_system_time(1400)
      expect(page.evaluate('Date.now()')).to eq(1400)
    end

    it 'should throw for invalid date' do
      expect { page.clock.set_system_time('invalid') }.to raise_error(/Invalid date: invalid/)
    end

    it 'replace global setTimeout' do
      page.evaluate('async () => { setTimeout(window.stub, 1000) }')
      page.clock.run_for(1000)
      wait_for_async_evaluation
      expect(calls.size).to eq(1)
    end

    it 'global fake setTimeout should return id' do
      to = page.evaluate('setTimeout(window.stub, 1000)')
      expect(to).to be_a(Integer)
    end

    it 'replace global clearTimeout' do
      page.evaluate('async () => { const to = setTimeout(window.stub, 1000); clearTimeout(to) }')
      page.clock.run_for(1000)
      wait_for_async_evaluation
      expect(calls).to be_empty
    end

    it 'replace global setInterval' do
      page.evaluate('async () => { setInterval(window.stub, 500) }')
      page.clock.run_for(1000)
      wait_for_async_evaluation
      expect(calls.size).to eq(2)
    end

    it 'replace global clearInterval' do
      page.evaluate('async () => { const to = setInterval(window.stub, 500); clearInterval(to) }')
      page.clock.run_for(1000)
      wait_for_async_evaluation
      expect(calls).to be_empty
    end

    it 'replace global performance.now' do
      js = <<~JAVASCRIPT
      async () => {
        const prev = performance.now();
        await new Promise(f => setTimeout(f, 1000));
        const next = performance.now();
        return { prev, next }
      }
      JAVASCRIPT
      promise = Concurrent::Promises.future { page.evaluate(js) }
      page.clock.run_for(1000)
      wait_for_async_evaluation
      expect(promise.value!).to eq('prev' => 1000, 'next' => 2000)
    end

    it 'fakes Date constructor' do
      now = page.evaluate('new Date().getTime()')
      expect(now).to eq(1000)
    end
  end

  describe 'stubTimers' do
    it 'replaces global performance.timeOrigin' do
      page.clock.install(time: 1000)
      page.clock.pause_at(2000)
      javascript = <<~JAVASCRIPT
      async () => {
        const prev = performance.now();
        await new Promise(f => setTimeout(f, 1000));
        const next = performance.now();
        return { prev, next };
      }
      JAVASCRIPT
      promise = Concurrent::Promises.future { page.evaluate(javascript) }
      page.clock.run_for(1000)
      expect(page.evaluate('performance.timeOrigin')).to eq(1000)
      wait_for_async_evaluation
      expect(promise.value!).to eq('prev' => 1000, 'next' => 2000)
    end
  end

  # it.describe('popup', () => {
  #   it('should tick after popup', async ({ page }) => {
  #     await page.clock.install({ time: 0 });
  #     const now = new Date('2015-09-25');
  #     await page.clock.pauseAt(now);
  #     const [popup] = await Promise.all([
  #       page.waitForEvent('popup'),
  #       page.evaluate(() => window.open('about:blank')),
  #     ]);
  #     const popupTime = await popup.evaluate(() => Date.now());
  #     expect(popupTime).toBe(now.getTime());
  #     await page.clock.runFor(1000);
  #     const popupTimeAfter = await popup.evaluate(() => Date.now());
  #     expect(popupTimeAfter).toBe(now.getTime() + 1000);
  #   });

  #   it('should tick before popup', async ({ page }) => {
  #     await page.clock.install({ time: 0 });
  #     const now = new Date('2015-09-25');
  #     await page.clock.pauseAt(now);
  #     await page.clock.runFor(1000);

  #     const [popup] = await Promise.all([
  #       page.waitForEvent('popup'),
  #       page.evaluate(() => window.open('about:blank')),
  #     ]);
  #     const popupTime = await popup.evaluate(() => Date.now());
  #     expect(popupTime).toBe(now.getTime() + 1000);
  #   });

  #   it('should run time before popup', async ({ page, server }) => {
  #     server.setRoute('/popup.html', async (req, res) => {
  #       res.setHeader('Content-Type', 'text/html');
  #       res.end(`<script>window.time = Date.now()</script>`);
  #     });
  #     await page.goto(server.EMPTY_PAGE);
  #     // Wait for 2 second in real life to check that it is past in popup.
  #     await page.waitForTimeout(2000);
  #     const [popup] = await Promise.all([
  #       page.waitForEvent('popup'),
  #       page.evaluate(url => window.open(url), server.PREFIX + '/popup.html'),
  #     ]);
  #     const popupTime = await popup.evaluate('time');
  #     expect(popupTime).toBeGreaterThanOrEqual(2000);
  #   });

  #   it('should not run time before popup on pause', async ({ page, server }) => {
  #     server.setRoute('/popup.html', async (req, res) => {
  #       res.setHeader('Content-Type', 'text/html');
  #       res.end(`<script>window.time = Date.now()</script>`);
  #     });
  #     await page.clock.install({ time: 0 });
  #     await page.clock.pauseAt(1000);
  #     await page.goto(server.EMPTY_PAGE);
  #     // Wait for 2 second in real life to check that it is past in popup.
  #     await page.waitForTimeout(2000);
  #     const [popup] = await Promise.all([
  #       page.waitForEvent('popup'),
  #       page.evaluate(url => window.open(url), server.PREFIX + '/popup.html'),
  #     ]);
  #     const popupTime = await popup.evaluate('time');
  #     expect(popupTime).toBe(1000);
  #   });
  # });

  describe 'set_fixed_time' do
    it 'should work' do
      page.clock.set_fixed_time(DateTime.parse("2020-01-01T00:12:34+0900"))
      expect(page.evaluate('() => new Date().getUTCFullYear()')).to eq(2019)
      expect(page.evaluate('() => new Date().getUTCMonth()')).to eq(11)
      expect(page.evaluate('() => new Date().getUTCDate()')).to eq(31)
      expect(page.evaluate('() => new Date().getUTCHours()')).to eq(15)
      expect(page.evaluate('() => new Date().getUTCMinutes()')).to eq(12)
      expect(page.evaluate('() => new Date().getUTCSeconds()')).to eq(34)
    end

    it 'does not fake methods' do
      page.clock.fixed_time = 0

      Timeout.timeout(1) do
        # Should not stall.
        page.evaluate('() => { return new Promise(f => setTimeout(f, 1)) }')
      end
    end

    it 'allows setting time multiple times' do
      page.clock.fixed_time = 100
      expect(page.evaluate('Date.now()')).to eq(100)
      page.clock.fixed_time = 200
      expect(page.evaluate('Date.now()')).to eq(200)
    end

    it 'fixed time is not affected by clock manipulation' do
      page.clock.fixed_time = 100
      expect(page.evaluate('Date.now()')).to eq(100)
      page.clock.fast_forward(20)
      expect(page.evaluate('Date.now()')).to eq(100)
    end

    it 'allows installing fake timers after settings time' do
      page.clock.fixed_time = 100
      expect(page.evaluate('Date.now()')).to eq(100)
      page.clock.fixed_time = 200
      page.evaluate('setTimeout(() => window.stub(Date.now()))')
      page.clock.run_for(0)
      expect(calls).to eq([[200]])
    end
  end

  describe 'while running'  do
    it 'should progress time' do
      page.clock.install(time: 0)
      page.goto('data:text/html,')
      page.wait_for_timeout(1000)
      now = page.evaluate('Date.now()')
      expect(now).to be_between(1000, 2000)
    end

    it 'should runFor' do
      page.clock.install(time: 0)
      page.goto('data:text/html,')
      page.clock.run_for(10000)
      now = page.evaluate('Date.now()')
      expect(now).to be_between(10000, 11000)
    end

    it 'should fastForward' do
      page.clock.install(time: 0)
      page.goto('data:text/html,')
      page.clock.fast_forward(10000)
      now = page.evaluate('Date.now()')
      expect(now).to be_between(10000, 11000)
    end

    it 'should pause' do
      page.clock.install(time: 0)
      page.goto('data:text/html,')
      page.clock.pause_at(1000)
      page.wait_for_timeout(1000)
      page.clock.resume
      now = page.evaluate('Date.now()')
      expect(now).to be_between(0, 1000)
    end

    it 'should pause and fastForward' do
      page.clock.install(time: 0)
      page.goto('data:text/html,')
      page.clock.pause_at(1000)
      page.clock.fast_forward(1000)
      now = page.evaluate('Date.now()')
      expect(now).to eq(2000)
    end

    it 'should set system time on pause' do
      page.clock.install(time: 0)
      page.goto('data:text/html,')
      page.clock.pause_at(1000)
      now = page.evaluate('Date.now()')
      expect(now).to eq(1000)
    end
  end

  describe 'while on pause' do
    it 'fastForward should not run nested immediate' do
      page.clock.install(time: 0)
      page.goto('data:text/html,')
      page.clock.pause_at(1000)
      js = <<~JAVASCRIPT
      () => {
        setTimeout(() => {
          window.stub('outer');
          setTimeout(() => window.stub('inner'), 0);
        }, 1000);
      }
      JAVASCRIPT
      page.evaluate(js)
      page.clock.fast_forward(1000)
      wait_for_async_evaluation
      expect(calls).to eq([['outer']])
      page.clock.fast_forward(1)
      wait_for_async_evaluation
      expect(calls).to eq([['outer'], ['inner']])
    end

    it 'runFor should not run nested immediate' do
      page.clock.install(time: 0)
      page.goto('data:text/html,')
      page.clock.pause_at(1000)
      js = <<~JAVASCRIPT
      () => {
        setTimeout(() => {
          window.stub('outer');
          setTimeout(() => window.stub('inner'), 0);
        }, 1000);
      }
      JAVASCRIPT
      page.evaluate(js)
      page.clock.run_for(1000)
      wait_for_async_evaluation
      expect(calls).to eq([['outer']])
      page.clock.run_for(1)
      wait_for_async_evaluation
      expect(calls).to eq([['outer'], ['inner']])
    end

    it 'runFor should not run nested immediate from microtask' do
      page.clock.install(time: 0)
      page.goto('data:text/html,')
      page.clock.pause_at(1000)
      js = <<~JAVASCRIPT
      () => {
        setTimeout(() => {
          window.stub('outer');
          void Promise.resolve().then(() => setTimeout(() => window.stub('inner'), 0));
        }, 1000);
      }
      JAVASCRIPT
      page.evaluate(js)
      page.clock.run_for(1000)
      wait_for_async_evaluation
      expect(calls).to eq([['outer']])
      page.clock.run_for(1)
      wait_for_async_evaluation
      expect(calls).to eq([['outer'], ['inner']])
    end
  end
end
