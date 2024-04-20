require 'spec_helper'

RSpec.describe 'BrowserContext#clear_cookies', sinatra: true do
  it 'should clear cookies' do
    with_context do |context|
      page = context.new_page
      page.goto(server_empty_page)
      context.add_cookies([
        {
          url: server_empty_page,
          name: 'cookie1',
          value: '1',
        },
      ])
      expect(page.evaluate('document.cookie')).to eq('cookie1=1')
      context.clear_cookies
      expect(context.cookies).to be_empty
      page.reload
      expect(page.evaluate('document.cookie')).to eq('')
    end
  end

  it 'should isolate cookies when clearing' do
    with_context do |context|
      with_context do |another_context|
        context.add_cookies([{ url: server_empty_page, name: 'page1cookie', value: 'page1value' }])
        another_context.add_cookies([{ url: server_empty_page, name: 'page2cookie', value: 'page2value' }])

        expect(context.cookies.size).to eq(1)
        expect(another_context.cookies.size).to eq(1)

        context.clear_cookies
        expect(context.cookies.size).to eq(0)
        expect(another_context.cookies.size).to eq(1)

        another_context.clear_cookies
        expect(context.cookies.size).to eq(0)
        expect(another_context.cookies.size).to eq(0)
      end
    end
  end

  it 'should remove cookies by name' do
    with_context do |context|
      context.add_cookies([
        {
          name: 'cookie1',
          value: '1',
          domain: URI(server_prefix).host,
          path: '/',
        },
        {
          name: 'cookie2',
          value: '2',
          domain: URI(server_prefix).host,
          path: '/',
        }
      ])
      page = context.new_page
      page.goto(server_empty_page)
      expect(page.evaluate('document.cookie')).to eq('cookie1=1; cookie2=2')
      context.clear_cookies(name: 'cookie1')
      expect(page.evaluate('document.cookie')).to eq('cookie2=2')
    end
  end

  it 'should remove cookies by name regex' do
    with_context do |context|
      context.add_cookies([
        {
          name: 'cookie1',
          value: '1',
          domain: URI(server_prefix).host,
          path: '/',
        },
        {
          name: 'cookie2',
          value: '2',
          domain: URI(server_prefix).host,
          path: '/',
        }
      ])
      page = context.new_page
      page.goto(server_empty_page)
      expect(page.evaluate('document.cookie')).to eq('cookie1=1; cookie2=2')
      context.clear_cookies(name: /coo.*1/)
      expect(page.evaluate('document.cookie')).to eq('cookie2=2')
    end
  end

  it 'should remove cookies by domain' do
    with_context do |context|
      context.add_cookies([
        {
          name: 'cookie1',
          value: '1',
          domain: URI(server_prefix).host,
          path: '/',
        },
        {
          name: 'cookie2',
          value: '2',
          domain: URI(server_cross_process_prefix).host,
          path: '/',
        }
      ])
      page = context.new_page
      page.goto(server_empty_page)
      expect(page.evaluate('document.cookie')).to eq('cookie1=1')
      page.goto("#{server_cross_process_prefix}/empty.html")
      expect(page.evaluate('document.cookie')).to eq('cookie2=2')
      context.clear_cookies(domain: URI(server_cross_process_prefix).host)
      expect(page.evaluate('document.cookie')).to eq('')
      page.goto(server_empty_page)
      expect(page.evaluate('document.cookie')).to eq('cookie1=1')
    end
  end

  it 'should remove cookies by path' do
    with_context do |context|
      context.add_cookies([
        {
          name: 'cookie1',
          value: '1',
          domain: URI(server_prefix).host,
          path: '/api/v1',
        },
        {
          name: 'cookie2',
          value: '2',
          domain: URI(server_prefix).host,
          path: '/api/v2',
        },
        {
          name: 'cookie3',
          value: '3',
          domain: URI(server_prefix).host,
          path: '/',
        }
      ])
      page = context.new_page
      page.goto("#{server_prefix}/api/v1")
      expect(page.evaluate('document.cookie')).to eq('cookie1=1; cookie3=3')
      context.clear_cookies(path: '/api/v1')
      expect(page.evaluate('document.cookie')).to eq('cookie3=3')
      page.goto("#{server_prefix}/api/v2")
      expect(page.evaluate('document.cookie')).to eq('cookie2=2; cookie3=3')
      page.goto(server_empty_page)
      expect(page.evaluate('document.cookie')).to eq('cookie3=3')
    end
  end

  it 'should remove cookies by name and domain' do
    with_context do |context|
      context.add_cookies([
        {
          name: 'cookie1',
          value: '1',
          domain: URI(server_prefix).host,
          path: '/',
        },
        {
          name: 'cookie1',
          value: '1',
          domain: URI(server_cross_process_prefix).host,
          path: '/',
        }
      ])
      page = context.new_page
      page.goto(server_empty_page)
      expect(page.evaluate('document.cookie')).to eq('cookie1=1')
      context.clear_cookies(name: 'cookie1', domain: URI(server_prefix).host)
      expect(page.evaluate('document.cookie')).to eq('')
      page.goto("#{server_cross_process_prefix}/empty.html")
      expect(page.evaluate('document.cookie')).to eq('cookie1=1')
    end
  end
end
