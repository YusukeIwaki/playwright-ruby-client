require 'spec_helper'

RSpec.describe SinatraRouting do
  sinatra do
    get('/') { '<h1>It Works!</h1>' }
  end

  it 'works' do
    uri = URI("#{server_prefix}/")
    expect(Net::HTTP.get(uri)).to eq('<h1>It Works!</h1>')
  end

  it 'serves assets' do
    uri = URI("#{server_prefix}/one-style.html")
    expect(Net::HTTP.get(uri)).to include('<div>hello, world!</div>')
  end
end
