module Playwright
  define_api_implementation :LocatorImpl do
    def initialize(frame:, timeout_settings:, selector:)
      @frame = frame
      @timeout_settings = timeout_settings
      @selector = selector
    end

    def to_s
      "Locator@#{@selector}"
    end

    private def with_element(timeout: nil, &block)
      start_time = Time.now

      handle = @frame.wait_for_selector(@selector, strict: true, state: 'attached', timeout: timeout)
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

    def check(
          force: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil,
          trial: nil)

      @frame.check(@selector,
        strict: true,
        force: force,
        noWaitAfter: noWaitAfter,
        position: position,
        timeout: timeout,
        trial: trial)
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

    def dblclick(
          button: nil,
          delay: nil,
          force: nil,
          modifiers: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil,
          trial: nil)

      @frame.dblclick(@selector,
        strict: true,
        button: button,
        delay: delay,
        force: force,
        modifiers: modifiers,
        noWaitAfter: noWaitAfter,
        position: position,
        timeout: timeout,
        trial: trial)
    end

    def dispatch_event(type, eventInit: nil, timeout: nil)
      @frame.dispatch_event(@selector, type, strict: true, eventInit: eventInit, timeout: timeout)
    end

    def evaluate(expression, arg: nil, timeout: nil)
      with_element(timeout: timeout) do |handle|
        handle.evaluate(expression, arg: arg)
      end
    end

    def evaluate_all(expression, arg: nil)
      @frame.eval_on_selector_all(@selector, expression, arg: arg)
    end

    def evaluate_handle(expression, arg: nil, timeout: nil)
      with_element(timeout: timeout) do |handle|
        handle.evaluate_handle(expression, arg: arg)
      end
    end

    def fill(value, force: nil, noWaitAfter: nil, timeout: nil)
      @frame.fill(@selector, value, strict: true, force: force, noWaitAfter: noWaitAfter, timeout: timeout)
    end

    def locator(selector)
      LocatorImpl.new(
        frame: @frame,
        timeout_settings: @timeout_settings,
        selector: "#{@selector} >> #{selector}",
      )
    end

    def element_handle(timeout: nil)
      @frame.wait_for_selector(@selector, strict: true, state: 'attached', timeout: timeout)
    end

    def element_handles
      @frame.query_selector_all(@selector)
    end

    def first
      LocatorImpl.new(
        frame: @frame,
        timeout_settings: @timeout_settings,
        selector: "#{@selector} >> _nth=first",
      )
    end

    def last
      LocatorImpl.new(
        frame: @frame,
        timeout_settings: @timeout_settings,
        selector: "#{@selector} >> _nth=last",
      )
    end

    def nth(index)
      LocatorImpl.new(
        frame: @frame,
        timeout_settings: @timeout_settings,
        selector: "#{@selector} >> _nth=#{index}",
      )
    end

    def focus(timeout: nil)
      @frame.focus(@selector, strict: true, timeout: timeout)
    end

    def count
      @frame.eval_on_selector_all(@selector, 'ee => ee.length')
    end

    def get_attribute(name, timeout: nil)
      @frame.get_attribute(@selector, name, strict: true, timeout: timeout)
    end

    def hover(
          force: nil,
          modifiers: nil,
          position: nil,
          timeout: nil,
          trial: nil)
      @frame.hover(@selector,
        strict: true,
        force: force,
        modifiers: modifiers,
        position: position,
        timeout: timeout,
        trial: trial)
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

    %i[checked? disabled? editable? enabled? hidden? visible?].each do |method_name|
      define_method(method_name) do |timeout: nil|
        @frame.public_send(method_name, @selector, strict: true, timeout: timeout)
      end
    end

    def press(key, delay: nil, noWaitAfter: nil, timeout: nil)
      @frame.press(@selector, key, strict: true, noWaitAfter: noWaitAfter, timeout: timeout)
    end

    def screenshot(
          omitBackground: nil,
          path: nil,
          quality: nil,
          timeout: nil,
          type: nil)
      with_element(timeout: timeout) do |handle, options|
        handle.screenshot(
          omitBackground: omitBackground,
          path: path,
          quality: quality,
          timeout: options[:timeout],
          type: type)
      end
    end

    def scroll_into_view_if_needed(timeout: nil)
      with_element(timeout: timeout) do |handle, options|
        handle.scroll_into_view_if_needed(timeout: options[:timeout])
      end
    end

    # def select_option(force: nil, noWaitAfter: nil, timeout: nil)
    #   @frame.select_option(@selector, values, strict: true, force: force, noWaitAfter: noWaitAfter, timeout: timeout)
    # end

    def select_text(force: nil, timeout: nil)
      with_element(timeout: timeout) do |handle, options|
        handle.select_text(force: force, timeout: options[:timeout])
      end
    end

    def set_input_files(files, noWaitAfter: nil, timeout: nil)
      @frame.set_input_files(@selector, files, strict: true, noWaitAfter: noWaitAfter, timeout: timeout)
    end

    def tap_point(
          force: nil,
          modifiers: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil,
          trial: nil)
      @frame.tap_point(@selector,
        strict: true,
        force: force,
        modifiers: modifiers,
        noWaitAfter: noWaitAfter,
        position: position,
        timeout: timeout,
        trial: trial)
    end

    def text_content(timeout: nil)
      @frame.text_content(@selector, strict: true, timeout: timeout)
    end

    def type(text, delay: nil, noWaitAfter: nil, timeout: nil)
      @frame.type(@selector, text, strict: true, delay: delay, noWaitAfter: noWaitAfter, timeout: timeout)
    end

    def uncheck(
          force: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil,
          trial: nil)
      @frame.uncheck(@selector,
        strict: true,
        force: force,
        noWaitAfter: noWaitAfter,
        position: position,
        timeout: timeout,
        trial: trial)
    end

    def all_inner_texts
      @frame.eval_on_selector_all(@selector, 'ee => ee.map(e => e.innerText)')
    end

    def all_text_contents
      @frame.eval_on_selector_all(@selector, "ee => ee.map(e => e.textContent || '')")
    end
  end
end
