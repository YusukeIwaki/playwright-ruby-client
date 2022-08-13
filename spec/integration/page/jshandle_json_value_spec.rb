require 'spec_helper'

RSpec.describe 'JSHandle#json_value' do
  it 'should work' do
    with_page do |page|
      handle = page.evaluate_handle('() => ({ foo: "bar" })')
      json = handle.json_value
      expect(json).to eq({ 'foo' => 'bar' })
    end
  end
end
