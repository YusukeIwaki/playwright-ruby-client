module Playwright
  define_api_implementation :FileChooserImpl do
    def initialize(page:, element_handle:, is_multiple:)
      @page = page
      @element_handle = element_handle
      @is_multiple = is_multiple
    end

    attr_reader :page

    def element
      @element_handle
    end

    def multiple?
      @is_multiple
    end

    def set_files(files, noWaitAfter: nil, timeout: nil)
      @element_handle.set_input_files(files, noWaitAfter: noWaitAfter, timeout: timeout)
    end
  end
end
