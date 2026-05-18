module Playwright
  define_api_implementation :ConsoleMessageImpl do
    def initialize(event, page, worker)
      @event = event
      @page = page
      @worker = worker
    end

    attr_reader :page, :worker

    def type
      @event['type']
    end

    def text
      @event['text']
    end

    def args
      @event['args']&.map do |arg|
        ChannelOwner.from(arg)
      end
    end

    def location
      location = @event['location']
      return location unless location

      {
        'url' => location['url'],
        'line' => location['lineNumber'],
        'column' => location['columnNumber'],
        'lineNumber' => location['lineNumber'],
        'columnNumber' => location['columnNumber'],
      }
    end

    def timestamp
      @event['timestamp']
    end
  end
end
