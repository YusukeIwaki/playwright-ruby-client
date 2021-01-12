[![Gem Version](https://badge.fury.io/rb/playwright-ruby-client.svg)](https://badge.fury.io/rb/playwright-ruby-client)

# playwright-ruby-client

A Ruby client for Playwright driver.

Note: Currently, this Gem is just a PoC (Proof of Concept). If you want to develop browser-automation for Chrome with Ruby, consider using [puppeteer-ruby](https://github.com/YusukeIwaki/puppeteer-ruby)

## Getting Started

At this point, playwright-ruby-client doesn't include the downloader of playwright-cli, so **we have to install [playwright-cli](https://github.com/microsoft/playwright-cli) in advance**.

```sh
npm install playwright-cli
./node_modules/.bin/playwright-cli install
```

and then, set `playwright_cli_executable_path: ./node_modules/.bin/playwright-cli` at `Playwright.create`.

Instead of npm install, you can also directly download playwright driver from playwright.azureedge.net/builds/. The URL can be easily detected from [here](https://github.com/microsoft/playwright-python/blob/79f6ce0a6a69c480573372706df84af5ef99c4a4/setup.py#L56-L61)

### Capture a site

```ruby
require 'playwright'

Playwright.create(playwright_cli_executable_path: '/path/to/playwright-cli') do |playwright|
  playwright.chromium.launch(headless: false) do |browser|
    page = browser.new_page
    page.goto('https://github.com/YusukeIwaki')
    page.screenshot(path: './YusukeIwaki.png')
  end
end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Playwright project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/playwright-ruby-client/blob/master/CODE_OF_CONDUCT.md).
