require 'spec_helper'

RSpec.describe 'timeout' do
  it 'should have timeout error name' do
    with_page do |page|
      begin
        page.wait_for_selector('#not-fount', timeout: 1)
        raise "fail"
      rescue => err
        expect(error.name).to eq('TimeoutError')
      end
    end
  end
end
