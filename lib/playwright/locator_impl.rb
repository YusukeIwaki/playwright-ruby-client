module Playwright
  define_api_implementation :LocatorImpl do
    def initialize(frame:, timeout_settings:, selector:)
      @frame = frame
      @timeout_settings = timeout_settings
      @selector = selector
    end

    private def with_element(timeout: nil, &block)
      start_time = Time.now

      handle = @frame.wait_for_selector(@selector, strict: true, timeout: timeout)
      unless handle
        raise "Could not resolve #{@selector} to DOM Element"
      end

      call_options = {}
      if timeout
        call_options[:timeout] = (timeout - (Time.now - start_time) * 1000).to_i
      end

      begin
        block.call(handle, call_options)
      ensure
        handle.dispose
      end
    end

    def bounding_box(timeout: nil)
      with_element(timeout: timeout) do |handle|
        handle.bounding_box
      end
    end

    def click(
          button: nil,
          clickCount: nil,
          delay: nil,
          force: nil,
          modifiers: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil,
          trial: nil)

      @frame.click(@selector,
        strict: true,
        button: button,
        clickCount: clickCount,
        delay: delay,
        force: force,
        modifiers: modifiers,
        noWaitAfter: noWaitAfter,
        position: position,
        timeout: timeout,
        trial: trial)
    end

    def element_handle(timeout: nil)
      @frame.wait_for_selector(@selector, strict: true, timeout: timeout)
    end

    def inner_html(timeout: nil)
      @frame.inner_html(@selector, strict: true, timeout: timeout)
    end

    def inner_text(timeout: nil)
      @frame.inner_text(@selector, strict: true, timeout: timeout)
    end

    def input_value(timeout: nil)
      @frame.input_value(@selector, strict: true, timeout: timeout)
    end

    def text_content(timeout: nil)
      @frame.text_content(@selector, strict: true, timeout: timeout)
    end
  end
end
