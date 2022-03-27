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
end
