require 'base64'

module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_page.py
  define_channel_owner :Page do
    include Utils::Errors::SafeCloseError
    attr_writer :owned_context

    private def after_initialize
      @browser_context = @parent
      @timeout_settings = TimeoutSettings.new(@browser_context.send(:_timeout_settings))
      @accessibility = Accessibility.new(@channel)
      @keyboard = KeyboardImpl.new(@channel)
      @mouse = MouseImpl.new(@channel)
      @touchscreen = TouchscreenImpl.new(@channel)

      if @initializer['viewportSize']
        @viewport_size = {
          width: @initializer['viewportSize']['width'],
          height: @initializer['viewportSize']['height'],
        }
      end
      @closed = false
      @bindings = {}
      @routes = Set.new

      @main_frame = ChannelOwners::Frame.from(@initializer['mainFrame'])
      @main_frame.send(:update_page_from_page, self)
      @frames = Set.new
      @frames << @main_frame
      @opener = ChannelOwners::Page.from_nullable(@initializer['opener'])

      @channel.once('close', ->(_) { on_close })
      @channel.on('console', ->(params) {
        console_message = ChannelOwners::ConsoleMessage.from(params['message'])
        emit(Events::Page::Console, console_message)
      })
      @channel.on('crash', ->(_) { emit(Events::Page::Crash) })
      @channel.on('dialog', method(:on_dialog))
      @channel.on('domcontentloaded', ->(_) { emit(Events::Page::DOMContentLoaded) })
      @channel.on('download', method(:on_download))
      @channel.on('fileChooser', ->(params) {
        chooser = FileChooserImpl.new(
                    page: self,
                    element_handle: ChannelOwners::ElementHandle.from(params['element']),
                    is_multiple: params['isMultiple'])
        emit(Events::Page::FileChooser, chooser)
      })
      @channel.on('frameAttached', ->(params) {
        on_frame_attached(ChannelOwners::Frame.from(params['frame']))
      })
      @channel.on('frameDetached', ->(params) {
        on_frame_detached(ChannelOwners::Frame.from(params['frame']))
      })
      @channel.on('load', ->(_) { emit(Events::Page::Load) })
      @channel.on('pageError', ->(params) {
        emit(Events::Page::PageError, Error.parse(params['error']['error']))
      })
      @channel.on('request', ->(params) {
        emit(Events::Page::Request, ChannelOwners::Request.from(params['request']))
      })
      @channel.on('requestFailed', ->(params) {
        on_request_failed(
          ChannelOwners::Request.from(params['request']),
          params['responseEndTiming'],
          params['failureText'],
        )
      })
      @channel.on('requestFinished', ->(params) {
        on_request_finished(
          ChannelOwners::Request.from(params['request']),
          params['responseEndTiming'],
        )
      })
      @channel.on('response', ->(params) {
        emit(Events::Page::Response, ChannelOwners::Response.from(params['response']))
      })
      @channel.on('route', ->(params) {
        on_route(ChannelOwners::Route.from(params['route']), ChannelOwners::Request.from(params['request']))
      })
      @channel.on('video', method(:on_video))
      @channel.on('webSocket', ->(params) {
        emit(Events::Page::WebSocket, ChannelOwners::WebSocket.from(params['webSocket']))
      })
      @channel.on('worker', ->(params) {
        on_worker(ChannelOwners::Worker.from(params['worker']))
      })
    end

    attr_reader \
      :accessibility,
      :keyboard,
      :mouse,
      :touchscreen,
      :viewport_size,
      :main_frame

    private def on_request_failed(request, response_end_timing, failure_text)
      request.send(:update_failure_text, failure_text)
      request.send(:update_response_end_timing, response_end_timing)
      emit(Events::Page::RequestFailed, request)
    end

    private def on_request_finished(request, response_end_timing)
      request.send(:update_response_end_timing, response_end_timing)
      emit(Events::Page::RequestFinished, request)
    end

    private def on_frame_attached(frame)
      frame.send(:update_page_from_page, self)
      @frames << frame
      emit(Events::Page::FrameAttached, frame)
    end

    private def on_frame_detached(frame)
      @frames.delete(frame)
      frame.detached = true
      emit(Events::Page::FrameDetached, frame)
    end

    private def on_route(route, request)
      # It is not desired to use PlaywrightApi.wrap directly.
      # However it is a little difficult to define wrapper for `handler` parameter in generate_api.
      # Just a workaround...
      wrapped_route = PlaywrightApi.wrap(route)
      wrapped_request = PlaywrightApi.wrap(request)

      if @routes.none? { |handler_entry| handler_entry.handle(wrapped_route, wrapped_request) }
        @browser_context.send(:on_route, route, request)
      end
    end

    private def on_close
      @closed = true
      @browser_context.send(:remove_page, self)
      emit(Events::Page::Close)
    end

    private def on_dialog(params)
      dialog = ChannelOwners::Dialog.from(params['dialog'])
      unless emit(Events::Page::Dialog, dialog)
        dialog.dismiss
      end
    end

    private def on_download(params)
      download = Download.new(
        url: params['url'],
        suggested_filename: params['suggestedFilename'],
        artifact: ChannelOwners::Artifact.from(params['artifact']),
      )
      emit(Events::Page::Download, download)
    end

    private def on_video(params)
      artifact = ChannelOwners::Artifact.from(params['artifact'])
      video.send(:set_artifact, artifact)
    end

    # @override
    def on(event, callback)
      if event == Events::Page::FileChooser && listener_count(event) == 0
        @channel.async_send_message_to_server('setFileChooserInterceptedNoReply', intercepted: true)
      end
      super
    end

    # @override
    def once(event, callback)
      if event == Events::Page::FileChooser && listener_count(event) == 0
        @channel.async_send_message_to_server('setFileChooserInterceptedNoReply', intercepted: true)
      end
      super
    end

    # @override
    def off(event, callback)
      super
      if event == Events::Page::FileChooser && listener_count(event) == 0
        @channel.async_send_message_to_server('setFileChooserInterceptedNoReply', intercepted: false)
      end
    end

    def context
      @browser_context
    end

    def opener
      if @opener&.closed?
        nil
      else
        @opener
      end
    end

    private def emit_popup_event_from_browser_context
      if @opener && !@opener.closed?
        @opener.emit(Events::Page::Popup, self)
      end
    end

    def frame(name: nil, url: nil)
      if name
        @frames.find { |f| f.name == name }
      elsif url
        # ref: https://github.com/microsoft/playwright-python/blob/c4320c27cb080b385a5e45be46baa3cb7a9409ff/playwright/_impl/_helper.py#L104
        case url
        when String
          @frames.find { |f| f.url == url }
        when Regexp
          @frames.find { |f| url.match?(f.url) }
        else
          raise NotImplementedError.new('Page#frame with url is not completely implemented yet')
        end
      else
        raise ArgumentError.new('Either name or url matcher should be specified')
      end
    end

    def frames
      @frames.to_a
    end

    def set_default_navigation_timeout(timeout)
      @timeout_settings.default_navigation_timeout = timeout
      @channel.send_message_to_server('setDefaultNavigationTimeoutNoReply', timeout: timeout)
    end

    def set_default_timeout(timeout)
      @timeout_settings.default_timeout = timeout
      @channel.send_message_to_server('setDefaultTimeoutNoReply', timeout: timeout)
    end

    def query_selector(selector)
      @main_frame.query_selector(selector)
    end

    def query_selector_all(selector)
      @main_frame.query_selector_all(selector)
    end

    def wait_for_selector(selector, state: nil, timeout: nil)
      @main_frame.wait_for_selector(selector, state: state, timeout: timeout)
    end

    def checked?(selector, timeout: nil)
      @main_frame.checked?(selector, timeout: timeout)
    end

    def disabled?(selector, timeout: nil)
      @main_frame.disabled?(selector, timeout: timeout)
    end

    def editable?(selector, timeout: nil)
      @main_frame.editable?(selector, timeout: timeout)
    end

    def enabled?(selector, timeout: nil)
      @main_frame.enabled?(selector, timeout: timeout)
    end

    def hidden?(selector, timeout: nil)
      @main_frame.hidden?(selector, timeout: timeout)
    end

    def visible?(selector, timeout: nil)
      @main_frame.visible?(selector, timeout: timeout)
    end

    def dispatch_event(selector, type, eventInit: nil, timeout: nil)
      @main_frame.dispatch_event(selector, type, eventInit: eventInit, timeout: timeout)
    end

    def evaluate(pageFunction, arg: nil)
      @main_frame.evaluate(pageFunction, arg: arg)
    end

    def evaluate_handle(pageFunction, arg: nil)
      @main_frame.evaluate_handle(pageFunction, arg: arg)
    end

    def eval_on_selector(selector, pageFunction, arg: nil)
      @main_frame.eval_on_selector(selector, pageFunction, arg: arg)
    end

    def eval_on_selector_all(selector, pageFunction, arg: nil)
      @main_frame.eval_on_selector_all(selector, pageFunction, arg: arg)
    end

    def add_script_tag(content: nil, path: nil, type: nil, url: nil)
      @main_frame.add_script_tag(content: content, path: path, type: type, url: url)
    end

    def add_style_tag(content: nil, path: nil, url: nil)
      @main_frame.add_style_tag(content: content, path: path, url: url)
    end

    def expose_function(name, callback)
      @channel.send_message_to_server('exposeBinding', name: name)
      @bindings[name] = ->(_source, *args) { callback.call(*args) }
    end

    def expose_binding(name, callback, handle: nil)
      params = {
        name: name,
        needsHandle: handle,
      }.compact
      @channel.send_message_to_server('exposeBinding', params)
      @bindings[name] = callback
    end

    def set_extra_http_headers(headers)
      serialized_headers = HttpHeaders.new(headers).as_serialized
      @channel.send_message_to_server('setExtraHTTPHeaders', headers: serialized_headers)
    end

    def url
      @main_frame.url
    end

    def content
      @main_frame.content
    end

    def set_content(html, timeout: nil, waitUntil: nil)
      @main_frame.set_content(html, timeout: timeout, waitUntil: waitUntil)
    end

    def goto(url, timeout: nil, waitUntil: nil, referer: nil)
      @main_frame.goto(url, timeout: timeout,  waitUntil: waitUntil, referer: referer)
    end

    def reload(timeout: nil, waitUntil: nil)
      params = {
        timeout: timeout,
        waitUntil: waitUntil,
      }.compact
      resp = @channel.send_message_to_server('reoad', params)
      ChannelOwners::Response.from_nullable(resp)
    end

    def wait_for_load_state(state: nil, timeout: nil)
      @main_frame.wait_for_load_state(state: state, timeout: timeout)
    end

    def wait_for_url(url, timeout: nil, waitUntil: nil)
      @main_frame.wait_for_url(url, timeout: timeout,  waitUntil: waitUntil)
    end

    def go_back(timeout: nil, waitUntil: nil)
      params = { timeout: timeout, waitUntil: waitUntil }.compact
      resp = @channel.send_message_to_server('goBack', params)
      ChannelOwners::Response.from_nullable(resp)
    end

    def go_forward(timeout: nil, waitUntil: nil)
      params = { timeout: timeout, waitUntil: waitUntil }.compact
      resp = @channel.send_message_to_server('goForward', params)
      ChannelOwners::Response.from_nullable(resp)
    end

    def emulate_media(colorScheme: nil, media: nil)
      params = {
        colorScheme: colorScheme,
        media: media,
      }.compact
      @channel.send_message_to_server('emulateMedia', params)

      nil
    end

    def set_viewport_size(viewportSize)
      @viewport_size = viewportSize
      @channel.send_message_to_server('setViewportSize', { viewportSize: viewportSize })
      nil
    end

    def bring_to_front
      @channel.send_message_to_server('bringToFront')
      nil
    end

    def add_init_script(path: nil, script: nil)
      source =
        if path
          File.read(path)
        elsif script
          script
        else
          raise ArgumentError.new('Either path or script parameter must be specified')
        end

      @channel.send_message_to_server('addInitScript', source: script)
      nil
    end

    def route(url, handler)
      entry = RouteHandlerEntry.new(url, handler)
      @routes << entry
      if @routes.count >= 1
        @channel.send_message_to_server('setNetworkInterceptionEnabled', enabled: true)
      end
    end

    def unroute(url, handler: nil)
      @routes.reject! do |handler_entry|
        handler_entry.same_value?(url: url, handler: handler)
      end
      if @routes.count == 0
        @channel.send_message_to_server('setNetworkInterceptionEnabled', enabled: false)
      end
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
      decoded_binary = Base64.strict_decode64(encoded_binary)
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

      @main_frame.click(
        selector,
        button: button,
        clickCount: clickCount,
        delay: delay,
        force: force,
        modifiers: modifiers,
        noWaitAfter: noWaitAfter,
        position: position,
        timeout: timeout,
      )
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
      @main_frame.dblclick(
        selector,
        button: button,
        delay: delay,
        force: force,
        modifiers: modifiers,
        noWaitAfter: noWaitAfter,
        position: position,
        timeout: timeout,
      )
    end

    def tap_point(
          selector,
          force: nil,
          modifiers: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil)
      @main_frame.tap_point(
        selector,
        force: force,
        modifiers: modifiers,
        noWaitAfter: noWaitAfter,
        position: position,
        timeout: timeout,
      )
    end

    def fill(selector, value, noWaitAfter: nil, timeout: nil)
      @main_frame.fill(selector, value, noWaitAfter: noWaitAfter, timeout: timeout)
    end

    def focus(selector, timeout: nil)
      @main_frame.focus(selector, timeout: timeout)
    end

    def text_content(selector, timeout: nil)
      @main_frame.text_content(selector, timeout: timeout)
    end

    def inner_text(selector, timeout: nil)
      @main_frame.inner_text(selector, timeout: timeout)
    end

    def inner_html(selector, timeout: nil)
      @main_frame.inner_html(selector, timeout: timeout)
    end

    def get_attribute(selector, name, timeout: nil)
      @main_frame.get_attribute(selector, name, timeout: timeout)
    end

    def hover(
          selector,
          force: nil,
          modifiers: nil,
          position: nil,
          timeout: nil)
      @main_frame.hover(
        selector,
        force: force,
        modifiers: modifiers,
        position: position,
        timeout: timeout,
      )
    end

    def select_option(
          selector,
          element: nil,
          index: nil,
          value: nil,
          label: nil,
          noWaitAfter: nil,
          timeout: nil)
      @main_frame.select_option(
        selector,
        element: element,
        index: index,
        value: value,
        label: label,
        noWaitAfter: noWaitAfter,
        timeout: timeout,
      )
    end

    def set_input_files(selector, files, noWaitAfter: nil, timeout: nil)
      @main_frame.set_input_files(selector, files, noWaitAfter: noWaitAfter, timeout: timeout)
    end

    def type(
      selector,
      text,
      delay: nil,
      noWaitAfter: nil,
      timeout: nil)

      @main_frame.type(selector, text, delay: delay, noWaitAfter: noWaitAfter, timeout: timeout)
    end

    def press(
      selector,
      key,
      delay: nil,
      noWaitAfter: nil,
      timeout: nil)

      @main_frame.press(selector, key, delay: delay, noWaitAfter: noWaitAfter, timeout: timeout)
    end

    def check(selector, force: nil, noWaitAfter: nil, timeout: nil)
      @main_frame.check(selector, force: force, noWaitAfter: noWaitAfter, timeout: timeout)
    end

    def uncheck(selector, force: nil, noWaitAfter: nil, timeout: nil)
      @main_frame.uncheck(selector, force: force, noWaitAfter: noWaitAfter, timeout: timeout)
    end

    def wait_for_function(pageFunction, arg: nil, polling: nil, timeout: nil)
      @main_frame.wait_for_function(pageFunction, arg: arg, polling: polling, timeout: timeout)
    end

    def pdf(
          displayHeaderFooter: nil,
          footerTemplate: nil,
          format: nil,
          headerTemplate: nil,
          height: nil,
          landscape: nil,
          margin: nil,
          pageRanges: nil,
          path: nil,
          preferCSSPageSize: nil,
          printBackground: nil,
          scale: nil,
          width: nil)

      params = {
        displayHeaderFooter: displayHeaderFooter,
        footerTemplate: footerTemplate,
        format: format,
        headerTemplate: headerTemplate,
        height: height,
        landscape: landscape,
        margin: margin,
        pageRanges: pageRanges,
        preferCSSPageSize: preferCSSPageSize,
        printBackground: printBackground,
        scale: scale,
        width: width,
      }.compact
      encoded_binary = @channel.send_message_to_server('pdf', params)
      decoded_binary = Base64.strict_decode64(encoded_binary)
      if path
        File.open(path, 'wb') do |f|
          f.write(decoded_binary)
        end
      end
      decoded_binary
    end

    def video
      return nil unless @browser_context.send(:has_record_video_option?)
      @video ||= Video.new(self)
    end

    def start_js_coverage(resetOnNavigation: nil, reportAnonymousScripts: nil)
      params = {
        resetOnNavigation: resetOnNavigation,
        reportAnonymousScripts: reportAnonymousScripts,
      }.compact

      @channel.send_message_to_server('startJSCoverage', params)
    end

    def stop_js_coverage
      @channel.send_message_to_server('stopJSCoverage')
    end

    def start_css_coverage(resetOnNavigation: nil, reportAnonymousScripts: nil)
      params = {
        resetOnNavigation: resetOnNavigation,
      }.compact

      @channel.send_message_to_server('startCSSCoverage', params)
    end

    def stop_css_coverage
      @channel.send_message_to_server('stopCSSCoverage')
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

    class FrameAlreadyDetachedError < StandardError
      def initialize
        super('Navigating frame was detached!')
      end
    end

    def expect_event(event, predicate: nil, timeout: nil, &block)
      wait_helper = WaitHelper.new
      wait_helper.reject_on_timeout(timeout || @timeout_settings.timeout, "Timeout while waiting for event \"#{event}\"")

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

    def expect_console_message(predicate: nil, timeout: nil, &block)
      expect_event(Events::Page::Console, predicate: predicate, timeout: timeout, &block)
    end

    def expect_download(predicate: nil, timeout: nil, &block)
      expect_event(Events::Page::Download, predicate: predicate, timeout: timeout, &block)
    end

    def expect_file_chooser(predicate: nil, timeout: nil, &block)
      expect_event(Events::Page::FileChooser, predicate: predicate, timeout: timeout, &block)
    end

    def expect_navigation(timeout: nil, url: nil, waitUntil: nil, &block)
      @main_frame.expect_navigation(
        timeout: timeout,
        url: url,
        waitUntil: waitUntil,
        &block)
    end

    def expect_popup(predicate: nil, timeout: nil, &block)
      expect_event(Events::Page::Popup, predicate: predicate, timeout: timeout, &block)
    end

    def expect_request(urlOrPredicate, timeout: nil)
      predicate =
        case urlOrPredicate
        when String, Regexp
          url_matcher = UrlMatcher.new(urlOrPredicate)
          -> (req){ url_matcher.match?(req.url) }
        when Proc
          urlOrPredicate
        else
          -> (_) { true }
        end

      expect_event(Events::Page::Request, predicate: predicate, timeout: timeout)
    end

    def expect_response(urlOrPredicate, timeout: nil)
      predicate =
        case urlOrPredicate
        when String, Regexp
          url_matcher = UrlMatcher.new(urlOrPredicate)
          -> (req){ url_matcher.match?(req.url) }
        when Proc
          urlOrPredicate
        else
          -> (_) { true }
        end

      expect_event(Events::Page::Response, predicate: predicate, timeout: timeout)
    end

    # called from BrowserContext#on_page with send(:update_browser_context, page), so keep private.
    private def update_browser_context(context)
      @browser_context = context
      @timeout_settings = TimeoutSettings.new(context.send(:_timeout_settings))
    end

    # called from Frame with send(:timeout_settings)
    private def timeout_settings
      @timeout_settings
    end

    # called from BrowserContext#expose_binding
    private def has_bindings?(name)
      @bindings.key?(name)
    end
  end
end
