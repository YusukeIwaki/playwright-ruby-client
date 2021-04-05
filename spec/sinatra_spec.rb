# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'sinatra: true' do
  it 'works', sinatra: true do
    sinatra.get('/') { '<h1>It Works!</h1>' }

    uri = URI("#{server_prefix}/")
    expect(Net::HTTP.get(uri)).to eq('<h1>It Works!</h1>')
  end

  it 'serves assets', sinatra: true do
    uri = URI("#{server_prefix}/one-style.html")
    expect(Net::HTTP.get(uri)).to include('<div>hello, world!</div>')
  end

  it 'can override static assets with dynamic route', sinatra: true do
    sinatra.get('/one-style.html') { 'ONE STYLE '}

    uri = URI("#{server_prefix}/one-style.html")
    expect(Net::HTTP.get(uri)).to include('ONE STYLE')
  end

  it 'can revert routes', sinatra: true do
    uri = URI("#{server_prefix}/one-style.html")
    expect(Net::HTTP.get(uri)).not_to include('ONE STYLE')
  end
end
