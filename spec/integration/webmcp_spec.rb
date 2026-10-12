require 'spec_helper'

# https://github.com/microsoft/playwright/blob/release-1.64/tests/library/webmcp.spec.ts
RSpec.describe 'WebMCP', sinatra: true do
  let(:add_schema) do
    { 'type' => 'object', 'properties' => { 'a' => { 'type' => 'number' }, 'b' => { 'type' => 'number' } }, 'required' => %w[a b] }
  end

  let(:add_script) do
    <<~JS
      modelContext.registerTool({
        name: 'add', description: 'Adds two numbers',
        inputSchema: #{JSON.generate(add_schema)},
        annotations: { readOnlyHint: true },
        async execute(input) { return { content: [{ type: 'text', text: String(input.a + input.b) }] }; },
      });
    JS
  end

  before do
    skip 'WebKit does not implement WebMCP' if webkit?
    options = if firefox?
      { firefoxUserPrefs: { 'dom.modelcontext.enabled' => true, 'dom.modelcontext.testing.enabled' => true } }
    else
      { args: ['--enable-features=WebMCP'] }
    end
    @webmcp_browser = browser_type.launch(**options)
    @page = @webmcp_browser.new_page
  end

  after { @webmcp_browser&.close }

  def serve(path, body)
    sinatra.get(path) { "<title>WebMCP</title>#{body}" }
  end

  def register_script(tools)
    "<script>const modelContext = document.modelContext || navigator.modelContext; #{tools}</script>"
  end

  def register_frame_tools(frame, tools)
    # Chromium can leave getTools pending when iframe WebMCP initializes during navigation.
    frame.evaluate("() => { const modelContext = document.modelContext || navigator.modelContext; #{tools} }")
  end

  def text_result(text)
    { 'content' => [{ 'type' => 'text', 'text' => text }] }
  end

  it 'should list tools registered by the page' do
    serve('/', register_script(add_script + "modelContext.registerTool({ name: 'noop', description: 'Does nothing', async execute() {} });"))
    @page.goto(server_prefix)
    expect(@page.webmcp.tools.sort_by { |tool| tool['name'] }).to eq([
      { 'name' => 'add', 'description' => 'Adds two numbers', 'inputSchema' => add_schema, 'annotations' => { 'readOnly' => true } },
      { 'name' => 'noop', 'description' => 'Does nothing' },
    ])
  end

  it 'should report no tools when the page registers none' do
    @page.goto(server_empty_page)
    expect(@page.webmcp.tools).to eq([])
  end

  it 'should call a tool' do
    serve('/', register_script(add_script))
    @page.goto(server_prefix)
    expect(@page.webmcp.call_tool('add', input: { a: 2, b: 40 })).to eq(text_result('42'))
  end

  it 'should return isError results as is' do
    serve('/', register_script("modelContext.registerTool({ name: 'broken', description: 'Always fails', async execute() { return { content: [{ type: 'text', text: 'nope' }], isError: true }; } });"))
    @page.goto(server_prefix)
    expect(@page.webmcp.call_tool('broken')).to eq(text_result('nope').merge('isError' => true))
  end

  it 'should throw when the tool throws' do
    serve('/', register_script("modelContext.registerTool({ name: 'throwing', description: 'Throws', async execute() { throw new Error('boom'); } });"))
    @page.goto(server_prefix)
    expect { @page.webmcp.call_tool('throwing') }.to raise_error(/#{chromium? ? 'the invocation failed' : 'boom'}/)
  end

  it 'should throw for an unknown tool' do
    serve('/', register_script(add_script))
    @page.goto(server_prefix)
    expect { @page.webmcp.call_tool('missing') }.to raise_error { |error|
      expect(error.message).to include('No WebMCP tool named "missing"', 'Available tools: add')
    }
  end

  it 'should time out when the tool does not settle' do
    serve('/', register_script("modelContext.registerTool({ name: 'stuck', description: 'Never resolves', execute() { return new Promise(() => {}); } });"))
    @page.goto(server_prefix)
    expect { @page.webmcp.call_tool('stuck', input: {}, timeout: 500) }.to raise_error(/Timeout 500ms exceeded/)
  end

  it 'should drop tools after navigation' do
    serve('/', register_script(add_script))
    @page.goto(server_prefix)
    expect(@page.webmcp.tools.size).to eq(1)
    @page.goto(server_empty_page)
    expect(@page.webmcp.tools).to eq([])
    expect { @page.webmcp.call_tool('add', input: { a: 1, b: 1 }) }.to raise_error(/The frame does not register any WebMCP tools/)
  end

  it 'should list a tool registered after load' do
    serve('/', register_script(add_script))
    @page.goto(server_prefix)
    expect(@page.webmcp.tools.size).to eq(1)
    @page.evaluate("() => (document.modelContext || navigator.modelContext).registerTool({ name: 'late', description: 'Registered later', async execute() {} })")
    expect(@page.webmcp.tools.map { |tool| tool['name'] }.sort).to eq(%w[add late])
  end

  it 'should list tools while a tool is running' do
    serve('/', register_script(add_script + "modelContext.registerTool({ name: 'gated', description: 'Resolves when released', execute() { return new Promise(resolve => window.release = () => resolve({ content: [{ type: 'text', text: 'released' }] })); } });"))
    @page.goto(server_prefix)
    result = Concurrent::Promises.future { @page.webmcp.call_tool('gated') }
    @page.wait_for_function('() => !!window.release')
    expect(@page.webmcp.tools.size).to eq(2)
    @page.evaluate('() => window.release()')
    expect(result.value!).to eq(text_result('released'))
  end

  it 'should list declarative tools' do
    skip 'Only Chromium implements declarative tools' unless chromium?
    serve('/', '<form toolname="subscribe" tooldescription="Subscribes to the newsletter"><input name="email" type="email"><button>Subscribe</button></form>')
    @page.goto(server_prefix)
    expect(@page.webmcp.tools).to match([a_hash_including(
      'name' => 'subscribe', 'description' => 'Subscribes to the newsletter',
      'inputSchema' => a_hash_including('type' => 'object', 'properties' => { 'email' => { 'type' => 'string' } }),
    )])
    expect { @page.webmcp.call_tool('subscribe', input: { email: 'me@example.com' }, timeout: 500) }.to raise_error(/Timeout 500ms exceeded/)
  end

  it 'should scope tools to their frame' do
    skip 'Firefox does not support WebMCP tools in iframes yet' if firefox?
    serve('/', register_script(add_script) + '<iframe src="/frame.html"></iframe>')
    serve('/frame.html', '')
    @page.goto(server_prefix)
    frame = @page.frames[1]
    register_frame_tools(frame, "modelContext.registerTool({ name: 'subscribe', description: 'Subscribes to the newsletter', async execute() { return { content: [{ type: 'text', text: 'subscribed' }] }; } });")
    expect(@page.webmcp.tools).to match([a_hash_including('name' => 'add')])
    expect(frame.webmcp.tools).to match([a_hash_including('name' => 'subscribe')])
    expect(frame.webmcp.call_tool('subscribe')).to eq(text_result('subscribed'))
    expect { @page.webmcp.call_tool('subscribe') }.to raise_error { |error|
      expect(error.message).to include('No WebMCP tool named "subscribe"', 'Available tools: add')
    }
  end

  it 'should call same-name tools in their own frame' do
    skip 'Firefox does not support WebMCP tools in iframes yet' if firefox?
    echo = ->(text) { "modelContext.registerTool({ name: 'echo', description: 'Echoes', async execute() { return { content: [{ type: 'text', text: '#{text}' }] }; } });" }
    serve('/', register_script(echo.call('main')) + '<iframe src="/frame.html"></iframe>')
    serve('/frame.html', '')
    @page.goto(server_prefix)
    frame = @page.frames[1]
    register_frame_tools(frame, echo.call('frame'))
    expect(@page.webmcp.call_tool('echo')).to eq(text_result('main'))
    expect(frame.webmcp.call_tool('echo')).to eq(text_result('frame'))
  end

  it 'should list and call tools in cross-origin and nested frames' do
    skip 'Firefox does not support WebMCP tools in iframes yet' if firefox?
    echo = ->(text) { "modelContext.registerTool({ name: 'echo-#{text}', description: 'Echoes #{text}', async execute() { return { content: [{ type: 'text', text: '#{text}' }] }; } });" }
    serve('/', register_script(echo.call('main')) + "<iframe allow=\"tools\" src=\"#{server_cross_process_prefix}/frame.html\"></iframe>")
    serve('/frame.html', '<iframe src="/nested.html"></iframe>')
    serve('/nested.html', '')
    @page.goto(server_prefix)
    main, frame, nested = @page.frames
    register_frame_tools(frame, echo.call('frame'))
    register_frame_tools(nested, echo.call('nested'))
    [main, frame, nested].zip(%w[main frame nested]).each do |target, text|
      expect(target.webmcp.tools).to eq([{ 'name' => "echo-#{text}", 'description' => "Echoes #{text}" }])
    end
    expect(frame.webmcp.call_tool('echo-frame')).to eq(text_result('frame'))
    expect(nested.webmcp.call_tool('echo-nested')).to eq(text_result('nested'))
  end
end
