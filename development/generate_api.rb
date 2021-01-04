# https://github.com/microsoft/playwright-python/blob/0b4a980fed366c4c1dee9bfcdd72662d629fdc8d/scripts/generate_api.py#L191
ALL_TYPES = %w[
    Request
    Response
    Route
    WebSocket
    Keyboard
    Mouse
    Touchscreen
    JSHandle
    ElementHandle
    Accessibility
    FileChooser
    Frame
    Worker
    Selectors
    ConsoleMessage
    Dialog
    Download
    Video
    BindingCall
    Page
    BrowserContext
    CDPSession
    ChromiumBrowserContext
    Browser
    BrowserType
    Playwright
]

require 'bundler/setup'
require 'dry/inflector'
require 'erb'
require 'json'
require 'playwright/event_emitter'
require 'playwright/channel_owner'

Dir[File.join(__dir__, 'generate_api', 'models', '*.rb')].each { |f| require f }
Dir[File.join(__dir__, 'generate_api', 'views', '*.rb')].each { |f| require f }

api_json = JSON.parse(File.read(File.join(__dir__, 'api.json')))
inflector = Dry::Inflector.new

ALL_TYPES.each do |class_name|
  doc_json = api_json[class_name]
  doc = doc_json ? ClassDoc.new(doc_json, root: api_json) : nil
  klass = Playwright::ChannelOwners.const_get(class_name) rescue nil

  view =
    if klass
      if doc
        ImplementedClassWithDoc.new(doc, klass, inflector)
      else
        ImplementedClassWithoutDoc.new(klass, inflector)
      end
    else
      if doc
        UnimplementedClassWithDoc.new(doc, inflector)
      else
        raise "#{class_name} is not implemented nor not in api-docs. Something is wrong."
      end
    end

  filename = "#{inflector.underscore(class_name)}.rb"
  File.open(File.join('.', 'lib', 'playwright_api', filename), 'w') do |f|
    view.lines.each do |line|
      f.write(line)
      f.write("\n")
    end
  end
end
