require 'spec_helper'

RSpec.describe 'Page#evaluate' do
  it 'should return undefined for non-serializable objects' do
    with_page do |page|
      expect(page.evaluate('() => function() {}')).to be_nil
    end
  end

  it 'should alias Window, Document and Node' do
    with_page do |page|
      expect(page.evaluate('() => window')).to eq('ref: <Window>')
      expect(page.evaluate('() => document')).to eq('ref: <Document>')
      expect(page.evaluate('() => document.body')).to eq('ref: <Node>')
    end
  end

  it 'should serialize circular object' do
    with_page do |page|
      a = {}
      a['b'] = a
      result = page.evaluate('(x) => x', arg: a)
      expect(result['b']).to eq(result)
    end
  end

  it 'should work for circular object' do
    with_page do |page|
      result = page.evaluate <<~JAVASCRIPT
      () => {
        const a = {};
        a.b = a;
        return a;
      };
      JAVASCRIPT
      expect(result['b']).to eq(result)
    end
  end
end
