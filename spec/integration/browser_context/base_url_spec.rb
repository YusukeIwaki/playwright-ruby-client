require 'spec_helper'

RSpec.describe 'baseUrl' do
  it 'should construct a new URL when a baseURL in browser.newContext is passed to page.goto', sinatra: true do
    with_context(baseURL: server_prefix) do |context|
      page = context.new_page
      expect(page.goto('/empty.html').url).to eq(server_empty_page)
    end
  end

  it 'should construct a new URL when a baseURL in browser.newPage is passed to page.goto', sinatra: true do
    with_page(baseURL: server_prefix) do |page|
      expect(page.goto('/empty.html').url).to eq(server_empty_page)
    end
  end

  it 'should construct the URLs correctly when a baseURL without a trailing slash in browser.newPage is passed to page.goto', sinatra: true do
    with_page(baseURL: "#{server_prefix}/url-construction") do |page|
      expect(page.goto('mypage.html').url).to eq("#{server_prefix}/mypage.html")
      expect(page.goto('./mypage.html').url).to eq("#{server_prefix}/mypage.html")
      expect(page.goto('/mypage.html').url).to eq("#{server_prefix}/mypage.html")
    end
  end

  it 'should construct the URLs correctly when a baseURL with a trailing slash in browser.newPage is passed to page.goto', sinatra: true do
    with_page(baseURL: "#{server_prefix}/url-construction/") do |page|
      expect(page.goto('mypage.html').url).to eq("#{server_prefix}/url-construction/mypage.html")
      expect(page.goto('./mypage.html').url).to eq("#{server_prefix}/url-construction/mypage.html")
      expect(page.goto('/mypage.html').url).to eq("#{server_prefix}/mypage.html")
      expect(page.goto('.').url).to eq("#{server_prefix}/url-construction/")
      expect(page.goto('/').url).to eq("#{server_prefix}/")
    end
  end

  it 'should not construct a new URL when valid URLs are passed', sinatra: true do
    with_page(baseURL: 'https://example.com') do |page|
      expect(page.goto(server_empty_page).url).to eq(server_empty_page)

      page.goto('data:text/html,Hello world')
      expect(page.evaluate('window.location.href')).to eq('data:text/html,Hello world')

      page.goto('about:blank')
      expect(page.evaluate('window.location.href')).to eq('about:blank')
    end
  end

  it 'should be able to match a URL relative to its given URL with urlMatcher', sinatra: true do
    sinatra.get('/kek/index.html') do
      body('It works!')
    end

    with_page(baseURL: "#{server_prefix}/foobar/") do |page|
      page.goto('/kek/index.html')
      page.wait_for_url('/kek/index.html')
      expect(page.url).to eq("#{server_prefix}/kek/index.html")

      page.route('./kek/index.html', ->(route, _) { route.fulfill(body: 'base-url-matched-route') })
      response = page.expect_response('./kek/index.html') do
        request = page.expect_request('./kek/index.html') do
          page.goto('./kek/index.html')
        end
        expect(request.url).to eq("#{server_prefix}/foobar/kek/index.html")
      end
      expect(response.url).to eq("#{server_prefix}/foobar/kek/index.html")
      expect(response.body).to eq('base-url-matched-route')
    end
  end
end
