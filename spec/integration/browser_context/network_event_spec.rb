require 'spec_helper'

RSpec.describe 'network event' do
  it 'BrowserContext.Events.Request', sinatra: true do
    with_context do |context|
      page = context.new_page
      requests = []
      context.on('request', -> (req) { requests << req })
      page.goto(server_empty_page)
      page.content = '<a target=_blank rel=noopener href="/one-style.html">yo</a>'

      page1 = context.expect_event('page') do
        page.click('a')
      end

      page1.wait_for_load_state
      urls = requests.map(&:url)
      expect(urls).to eq([
        server_empty_page,
        "#{server_prefix}/one-style.html",
        "#{server_prefix}/one-style.css",
      ])
    end
  end

  it 'BrowserContext.Events.Response', sinatra: true do
    with_context do |context|
      page = context.new_page
      responses = []
      context.on('response', -> (res) { responses << res })
      page.goto(server_empty_page)
      page.content = '<a target=_blank rel=noopener href="/one-style.html">yo</a>'

      page1 = context.expect_event('page') do
        page.click('a')
      end

      page1.wait_for_load_state
      urls = responses.map(&:url)
      expect(urls).to eq([
        server_empty_page,
        "#{server_prefix}/one-style.html",
        "#{server_prefix}/one-style.css",
      ])
    end
  end

  it 'BrowserContext.Events.RequestFailed', sinatra: true do
    sinatra.get('/one-style.css') { raise 'boom!' }
    #   server.setRoute('/one-style.css', (_, res) => {
    #     res.setHeader('Content-Type', 'text/css');
    #     res.connection.destroy();
    #   });

    with_context do |context|
      page = context.new_page
      failed_requests = []
      context.on('requestfailed', -> (req) { failed_requests << req })
      page.goto("#{server_prefix}/one-style.html")

      expect(failed_requests.size).to eq(1)

      req = failed_requests.first
      expect(req.url).to include("one-style.css")
      #   expect(req.response).to be_nil
      #   expect(failedRequests[0].resourceType()).toBe('stylesheet');
      #   expect(failedRequests[0].frame()).toBeTruthy();
    end
  end

  it 'BrowserContext.Events.RequestFinished', sinatra: true do
    with_context do |context|
      page = context.new_page


      response = nil
      context.expect_event('requestfinished') do
        response = page.goto(server_empty_page)
      end
      req = response.request
      expect(req.url).to eq(server_empty_page)
      expect(req.response).to be_a(Playwright::Response)
      expect(req.frame).to eq(page.main_frame)
      expect(req.frame.url).to eq(server_empty_page)
    end
  end

  it 'should fire events in proper order', sinatra: true do
    with_context do |context|
      page = context.new_page
      events = []
      context.on('request', ->(req) { events << 'req' })
      context.on('response', ->(res) { events << 'res' })
      context.on('requestfinished', ->(req) { events << 'reqfinish' })
      context.expect_event('requestfinished') do
        page.goto(server_empty_page)
      end
      expect(events).to eq(%w(req res reqfinish))
    end
  end
end
