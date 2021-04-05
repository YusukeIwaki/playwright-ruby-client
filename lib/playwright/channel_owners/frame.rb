module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_frame.py
  define_channel_owner :Frame do
    private def after_initialize
      if @initializer['parentFrame']
        @parent_frame = ChannelOwners::Frame.from(@initializer['parentFrame'])
        @parent_frame.send(:append_child_frame_from_child, self)
      end
      @name = @initializer['name']
      @url = @initializer['url']
      @detached = false
      @child_frames = Set.new
      @load_states = Set.new(@initializer['loadStates'])
      @event_emitter = Object.new.extend(EventEmitter)

      @channel.on('loadstate', ->(params) {
        on_load_state(add: params['add'], remove: params['remove'])
      })
      @channel.on('navigated', method(:on_frame_navigated))
    end

    attr_reader :page, :parent_frame
    attr_writer :detached

    private def on_load_state(add:, remove:)
      if add
        @load_states << add
        @event_emitter.emit('loadstate', add)
      end
      if remove
        @load_states.delete(remove)
      end
    end

    private def on_frame_navigated(event)
      @url = event['url']
      @name = event['name']
      @event_emitter.emit('navigated', event)

      unless event['error']
        @page&.emit('framenavigated', self)
      end
    end

    def goto(url, timeout: nil, waitUntil: nil, referer: nil)
      params = {
        url: url,
        timeout: timeout,
        waitUntil: waitUntil,
        referer: referer
      }.compact
      resp = @channel.send_message_to_server('goto', params)
      ChannelOwners::Response.from_nullable(resp)
    end

    private def setup_navigation_wait_helper(timeout:)
      WaitHelper.new.tap do |helper|
        helper.reject_on_event(@page, Events::Page::Close, AlreadyClosedError.new)
        helper.reject_on_event(@page, Events::Page::Crash, CrashedError.new)
        helper.reject_on_event(@page, Events::Page::FrameDetached, FrameAlreadyDetachedError.new)
        helper.reject_on_timeout(timeout, "Timeout #{timeout}ms exceeded.")
      end
    end

    def expect_navigation(timeout: nil, url: nil, waitUntil: nil, &block)
      option_wait_until = waitUntil || 'load'
      option_timeout = timeout || @page.send(:timeout_settings).navigation_timeout
      time_start = Time.now

      wait_helper = setup_navigation_wait_helper(timeout: option_timeout)

      predicate =
        if url
          matcher = UrlMatcher.new(url)
          ->(event) { event['error'] || matcher.match?(event['url']) }
        else
          ->(_) { true }
        end

      wait_helper.wait_for_event(@event_emitter, 'navigated', predicate: predicate)

      block&.call

      event = wait_helper.promise.value!
      if event['error']
        raise event['error']
      end

      unless @load_states.include?(option_wait_until)
        elapsed_time = Time.now - time_start
        if elapsed_time < option_timeout
          wait_for_load_state(state: option_wait_until, timeout: option_timeout - elapsed_time)
        end
      end

      request_json = event.dig('newDocument', 'request')
      request = ChannelOwners::Request.from_nullable(request_json)
      request&.response
    end

    def wait_for_url(url, timeout: nil, waitUntil: nil)
      matcher = UrlMatcher.new(url)
      if matcher.match?(@url)
        wait_for_load_state(state: waitUntil, timeout: timeout)
      else
        expect_navigation(timeout: timeout, url: url, waitUntil: waitUntil)
      end
    end

    def wait_for_load_state(state: nil, timeout: nil)
      option_state = state || 'load'
      option_timeout = timeout || @page.send(:timeout_settings).navigation_timeout
      unless %w(load domcontentloaded networkidle).include?(option_state)
        raise ArgumentError.new('state: expected one of (load|domcontentloaded|networkidle)')
      end
      if @load_states.include?(option_state)
        return
      end

      wait_helper = setup_navigation_wait_helper(timeout: option_timeout)

      predicate = ->(state) { state == option_state }
      wait_helper.wait_for_event(@event_emitter, 'loadstate', predicate: predicate)
      wait_helper.promise.value!

      nil
    end

    def evaluate(pageFunction, arg: nil)
      if JavaScript.function?(pageFunction)
        JavaScript::Function.new(pageFunction, arg).evaluate(@channel)
      else
        JavaScript::Expression.new(pageFunction).evaluate(@channel)
      end
    end

    def evaluate_handle(pageFunction, arg: nil)
      if JavaScript.function?(pageFunction)
        JavaScript::Function.new(pageFunction, arg).evaluate_handle(@channel)
      else
        JavaScript::Expression.new(pageFunction).evaluate_handle(@channel)
      end
    end

    def query_selector(selector)
      resp = @channel.send_message_to_server('querySelector', selector: selector)
      ChannelOwners::ElementHandle.from_nullable(resp)
    end

    def query_selector_all(selector)
      @channel.send_message_to_server('querySelectorAll', selector: selector).map do |el|
        ChannelOwners::ElementHandle.from(el)
      end
    end

    def wait_for_selector(selector, state: nil, timeout: nil)
      params = { selector: selector, state: state, timeout: timeout }.compact
      resp = @channel.send_message_to_server('waitForSelector', params)

      ChannelOwners::ElementHandle.from_nullable(resp)
    end

    def checked?(selector, timeout: nil)
      params = { selector: selector, timeout: timeout }.compact
      @channel.send_message_to_server('isChecked', params)
    end

    def disabled?(selector, timeout: nil)
      params = { selector: selector, timeout: timeout }.compact
      @channel.send_message_to_server('isDisabled', params)
    end

    def editable?(selector, timeout: nil)
      params = { selector: selector, timeout: timeout }.compact
      @channel.send_message_to_server('isEditable', params)
    end

    def enabled?(selector, timeout: nil)
      params = { selector: selector, timeout: timeout }.compact
      @channel.send_message_to_server('isEnabled', params)
    end

    def hidden?(selector, timeout: nil)
      params = { selector: selector, timeout: timeout }.compact
      @channel.send_message_to_server('isHidden', params)
    end

    def visible?(selector, timeout: nil)
      params = { selector: selector, timeout: timeout }.compact
      @channel.send_message_to_server('isVisible', params)
    end

    def dispatch_event(selector, type, eventInit: nil, timeout: nil)
      params = {
        selector: selector,
        type: type,
        eventInit: JavaScript::ValueSerializer.new(eventInit).serialize,
        timeout: timeout,
      }.compact
      @channel.send_message_to_server('dispatchEvent', params)

      nil
    end

    def eval_on_selector(selector, pageFunction, arg: nil)
      if JavaScript.function?(pageFunction)
        JavaScript::Function.new(pageFunction, arg).eval_on_selector(@channel, selector)
      else
        JavaScript::Expression.new(pageFunction).eval_on_selector(@channel, selector)
      end
    end

    def eval_on_selector_all(selector, pageFunction, arg: nil)
      if JavaScript.function?(pageFunction)
        JavaScript::Function.new(pageFunction, arg).eval_on_selector_all(@channel, selector)
      else
        JavaScript::Expression.new(pageFunction).eval_on_selector_all(@channel, selector)
      end
    end

    def content
      @channel.send_message_to_server('content')
    end

    def set_content(html, timeout: nil, waitUntil: nil)
      params = {
        html: html,
        timeout: timeout,
        waitUntil: waitUntil,
      }.compact

      @channel.send_message_to_server('setContent', params)

      nil
    end

    def name
      @name || ''
    end

    def url
      @url || ''
    end

    def child_frames
      @child_frames.to_a
    end

    def detached?
      @detached
    end

    def add_script_tag(content: nil, path: nil, type: nil, url: nil)
      params = {
        content: content,
        type: type,
        url: url,
      }.compact
      if path
        params[:content] = "#{File.read(path)}\n//# sourceURL=#{path}"
      end
      resp = @channel.send_message_to_server('addScriptTag', params)
      ChannelOwners::ElementHandle.from(resp)
    end

    def add_style_tag(content: nil, path: nil, url: nil)
      params = {
        content: content,
        url: url,
      }.compact
      if path
        params[:content] = "#{File.read(path)}\n/*# sourceURL=#{path}*/"
      end
      resp = @channel.send_message_to_server('addStyleTag', params)
      ChannelOwners::ElementHandle.from(resp)
    end

    def click(
          selector,
          button: nil,
          clickCount: nil,
          delay: nil,
          force: nil,
          modifiers: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil)

      params = {
        selector: selector,
        button: button,
        clickCount: clickCount,
        delay: delay,
        force: force,
        modifiers: modifiers,
        noWaitAfter: noWaitAfter,
        position: position,
        timeout: timeout,
      }.compact
      @channel.send_message_to_server('click', params)

      nil
    end

    def dblclick(
          selector,
          button: nil,
          delay: nil,
          force: nil,
          modifiers: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil)

      params = {
        selector: selector,
        button: button,
        delay: delay,
        force: force,
        modifiers: modifiers,
        noWaitAfter: noWaitAfter,
        position: position,
        timeout: timeout,
      }.compact
      @channel.send_message_to_server('dblclick', params)

      nil
    end

    def tap_point(
          selector,
          force: nil,
          modifiers: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil)
      params = {
        selector: selector,
        force: force,
        modifiers: modifiers,
        noWaitAfter: noWaitAfter,
        position: position,
        timeout: timeout,
      }.compact
      @channel.send_message_to_server('tap', params)

      nil
    end

    def fill(selector, value, noWaitAfter: nil, timeout: nil)
      params = {
        selector: selector,
        value: value,
        noWaitAfter: noWaitAfter,
        timeout: timeout,
      }.compact
      @channel.send_message_to_server('fill', params)

      nil
    end

    def focus(selector, timeout: nil)
      params = { selector: selector, timeout: timeout }.compact
      @channel.send_message_to_server('focus', params)
      nil
    end

    def text_content(selector, timeout: nil)
      params = { selector: selector, timeout: timeout }.compact
      @channel.send_message_to_server('textContent', params)
    end

    def inner_text(selector, timeout: nil)
      params = { selector: selector, timeout: timeout }.compact
      @channel.send_message_to_server('innerText', params)
    end

    def inner_html(selector, timeout: nil)
      params = { selector: selector, timeout: timeout }.compact
      @channel.send_message_to_server('innerHTML', params)
    end

    def get_attribute(selector, name, timeout: nil)
      params = {
        selector: selector,
        name: name,
        timeout: timeout,
      }.compact
      @channel.send_message_to_server('getAttribute', params)
    end

    def hover(
          selector,
          force: nil,
          modifiers: nil,
          position: nil,
          timeout: nil)
      params = {
        selector: selector,
        force: force,
        modifiers: modifiers,
        position: position,
        timeout: timeout,
      }.compact
      @channel.send_message_to_server('hover', params)

      nil
    end

    def select_option(
          selector,
          element: nil,
          index: nil,
          value: nil,
          label: nil,
          noWaitAfter: nil,
          timeout: nil)
      base_params = SelectOptionValues.new(
        element: element,
        index: index,
        value: value,
        label: label,
      ).as_params
      params = base_params + { selector: selector, noWaitAfter: noWaitAfter, timeout: timeout }.compact
      @channel.send_message_to_server('selectOption', params)

      nil
    end

    def set_input_files(selector, files, noWaitAfter: nil, timeout: nil)
      file_payloads = InputFiles.new(files).as_params
      params = { files: file_payloads, selector: selector, noWaitAfter: noWaitAfter, timeout: timeout }.compact
      @channel.send_message_to_server('setInputFiles', params)

      nil
    end

    def type(
          selector,
          text,
          delay: nil,
          noWaitAfter: nil,
          timeout: nil)

      params = {
        selector: selector,
        text: text,
        delay: delay,
        noWaitAfter: noWaitAfter,
        timeout: timeout,
      }.compact
      @channel.send_message_to_server('type', params)

      nil
    end

    def press(
          selector,
          key,
          delay: nil,
          noWaitAfter: nil,
          timeout: nil)

      params = {
        selector: selector,
        key: key,
        delay: delay,
        noWaitAfter: noWaitAfter,
        timeout: timeout,
      }.compact
      @channel.send_message_to_server('press', params)

      nil
    end

    def check(selector, force: nil, noWaitAfter: nil, timeout: nil)
      params = {
        selector: selector,
        force: force,
        noWaitAfter:  noWaitAfter,
        timeout: timeout,
      }.compact
      @channel.send_message_to_server('check', params)

      nil
    end

    def uncheck(selector, force: nil, noWaitAfter: nil, timeout: nil)
      params = {
        selector: selector,
        force: force,
        noWaitAfter:  noWaitAfter,
        timeout: timeout,
      }.compact
      @channel.send_message_to_server('uncheck', params)

      nil
    end

    def wait_for_function(pageFunction, arg: nil, polling: nil, timeout: nil)
      if polling.is_a?(String) && polling != 'raf'
        raise ArgumentError.new("Unknown polling option: #{polling}")
      end

      function_or_expression =
        if JavaScript.function?(pageFunction)
          JavaScript::Function.new(pageFunction, arg)
        else
          JavaScript::Expression.new(pageFunction)
        end

      function_or_expression.wait_for_function(@channel, polling: polling, timeout: timeout)
    end

    def title
      @channel.send_message_to_server('title')
    end

    # @param page [Page]
    # @note This method should be used internally. Accessed via .send method, so keep private!
    private def update_page_from_page(page)
      @page = page
    end

    # @param child [Frame]
    # @note This method should be used internally. Accessed via .send method, so keep private!
    private def append_child_frame_from_child(frame)
      @child_frames << frame
    end
  end
end
