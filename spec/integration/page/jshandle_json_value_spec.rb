require 'spec_helper'

RSpec.describe 'JSHandle#json_value' do
  it 'should work' do
    with_page do |page|
      handle = page.evaluate_handle('() => ({ foo: "bar" })')
      json = handle.json_value
      expect(json).to eq({ 'foo' => 'bar' })
    end
  end

  it 'should work with dates' do
    with_page do |page|
      handle = page.evaluate_handle('() => new Date("2017-09-26T00:00:00.000Z")')
      date = handle.json_value
      expect(date).to be_a(Date)
      expect(date).to eq(Date.parse('2017-09-26 00:00:00'))
    end
  end

  it 'should handle circular objects' do
    with_page do |page|
      handle = page.evaluate_handle("const a = {}; a.b = a; a")
      json = handle.json_value
      expect(json['b']).to eq(json)
    end
  end
end
