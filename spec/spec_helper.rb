# frozen_string_literal: true

require 'bundler/setup'
require 'playwright'
require 'timeout'
require 'tmpdir'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.define_derived_metadata(file_path: %r(/spec/development/generate_api/)) do |metadata|
    metadata[:type] = :generate_api
  end

  config.before(:context, type: :generate_api) do
    require './development/generate_api'
  end

  config.define_derived_metadata(file_path: %r(/spec/integration/)) do |metadata|
    metadata[:type] = :integration
  end

  browser_type = :chromium
  BROWSER_TYPES = %i(chromium webkit firefox)
  if BROWSER_TYPES.include?(ENV['BROWSER']&.to_sym)
    browser_type = ENV['BROWSER'].to_sym
  end

  config.around(:each, type: :integration) do |example|
    @playwright_browser_type_param = browser_type

    block = ->(playwright) {
      @playwright_playwright = playwright
      @playwright_browser_type = playwright.send(@playwright_browser_type_param)

      @playwright_browser_type.launch do |browser|
        @playwright_browser = browser

        if ENV['CI']
          # Every integration test case should spend less than 20sec, in CI.
          Timeout.timeout(20) { example.run }
        else
          example.run
        end
      end
    }

    if ENV['PLAYWRIGHT_WS_ENDPOINT']
      Playwright.connect_to_playwright_server(ENV['PLAYWRIGHT_WS_ENDPOINT'], &block)
    else
      Playwright.create(playwright_cli_executable_path: ENV['PLAYWRIGHT_CLI_EXECUTABLE_PATH'], &block)
    end
  end

  module IntegrationTestCaseMethods
    def playwright
      @playwright_playwright or raise NoMethodError.new('undefined method "playwright"')
    end

    def browser_type
      @playwright_browser_type or raise NoMethodError.new('undefined method "browser_type"')
    end

    def browser
      @playwright_browser or raise NoMethodError.new('undefined method "browser"')
    end

    def with_context(**kwargs, &block)
      unless @playwright_browser
        raise '@playwright_browser must not be null.'
      end
      @playwright_browser.new_context(**kwargs, &block)
    end

    def with_page(**kwargs, &block)
      unless @playwright_browser
        raise '@playwright_browser must not be null.'
      end
      @playwright_browser.new_page(**kwargs, &block)
    end

    def give_it_a_chance_to_resolve(page)
      5.times do
        sleep 0.04 # wait a bit for avoiding `undefined:1` error.
        page.evaluate('() => new Promise(f => requestAnimationFrame(() => requestAnimationFrame(f)))')
      end
    end

    def sleep_a_bit_for_race_condition
      sleep 0.5
    end

    def remote?
      !!ENV['PLAYWRIGHT_WS_ENDPOINT']
    end
  end
  BROWSER_TYPES.each do |type|
    IntegrationTestCaseMethods.send(:define_method, "#{type}?") { @playwright_browser_type_param == type }
  end
  config.include IntegrationTestCaseMethods, type: :integration

  #   it 'can connect to /awesome', sinatra: true do
  #     url = "#{server_prefix}/awesome" # => http://localhost:4567/awesome
  #
  test_with_sinatra = Module.new do
    attr_reader :ws_url, :server_prefix, :server_cross_process_prefix, :server_empty_page, :server_port, :sinatra
  end
  config.include(test_with_sinatra, sinatra: true)

  # ref: https://devcenter.heroku.com/articles/ruby-websockets
  class WsApp
    KEEPALIVE_TIME = 15 # in seconds

    def initialize(app)
      @app = app
    end

    def call(env)
      # require here for avoiding Windows CI failure in example spec.
      require 'faye/websocket'
      if Faye::WebSocket.websocket?(env) && env['PATH_INFO'] == '/ws'
        ws = Faye::WebSocket.new(env, nil, { ping: KEEPALIVE_TIME })

        ws.on(:open) do |event|
          ws.send('incoming')
        end

        ws.on(:message) do |event|
          case event.data
          when 'echo-bin'
            ws.send([4, 2])
            ws.close
          when 'echo-text'
            ws.send('text')
            ws.close
          when 'close'
            ws.close
          else
            puts "[WebSocket#on_message] message=#{event.data}"
          end
        end

        ws.on(:close) do |event|
          ws = nil
        end

        # Return async Rack response
        ws.rack_response
      else
        @app.call(env)
      end
    end
  end

  if ENV['CI']
    module PumaEventsLogSuppressing
      ACCEPT= [
        /^\* Listening on (http|ssl)/,
      ]

      def log(str)
        if ACCEPT.any? { |regex| regex.match?(str) }
          super
        else
          # suppress log
        end
      end
    end
    require 'puma/events'
    Puma::Events.prepend(PumaEventsLogSuppressing)
  end

  config.around(sinatra: true) do |example|
    require 'net/http'
    require 'sinatra/base'

    sinatra_app = Class.new(Sinatra::Base) do
      # Change the priority of static file routing.
      # Original impl is here:
      # https://github.com/sinatra/sinatra/blob/v2.1.0/lib/sinatra/base.rb
      #
      # Dispatch a request with error handling.
      def dispatch!
        # Avoid passing frozen string in force_encoding
        @params.merge!(@request.params).each do |key, val|
          next unless val.respond_to?(:force_encoding)
          val = val.dup if val.frozen?
          @params[key] = force_encoding(val)
        end

        invoke do
          filter! :before do
            @pinned_response = !@response['Content-Type'].nil?
          end
          route!
          static! if settings.static? && (request.get? || request.head?)

          route_missing_really!
        end
      rescue ::Exception => boom
        invoke { handle_exception!(boom) }
      ensure
        begin
          filter! :after unless env['sinatra.static_file']
        rescue ::Exception => boom
          invoke { handle_exception!(boom) } unless @env['sinatra.error']
        end
      end

      alias_method :route_missing_really!, :route_missing

      def route_missing
        # Do nothing when called in #route!
      end
    end

    sinatra_app.disable(:protection)
    sinatra_app.set(:public_folder, File.join(__dir__, 'assets'))
    sinatra_app.use(WsApp) if example.metadata[:web_socket]

    (8000..8010).each do |server_port|
      @ws_url = "ws://localhost:#{server_port}/ws"
      @server_prefix = "http://localhost:#{server_port}"
      @server_cross_process_prefix = "http://127.0.0.1:#{server_port}"
      @server_empty_page = "#{@server_prefix}/empty.html"
      @server_port = server_port

      port_is_used = Socket.tcp('localhost', server_port, connect_timeout: 1) { true } rescue false
      break unless port_is_used
    end

    sinatra_app.get('/_ping') { '_pong' }

    if example.metadata[:tls]
      @server_prefix = "https://localhost:#{@server_port}"
      @server_empty_page = "#{@server_prefix}/empty.html"

      base_path = File.join(__dir__, 'assets/client-certificates/server')
      key_path = File.join(base_path, 'server_key.pem')
      cert_path = File.join(base_path, 'server_cert.pem')
      ca_path = File.join(base_path, 'server_cert.pem')
      uri = URI('ssl://localhost')
      uri.query = URI.encode_www_form(
        key: key_path,
        cert: cert_path,
        ca: ca_path,
        verify_mode: 'force_peer',
      )
      bind = uri.to_s
    else
      bind = '127.0.0.1'
    end

    # Start server and wait for server ready.
    # FIXME should change port when Errno::EADDRINUSE
    Thread.new(@server_port) { |port| sinatra_app.run!(port: port, bind: bind) }
    Timeout.timeout(3) do
      loop do
        begin
          if example.metadata[:tls]
            Net::HTTP.start('localhost', @server_port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
              http.get('/_ping')
            end
          else
            Net::HTTP.get(URI("#{server_prefix}/_ping"))
          end
          break
        rescue Errno::ECONNRESET, OpenSSL::SSL::SSLError, EOFError
          # In this case socket is connected but just SSL client cert is not provided.
          break
        rescue Errno::EADDRNOTAVAIL
          sleep 1
        rescue Errno::ECONNREFUSED
          sleep 0.1
        end
      end
    end

    if defined?(Puma::Launcher)
      # Puma::Launcher consumes SIGINT.
      # For stopping execution immidiately by Ctrl+C,
      # raise SignalException manually here.
      Signal.trap(:INT) do
        raise SignalException.new('INT')
      end
    else
      raise 'Consider removing this if puma is no longer used'
    end

    begin
      @sinatra = sinatra_app
      example.run
    ensure
      sinatra_app.quit!
    end
  end
end
