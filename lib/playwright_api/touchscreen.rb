module Playwright
  # The Touchscreen class operates in main-frame CSS pixels relative to the top-left corner of the viewport. Methods on the
  # touchscreen can only be used in browser contexts that have been initialized with `hasTouch` set to true.
  class Touchscreen < PlaywrightApi

    # Dispatches a `touchstart` and `touchend` event with a single touch at the position (`x`,`y`).
    def tap_point(x, y)
      raise NotImplementedError.new('tap_point is not implemented yet.')
    end
  end
end
