module Playwright
  define_api_implementation :FrameLocatorImpl do
    def initialize(frame:, timeout_settings:, frame_selector:)
      @frame = frame
      @timeout_settings = timeout_settings
      @frame_selector = frame_selector
    end

    def locator(selector, hasText: nil)
      LocatorImpl.new(
        frame: @frame,
        timeout_settings: @timeout_settings,
        selector: "#{@frame_selector} >> control=enter-frame >> #{selector}",
        hasText: hasText,
      )
    end

    def frame_locator(selector)
      FrameLocatorImpl.new(
        frame: @frame,
        timeout_settings: @timeout_settings,
        frame_selector: "#{@frame_selector} >> control=enter-frame >> #{selector}",
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
