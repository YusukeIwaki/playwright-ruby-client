require 'base64'

module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_page.py
  define_channel_owner :Page do
    include Utils::Errors::SafeCloseError
    attr_writer :owned_context

    def after_initialize
      @browser_context = @parent
      # @timeout_settings = ...
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

    # called from BrowserContext#on_page with send(:update_browser_context, page), so keep private.
    private def update_browser_context(context)
      @browser_context = context
      # @timeout_settings = ...
    end
  end
end
