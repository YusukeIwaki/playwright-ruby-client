---
sidebar_position: 1
---

# Install Playwright CLI

`playwright-ruby-client` doesn't include Playwright. Install Node.js and the compatible `playwright-core` npm package in advance, then pass its CLI path to `Playwright.create`.

The npm package version must match `Playwright::COMPATIBLE_PLAYWRIGHT_VERSION`. Using an unversioned `npx playwright` command can install an incompatible version.

:::note

Also the article [Playwright on Alpine Linux](./playwright_on_alpine_linux) would be helpful if you plan to

- Build a browser server/container like Selenium Grid
- Run automation scripts on Alpine Linux

:::

## Using `npm install`

```shell
$ export PLAYWRIGHT_CLI_VERSION=$(bundle exec ruby -e 'require "playwright/version"; puts Playwright::COMPATIBLE_PLAYWRIGHT_VERSION')
$ npm install "playwright-core@$PLAYWRIGHT_CLI_VERSION"
$ ./node_modules/.bin/playwright-core install
```

Then use the installed CLI when creating the Ruby client:

```ruby
Playwright.create(playwright_cli_executable_path: './node_modules/.bin/playwright-core') do |playwright|
  # ...
end
```
