module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_frame.py
  define_channel_owner :Frame do
    def after_initialize
      @event_emitter = Object.new.extend(EventEmitter)
      if @initializer['parentFrame']
        @parent_frame = self.from(@initializer['parentFrame'])
        @parent_frame.send(:append_child_frame_from_child, self)
      end
      @name = @initializer['name']
      @url = @initializer['url']
      @detached = false
      @child_frames = Set.new
      @load_states = Set.new(@initializer['loadStates'])
    end

    attr_reader :page

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
