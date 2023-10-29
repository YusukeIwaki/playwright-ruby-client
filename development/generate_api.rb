# https://github.com/microsoft/playwright-python/blob/ab954acef18fba57bb1c114fe2399d3d02a9ecb9/scripts/generate_api.py#L252
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
    Page
    BrowserContext
    CDPSession
    Browser
    BrowserType
    Playwright
    Tracing
    Locator
    FrameLocator
    APIResponse
    APIRequestContext
    APIRequest
    LocatorAssertions
]
EXPERIMENTAL = %w[
  Android
  AndroidDevice
  AndroidInput
  AndroidSocket
  AndroidWebView
]
API_IMPLEMENTATIONS = %w[
  Accessibility
  AndroidInput
  ConsoleMessage
  FileChooser
  Keyboard
  Mouse
  Touchscreen
  Download
  Locator
  FrameLocator
  APIRequest
  APIResponse
  LocatorAssertions
]

require 'bundler/setup'
require 'dry/inflector'
require 'json'
require 'playwright/event_emitter'
require 'playwright/utils'
require 'playwright/channel_owner'
require 'playwright/api_implementation'

Dir[File.join(__dir__, 'generate_api', 'models', '*.rb')].each { |f| require f }
Dir[File.join(__dir__, 'generate_api', 'renderers', '*.rb')].each { |f| require f }

if $0 == __FILE__
  api_json = JSON.parse(File.read(File.join(__dir__, 'api.json')))
  inflector = Dry::Inflector.new

  # Aggregate document and actual implementation.
  target_classes = (ALL_TYPES + EXPERIMENTAL).map do |class_name|
    doc_json = api_json.find { |json| json['name'] == class_name }
    doc = doc_json ? ClassDoc.new(doc_json, root: api_json) : nil

    klass =
      if API_IMPLEMENTATIONS.include?(class_name)
        Playwright.const_get("#{class_name}Impl") rescue nil
      else
        Playwright::ChannelOwners.const_get(class_name) rescue nil
      end

    if klass
      if doc
        ImplementedClassWithDoc.new(doc, klass, inflector)
      else
        ImplementedClassWithoutDoc.new(class_name, klass, inflector)
      end
    else
      if doc
        UnimplementedClassWithDoc.new(doc, inflector)
      else
        raise "#{class_name} is not implemented nor not in api-docs. Something is wrong."
      end
    end
  end

  # Mark as experimental
  target_classes.each do |target_class|
    target_class.mark_as_experimental if EXPERIMENTAL.include?(target_class.class_name)
  end

  PlaywrightApiRenderer.new(target_classes).render
  ApiCoverageRenderer.new(target_classes).render
  ApidocRenderer.new(target_classes).render
  RbsRenderer.new(target_classes).render
end
