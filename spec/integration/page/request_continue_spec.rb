require 'spec_helper'

RSpec.describe 'request#continue' do
  it 'should work', sinatra: true do
    with_page do |page|
      page.route('**/*', -> (route, _) { route.continue })
      page.goto(server_empty_page)
    end
  end

  it 'continue should not change multipart/form-data body', sinatra: true do
    with_page do |page|
      page.goto(server_empty_page)
      promise = Concurrent::Promises.resolvable_future
      sinatra.post('/upload') do
        content_type 'text/plain'
        promise.fulfill(params[:file][:tempfile].read)
        'done'
      end

      page.route('**/*', -> (route, _) { route.continue })

      status = page.evaluate(<<~JAVASCRIPT)
      async () => {
        const newFile = new File(['file content'], 'file.txt');
        const formData = new FormData();
        formData.append('file', newFile);
        const response = await fetch('/upload', {
          method: 'POST',
          credentials: 'include',
          body: formData,
        });
        return response.status;
      }
      JAVASCRIPT
      expect(status).to eq(200)
      expect(promise.value!).to eq('file content')
    end
  end
end
