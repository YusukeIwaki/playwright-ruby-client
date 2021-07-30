---
sidebar_position: 7
---

# Playwright on Alpine Linux

**NOTE: This feature is EXPERIMENTAL.**

Playwright actually requires a permission for shell command execution, and many run-time dependencies for each browser.

![all-in-one](https://user-images.githubusercontent.com/11763113/124934388-9c9c9100-e03f-11eb-8f13-324afac3be2a.png)

This all-in-one architecture is reasonable for browser automation in our own computers.

However we may have trouble with bringing Playwright into:

* Docker
  * Alpine Linux
* Serverless computing
  * AWS Lambda
  * Google Cloud Functions
* PaaS
  * Heroku
  * Google App Engine

This article introduces a way to separate environments into client (for executing Playwright script) and server (for working with browsers). The main use-case assumes Docker (using Alpine Linux), however the way can be applied also into other use-cases.

## Overview

Playwrignt Ruby client is running on Alpine Linux. It just sends/receives JSON messages of Playwright-protocol via WebSocket.

Playwright server is running on a container of [official Docker image](https://hub.docker.com/_/microsoft-playwright). It just operates browsers in response to the JSON messages from WebSocket.

![overview](https://user-images.githubusercontent.com/11763113/124934448-ad4d0700-e03f-11eb-942e-b9f3282bb703.png)

## Playwright client

Many example uses `Playwright#create`, which internally uses Pipe (stdin/stdout) transport for Playwright-protocol messaging. Instead, **just use `Playwright#connect_to_playwright_server(endpoint)`** for WebSocket transport.

```ruby {3}
require 'playwright'

Playwright.connect_to_playwright_server('wss://example.com:8888/ws') do |playwright|
  playwright.chromium.launch do |browser|
    page = browser.new_page
    page.goto('https://github.com/microsoft/playwright')
    page.screenshot(path: 'github-microsoft-playwright.png')
  end
end
```

`wss://example.com:8888/ws` is an example of endpoint URL of the Playwright server. In local development environment, it is typically `"ws://127.0.0.1:#{port}/ws"`.

## Playwright server

With the [official Docker image](https://hub.docker.com/_/microsoft-playwright) or in the local development environment with Node.js, just execute `npx playwright install && npx playwright run-server $PORT`. (`$PORT` is a port number of the server)

If custom Docker image is preferred, build it as follows:

```Dockerfile
FROM mcr.microsoft.com/playwright:focal

WORKDIR /root
RUN npm install playwright@1.12.3 && ./node_modules/.bin/playwright install

ENV PORT 8888
CMD ["./node_modules/.bin/playwright", "run-server", "$PORT"]
```

## Debugging for connection

The client and server are really quiet. This chapter shows how to check if the communication on the WebSocket works well or not.

### Show JSON message on client

Just set an environment variable `DEBUG=1`.

```
DEBUG=1 bundle exec ruby some-automation-with-playwright.rb
```


### Enable verbose logging on server

Just set an environment variable `DEBUG=pw:*` or `DEBUG=pw:server`

```
DEBUG=pw:* npx playwright run-server 8888
```

See [the official documentation](https://playwright.dev/docs/debug/#verbose-api-logs) for details.
