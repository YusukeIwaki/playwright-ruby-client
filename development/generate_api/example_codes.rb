module ExampleCodes
  # Browser
  def example_b8acc529feb6c35ab828780a127d7bf2c079dc7f2847ef251c4c1a33b4197bf9(playwright:)
    firefox = playwright.firefox
    browser = firefox.launch
    begin
      page = browser.new_page
      page.goto("https://example.com")
    ensure
      browser.close
    end
  end

  # Browser#contexts
  def example_7f9edd4a42641957d48081449ceb3c54829485d152db1cc82a82f1f21191b90c(playwright:)
    playwright.webkit.launch do |browser|
      puts browser.contexts.count # => 0
      context = browser.new_context
      puts browser.contexts.count # => 1
    end
  end

  # Browser#new_context
  def example_3661a62dd097b41417b066df731db5f80905ccb40be870c04c44980ee7425f56(playwright:)
    playwright.firefox.launch do |browser| # or "chromium.launch" or "webkit.launch".
      # create a new incognito browser context.
      context = browser.new_context

      # create a new page in a pristine context.
      page = context.new_page()
      page.goto("https://example.com")
    end
  end

  # Browser#start_tracing
  def example_5a1282084821fd9127ef5ca54bdda63cdff46564f3cb20e347317dee260d33b3(browser:, page:)
    browser.start_tracing(page: page, path: "trace.json")
    begin
      page.goto("https://www.google.com")
    ensure
      browser.stop_tracing
    end
  end

  # Playwright
  def example_efc99085566bf177ec87b1bd3bb30d75b6053ec9b579a8ac8bb9f22e5942289a
    require 'playwright'

    Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
      chromium = playwright.chromium # or "firefox" or "webkit".
      chromium.launch do |browser|
        page = browser.new_page
        page.goto('https://example.com/')

        # other actions

      end
    end
  end

  # Playwright#devices
  def example_2c0457a5b76f4a0471fcafd994f7bad94d04f6871480be8118d200c76e59dd72
    require 'playwright'

    Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
      iphone = playwright.devices["iPhone 6"]
      playwright.webkit.launch do |browser|
        context = browser.new_context(**iphone)
        page = context.new_page
        page.goto('https://example.com/')

        # other actions

      end
    end
  end

  # Page
  def example_d3546d9e2ff0cfa4b0f89f4f357816699c86075dc0dc48e65634d8f0521b5cf6(playwright:)
    playwright.webkit.launch do |browser|
      page = browser.new_page
      page.goto('https://example.com/')
      page.screenshot(path: 'screenshot.png')
    end
  end

  # Page - on
  def example_7c555f32653d321e7da3ac5dbb3a9bdf48a3ee9f7bad6e34765742ba1ab99484(page:)
    page.once("load", -> (page) { puts "page loaded!" })
  end

  # Page - on/off
  def example_dc5a169a728f9186d97bbbda448c9a41c908018224ed1df4545cab1ae979ec01(page:)
    listener = -> (req) { puts "a request was made: #{req.url}" }
    page.on('request', listener)
    page.goto('https://example.com/') # => prints 'a request was made: https://example.com/'
    page.off('request', listener)
    page.goto('https://example.com/') # => no print
  end

  # Page#add_init_script
  def example_7d496db52fdb297d5d1941f3a843bcb1b4deb6edd67b5160a880258ed22f2053(page:)
    # in your playwright script, assuming the preload.js file is in same directory
    page.add_init_script(path: "./preload.js")
  end

  # Page#eval_on_selector
  def example_b3c0c695bba9bafb039d1003e5553b6792256703559205e4786e42a2b6800622(page:)
    search_value = page.eval_on_selector("#search", "el => el.value")
    preload_href = page.eval_on_selector("link[rel=preload]", "el => el.href")
    html = page.eval_on_selector(".main-container", "(e, suffix) => e.outer_html + suffix", arg: "hello")
  end

  # Page#eval_on_selector_all
  def example_aff87cecea5eee1970fcc9d8baafbbfba24b300f9648c49033eed4b72e7b1dbd(page:)
    div_counts = page.eval_on_selector_all("div", "(divs, min) => divs.length >= min", arg: 10)
  end

  # Page#evaluate
  def example_7a5617310ae3ed83b6ca98b9f363441234fd7c25af7c86f81fe840d4599e4da8(page:)
    result = page.evaluate("([x, y]) => Promise.resolve(x * y)", arg: [7, 8])
    puts result # => "56"
  end

  # Page#evaluate
  def example_23b23ab6bd2ef249ab5ba8ecf6bdb1b450ce4a8a9685d23b0b050cf1b040b7da(page:)
    puts page.evaluate("1 + 2") # => 3
    x = 10
    puts page.evaluate("1 + #{x}") # => "11"
  end

  # Page#evaluate
  def example_54a27f89dda0a0a05fac76ffad76c4a1173dae259842d15dbaf7ea587e6e327d
    body_handle = page.query_selector("body")
    html = page.evaluate("([body, suffix]) => body.innerHTML + suffix", arg: [body_handle, "hello"])
    body_handle.dispose()
  end

  # Page#evaluate_handle
  def example_fd8ed14043be0b21635ea7b0c55b59c55991a6a686904fcb82f2eee7671f9d55
    body_handle = page.evaluate_handle("document.body")
    result_handle = page.evaluate_handle("body => body.innerHTML", arg: body_handle)
    puts result_handle.json_value()
    result_handle.dispose()
  end
end
