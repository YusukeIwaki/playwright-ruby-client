module Playwright
  # https://github.com/microsoft/playwright/blob/v1.64.0/packages/playwright-core/src/client/webmcp.ts
  define_api_implementation :WebMCPImpl do
    def initialize(frame)
      @frame = frame
    end

    def tools(timeout: nil)
      @frame.channel.send_message_to_server('webmcpTools', timeout: @frame.send(:_timeout, timeout))
    end

    def call_tool(name, input: nil, timeout: nil)
      result = @frame.channel.send_message_to_server('webmcpCallTool',
        name: name,
        input: JavaScript::ValueSerializer.new(input).serialize,
        timeout: @frame.send(:_timeout, timeout),
      )
      JavaScript::ValueParser.new(result).parse
    end
  end
end
