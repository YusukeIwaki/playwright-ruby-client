module Playwright
  class Disposable
    def initialize(impl)
      @impl = impl
    end

    def dispose
      @impl.dispose
    end
  end
end
