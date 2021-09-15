require 'spec_helper'

RSpec.describe Playwright::RawHeaders do
  let(:instance) { Playwright::RawHeaders.new(headers) }

  let(:headers) do
    [
      { 'name' => 'Set-Cookie', 'value' => 'a=b' },
      { 'name' => 'set-cookie', 'value' => 'c=d' },
      { 'name' => 'Foo', 'value' => 'bar' },
      { 'name' => 'Foo', 'value' => 'bar2' },
      { 'name' => 'bAz', 'value' => 'BaZ' },
    ]
  end

  it 'get, get_all, headers => case insentitive' do
    expect(instance.get('set-cookie')).to eq("a=b\nc=d")
    expect(instance.get_all('set-cookie')).to eq(%w[a=b c=d])
    expect(instance.headers['set-cookie']).to eq("a=b\nc=d")

    expect(instance.get('foo')).to eq("bar, bar2")
    expect(instance.get_all('foo')).to eq(%w[bar bar2])
    expect(instance.headers['foo']).to eq("bar, bar2")

    expect(instance.get('baz')).to eq("BaZ")
    expect(instance.get_all('baz')).to eq(%w[BaZ])
    expect(instance.headers['baz']).to eq("BaZ")
  end

  it 'get, headers => returns nil on unknown key specified' do
    expect(instance.get('unknown-header')).to be_nil
    expect(instance.headers['unknown-header']).to be_nil
  end

  it 'get_all => returns [] on unknown key specified' do
    expect(instance.get_all('unknown-header')).to eq([])
  end

  it 'headers_array => case sensitive' do
    arr = instance.headers_array
    expect(arr.select{ |h| h[:name] == 'Set-Cookie' }.count).to eq(1)
    expect(arr.select{ |h| h[:name] == 'set-cookie' }.count).to eq(1)
    expect(arr.select{ |h| h[:name] == 'set-cOOkie' }.count).to eq(0)
    expect(arr.select{ |h| h[:name] == 'Foo' }.count).to eq(2)
    expect(arr.select{ |h| h[:name] == 'foo' }.count).to eq(0)
    expect(arr.find{ |h| h[:name] == 'bAz' }[:value]).to eq('BaZ')
  end
end
