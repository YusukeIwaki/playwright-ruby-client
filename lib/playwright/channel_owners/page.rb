module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_page.py
  define_channel_owner :Page do
    attr_writer :owned_context

    def after_initialize
      @accessibility = Accessibility.new(@channel)
      @keyboard = Keyboard.new(@channel)
      @mouse = Mouse.new(@channel)
      @touchscreen = Touchscreen.new(@channel)

      @main_frame = @initializer['mainFrame'].object
      @main_frame.send(:update_page_from_page, self)
      @frames = Set.new
      @frames << @main_frame
    end

    attr_reader :main_frame

    def goto(url, timeout: nil, waitUntil: nil, referer: nil)
      @main_frame.goto(url, timeout: timeout,  waitUntil: waitUntil, referer: referer)
    end
  end
end
