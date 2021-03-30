require 'spec_helper'
require 'async'

RSpec.describe Playwright::AsyncEvaluation do
  around do |example|
    Async { example.run }
  end

  it 'is not resolved on initialize' do
    future = Playwright::AsyncEvaluation.new { |t| t.sleep 2 }
    expect(future).not_to be_resolved
    expect(future).not_to be_fulfilled
    expect(future).not_to be_rejected
  end

  it 'is resolved on success' do
    future = Playwright::AsyncEvaluation.new { 123 }
    expect(future).to be_resolved
    expect(future).to be_fulfilled
    expect(future).not_to be_rejected
    expect(future.value!).to eq(123)
  end

  it 'is rejected on error' do
    future = Playwright::AsyncEvaluation.new { raise 'invalid' }
    expect(future).to be_resolved
    expect(future).not_to be_fulfilled
    expect(future).to be_rejected
    expect { future.value! }.to raise_error(/invalid/)
  end
end
