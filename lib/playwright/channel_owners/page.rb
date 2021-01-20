require 'base64'

module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_page.py
  define_channel_owner :Page do
    include Utils::Errors::SafeCloseError
    attr_writer :owned_context

    def after_initialize
      @browser_context = @parent
      @timeout_settings = TimeoutSettings.new(@browser_context.send(:_timeout_settings))
      @accessibility = Accessibility.new(@channel)
      @keyboard = Keyboard.new(@channel)
      @mouse = Mouse.new(@channel)
      @touchscreen = Touchscreen.new(@channel)

      @viewport_size = @initializer['viewportSize']
      @closed = false
      @main_frame = ChannelOwners::Frame.from(@initializer['mainFrame'])
      @main_frame.send(:update_page_from_page, self)
      @frames = Set.new
      @frames << @main_frame

      @channel.on('load', ->(_) { emit(Events::Page::Load) })
      @channel.once('close', method(:on_close))
    end

    attr_reader \
      :accessibility,
      :keyboard,
      :mouse,
      :touchscreen,
      :viewport_size,
      :main_frame

    private def on_close(_ = {})
      @closed = true
      @browser_context.send(:remove_page, self)
      emit(Events::Page::Close)
    end

    def context
      @browser_context
    end

    def evaluate(pageFunction, arg: nil)
      @main_frame.evaluate(pageFunction, arg: arg)
    end

    def evaluate_handle(pageFunction, arg: nil)
      @main_frame.evaluate_handle(pageFunction, arg: arg)
    end

    def goto(url, timeout: nil, waitUntil: nil, referer: nil)
      @main_frame.goto(url, timeout: timeout,  waitUntil: waitUntil, referer: referer)
    end

    def set_viewport_size(viewportSize)
      @viewport_size = viewportSize
      @channel.send_message_to_server('setViewportSize', { viewportSize: viewportSize })
      nil
    end

    def screenshot(
      path: nil,
      type: nil,
      quality: nil,
      fullPage: nil,
      clip: nil,
      omitBackground: nil,
      timeout: nil)

      params = {
        type: type,
        quality: quality,
        fullPage: fullPage,
        clip: clip,
        omitBackground: omitBackground,
        timeout: timeout,
      }.compact
      encoded_binary = @channel.send_message_to_server('screenshot', params)
      decoded_binary = Base64.decode64(encoded_binary)
      if path
        File.open(path, 'wb') do |f|
          f.write(decoded_binary)
        end
      end
      decoded_binary
    end

    def title
      @main_frame.title
    end

    def type_text(
      selector,
      text,
      delay: nil,
      noWaitAfter: nil,
      timeout: nil)

      @main_frame.type_text(selector, text, delay: delay, noWaitAfter: noWaitAfter, timeout: timeout)
    end

    def press(
      selector,
      key,
      delay: nil,
      noWaitAfter: nil,
      timeout: nil)

      @main_frame.press(selector, key, delay: delay, noWaitAfter: noWaitAfter, timeout: timeout)
    end

    def close(runBeforeUnload: nil)
      options = { runBeforeUnload: runBeforeUnload }.compact
      @channel.send_message_to_server('close', options)
      @owned_context&.close
      nil
    rescue => err
      raise unless safe_close_error?(err)
    end

    def closed?
      @closed
    end

    class CrashedError < StandardError
      def initialize
        super('Page crashed')
      end
    end

    class AlreadyClosedError < StandardError
      def initialize
        super('Page closed')
      end
    end

    def wait_for_event(event, optionsOrPredicate: nil, &block)
      predicate, timeout =
        case optionsOrPredicate
        when Proc
          [optionsOrPredicate, nil]
        when Hash
          [optionsOrPredicate[:predicate], optionsOrPredicate[:timeout]]
        else
          [nil, nil]
        end
      timeout ||= @timeout_settings.timeout

      wait_helper = WaitHelper.new
      wait_helper.reject_on_timeout(timeout, "Timeout while waiting for event \"#{event}\"")

      unless event == Events::Page::Crash
        wait_helper.reject_on_event(self, Events::Page::Crash, CrashedError.new)
      end

      unless event == Events::Page::Close
        wait_helper.reject_on_event(self, Events::Page::Close, AlreadyClosedError.new)
      end

      wait_helper.wait_for_event(self, event, predicate: predicate)

      block&.call

      wait_helper.promise.value!
    end

    def wait_for_request(urlOrPredicate, timeout: nil)
      predicate =
        case urlOrPredicate
        when String
          -> (req){ req.url == urlOrPredicate }
        when Regexp
          -> (req){ urlOrPredicate.match?(req.url) }
        when Proc
          urlOrPredicate
        else
          -> (_) { true }
        end

      wait_for_event(Events::Page::Request, optionsOrPredicate: { predicate: predicate, timeout: timeout})
    end

    def wait_for_response(urlOrPredicate, timeout: nil)
      predicate =
        case urlOrPredicate
        when String
          -> (res){ res.url == urlOrPredicate }
        when Regexp
          -> (res){ urlOrPredicate.match?(res.url) }
        when Proc
          urlOrPredicate
        else
          -> (_) { true }
        end

      wait_for_event(Events::Page::Response, optionsOrPredicate: { predicate: predicate, timeout: timeout})
    end

    # called from BrowserContext#on_page with send(:update_browser_context, page), so keep private.
    private def update_browser_context(context)
      @browser_context = context
      @timeout_settings = TimeoutSettings.new(context.send(:_timeout_settings))
    end
  end
end
