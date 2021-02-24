module Playwright
  define_channel_owner :BindingCall do
    def name
      @initializer['name']
    end
  end
end
