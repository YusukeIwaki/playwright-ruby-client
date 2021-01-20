require 'spec_helper'

RSpec.describe 'sinatra: true' do
  it 'serves assets', sinatra: true do
    uri = URI("#{server_prefix}/one-style.html")
    expect(Net::HTTP.get(uri)).to include('<div>hello, world!</div>')
  end
end
