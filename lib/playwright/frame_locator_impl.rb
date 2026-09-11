require_relative './locator_utils'

module Playwright
  define_api_implementation :FrameLocatorImpl do
    include LocatorUtils

    def initialize(frame:, frame_selector:)
      @frame = frame
      @frame_selector = frame_selector
    end

    private def _timeout(timeout)
      @frame.send(:_timeout, timeout)
    end

    private def child_selector(selector)
      if @frame_selector == 'internal:control=any-frame'
        "#{@frame_selector} >> #{selector}"
      else
        "#{@frame_selector} >> internal:control=enter-frame >> #{selector}"
      end
    end

    private def nth_selector(index)
      if @frame_selector == 'internal:control=any-frame'
        raise 'Selecting the nth frame is not allowed on frameLocator().'
      end
      "#{@frame_selector} >> nth=#{index}"
    end

    def locator(
      selector,
      has: nil,
      hasNot: nil,
      hasNotText: nil,
      hasText: nil)
      LocatorImpl.new(
        frame: @frame,
        selector: child_selector(selector),
        has: has,
        hasNot: hasNot,
        hasNotText: hasNotText,
        hasText: hasText)
    end

    def owner
      LocatorImpl.new(
        frame: @frame,
        selector: @frame_selector,
      )
    end

    def frame_locator(selector)
      FrameLocatorImpl.new(
        frame: @frame,
        frame_selector: child_selector(selector),
      )
    end

    def first
      FrameLocatorImpl.new(
        frame: @frame,
        frame_selector: nth_selector(0),
      )
    end

    def last
      FrameLocatorImpl.new(
        frame: @frame,
        frame_selector: nth_selector(-1),
      )
    end

    def nth(index)
      FrameLocatorImpl.new(
        frame: @frame,
        frame_selector: nth_selector(index),
      )
    end
  end
end
