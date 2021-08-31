require 'spec_helper'
require 'tempfile'

RSpec.describe 'HAR' do
  def parse_har_file(file)
    har = JSON.parse(File.read(file))
    har['log']
  end

  def with_page_with_har(&block)
    Tempfile.create do |file|
      with_context(record_har_path: file.path) do |context|
        block.call(context.new_page)
      end
      parse_har_file(file.path)
    end
  end

  it 'should have version and creator', sinatra: true do
    log = with_page_with_har do |page|
      page.goto(server_empty_page)
    end
    expect(log['version']).to eq('1.2')
    expect(log['creator']['name']).to eq('Playwright')
  end

  it 'should have different hars for concurrent contexts' do
    log1 = nil
    log0 = with_page_with_har do |page0|
      page0.goto('data:text/html,<title>Zero</title>')
      page0.wait_for_load_state(state: 'domcontentloaded')

      log1 = with_page_with_har do |page1|
        page1.goto('data:text/html,<title>One</title>')
        page1.wait_for_load_state(state: 'domcontentloaded')
      end
    end

    expect(log0['pages'].count).to eq(1)
    expect(log0['pages'].first['title']).to eq('Zero')
    expect(log1['pages'].count).to eq(1)
    expect(log1['pages'].first['title']).to eq('One')
    expect(log0['pages'].first['id']).not_to eq(log1['pages'].first['id'])
  end

  it 'should return server address directly from response', sinatra: true do
    with_page do |page|
      response = page.goto(server_empty_page)
      addr = response.server_addr
      expect(addr['ipAddress']).to match(/^127\.0\.0\.1|\[::1\]/)
      expect(addr['port']).to eq(server_port)
    end
  end
end
