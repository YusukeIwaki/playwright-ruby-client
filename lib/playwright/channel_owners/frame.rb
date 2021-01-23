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
