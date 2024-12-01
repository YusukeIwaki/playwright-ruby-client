# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'
require './development/generate_api/example_codes'

RSpec.describe 'example' do
  include ExampleCodes

  it 'should browse playwright.dev' do
    with_page do |page|
      page.goto('https://playwright.dev/')
      expect(page.evaluate('() => document.body.textContent')).to include('Playwright')
    end
  end

  it 'should take a screenshot' do
    with_page do |page|
      with_network_retry { page.goto('https://github.com/YusukeIwaki') }
      tmpdir = Dir.mktmpdir
      begin
        path = File.join(tmpdir, 'YusukeIwaki.png')
        page.screenshot(path: path)
        expect(File.open(path, 'rb').read.size).to be > 1000
      ensure
        FileUtils.remove_entry(tmpdir, true)
      end
    end
  end

  it 'should input text and grab DOM elements', skip: ENV['CI'] do
    with_page do |page|
      page = browser.new_page
      page.viewport_size = { width: 1280, height: 800 }
      with_network_retry { page.goto('https://github.com/') }

      page.get_by_placeholder("Search or jump to...").click
      page.locator('input[name="query-builder-test"]').click

      expect(page.keyboard).to be_a(::Playwright::Keyboard)

      page.keyboard.type("playwright")
      page.expect_navigation {
        page.keyboard.press("Enter")
      }

      list = page.get_by_test_id('results-list').locator('.search-title')

      # wait for item to appear
      list.first.wait_for

      # list them
      list.locator('.search-title').all.each do |item|
        title = item.text_content
        puts("==> #{title}")
      end
    end
  end

  it 'should enable debug console', skip: ENV['CI'] do
    with_context do |context|
      context.enable_debug_console!
      page = context.new_page
      page.goto('https://example.com')
    end
  end

  it 'should evaluate expression' do
    with_page do |page|
      expect(page.evaluate('2 + 3')).to eq(5)
    end
  end

  it 'should evaluate function returning object' do
    with_page do |page|
      expect(page.evaluate('() => { return { a: 3, b: 4 } }')).to eq({'a' => 3, 'b' => 4})
    end
  end

  it 'exposes guid for Page' do
    with_page do |page|
      expect(browser.contexts.map(&:pages).flatten.map(&:guid)).to include(page.guid)
    end
  end

  it 'returns the same Playwright API instance for the same impl' do
    with_page do |page|
      expect(page.context.pages.last).to equal(page)
      expect(browser.new_page).not_to equal(page)
    end
  end

  it 'should auto-wait for visible' do
    with_page do |page|
      page.content = '<p>loading</p>'
      div = page.locator('div')
      promise = Concurrent::Promises.future {
        puts "TRY CLICKING"
        div.click
        puts "DONE!!"
      }
      sleep 1
      page.evaluate("(html) => document.body.innerHTML=html", arg: "<div onclick='this.innerText=\"clicked\"'>content</div>")
      promise.value!
      expect(div.text_content).to eq('clicked')
    end
  end

  context 'for ExampleCodes' do
    it 'should work with Accessibility' do
      skip unless chromium?

      with_page do |page|
        page.content = <<~HTML
        <head>
          <title>Accessibility Test</title>
        </head>
        <body>
          <h1>Inputs</h1>
          <input placeholder="Empty input" autofocus />
          <input placeholder="readonly input" readonly />
          <input placeholder="disabled input" disabled />
          <input aria-label="Input with whitespace" value="  " />
          <input value="value only" />
          <input aria-placeholder="placeholder" value="and a value" />
          <div aria-hidden="true" id="desc">This is a description!</div>
          <input aria-placeholder="placeholder" value="and a value" aria-describedby="desc" />
        </body>
        HTML
        page.locator('input').first.focus

        example_2e5019929403491cde0c78bed1e0e18e0c86ab423d7ac8715876c4de4814f483(page: page)
        example_3d67a99411b5f924d573427b6f54aff63f7241f2b810959b79948bd3b522404a(page: page)
      end
    end

    it 'should work with BrowserContext#expose_binding' do
      with_context do |context|
        example_ba61d7312419a50eab8b67fd47e467e3b53590e7fd2ee55055fb6d12c94a61e4(browser_context: context)
        example_93e847f70b01456eec429a1ebfaa6b8f5334f4c227fd73e62dd6a7facb48dbbd(browser_context: context)
        example_714719de9c92e66678257180301c2512f8cd69185f53a5121b6c52194f61a871(browser_context: context)
      end
    end

    it 'should work with BrowserContext#route' do
      example_8bee851cbea1ae0c60fba8361af41cc837666490d20c25552a32f79c4e044721(browser: browser)
      example_aa8a83c2ddd0d9a327cfce8528c61f52cb5d6ec0f0258e03d73fad5481f15360(browser: browser)
    end

    it 'should work with BrowserContext#set_geolocation' do
      with_context do |context|
        example_12142bb78171e322de3049ac91a332da192d99461076da67614b9520b7cd0c6f(browser_context: context)
      end
    end

    it 'should work with CDPSession' do
      skip unless chromium?

      with_page do |page|
        example_314a4cc521d931dff12aaf59a90d03d01ed5d1440e3dbddd57e526cb467d0450(page: page)
      end
    end

    it 'should work with Clock' do
      skip unless chromium?

      with_page do |page|
        require 'time'
        example_aa1d7ed6650f37a2ef8a00945f0f328896eae665418b6758a9e24fcc4c7bcd83(page: page) # fast_forward
        example_ce3b9a2e3e9e37774d4176926f5aa8ddf76d8c2b3ef27d8d8f82068dd3720a48(page: page) # run_for
        example_e3bfa88ff84efbef1546730c2046e627141c6cd5f09c54dc2cf0e07cbb17c0b5(page: page) # pause_at
        example_612285ca3970e44df82608ceff6f6b9ae471b0f7860b60916bbaefd327dd2ffd(page: page) # set_fixed_time
        example_1f707241c9dfcb70391f40269feeb3e50099815e43b9742bba738b72defae04f(page: page) # set_system_time
      end
    end

    it 'should work with ConsoleMessage' do
      skip unless chromium?

      with_page do |page|
        example_585cbbd055f47a5d0d7a6197d90874436cd4a2d50a92956723fc69336f8ccee9(page: page)
      end
    end

    it 'should work with Dialog' do
      with_page do |page|
        example_a7dcc75b7aa5544237ac3a964e9196d0445308864d3ce820f8cb8396f687b04a(page: page)
      end
    end

    it 'should work with Download', sinatra: true do
      sinatra.get('/download') do
        headers(
          'Content-Type' => 'application/octet-stream',
          'Content-Disposition' => 'attachment',
        )
        body('Hello world!')
      end

      tmpdir = Dir.mktmpdir
      begin
        with_page(acceptDownloads: true) do |page|
          page.content = "<a href=\"#{server_prefix}/download\">Download file</a>"
          path = example_c247767083cf193df26a39a61a3a8bc19d63ed5c24db91b88c50b7d37975005d(page: page, download_dir: tmpdir)
          expect(File.exist?(path)).to eq(true)

          download = page.expect_download do
            page.get_by_text("Download file").click
          end
          example_66ffd4ef7286957e4294d84b8f660ff852c87af27a56b3e4dd9f84562b5ece02(download: download, download_dir: tmpdir)
          path = File.join(tmpdir, download.suggested_filename)
          expect(File.exist?(path)).to eq(true)
        end
      ensure
        FileUtils.remove_entry(tmpdir, true)
      end
    end

    it 'should work with ElementHandle' do
      with_page do |page|
        page.content = "<a onclick=\"this.innerText='clicked!'\">Click Me</a>"
        example_79d8d3cbe504c5562bfee5b1e40f4dfddf2cca147b57c9dac0249bcf96978263(page: page)
        expect(page.text_content('a')).to eq('clicked!')
      end
    end

    it 'should work with ElementHandle#set_input_files' do
      with_page do |page|
        page.content = "<input type='file' />"
        element = page.query_selector('input')
        element.set_input_files(File.new(__FILE__))
      end
    end

    it 'should work with Frame' do
      with_page do |page|
        example_2bc8a0187190738d8dc7b29c66ad5f9f2187fd1827455e9ceb1e9ace26aaf534(page: page)
      end
    end

    it 'should work with Frame#get_by_label' do
      with_page do |page|
        page.content = <<~HTML
        <input aria-label="Username">
        <label for="password-input">Password:</label>
        <input id="password-input">
        HTML
        example_18ca1d75e8a2404e6a0c269ff926bc1499f15e7dc041441f764ae3bde033b0cf(page: page)
        expect(page.locator('input').first.input_value).to eq('john')
        expect(page.locator('#password-input').input_value).to eq('secret')
      end
    end

    it 'should work with Frame#get_by_placeholder' do
      with_page do |page|
        page.content = '<input type="email" placeholder="name@example.com" />'
        example_c521b79be0a480325f84dc2c110a9803f0d74b2042da32c84660abe90ab7bb37(page: page)
        expect(page.locator('input').input_value).to eq('playwright@microsoft.com')
      end
    end

    it 'should work with Frame#get_by_role' do
      with_page do |page|
        page.content = <<~HTML
        <h3>Sign up</h3>
        <label>
          <input type="checkbox" /> Subscribe
        </label>
        <br/>
        <button>Submit</button>
        HTML
        example_d0da510d996da8a4b3e0505412b0b651049ab11b56317300ba3dc52e928500b3(page: page)
      end
    end

    it 'should work with Frame#get_by_test_id' do
      with_page do |page|
        page.content = '<button data-testid="directions" onclick="this.innerText=123">Itinéraire</button>'
        example_291583061a6a67f91ea5f926eac4b5cd6c351d7009ddfef39b52efba03909ca0(page: page)
        expect(page.text_content('button')).to eq('123')
      end
    end

    it 'should work with Frame#get_by_title' do
      with_page do |page|
        page.content = "<span title='Issues count'>25 issues</span>"
        text = example_0aecb761822601bd6adf174c0aeb9db69bf4880a62eb4a1cdeb67c2f57c7149e(page: page)
        expect(text).to eq('25 issues')
      end
    end

    it 'should work with JSHandle#properties' do
      with_page do |page|
        with_network_retry do
          example_49eec7966dd7a081de100e4563b110174e5e2dc4b89959cd14894097080346dc(page: page)
        end
      end
    end

    it 'should work with Keyboard' do
      with_page do |page|
        page.content = '<input type="text"/>'
        page.focus('input')
        example_575870a45e4fe08d3e06be3420e8a11be03f85791cd8174f27198c016031ae72(page: page)
        expect(page.input_value('input')).to eq('Hello!')

        page.fill('input', '')
        example_a4f00f0cd486431b7eca785304f4e9715522da45b66dda7f3a5f6899b889b9fd(page: page)
        expect(page.input_value('input')).to eq('AA')
      end
    end

    it 'should work with Keyboard#press' do
      with_page do |page|
        with_network_retry do
          example_88943eb85c1ac7c261601e6edbdead07a31c2784326c496e10667ede1a853bab(page: page)
        end
      end
    end

    it 'should work with Keyboard#type' do
      with_page do |page|
        page.content = '<input type="text"/>'
        page.focus('input')
        example_d9ced919f139961fd2b795c71375ca96f788a19c1f8e1479c5ec905fb5c02d43(page: page)
        expect(page.input_value('input')).to eq('HelloWorld')
      end
    end

    it 'should work with Locator' do
      with_page do |page|
        page.content = "<button onclick=\"this.innerText='clicked!'\">Submit</button>"
        example_9f72eed0cd4b2405e6a115b812b36ff2624e889f9086925c47665333a7edabbc(page: page)
        expect(page.eval_on_selector('button', 'el => el.innerText')).to eq('clicked!')
      end
    end

    it 'should work with Locator/strictness' do
      with_page do |page|
        page.content = "<button onclick=\"this.innerText='clicked!'\">Submit</button>"
        expect(example_5c129e11b91105b449e998fc2944c4591340eca625fe27a86eb555d5959dfc14(page: page)).to eq(1)
        expect(page.eval_on_selector('button', 'el => el.innerText')).to eq('clicked!')
      end

      with_page do |page|
        page.content = "<button>1</button><button>2</button>"
        expect { example_5c129e11b91105b449e998fc2944c4591340eca625fe27a86eb555d5959dfc14(page: page) }.to raise_error(/strict mode violation/)
      end
    end

    it 'should work with Locator#and' do
      with_page do |page|
        page.content = <<~HTML
        <div>
          <button id="btn_cancel" title='No thank you'>Cancel</button>
          <button id="btn_ok" title='Subscribe'>OK - sub</button>
        </div>
        HTML
        button = example_0174039af5c928df43c04ef148ea798c5dcc7b6fc4ce4abc3a99a300f372a104(page: page)
        expect(button['id']).to eq('btn_ok')
      end
    end

    it 'should work with Locator#count' do
      with_page do |page|
        page.content = <<~HTML
        <ul>
          <li>Item 1</li>
          <li>Item 2</li>
          <li>Item 3</li>
          <li>Item 4</li>
        </ul>
        HTML
        expect(example_a711e425f2e4fe8cdd4e7ff99d609e607146ddb7b1fb5c5d8978bd0555ac1fcd(page: page)).to eq(4)
      end
    end

    it 'should work with Locator#evaluate_all' do
      with_page do |page|
        page.content = <<~HTML
        <body>
        #{10.times.map { |i| "<div>#{i}</div>" } }
        </body>
        HTML
        expect(example_877178e12857c7b3ef09f6c50606489c9d9894220622379b72e1e180a2970b96(page: page)).to eq(true)

        page.content = <<~HTML
        <body>
        #{9.times.map { |i| "<div>#{i}</div>" } }
        </body>
        HTML
        expect(example_877178e12857c7b3ef09f6c50606489c9d9894220622379b72e1e180a2970b96(page: page)).to eq(false)
      end
    end

    it 'should work with Locator#get_by_text' do
      with_page do |page|
        example_cbf4890335f3140b7b275bdad85b330140e5fbb21e7f4b89643c73115ee62a17(page: page)
      end
    end

    context 'LocatorAssertions' do
      require 'playwright/test'
      include Playwright::Test::Matchers

      it 'should work' do
        with_page do |page|
          example_eff0600f575bf375d7372280ca8e6dfc51d927ced49fbcb75408c894b9e0564e(page: page)
        end
      end

      it 'should work with #be_attached' do
        with_page do |page|
          example_781b6f44dd462fc3753b3e48d6888f2ef4d0794253bf6ffb4c42c76f5ec3b454(page: page)
        end
      end
    end

    it 'should work with Page#dispatch_event' do
      with_page do |page|
        example_9220b94fd2fa381ab91448dcb551e2eb9806ad331c83454a710f4d8a280990e8(page: page)
        example_9b4482b7243b7ce304d6ce8454395e23db30f3d1d83229242ab7bd2abd5b72e0(page: page)
      end
    end

    it 'should work with Page#emulate_media' do
      with_page do |page|
        example_df304caf6c61f6f44b3e2b0006a7e05552362a47b17c9ba227df76e918d88a5c(page: page)
        example_8abc1c4dd851cb7563f1f6b6489ebdc31d783b4eadbb48b0bfa0cfd2a993f788(page: page)
      end
    end

    it 'should work with Page#press' do
      with_page do |page|
        with_network_retry do
          example_aa4598bd7dbeb8d2f8f5c0aa3bdc84042eb396de37b49f8ff8c1ea39f080f709(page: page)
        end
      end
    end

    it 'should work with Page#expect_request' do
      with_page do |page|
        with_network_retry do
          example_0c91be8bc12e1e564d14d37e5e0be8d4e56189ef1184ff34ccc0d92338ad598b(page: page)
        end
      end
    end

    it 'should work with Page#expect_response' do
      with_page do |page|
        with_network_retry do
          example_13746919ebdd1549604b1a2c4a6cc9321ba9d0728c281be6f1d10d053fc44108(page: page)
        end
      end
    end

    it 'should work with Page#wait_for_selector' do
      with_page do |page|
        with_network_retry do
          example_903c7325fd65fcdf6f22c77fc159922a568841abce60ae1b7c54ab5837401862(page: page)
        end
      end
    end

    context 'PageAssertions' do
      require 'playwright/test'
      include Playwright::Test::Matchers

      it 'should work with PageAssertions' do
        with_page do |page|
          with_network_retry do
            example_8bd802801208367a0779634066c3f38ec5326b1ca16fc94eb5621dca49d1f649(page: page)
          end
          page.goto('https://example.com/item/checkout.html')
          example_87c22b447771ce189eebbfd6163474cb36badeb87ce402dcf88c4042335c31e9(page: page)
          page.evaluate('() => { document.title = "Item 1: checkout" }')
          example_b4ad3d990aa1e6825a4b5b711e89d712607aee31a03393c3cd1a9c3f6d39f124(page: page)
        end
      end
    end

    it 'should work with Request#redirected_to', sinatra: true do
      sinatra.get('/302') do
        redirect to('/empty.html'), 302
      end

      with_page do |page|
        req = with_network_retry { page.goto("#{server_prefix}/302").request }
        req2 = with_network_retry { example_922623f4033e7ec2158787e54a8554655f7e1e20a024e4bf4f69337f781ab88a(request: req) }
        expect(req2).to eq(req)
      end
    end

    it 'should work with Request#timing' do
      with_page do |page|
        with_network_retry do
          example_e2a297fe95fd0699b6a856c3be2f28106daa2615c0f4d6084f5012682a619d20(page: page)
        end
      end
    end

    it 'should work with Route#continue', sinatra: true do
      sinatra.get('/empty2.html') do
        headers(
          'foo' => 'FOO',
          'bar' => 'BAR',
        )
        body('')
      end

      with_page do |page|
        example_7e4301435099b6132736c17a7bc117a684c61411bdf344a1e10700f86bdd293d(page: page)
        url = "#{server_cross_process_prefix}/empty2.html"
        page.content = "<a href=\"#{url}\">link</a>"
        response = page.expect_request(url) { page.click('a') }
        headers = response.all_headers
        expect(headers['foo']).to eq('bar')
        expect(headers['user-agent']).to eq('Unknown Browser')
      end
    end

    it 'should work with Route#fallback', sinatra: true do
      sinatra.get('/empty2.html') do
        headers(
          'foo' => 'FOO',
          'bar' => 'BAR',
        )
        body('')
      end

      with_page do |page|
        example_20e6411032d6255108d5adc862d7a215cbca591255ca60fb3d91895c65229f0d(page: page)
        url = "#{server_cross_process_prefix}/empty2.html"
        page.content = "<a href=\"#{url}\">link</a>"
        response = page.expect_request(url) { page.click('a') }
        headers = response.all_headers
        expect(headers['foo']).to eq('bar')
        expect(headers['user-agent']).to eq('Unknown Browser')
      end
    end

    it 'should work with Route#fetch', sinatra: true do
      with_page do |page|
        example_62dfcdbf7cb03feca462cfd43ba72022e8c7432f93d9566ad1abde69ec3f7666(page: page)
        response = page.goto('https://dog.ceo/api/breeds/list/all')
        json = response.json
        expect(json["message"]["big_red_dog"]).to be_a(Array)
        expect(json["message"]["big_red_dog"]).to be_empty
      end
    end

    it 'should work with Route#fulfill', sinatra: true do
      with_page do |page|
        example_6d2dfd4bb5c8360f8d80bb91c563b0bd9b99aa24595063cf85e5a6e1b105f89c(page: page)
        page.content = "<a href=\"#{server_cross_process_prefix}/empty.html\">link</a>"
        response = page.expect_navigation { page.click('a') }
        expect(response.status).to eq(404)
        expect(response.body).to eq('not found!!')
      end
    end

    it 'should work with Selector' do
      skip unless chromium?
      skip if remote?

      expect(example_3e739d4f0e30e20a6a698e0e17605a841c35e65e75aa3c2642f8bfc368b33f9e(playwright: playwright)).to eq(1)
    end

    it 'should work with Tracing' do
      pending if remote? # localUtils is not available in remote.

      with_context do |context|
        example_c74a3f913c302bc9bf81146db28832bdfe33ab7721f1343efb1e207bb070abce(context: context)
      end
      with_context do |context|
        example_9bd098f4f0838dc7408dffc68bff0351714717a1fed7a909801dc263dfff2a17(context: context)
      end
    end

    it 'should work with Worker', skip: ENV['CI'] do
      with_page do |page|
        worker_objs = []
        page.expect_worker do
          worker_objs << page.evaluate_handle("() => new Worker(URL.createObjectURL(new Blob(['1'], {type: 'application/javascript'})))")
        end

        example_29716fdd4471a97923a64eebeee96330ab508226a496ae8fd13f12eb07d55ee6(page: page)

        page.expect_worker do
          worker_objs << page.evaluate_handle("() => new Worker(URL.createObjectURL(new Blob(['2'], {type: 'application/javascript'})))")
        end

        expect(page.workers.size).to eq(2)
        page.evaluate('workerObjs => workerObjs.forEach(worker => worker.terminate())', arg: worker_objs)
        expect(page.workers).to be_empty
      end
    end
  end
end
