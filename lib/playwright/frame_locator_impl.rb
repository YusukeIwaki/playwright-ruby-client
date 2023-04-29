require_relative './locator_utils'

module Playwright
  define_api_implementation :FrameLocatorImpl do
    include LocatorUtils

    def initialize(frame:, timeout_settings:, frame_selector:)
      @frame = frame
      @timeout_settings = timeout_settings
      @frame_selector = frame_selector
    end

    def locator(
      selector,
      has: nil,
      hasNot: nil,
      hasNotText: nil,
      hasText: nil)
      LocatorImpl.new(
        frame: @frame,
        timeout_settings: @timeout_settings,
        selector: "#{@frame_selector} >> internal:control=enter-frame >> #{selector}",
        has: has,
        hasNot: hasNot,
        hasNotText: hasNotText,
        hasText: hasText)
    end

    def frame_locator(selector)
      FrameLocatorImpl.new(
        frame: @frame,
        timeout_settings: @timeout_settings,
        frame_selector: "#{@frame_selector} >> internal:control=enter-frame >> #{selector}",
      )
    end

    def first
      FrameLocatorImpl.new(
        frame: @frame,
        timeout_settings: @timeout_settings,
        frame_selector: "#{@frame_selector} >> nth=0",
      )
    end

    def last
      FrameLocatorImpl.new(
        frame: @frame,
        timeout_settings: @timeout_settings,
        frame_selector: "#{@frame_selector} >> nth=-1",
      )
    end

    def nth(index)
      FrameLocatorImpl.new(
        frame: @frame,
        timeout_settings: @timeout_settings,
        frame_selector: "#{@frame_selector} >> nth=#{index}",
      )
    end
  end
end
