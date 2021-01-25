module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_frame.py
  define_channel_owner :Frame do
    def after_initialize
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

    def wait_for_navigation(timeout: nil, url: nil, waitUntil: nil, &block)
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

    def wait_for_load_state(state: nil, timeout: nil)
      option_state = state || 'load'
      unless %w(load domcontentloaded networkidle).include?(option_state)
        raise ArgumentError.new('state: expected one of (load|domcontentloaded|networkidle)')
      end
      if @load_states.include?(option_state)
        return
      end

      wait_helper = setup_navigation_wait_helper(timeout: timeout)

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

    def focus(selector, timeout: nil)
      params = { selector: selector, timeout: timeout }.compact
      @channel.send_message_to_server('focus', params)
      nil
    end

    def type_text(
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
