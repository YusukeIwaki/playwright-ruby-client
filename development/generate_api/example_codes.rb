module ExampleCodes
  def with_network_retry(max_retry: 2, timeout: 4, &block)
    if max_retry <= 0
      Timeout.timeout(timeout, &block)
    else
      begin
        Timeout.timeout(timeout, &block)
      rescue Timeout::Error
        puts "Retry with { remaining: #{max_retry - 1}, timeout: #{timeout * 1.5} }"
        with_network_retry(max_retry: max_retry - 1, timeout: timeout * 1.5, &block)
      end
    end
  end

  # Accessibility
  def example_2e5019929403491cde0c78bed1e0e18e0c86ab423d7ac8715876c4de4814f483(page:)
    snapshot = page.accessibility.snapshot
    puts snapshot
  end

  # Accessibility
  def example_388652162f4e169aab346af9ea657dd96de9217cd390a4cae2090af952b7aebe(page:)
    def find_focused_node(node)
      if node['focused']
        node
      else
        node['children']&.find do |child|
          find_focused_node(child)
        end
      end
    end

    snapshot = page.accessibility.snapshot
    node = find_focused_node(snapshot)
    puts node['name']
  end

  # APIRequestContext
  def example_8b05a1e391492122df853bef56d8d3680ea0911e5ff2afd7e442ce0b1a3a4e10(playwright:)
    playwright.chromium.launch do |browser|
      # This will launch a new browser, create a context and page. When making HTTP
      # requests with the internal APIRequestContext (e.g. `context.request` or `page.request`)
      # it will automatically set the cookies to the browser page and vise versa.
      context = browser.new_context(base_url: 'https://api.github,com')
      api_request_context = context.request


      # Create a repository.
      response = api_request_context.post(
        "/user/repos",
        headers: {
          "Accept": "application/vnd.github.v3+json",
          "Authorization": "Bearer #{API_TOKEN}",
        },
        data: { name: 'test-repo-1' },
      )
      response.ok? # => true
      response.json['name'] # => "test-repo-1"

      # Delete a repository.
      response = api_request_context.delete(
        "/repos/YourName/test-repo-1",
        headers: {
          "Accept": "application/vnd.github.v3+json",
          "Authorization": "Bearer #{API_TOKEN}",
        },
      )
      response.ok? # => true
    end
  end

  # APIRequestContext#fetch
  def example_19c86319c1f40a2cae90cfaf7f6471c50b59319e8b08d6e37d9be9d4697de0b8(api_request_context:)
    data = {
      title: "Book Title",
      body: "John Doe",
    }
    api_request_context.fetch("https://example.com/api/create_book", method: 'post', data: data)
  end

  # APIRequestContext#fetch
  def example_c5f1dfbcb296a3bc1e1e9e0216dacb2ee7c2af8685053b9e4bb44c823d82767c(api_request_context:)
    api_request_context.fetch(
      "https://example.com/api/upload_script",
      method: 'post',
      multipart: {
        fileField: {
          name: "f.js",
          mimeType: "text/javascript",
          buffer: "console.log(2022);",
        },
      },
    )
  end

  # APIRequestContext#get
  def example_cf0d399f908388d6949e0fd2a750800a486e56e31ddc57b5b8f685b94cccfed8(api_request_context:)
    query_params = {
      isbn: "1234",
      page: "23"
    }
    api_request_context.get("https://example.com/api/get_text", params: query_params)
  end

  # APIRequestContext#post
  def example_d42fb8f54175536448ed40ab14732e18bb20140493c96e5d07990ef7c200ac15(api_request_context:)
    data = {
      title: "Book Title",
      body: "John Doe",
    }
    api_request_context.post("https://example.com/api/create_book", data: data)
  end

  # APIRequestContext#post
  def example_858c53bcbc4088deffa2489935a030bb6a485ae8927e43b393b38fd7e4414c17(api_request_context:)
    form_data = {
      title: "Book Title",
      body: "John Doe",
    }
    api_request_context.post("https://example.com/api/find_book", form: form_data)
  end

  # APIRequestContext#post
  def example_3a940e5f148822e63981b92e0dd21748d81cdebc826935849d9fa08723fbccdc(api_request_context:)
    api_request_context.post(
      "https://example.com/api/upload_script",
      multipart: {
        fileField: {
          name: "f.js",
          mimeType: "text/javascript",
          buffer: "console.log(2022);",
        },
      },
    )
  end

  # APIResponse
  def example_a719a9b85189fe45a431d283eeae787323cce9a2a09aeadb86555240ef21417c(playwright:)
    playwright.chromium.launch do |browser|
      context = browser.new_context
      response = context.request.get("https://example.com/user/repos")

      response.ok? # => true
      response.status # => 200
      response.headers["content-type"] # => "application/json; charset=utf-8"
      response.json # => { "name" => "Foo" }
      response.body # => "{ \"name\" => \"Foo\" }"
    end
  end

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
  def example_7c214a04c3801b617a25fc020a766d671422782121b1ec7e1876d10789385c9c(playwright:)
    playwright.firefox.launch do |browser| # or "chromium.launch" or "webkit.launch".
      # create a new incognito browser context.
      browser.new_context do |context|
        # create a new page in a pristine context.
        page = context.new_page
        page.goto("https://example.com")
      end
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

  # BrowserContext
  def example_b9d02375c8dbbd86bc9ee14a9333ff363525bbec88d23ff8d8edbfda67301ad2(browser:)
    # create a new incognito browser context
    context = browser.new_context

    # create a new page inside context.
    page = context.new_page
    page.goto("https://example.com")

    # dispose context once it is no longer needed.
    context.close
  end

  # BrowserContext#add_cookies
  def example_9a397455c0681f67226d5bcb8e14922d2a098e184daa133dc191b17bbf5c603e(browser_context:)
    browser_context.add_cookies([cookie_object1, cookie_object2])
  end

  # BrowserContext#add_init_script
  def example_16af9114b96dcc9b341808b8a5e2eb4bb1fa9541858e8d8432a33a979867ccc8(browser_context:)
    # in your playwright script, assuming the preload.js file is in same directory.
    browser_context.add_init_script(path: "preload.js")
  end

  # BrowserContext#clear_permissions
  def example_de61e349d06a98a38ba9bfccc5708125cd263b7d3a31b9a837eda3db0baac288(browser:)
    context = browser.new_context
    context.grant_permissions(["clipboard-read"])

    # do stuff ..

    context.clear_permissions
  end

  # BrowserContext#expose_binding
  def example_fac8dd8edc4c565fc04b423141a6881aab2388e7951e425c43865ddd656ffad6(browser_context:)
    browser_context.expose_binding("pageURL", ->(source) { source[:page].url })
    page = browser_context.new_page

    page.content = <<~HTML
    <script>
      async function onClick() {
        document.querySelector('div').textContent = await window.pageURL();
      }
    </script>
    <button onclick="onClick()">Click me</button>
    <div></div>
    HTML

    page.get_by_role("button").click
  end

  # BrowserContext#expose_binding
  def example_93e847f70b01456eec429a1ebfaa6b8f5334f4c227fd73e62dd6a7facb48dbbd(browser_context:)
    def print_text(source, element)
      element.text_content
    end

    browser_context.expose_binding("clicked", method(:print_text), handle: true)
    page = browser_context.new_page

    page.content = <<~HTML
    <script>
      document.addEventListener('click', async (event) => {
        alert(await window.clicked(event.target));
      })
    </script>
    <div>Click me</div>
    <div>Or click me</div>
    HTML

    page.locator('div').first.click
  end

  # BrowserContext#expose_function
  def example_3465d6b0d3caee840bd7e5ca7076e4def34af07010caca46ea35d2a536d7445d(browser_context:)
    require 'digest'

    def sha256(text)
      Digest::SHA256.hexdigest(text)
    end

    browser_context.expose_function("sha256", method(:sha256))
    page = browser_context.new_page()
    page.content = <<~HTML
    <script>
      async function onClick() {
        document.querySelector('div').textContent = await window.sha256('PLAYWRIGHT');
      }
    </script>
    <button onclick="onClick()">Click me</button>
    <div></div>
    HTML
    page.get_by_role("button").click
  end

  # BrowserContext#route
  def example_8bee851cbea1ae0c60fba8361af41cc837666490d20c25552a32f79c4e044721(browser:)
    context = browser.new_context
    page = context.new_page
    context.route("**/*.{png,jpg,jpeg}", ->(route, request) { route.abort })
    page.goto("https://example.com")
  end

  # BrowserContext#route
  def example_aa8a83c2ddd0d9a327cfce8528c61f52cb5d6ec0f0258e03d73fad5481f15360(browser:)
    context = browser.new_context
    page = context.new_page
    context.route(/\.(png|jpg)$/, ->(route, request) { route.abort })
    page.goto("https://example.com")
  end

  # BrowserContext#route
  def example_ac637e238bebf237fca2ef4fd8a2ef81644eefcf862b305de633c2fabc3b4721(browser:)
    def handle_route(route, request)
      if request.post_data["my-string"]
        mocked_data = request.post_data.merge({ "my-string" => 'mocked-data'})
        route.fulfill(postData: mocked_data)
      else
        route.continue
      end
    end
    context.route("/api/**", method(:handle_route))
  end

  # BrowserContext#set_geolocation
  def example_12142bb78171e322de3049ac91a332da192d99461076da67614b9520b7cd0c6f(browser_context:)
    browser_context.geolocation = { latitude: 59.95, longitude: 30.31667 }
  end

  # BrowserContext#expect_event
  def example_6619b3b87b68e56013f61689b1e1df60f6bf2950241ef796dd2dc58b7d3292c8(browser_context:, page:)
    new_page = browser_context.expect_event('page') do
      page.get_by_role("button").click
    end
  end

  # BrowserType
  def example_554dfa8c71a3e87116c6f226d58cdb57d7993dd5df94e22c8fc74c0f83ef7b50(playwright:)
    chromium = playwright.chromium
    chromium.launch do |browser|
      page = browser.new_page
      page.goto('https://example.com/')

      # other actions

    end
  end

  # BrowserType#connect_over_cdp
  def example_7ae1379c9f44409ef613cbabe79f870ce054522aa0aaa84078f853257efb38f2(playwright:)
    browser = playwright.chromium.connect_over_cdp("http://localhost:9222")
    default_context = browser.contexts.first
    page = default_context.pages.first
  end

  # BrowserType#launch
  def example_90d6ec37772ce92e29e8942ec516d4859264d02aa9b8b8e6f3a773318f567f90(playwright:)
    browser = playwright.chromium.launch( # or "firefox" or "webkit".
      ignoreDefaultArgs: ["--mute-audio"]
    )

    browser.close
  end

  # CDPSession
  def example_3a8a10e66fc750bb0e176f66b2bd2eb305c4264e4146b9725dcff57e77811b3d(page:)
    client = page.context.new_cdp_session(page)
    client.send_message('Animation.enable')
    client.on('Animation.animationCreated', -> (_) { puts 'Animation Created' })
    response = client.send_message('Animation.getPlaybackRate')
    puts "Playback rate is #{response['playbackRate']}"
    client.send_message(
      'Animation.setPlaybackRate',
      params: { playbackRate: response['playbackRate'] / 2.0 },
    )
  end

  # ConsoleMessage
  def example_585cbbd055f47a5d0d7a6197d90874436cd4a2d50a92956723fc69336f8ccee9(page:)
    # Listen for all console logs
    page.on("console", ->(msg) { puts msg.text })

    # Listen for all console events and handle errors
    page.on("console", ->(msg) {
      if msg.type == 'error'
        puts "error: #{msg.text}"
      end
    })

    # Get the next console log
    msg = page.expect_console_message do
      # Issue console.log inside the page
      page.evaluate("console.error('hello', 42, { foo: 'bar' })")
    end

    # Deconstruct print arguments
    msg.args[0].json_value # => 'hello'
    msg.args[1].json_value # => 42
    msg.args[2].json_value # => { 'foo' => 'bar' }
  end

  # Dialog
  def example_c954c35627e62be69e1f138f25d7377b13e18d08039d476946217827fa95db52(page:)
    def handle_dialog(dialog)
      puts "[#{dialog.type}] #{dialog.message}"
      if dialog.message =~ /foo/
        dialog.accept
      else
        dialog.dismiss
      end
    end

    page.on("dialog", method(:handle_dialog))
    page.evaluate("confirm('foo')") # will be accepted
    # => [confirm] foo
    page.evaluate("alert('bar')") # will be dismissed
    # => [alert] bar
  end

  # Download
  def example_26c9f5a18a58f9976e24d83a3ae807479df5e28de9028f085615d99be2cea5a1(page:)
    download = page.expect_download do
      page.get_by_text("Download file").click
    end

    # wait for download to complete
    path = download.path
  end

  # ElementHandle
  def example_79d8d3cbe504c5562bfee5b1e40f4dfddf2cca147b57c9dac0249bcf96978263(page:)
    href_element = page.query_selector("a")
    href_element.click
  end

  # ElementHandle
  def example_01a453e4368b0eae393813ed13b9cd67aa07743e178567efdf8822cfd9b3b232(page:)
    handle = page.query_selector("text=Submit")
    handle.hover
    handle.click
  end

  # ElementHandle
  def example_2d68ae4f558fc720de25f387c810e7b69eb8716a0e0e4200699393f99b8db6b2(page:)
    locator = page.get_by_text("Submit")
    locator.hover
    locator.click
  end

  # ElementHandle#bounding_box
  def example_8382aa7cfb42a9a17e348e2f738279f1bd9a038f1ea35cc3cb244cc64d768f93(page:, element_handle:)
    box = element_handle.bounding_box
    page.mouse.click(
      box["x"] + box["width"] / 2,
      box["y"] + box["height"] / 2,
    )
  end

  # ElementHandle#dispatch_event
  def example_3b86add6ce355082cd43f4ac0ba9e69c15960bbd7ca601d0618355fe53aa8902(element_handle:)
    element_handle.dispatch_event("click")
  end

  # ElementHandle#dispatch_event
  def example_6b70ea4cf0c7ae9c82cf0ed22ab0dbbb563e2d1419b35d04aa513cf91f0856f9(page:, element_handle:)
    # note you can only create data_transfer in chromium and firefox
    data_transfer = page.evaluate_handle("new DataTransfer()")
    element_handle.dispatch_event("dragstart", eventInit: { dataTransfer: data_transfer })
  end

  # ElementHandle#eval_on_selector
  def example_f6a83ec555fcf23877c11cf55f02a8c89a7fc11d3324859feda42e592e129f4f(page:)
    tweet_handle = page.query_selector(".tweet")
    tweet_handle.eval_on_selector(".like", "node => node.innerText") # => "100"
    tweet_handle.eval_on_selector(".retweets", "node => node.innerText") # => "10"
  end

  # ElementHandle#eval_on_selector_all
  def example_11b54bf5ec18a0d0ceee0868651bb41ab5cd3afcc6b20d5c44f90d835c8d6f81(page:)
    feed_handle = page.query_selector(".feed")
    feed_handle.eval_on_selector_all(".tweet", "nodes => nodes.map(n => n.innerText)") # => ["hello!", "hi!"]
  end

  # ElementHandle#select_option
  def example_dc2ce38846b91d234483ed8b915b785ffbd9403213279465acd6605f314fe736(element_handle:)
    # single selection matching the value
    element_handle.select_option(value: "blue")
    # single selection matching both the label
    element_handle.select_option(label: "blue")
    # multiple selection
    element_handle.select_option(value: ["red", "green", "blue"])
  end

  # ElementHandle#select_option
  def example_b4cdd4a1a4d0392c2d430e0fb5fc670df2d728b6907553650690a2d0377662e4(element_handle:)
    # multiple selection for blue, red and second option
    element_handle.select_option(value: "blue", index: 2, label: "red")
  end

  # ElementHandle#type
  def example_2dc9720467640fd8bc581ed65159742e51ff91b209cb176fef8b95f14eaad54e(element_handle:)
    element_handle.type("hello") # types instantly
    element_handle.type("world", delay: 100) # types slower, like a user
  end

  # ElementHandle#type
  def example_d13faaf53454653ce45371b5cf337082a82bf7bbb0aada7e97f47d14963bd6b0(page:)
    element_handle = page.query_selector("input")
    element_handle.type("some text")
    element_handle.press("Enter")
  end

  # ElementHandle#wait_for_selector
  def example_3b0f6c6573db513b7b707a39d6c5bbf5ce5896b4785466d80f525968cfbd0be7(page:)
    page.content = "<div><span></span></div>"
    div = page.query_selector("div")
    # waiting for the "span" selector relative to the div.
    span = div.wait_for_selector("span", state: "attached")
  end

  # FileChooser
  def example_b43c3f24b4fb04caf6c90bd75037e31ef5e16331e30b7799192f4cc0ad450778(page:)
    file_chooser = page.expect_file_chooser do
      page.get_by_text("Upload file").click # action to trigger file uploading
    end
    file_chooser.set_files("myfile.pdf")
  end

  # Frame
  def example_a4a9e01d1e0879958d591c4bc9061574f5c035e821a94214e650d15564d77bf4(page:)
    def dump_frame_tree(frame, indent = 0)
      puts "#{' ' * indent}#{frame.name}@#{frame.url}"
      frame.child_frames.each do |child|
        dump_frame_tree(child, indent + 2)
      end
    end

    page.goto("https://www.theverge.com")
    dump_frame_tree(page.main_frame)
  end

  # Frame#dispatch_event
  def example_de439a4f4839a9b1bc72dbe0890d6b989c437620ba1b88a2150faa79f98184fc(frame:)
    frame.dispatch_event("button#submit", "click")
  end

  # Frame#dispatch_event
  def example_5410f49339561b3cc9d91c7548c8195a570c8be704bb62f45d90c68f869d450d(frame:)
    # note you can only create data_transfer in chromium and firefox
    data_transfer = frame.evaluate_handle("new DataTransfer()")
    frame.dispatch_event("#source", "dragstart", eventInit: { dataTransfer: data_transfer })
  end

  # Frame#eval_on_selector
  def example_6814d0e91763f4d27a0d6a380c36d62b551e4c3e902d1157012dde0a49122abe(frame:)
    search_value = frame.eval_on_selector("#search", "el => el.value")
    preload_href = frame.eval_on_selector("link[rel=preload]", "el => el.href")
    html = frame.eval_on_selector(".main-container", "(e, suffix) => e.outerHTML + suffix", arg: "hello")
  end

  # Frame#eval_on_selector_all
  def example_618e7f8f681d1c4a1c0c9b8d23892e37cbbef013bf3d8906fd4311c51d9819d7(frame:)
    divs_counts = frame.eval_on_selector_all("div", "(divs, min) => divs.length >= min", arg: 10)
  end

  # Frame#evaluate
  def example_15a235841cd1bc56fad6e3c8aaea2a30e352fedd8238017f22f97fc70e058d2b(frame:)
    result = frame.evaluate("([x, y]) => Promise.resolve(x * y)", arg: [7, 8])
    puts result # => "56"
  end

  # Frame#evaluate
  def example_9c73167b900498bca191abc2ce2627e063f84b0abc8ce3a117416cb734602760(frame:)
    puts frame.evaluate("1 + 2") # => 3
    x = 10
    puts frame.evaluate("1 + #{x}") # => "11"
  end

  # Frame#evaluate
  def example_6ebfd0a9a1f3cb61410f494ffc34a17f5c6d57280326d077fca3b0a18aef7834(frame:)
    body_handle = frame.query_selector("body")
    html = frame.evaluate("([body, suffix]) => body.innerHTML + suffix", arg: [body_handle, "hello"])
    body_handle.dispose
  end

  # Frame#evaluate_handle
  def example_a1c8e837e826079359d01d6f7eecc64092a45d8c74280d23ee9039c379132c51(frame:)
    a_window_handle = frame.evaluate_handle("Promise.resolve(window)")
    a_window_handle # handle for the window object.
  end

  # Frame#frame_element
  def example_e6b4fdef29a401d84b17acfa319bee08f39e1f28e07c435463622220c6a24747(frame:)
    frame_element = frame.frame_element
    content_frame = frame_element.content_frame
    puts frame == content_frame # => true
  end

  # Frame#frame_locator
  def example_7c9cfab83defacca7518fb1e95efb47bdd2a9ba0e6be836e973be19d8b4c4cb7(frame:)
    locator = frame.frame_locator("#my-iframe").get_by_text("Submit")
    locator.click
  end

  # Frame#get_by_alt_text
  def example_40a7d124045a4f729e0deddcfb511b9232ada7f16e0caa4e07ea083c2bfd3c16(page:)
    page.get_by_alt_text("Playwright logo").click
  end

  # Frame#get_by_label
  def example_18ca1d75e8a2404e6a0c269ff926bc1499f15e7dc041441f764ae3bde033b0cf(page:)
    page.get_by_label("Username").fill("john")
    page.get_by_label("Password").fill("secret")
  end

  # Frame#get_by_placeholder
  def example_c521b79be0a480325f84dc2c110a9803f0d74b2042da32c84660abe90ab7bb37(page:)
    page.get_by_placeholder("name@example.com").fill("playwright@microsoft.com")
  end

  # Frame#get_by_role
  def example_d0da510d996da8a4b3e0505412b0b651049ab11b56317300ba3dc52e928500b3(page:)
    page.get_by_role("heading", name: "Sign up").visible? # => true
    page.get_by_role("checkbox", name: "Subscribe").check
    page.get_by_role("button", name: /submit/i).click
  end

  # Frame#get_by_test_id
  def example_291583061a6a67f91ea5f926eac4b5cd6c351d7009ddfef39b52efba03909ca0(page:)
    page.get_by_test_id("directions").click
  end

  def example_0aecb761822601bd6adf174c0aeb9db69bf4880a62eb4a1cdeb67c2f57c7149e(page:)
    page.get_by_title("Issues count").text_content # => "25 issues"
  end

  # Frame#select_option
  def example_230c12044664b222bf35d6163b1e415c011d87d9911a4d39648c7f601b344a31(frame:)
    # single selection matching the value
    frame.select_option("select#colors", value: "blue")
    # single selection matching both the label
    frame.select_option("select#colors", label: "blue")
    # multiple selection
    frame.select_option("select#colors", value: ["red", "green", "blue"])
  end

  # Frame#type
  def example_beae7f0d11663c3c98b9d3a8e6ab76b762578cf2856e3b04ad8e42bfb23bb1e1(frame:)
    frame.type("#mytextarea", "hello") # types instantly
    frame.type("#mytextarea", "world", delay: 100) # types slower, like a user
  end

  # Frame#wait_for_function
  def example_2f82dcf15fa9338be87a4faf7fe7de3c542040924db1e1ad1c98468ec0f425ce(frame:)
    frame.evaluate("window.x = 0; setTimeout(() => { window.x = 100 }, 1000);")
    frame.wait_for_function("() => window.x > 0")
  end

  # Frame#wait_for_function
  def example_8b95be0fb4d149890f7817d9473428a50dc631d3a75baf89846648ca6a157562(frame:)
    selector = ".foo"
    frame.wait_for_function("selector => !!document.querySelector(selector)", arg: selector)
  end

  # Frame#wait_for_load_state
  def example_fe41b79b58d046cda4673ededd4d216cb97a63204fcba69375ce8a84ea3f6894(frame:)
    frame.click("button") # click triggers navigation.
    frame.wait_for_load_state # the promise resolves after "load" event.
  end

  # Frame#expect_navigation
  def example_03f0ac17eb6c1ce8780cfa83c4ae15a9ddbfde3f96c96f36fdf3fbf9aac721f7(frame:)
    frame.expect_navigation do
      frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
    end # Resolves after navigation has finished
  end

  # Frame#wait_for_selector
  def example_a5b9dd4745d45ac630e5953be1c1815ae8e8ab03399fb35f45ea77c434f17eea(page:)
    %w[https://google.com https://bbc.com].each do |current_url|
      page.goto(current_url, waitUntil: "domcontentloaded")
      frame = page.main_frame
      element = frame.wait_for_selector("img")
      puts "Loaded image: #{element["src"]}"
    end
  end

  # Frame#wait_for_url
  def example_86a9a19ec4c41e1a5ac302fbca9a3d3d6dca3fe3314e065b8062ddf5f75abfbd(frame:)
    frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
    frame.wait_for_url("**/target.html")
  end

  # FrameLocator
  def example_4b7e4ce2b2fdb7e75c2145e4ba89216e4cbd2892caff1b05189e8729d3aa8dfb(page:)
    locator = page.frame_locator("my-frame").get_by_text("Submit")
    locator.click
  end

  # FrameLocator
  def example_e2ea8f31994ab012b3f8cd7f5abfb4cb610286a4be96c9d4d6f1ad9f9678a0ed(page:)
    # Throws if there are several frames in DOM:
    page.frame_locator('.result-frame').get_by_role('button').click

    # Works because we explicitly tell locator to pick the first frame:
    page.frame_locator('.result-frame').first.get_by_role('button').click
  end

  # FrameLocator
  def example_12733f9ff809e08435510bc818e9a4194f9f89cbf6de5c38bfb3e1dca9e72565
    frame_locator = locator.frame_locator(':scope')
  end

  # JSHandle
  def example_c408a96b8ac9c9bd54d915009c8b477eb75b7bf9e879fd76b32f3d4b6340a667(page:)
    window_handle = page.evaluate_handle("window")
    # ...
  end

  # JSHandle#evaluate
  def example_2400f96eaaed3bc6ef6b0a16ba48e83d38a166c7d55a5dba0025472cffc6f2be(page:)
    tweet_handle = page.query_selector(".tweet .retweets")
    tweet_handle.evaluate("node => node.innerText") # => "10 retweets"
  end

  # JSHandle#properties
  def example_b5cbf187e1332705618516d4be127b8091a5d1acfa9a12d382086a2b0e738909(page:)
    page.goto('https://example.com/')
    handle = page.evaluate_handle("({window, document})")
    properties = handle.properties
    puts properties
    window_handle = properties["window"]
    document_handle = properties["document"]
    handle.dispose
  end

  # Keyboard
  def example_575870a45e4fe08d3e06be3420e8a11be03f85791cd8174f27198c016031ae72(page:)
    page.keyboard.type("Hello World!")
    page.keyboard.press("ArrowLeft")
    page.keyboard.down("Shift")
    6.times { page.keyboard.press("ArrowLeft") }
    page.keyboard.up("Shift")
    page.keyboard.press("Backspace")
    # result text will end up saying "Hello!"
  end

  # Keyboard
  def example_a4f00f0cd486431b7eca785304f4e9715522da45b66dda7f3a5f6899b889b9fd(page:)
    page.keyboard.press("Shift+KeyA")
    # or
    page.keyboard.press("Shift+A")
  end

  # Keyboard
  def example_2deda0786a20a28cec9e8b438078a5fc567f7c7e5cf369419ab3c4d80a319ff6
    # on windows and linux
    page.keyboard.press("Control+A")
    # on mac_os
    page.keyboard.press("Meta+A")
  end

  # Keyboard#insert_text
  def example_a9cc2667e9f3e3b8c619649d7e4a7f5db9463e0b76d67a5e588158093a9e9124(page:)
    page.keyboard.insert_text("嗨")
  end

  # Keyboard#press
  def example_88943eb85c1ac7c261601e6edbdead07a31c2784326c496e10667ede1a853bab(page:)
    page.goto("https://keycode.info")
    page.keyboard.press("a")
    page.screenshot(path: "a.png")
    page.keyboard.press("ArrowLeft")
    page.screenshot(path: "arrow_left.png")
    page.keyboard.press("Shift+O")
    page.screenshot(path: "o.png")
  end

  # Keyboard#type
  def example_d9ced919f139961fd2b795c71375ca96f788a19c1f8e1479c5ec905fb5c02d43(page:)
    page.keyboard.type("Hello") # types instantly
    page.keyboard.type("World", delay: 100) # types slower, like a user
  end

  # Locator
  def example_9f72eed0cd4b2405e6a115b812b36ff2624e889f9086925c47665333a7edabbc(page:)
    locator = page.locator("text=Submit")
    locator.click
  end

  # Locator
  def example_5c129e11b91105b449e998fc2944c4591340eca625fe27a86eb555d5959dfc14(page:)
    # Throws if there are several buttons in DOM:
    page.locator('button').click

    # Works because we explicitly tell locator to pick the first element:
    page.locator('button').first.click

    # Works because count knows what to do with multiple matches:
    page.locator('button').count
  end

  # Locator#all
  def example_0d78b77c4a8b63146297e6f4db0c955a4077e32528fe59a292d9a3e76c000918(page:)
    page.get_by_role('listitem').all.each do |li|
      li.click
    end
  end

  # Locator#all_inner_texts
  def example_db3fbc8764290dcac5864a6d11dae6643865e74e0d1bb7e6a00ce777321a0b2f(page:)
    texts = page.get_by_role("link").all_inner_texts
  end

  # Locator#all_text_contents
  def example_46e7add209e0c75ea54b931e47cefd095d989d034e76ec8918939e0f47b89ca3(page:)
    texts = page.get_by_role("link").all_text_contents
  end

  # Locator#bounding_box
  def example_09bf5cd40405b9e5cd84333743b6ef919d0714bb4da78c86404789d26ff196ae(page:)
    element = page.get_by_role("button")
    box = element.bounding_box
    page.mouse.click(
      box["x"] + box["width"] / 2,
      box["y"] + box["height"] / 2,
    )
  end

  # Locator#check
  def example_17dff0bf6d8bc93d2e17be7fd1c1231ee72555eabb19c063d71ee804928273a8(page:)
    page.get_by_role("checkbox").check
  end

  # Locator#checked?
  def example_f617df59758f06107dd5c79e986aabbfde5861fbda6ccc5d8b91a508ebdc48f7(page:)
    checked = page.get_by_role("checkbox").checked?
  end

  # Locator#checked=
  def example_bab309d5b9f84c3b57a3057462dbddf7436cba6181457788c8e302d8e20aa108(page:)
    page.get_by_role("checkbox").checked = true
    page.get_by_role("checkbox").set_checked(true)
  end

  # Locator#clear
  def example_ccddf9c70c0dd2f6eaa85f46cf99155666e5be09f98bacfca21735d25e990707(page:)
    page.get_by_role("textbox").clear
  end

  # Locator#click
  def example_0e93b0bcf462c0151fa70dfb6c3cb691c67ec10cdf0498478427a5c1d2a83521(page:)
    page.get_by_role("button").click
  end

  # Locator#click
  def example_855b70722b9c7795f29b6aa150ba7997d542adf67f9104638ca48fd680ad6d86(page:)
    page.locator("canvas").click(button: "right", modifiers: ["Shift"], position: { x: 23, y: 32 })
  end

  # Locator#count
  def example_a711e425f2e4fe8cdd4e7ff99d609e607146ddb7b1fb5c5d8978bd0555ac1fcd(page:)
    count = page.get_by_role("listitem").count
  end

  # Locator#disabled?
  def example_5c008cd1a3ece779fe8c29092643a482cd0215d5c09001cd9ef08c444ea6cdd1(page:)
    disabled = page.get_by_role("button").disabled?
  end

  # Locator#dispatch_event
  def example_72b38530862dccd8b3ad53982f45a24a5ee82fc6e50fccec328d544bf1a78909(element_handle:)
    locator.dispatch_event("click")
  end

  # Locator#dispatch_event
  def example_bf805bb1858c7b8ea50d9c52704fab32064e1c26fb608232e823fe87267a07b3(page:, element_handle:)
    # note you can only create data_transfer in chromium and firefox
    data_transfer = page.evaluate_handle("new DataTransfer()")
    locator.dispatch_event("dragstart", eventInit: { dataTransfer: data_transfer })
  end

  # Locator#drag_to
  def example_f4046df878cf5096f750d2865c48060a3d7dd5e198e508776f9a09afbc567763(page:)
    source = page.locator("#source")
    target = page.locator("#target")

    source.drag_to(target)
    # or specify exact positions relative to the top-left corners of the elements:
    source.drag_to(
      target,
      sourcePosition: { x: 34, y: 7 },
      targetPosition: { x: 10, y: 20 },
    )
  end

  # Locator#editable?
  def example_10e437a8b21b128feda412f1e3cf85615fe260be2ad08758a3c5e5216b46187b(page:)
    editable = page.get_by_role("textbox").editable?
  end

  # Locator#enabled?
  def example_69710ffa4599909a9ae6cd570a2b88f6981c064c577b1e255fe5cc21b07d033c(page:)
    enabled = page.get_by_role("button").enabled?
  end

  # Locator#evaluate
  def example_df39b3df921f81e7cfb71cd873b76a5e91e46b4aa41e1f164128cb322aa38305(page:)
    tweet = page.query_selector(".tweet .retweets")
    tweet.evaluate("node => node.innerText") # => "10 retweets"
  end

  # Locator#evaluate_all
  def example_877178e12857c7b3ef09f6c50606489c9d9894220622379b72e1e180a2970b96(page:)
    locator = page.locator("div")
    more_than_ten = locator.evaluate_all("(divs, min) => divs.length >= min", arg: 10)
  end

  # Locator#fill
  def example_77567051f4c8531c719eb0b94e53a061ffe9a414e3bb131cbc956d1fdcf6eab3(page:)
    page.get_by_role("textbox").fill("example value")
  end

  # Locator#filter
  def example_516c962e3016789b2f0d21854daed72507a490b018b3f0213d4ae25f9ee03267(page:)
    row_locator = page.locator("tr")
    # ...
    row_locator.
        filter(hasText: "text in column 1").
        filter(has: page.get_by_role("button", name: "column 2 button")).
        screenshot
  end

  # Locator#get_by_text
  def example_cbf4890335f3140b7b275bdad85b330140e5fbb21e7f4b89643c73115ee62a17(page:)
    page.content = <<~HTML
      <div>Hello <span>world</span></div>
      <div>Hello</div>
    HTML

    # Matches <span>
    locator = page.get_by_text("world")
    expect(locator.evaluate('e => e.outerHTML')).to eq('<span>world</span>')

    # Matches first <div>
    locator = page.get_by_text("Hello world")
    expect(locator.evaluate('e => e.outerHTML')).to eq('<div>Hello <span>world</span></div>')

    # Matches second <div>
    locator = page.get_by_text("Hello", exact: true)
    expect(locator.evaluate('e => e.outerHTML')).to eq('<div>Hello</div>')

    # Matches both <div>s
    locator = page.get_by_text(/Hello/)
    expect(locator.count).to eq(2)
    expect(locator.first.evaluate('e => e.outerHTML')).to eq('<div>Hello <span>world</span></div>')
    expect(locator.last.evaluate('e => e.outerHTML')).to eq('<div>Hello</div>')

    # Matches second <div>
    locator = page.get_by_text(/^hello$/i)
    expect(locator.evaluate('e => e.outerHTML')).to eq('<div>Hello</div>')
  end

  # Locator#hidden?
  def example_f25a3bde8e8a1d091d01321314daa6059cb8aa026a3c2c4be50b1611bbdb3c19(page:)
    hidden = page.get_by_role("button").hidden?
  end

  # Locator#frame_locator
  def example_0ec60e5949820a3a318c7e05ea06b826218f2d79a94f8d599a29c8b07b2c1e63(page:)
    locator = page.frame_locator("iframe").get_by_text("Submit")
    locator.click
  end

  # Locator#hover
  def example_0a9e085f6c2ab04459adc2bf6ec73a06ff3cde201943ff8f4965552528b73f89(page:)
    page.get_by_role("link").hover
  end

  # Locator#input_valie
  def example_bb8cec73e5210f884833e04e6d71f7c035451bafd39500e057e6d6325c990474(page:)
    value = page.get_by_role("textbox").input_value
  end

  # Locator#last
  def example_37f239c3646f77e0658c12f139a5883eb99d9952f7761ad58ffb629fa385c7bb(page:)
    banana = page.get_by_role("listitem").last
  end

  # Locator#nth
  def example_d6cc7c4a653d7139137c582ad853bebd92e3b97893fb6d5f88919553404c57e4(page:)
    banana = page.get_by_role("listitem").nth(2)
  end

  # Locator#press
  def example_29eed7b713b928678523c677c788808779cf13dda2bb117aab2562cef3b08647(page:)
    page.get_by_role("textbox").press("Backspace")
  end

  # Locator#screenshot
  def example_43381950beaa21258e3f378d4b6aff54b83fa3eba52f36c65f4ca2d3d6df248d(page:)
    page.get_by_role("link").screenshot
  end

  # Locator#screenshot
  def example_d787f101e95d45bbcf3184b241bab4925e68d8e5c117299d0a95bf66f19bbdaa(page:)
    page.get_by_role("link").screenshot(animations="disabled", path="link.png")
  end

  # Locator#select_option
  def example_05e2ba1e92a54ea2d01e939597114efd78e2eec8bae4764c87d4c7d0c0f10689(element_handle:)
    # single selection matching the value or label
    element.select_option(value: "blue")
    # single selection matching both the label
    element.select_option(label: "blue")
    # multiple selection
    element.select_option(value: ["red", "green", "blue"])
  end

  # Locator#select_option
  def example_3aaff4985dc38e64fad34696c88a6a68a633e26aabee6fc749125f3ee1784e34(element_handle:)
    # multiple selection for blue, red and second option
    element.select_option(value: "blue", index: 2, label: "red")
  end

  # Locator#set_input_files
  def example_f1bf5c6c31c8405ce60cee9138c6d6dc6923be52e61ff8c2a3c3d28186b72282(page:)
    # Select one file
    page.get_by_label("Upload file").set_input_files('myfile.pdf')

    # Select multiple files
    page.get_by_label("Upload files").set_input_files(['file1.txt', 'file2.txt'])

    # Remove all the selected files
    page.get_by_label("Upload file").set_input_files([])
  end

  # Locator#type
  def example_fa1712c0b6ceb96fcaa74790d33f2c2eefe2bd1f06e61b78e0bb84a6f22c7961(element_handle:)
    element.type("hello") # types instantly
    element.type("world", delay: 100) # types slower, like a user
  end

  # Locator#type
  def example_c52737358713c715eb9607198a15d3e7533c8ca126cf61fa58d6cb31a701585b(page:)
    element = page.get_by_label("Password")
    element.type("my password")
    element.press("Enter")
  end

  # Locator#uncheck
  def example_ead0dc91ccaf4d3de1e28cccdadfacb0e75c79ffcfb8fc5a2b55afa736870fa6(page:)
    page.get_by_role("checkbox").uncheck
  end

  # Locator#visible?
  def example_b54ab20fe81143e0242d5d001ce2b1af4a272a2cc7c9d6925551de10f46a68c4(page:)
    visible = page.get_by_role("button").visible?
  end

  # Locator#wait_for
  def example_fe6f0a646d9e680807072ce223c7fdf83033490839c9a04e94ac48c278cb5568(page:)
    order_sent = page.locator("#order-sent")
    order_sent.wait_for
  end

  # Mouse
  def example_ba01da1f358cafb4c22b792488ff2f3de4dbd82d4ee1cc4050e3f0c24a2bd7dd(page:)
    # using ‘page.mouse’ to trace a 100x100 square.
    page.mouse.move(0, 0)
    page.mouse.down
    page.mouse.move(0, 100)
    page.mouse.move(100, 100)
    page.mouse.move(100, 0)
    page.mouse.move(0, 0)
    page.mouse.up
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

  # Page#dispatch_event
  def example_9220b94fd2fa381ab91448dcb551e2eb9806ad331c83454a710f4d8a280990e8(page:)
    page.content = '<button id="submit">Send</button>'
    page.dispatch_event("button#submit", "click")
  end

  # Page#dispatch_event
  def example_9b4482b7243b7ce304d6ce8454395e23db30f3d1d83229242ab7bd2abd5b72e0(page:)
    page.content = '<div id="source">Drag</div>'

    # note you can only create data_transfer in chromium and firefox
    data_transfer = page.evaluate_handle("new DataTransfer()")
    page.dispatch_event("#source", "dragstart", eventInit: { dataTransfer: data_transfer })
  end

  # Page#drag_and_drop
  def example_1b16c833a5a31719df85ea8c7d134c3199d3396171a69df3f0c80e67cc0df538(page:)
    page.drag_and_drop("#source", "#target")
    # or specify exact positions relative to the top-left corners of the elements:
    page.drag_and_drop(
      "#source",
      "#target",
      sourcePosition: { x: 34, y: 7 },
      targetPosition: { x: 10, y: 20 },
    )
  end

  # Page#emulate_media
  def example_df304caf6c61f6f44b3e2b0006a7e05552362a47b17c9ba227df76e918d88a5c(page:)
    page.evaluate("matchMedia('screen').matches") # => true
    page.evaluate("matchMedia('print').matches") # => false

    page.emulate_media(media: "print")
    page.evaluate("matchMedia('screen').matches") # => false
    page.evaluate("matchMedia('print').matches") # => true

    page.emulate_media
    page.evaluate("matchMedia('screen').matches") # => true
    page.evaluate("matchMedia('print').matches") # => false
  end

  # Page#emulate_media
  def example_f0479a2ee8d8f51dab94f48b7e121cade07e5026d4f602521cc6ccc47feb5a98(page:)
    page.emulate_media(colorScheme="dark")
    page.evaluate("matchMedia('(prefers-color-scheme: dark)').matches") # => true
    page.evaluate("matchMedia('(prefers-color-scheme: light)').matches") # => false
    page.evaluate("matchMedia('(prefers-color-scheme: no-preference)').matches") # => false
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
  def example_b49ac8565a94d1273fd47819ad9090736deb02feb0aea4a9eb35c68c66f22502(page:)
    body_handle = page.query_selector("body")
    html = page.evaluate("([body, suffix]) => body.innerHTML + suffix", arg: [body_handle, "hello"])
    body_handle.dispose
  end

  # Page#evaluate_handle
  def example_6802829f93cc4da7e67f3886b9773c7b84054afa84251add50704f8ca6837138(page:)
    a_window_handle = page.evaluate_handle("Promise.resolve(window)")
    a_window_handle # handle for the window object.
  end

  # Page#evaluate_handle
  def example_9daa37cfd3d747c9360d9544f64786bf49d291a6887b0efccc813215b62ae4c6(page:)
    a_handle = page.evaluate_handle("document") # handle for the "document"
  end

  # Page#evaluate_handle
  def example_fd8ed14043be0b21635ea7b0c55b59c55991a6a686904fcb82f2eee7671f9d55(page:)
    body_handle = page.evaluate_handle("document.body")
    result_handle = page.evaluate_handle("body => body.innerHTML", arg: body_handle)
    puts result_handle.json_value
    result_handle.dispose
  end

  # Page#expose_binding
  def example_551f5963351bfd7141fa8c94f5f22c305ec1c01d617861953374e9290929a551(page:)
    page.expose_binding("pageURL", ->(source) { source[:page].url })
    page.content = <<~HTML
    <script>
      async function onClick() {
        document.querySelector('div').textContent = await window.pageURL();
      }
    </script>
    <button onclick="onClick()">Click me</button>
    <div></div>
    HTML
    page.locator("button").click
  end

  # Page#expose_binding
  def example_6534a792e99e05b5644cea6e5b77ca5d864675a3012f447f0f8318c4fa6a6a54(page:)
    def print_text(source, element)
      element.text_content
    end

    page.expose_binding("clicked", method(:print_text), handle: true)
    page.content = <<~HTML
    <script>
      document.addEventListener('click', async (event) => {
        alert(await window.clicked(event.target));
      })
    </script>
    <div>Click me</div>
    <div>Or click me</div>
    HTML

    page.locator('div').first.click
  end

  # Page#expose_function
  def example_3692cd13d12f1d501e2a5e8e6a60d335c5ad54ab3b5eb34e3cec0227106d89f0(page:)
    require 'digest'

    def sha1(text)
      Digest::SHA256.hexdigest(text)
    end

    page.expose_function("sha256", method(:sha256))
    page.content = <<~HTML
    <script>
      async function onClick() {
        document.querySelector('div').textContent = await window.sha256('PLAYWRIGHT');
      }
    </script>
    <button onclick="onClick()">Click me</button>
    <div></div>
    HTML
    page.locator("button").click
  end

  # Page#frame
  def example_034f224ec0f7b4d98fdf875cefbc7e6c8726a6d615cbba9b1cb8c49180fd7d69(page:)
    frame = page.frame(name: "frame-name")
  end

  # Page#frame
  def example_a8a4717d8505a35662faafa9e6c2cfbbc0a44755c8e4d43252f882b7e4f1f04a(page:)
    frame = page.frame(url: /.*domain.*/)
  end

  # Page#frame_locator
  def example_e2abd82db97f2a0531855941d4ae70ef68fe8f844318e7a474d14a217dfd2595(page:)
    locator = page.frame_locator("#my-iframe").get_by_text("Submit")
    locator.click
  end

  # Page#pdf
  def example_e079fbec8ee0607ee45cdca94df61dea36f7fd3840986d5f4ac24918569a5f5e(page:)
    # generates a pdf with "screen" media type.
    page.emulate_media(media: "screen")
    page.pdf(path: "page.pdf")
  end

  # Page#press
  def example_aa4598bd7dbeb8d2f8f5c0aa3bdc84042eb396de37b49f8ff8c1ea39f080f709(page:)
    page.goto("https://keycode.info")
    page.press("body", "A")
    page.screenshot(path: "a.png")
    page.press("body", "ArrowLeft")
    page.screenshot(path: "arrow_left.png")
    page.press("body", "Shift+O")
    page.screenshot(path: "o.png")
  end

  # Page#route
  def example_a3038a6fd55b06cb841251877bf6eb781b08018695514c6e0054848d4e93d345(page:)
    page.route("**/*.{png,jpg,jpeg}", ->(route, request) { route.abort })
    page.goto("https://example.com")
  end

  # Page#route
  def example_7fda2a761bdd66b942415ab444c6b4bb89dd87ec0f0a4a03e6775feb694f7913(page:)
    page.route(/\.(png|jpg)$/, ->(route, request) { route.abort })
    page.goto("https://example.com")
  end

  # Page#route
  def example_ff4fba1273c7e65f4d68b4fcdd9dc4b792bba435005f0b9e7066ca18ded750b5(pgae:)
    def handle_route(route, request)
      if request.post_data["my-string"]
        mocked_data = request.post_data.merge({ "my-string" => 'mocked-data'})
        route.fulfill(postData: mocked_data)
      else
        route.continue
      end
    end
    page.route("/api/**", method(:handle_route))
  end

  # Page#select_option
  def example_4b17eb65721c55859c50eb12b4ee762e65408618cf3b7d07958b68d60ea6be6c(page:)
    # single selection matching the value
    page.select_option("select#colors", value: "blue")
    # single selection matching both the label
    page.select_option("select#colors", label: "blue")
    # multiple selection
    page.select_option("select#colors", value: ["red", "green", "blue"])
  end

  # Page#set_viewport_size
  def example_e3883d51c0785c34b62633fe311c4f1252dd9f29e6b4b6c7719f1eb74384e6e9(page:)
    page.viewport_size = { width: 640, height: 480 }
    page.goto("https://example.com")
  end

  # Page#type
  def example_4c7291f6023d2fe4f957cb7727646b50fdee40275db330a6f4517e349ea7f916(page:)
    page.type("#mytextarea", "hello") # types instantly
    page.type("#mytextarea", "world", delay: 100) # types slower, like a user
  end

  # Page#expect_event
  def example_37a07ca53382af80ed79aeaa2d65e450d4a8f6ee9753eb3c22ae2125d9cf83c8(page:)
    frame = page.expect_event("framenavigated") do
      page.get_by_role("button")
    end
  end

  # Page#wait_for_timeout
  def example_950cdc32e1332d1b12e420a817caa4317d0346ddda1b3cec97d77abe13c95260(page:)
    page.wait_for_timeout(1000)
  end

  # Page#wait_for_function
  def example_e50869c913bec2f0a89a22ff1c438128c3c8f2e3710acb10665445cf52e3ec73(page:)
    page.evaluate("window.x = 0; setTimeout(() => { window.x = 100 }, 1000);")
    page.wait_for_function("() => window.x > 0")
  end

  # Page#wait_for_function
  def example_04c93558dde8de62944515a8ed91fda6e0d01feca4d3bb2e58c6fda10a8c6ade(page:)
    selector = ".foo"
    page.wait_for_function("selector => !!document.querySelector(selector)", arg: selector)
  end

  # Page#wait_for_load_state
  def example_c20d17a107bdb6b05189fa02485e9c32a290ae0052686ac9d9611312995c5eed(page:)
    page.get_by_role("button").click # click triggers navigation.
    page.wait_for_load_state # the promise resolves after "load" event.
  end

  # Page#wait_for_load_state
  def example_fbda9305b509a808a81b1c3a54dc1eca9fbddf2695c8dd708b365ba75b777aa3(page:)
    popup = page.expect_popup do
      page.get_by_role("button").click # click triggers a popup.
    end

    # Wait for the "DOMContentLoaded" event.
    popup.wait_for_load_state("domcontentloaded")
    puts popup.title # popup is ready to use.
  end

  # Page#expect_navigation
  def example_3eda55b8be7aa66b69117d8f1a98374e8938923ba516831ee46bc5e1994aff33(page:)
    page.expect_navigation do
      # This action triggers the navigation after a timeout.
      page.get_by_text("Navigate after timeout").click
    end # Resolves after navigation has finished
  end

  # Page#expect_request
  def example_0c91be8bc12e1e564d14d37e5e0be8d4e56189ef1184ff34ccc0d92338ad598b(page:)
    page.content = '<form action="https://example.com/resource"><input type="submit" value="trigger request" /></form>'
    request = page.expect_request(/example.com\/resource/) do
      page.get_by_text("trigger request").click()
    end
    puts request.headers

    page.wait_for_load_state # wait for request finished.

    # or with a predicate
    page.content = '<form action="https://example.com/resource"><input type="submit" value="trigger request" /></form>'
    request = page.expect_request(->(req) { req.url.start_with? 'https://example.com/resource' }) do
      page.get_by_text("trigger request").click()
    end
    puts request.headers
  end

  # Page#expect_response
  def example_bdc21f273866a6ed56d91f269e9665afe7f32d277a2c27f399c1af0bcb087b28(page:)
    page.content = '<form action="https://example.com/resource"><input type="submit" value="trigger response" /></form>'
    response = page.expect_response(/example.com\/resource/) do
      page.get_by_text("trigger response").click()
    end
    puts response.body
    puts response.ok?

    page.wait_for_load_state # wait for request finished.

    # or with a predicate
    page.content = '<form action="https://example.com/resource"><input type="submit" value="trigger response" /></form>'
    response = page.expect_response(->(res) { res.url.start_with? 'https://example.com/resource' }) do
      page.get_by_text("trigger response").click()
    end
    puts response.body
    puts response.ok?
  end

  # Page#wait_for_selector
  def example_0a62ff34b0d31a64dd1597b9dff456e4139b36207d26efdec7109e278dc315a3(page:)
    %w[https://google.com https://bbc.com].each do |current_url|
      page.goto(current_url, waitUntil: "domcontentloaded")
      element = page.wait_for_selector("img")
      puts "Loaded image: #{element["src"]}"
    end
  end

  # Page#wait_for_url
  def example_a49b1deed2b93fe358b57bca9c4032f44b3d24436a78720421ba040aad4d661c(page:)
    page.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
    page.wait_for_url("**/target.html")
  end

  # Request#failure
  def example_5f3f4534ab17f584cfd41ca38448ce7de9490b6588e29e73116ede3cb15a25a5(page:)
    page.on("requestfailed", ->(request) { puts "#{request.url} #{request.failure}" })
  end

  # Request#redirected_from
  def example_89568fc86bf623eef37b68c6659b1a8524647c8365bb32a7a8af63bd86111075(page:)
    response = page.goto("http://github.com")
    puts response.url # => "https://github.com"
    puts response.request.redirected_from&.url # => "http://github.com"
  end

  # Request#redirected_from
  def example_6d7b3fbf8d69dbe639b71fedc5a8977777fca29dfb16d38012bb07c496342472(page:)
    response = page.goto("https://google.com")
    puts response.request.redirected_from&.url # => nil
  end

  # Request#redirected_to
  def example_922623f4033e7ec2158787e54a8554655f7e1e20a024e4bf4f69337f781ab88a(request:)
    request.redirected_from.redirected_to # equals to request
  end

  # Request#timing
  def example_e2a297fe95fd0699b6a856c3be2f28106daa2615c0f4d6084f5012682a619d20(page:)
    request = page.expect_event("requestfinished") do
      page.goto("https://example.com")
    end
    puts request.timing
  end

  # Route#continue
  def example_39b99a97428d536c6d26b43e024ebbd90aa62cdd9f58cc70d67e23ca6b6b1799(page:)
    def handle(route, request)
      # override headers
      headers = request.headers
      headers['foo'] = 'bar' # set "foo" header
      headers['user-agent'] = 'Unknown Browser' # modify user-agent
      headers.delete('bar') # remove "bar" header

      route.continue(headers: headers)
    end
    page.route("**/*", method(:handle))
  end

  # Route#fallback
  def example_347531c10d6bf4b1f6e727494b385f224aa59a068df9073b0afaa2ca1b66362d(page:)
    page.route("**/*", -> (route,_) { route.abort })  # Runs last.
    page.route("**/*", -> (route,_) { route.fallback })  # Runs second.
    page.route("**/*", -> (route,_) { route.fallback })  # Runs first.
  end

  # Route#fallback
  def example_2b4eca732c7ed8d0d22b23cd55d462cdd20bfc2f94f19640e744e265f53286ca(page:)
    # Handle GET requests.
    def handle_post(route, request)
      if request.method != "GET"
        route.fallback
        return
      end

      # Handling GET only.
      # ...
    end

    # Handle POST requests.
    def handle_post(route)
      if request.method != "POST"
        route.fallback
        return
      end

      # Handling POST only.
      # ...
    end

    page.route("**/*", handle_get)
    page.route("**/*", handle_post)
  end

  # Route#fallback
  def example_1622b8b89837489dedec666cb29388780382f6e997246b261aed07fb60c70cd8(page:)
    def handle(route, request)
      # override headers
      headers = request.headers
      headers['foo'] = 'bar' # set "foo" header
      headers['user-agent'] = 'Unknown Browser' # modify user-agent
      headers.delete('bar') # remove "bar" header

      route.fallback(headers: headers)
    end
    page.route("**/*", method(:handle))
  end

  # Route#fetch
  def example_62dfcdbf7cb03feca462cfd43ba72022e8c7432f93d9566ad1abde69ec3f7666(page:)
    def handle(route, request)
      response = route.fetch
      json = response.json
      json["message"]["big_red_dog"] = []

      route.fulfill(response: response, json: json)
    end
    page.route("https://dog.ceo/api/breeds/list/all", method(:handle))
  end

  # Route#fulfill
  def example_6d2dfd4bb5c8360f8d80bb91c563b0bd9b99aa24595063cf85e5a6e1b105f89c(page:)
    page.route("**/*", ->(route, request) {
      route.fulfill(
        status: 404,
        contentType: 'text/plain',
        body: 'not found!!',
      )
    })
  end

  # Route#fulfill
  def example_c77fd0986d0b74c905cd9417756c76775e612cc86410f9a5aabc5b46d233d150(page:)
    page.route("**/xhr_endpoint", ->(route, _) { route.fulfill(path: "mock_data.json") })
  end

  # Selectors
  def example_a1cd3939b9af300fdf06f296bb66176d84c00edb31cae728310fa823f22691f8(playwright:)
    tag_selector = <<~JAVASCRIPT
    {
        // Returns the first element matching given selector in the root's subtree.
        query(root, selector) {
            return root.querySelector(selector);
        },
        // Returns all elements matching given selector in the root's subtree.
        queryAll(root, selector) {
            return Array.from(root.querySelectorAll(selector));
        }
    }
    JAVASCRIPT

    # Register the engine. Selectors will be prefixed with "tag=".
    playwright.selectors.register("tag", script: tag_selector)
    playwright.chromium.launch do |browser|
      page = browser.new_page()
      page.content = '<div><button>Click me</button></div>'

      # Use the selector prefixed with its name.
      button = page.locator('tag=button')
      # Combine it with other selector engines.
      page.locator('tag=div').get_by_text('Click me').click

      # Can use it in any methods supporting selectors.
      button_count = page.locator('tag=button').count
      button_count # => 1
    end
  end

  # Tracing
  def example_4c3e7d3ff5866cd7fc56ca68dc38333760d280ebbcc3038295f985a9e8f47077(browser:)
    browser.new_context do |context|
      context.tracing.start(screenshots: true, snapshots: true)
      page = context.new_page
      page.goto('https://playwright.dev')
      context.tracing.stop(path: 'trace.zip')
    end
  end

  # Tracing#start
  def example_89f1898bef60f89ccf36656f6471cc0d2296bfd8cad633f1b8fd22ba4b4f65da(context:)
    context.tracing.start(name: 'trace', screenshots: true, snapshots: true)
    page = context.new_page
    page.goto('https://playwright.dev')
    context.tracing.stop(path: 'trace.zip')
  end

  # Tracing#start_chunk
  def example_e04b4e47771d459712f345ce14b805815a7240ddf2b30b0ae0395d4f62741043(context:)
    context.tracing.start(name: "trace", screenshots: true, snapshots: true)
    page = context.new_page
    page.goto("https://playwright.dev")

    context.tracing.start_chunk
    page.get_by_text("Get Started").click
    # Everything between start_chunk and stop_chunk will be recorded in the trace.
    context.tracing.stop_chunk(path: "trace1.zip")

    context.tracing.start_chunk
    page.goto("http://example.com")
    # Save a second trace file with different actions.
    context.tracing.stop_chunk(path: "trace2.zip")
  end

  # Worker
  def example_29716fdd4471a97923a64eebeee96330ab508226a496ae8fd13f12eb07d55ee6(page:)
    def handle_worker(worker)
      puts "worker created: #{worker.url}"
      worker.once("close", -> (w) { puts "worker destroyed: #{w.url}" })
    end

    page.on('worker', method(:handle_worker))

    puts "current workers:"
    page.workers.each do |worker|
      puts "    #{worker.url}"
    end
  end
end
