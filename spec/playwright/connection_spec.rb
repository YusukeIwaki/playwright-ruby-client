require 'spec_helper'

# Regression tests for https://github.com/YusukeIwaki/playwright-ruby-client/issues/392
#
# Once the driver is gone (Transport#on_driver_closed), in-flight calls must be
# rejected and subsequent calls must fail fast with TargetClosedError instead of
# hanging forever on promises that will never resolve.
RSpec.describe Playwright::Connection do
  class FakeTransport
    attr_reader :on_driver_crashed_block, :on_driver_closed_block

    def on_message_received(&block)
    end

    def on_driver_crashed(&block)
      @on_driver_crashed_block = block
    end

    def on_driver_closed(&block)
      @on_driver_closed_block = block
    end

    def send_message(message)
    end

    def async_run
    end

    def stop
    end
  end

  let(:transport) { FakeTransport.new }
  let(:connection) { Playwright::Connection.new(transport) }

  it 'rejects in-flight calls when the driver is closed' do
    future = connection.async_send_message_to_server('guid', 'method', {})
    transport.on_driver_closed_block.call
    expect { future.value! }.to raise_error(Playwright::TargetClosedError)
  end

  it 'fails fast with TargetClosedError for calls after the driver is closed' do
    connection # instantiate to register transport callbacks
    transport.on_driver_closed_block.call
    expect {
      connection.send_message_to_server('guid', 'method', {})
    }.to raise_error(Playwright::TargetClosedError)
  end
end
