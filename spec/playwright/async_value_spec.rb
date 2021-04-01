require 'spec_helper'
require 'async'

RSpec.describe Playwright::AsyncValue do
  around do |example|
    Async { example.run }
  end
  let(:promise) { Playwright::AsyncValue.new }

  it 'is not resolved on initialize' do
    expect(promise).not_to be_resolved
    expect(promise).not_to be_fulfilled
    expect(promise).not_to be_rejected
  end

  it 'blocks until fulfilled' do
    time_start = Time.now

    Async { |t| t.sleep 2 ; promise.fulfill }
    promise.value!

    expect(Time.now - time_start).to be > 1
  end

  it 'blocks until rejected' do
    time_start = Time.now

    Async { |t| t.sleep 2 ; promise.reject("invalid") }
    expect { promise.value! }.to raise_error(/invalid/)

    expect(Time.now - time_start).to be > 1
  end

  it 'returns soon if already resolved' do
    promise.fulfill

    Timeout.timeout(1) { promise.value! }
  end

  it "doesn't raise on reject" do
    expect { promise.reject("error!") }.not_to raise_error
  end

  it 'raises Rejection error for the result of reject' do
    promise.reject("Error!")
    expect { promise.value! }.to raise_error(Playwright::AsyncValue::Rejection)
  end

  it 'raises Rejection error for the result of reject' do
    promise.reject(ArgumentError.new("invalid"))
    expect { promise.value! }.to raise_error(ArgumentError)
  end

  it 'returns nil on fulfill without arg' do
    promise.fulfill
    Timeout.timeout(1) { expect(promise.value!).to be_nil }
  end

  it 'returns value on fulfill with arg' do
    promise.fulfill(123)
    Timeout.timeout(1) { expect(promise.value!).to eq(123) }
  end
end
