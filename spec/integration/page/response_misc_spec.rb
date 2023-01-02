require 'spec_helper'

RSpec.describe 'response' do
  it 'https://github.com/YusukeIwaki/playwright-ruby-client/issues/227', sinatra: true do
    sinatra.get('/test') do
      'TEST-123'
    end

    with_page do |page|
      response_promise = Concurrent::Promises.resolvable_future
      page.on("response", -> (response) { response_promise.fulfill(response.body) })
      page.goto("#{server_prefix}/test")
      expect(response_promise.value!).to eq('TEST-123')
    end
  end
end
