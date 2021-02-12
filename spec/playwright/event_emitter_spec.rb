require 'spec_helper'

RSpec.describe Playwright::EventEmitter do
  let(:klass) {
    Class.new do
      include Playwright::EventEmitter
    end
  }
  let(:instance) { klass.new }

  it 'callback emitted event' do
    dbl = double(:hoge)
    instance.on :hoge, -> { dbl.hoge }
    instance.on :hoge, -> { dbl.hoge2 }
    instance.on :fuga, -> { dbl.fuga }
    expect(dbl).to receive(:hoge)
    expect(dbl).to receive(:hoge2)
    instance.emit(:hoge)
  end

  it 'emit returns true if listeners exist' do
    instance.on :hoge, -> { 1 }
    expect(instance.emit(:hoge)).to eq(true)
  end

  it 'emit returns false if no listeners exist' do
    dbl = double(:hoge)
    expect(instance.emit(:hoge)).to eq(false)
  end

  it 'callback event with no args' do
    callback = double(:callback)
    instance.on(:hoge, callback)
    expect(callback).to receive(:call).with(no_args)
    instance.emit(:hoge)
  end

  it 'callback event with args' do
    callback = double(:callback)
    instance.on(:hoge, callback)
    expect(callback).to receive(:call).with(1, 2, 3)
    instance.emit(:hoge, 1, 2, 3)
  end

  it 'can register only 1 listener for each callback' do
    dbl = double(:hoge)
    callback = -> { dbl.hoge }
    3.times { instance.on(:hoge, callback) }
    expect(dbl).to receive(:hoge).once
    instance.emit(:hoge)
  end

  it 'can unregister listener' do
    dbl = double(:hoge)
    callback = -> { dbl.hoge }
    3.times { instance.on(:hoge, callback) }
    instance.off(:hoge, callback)
    expect(dbl).not_to receive(:hoge)
    instance.emit(:hoge)
  end

  it 'doesnt raise error on unregistering not registered listener' do
    dbl = double(:hoge)
    expect { instance.off :hoge, -> { dbl.hoge } }.not_to raise_error
    instance.emit(:hoge)
  end

  it 'can register ONCE listener' do
    dbl = double(:hoge)
    callback = -> { dbl.called }
    instance.once(:hoge, callback)
    expect(dbl).to receive(:called).once
    3.times { instance.emit(:hoge) }
  end

  it 'can register ONCE listener for multiple events' do
    dbl = double(:hoge)
    callback = -> { dbl.called }
    instance.once(:hoge, callback)
    instance.once(:fuga, callback)
    expect(dbl).to receive(:called).twice
    3.times { instance.emit(:hoge) }
    5.times { instance.emit(:fuga) }
  end
end
