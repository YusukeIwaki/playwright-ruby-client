[![Gem Version](https://badge.fury.io/rb/playwright-ruby-client.svg)](https://badge.fury.io/rb/playwright-ruby-client)

# playwright-ruby-client

A Ruby client for Playwright driver.

## Getting Started

At this point, playwright-ruby-client doesn't include the downloader of playwright-cli, so **we have to install [playwright-cli](https://github.com/microsoft/playwright-cli) in advance**.

via npm: `npm install -g playwright-cli`

or

direct download: `wget https://playwright.azureedge.net/builds/cli/next/playwright-cli-0.180.0-next.1608746109749-cbc13bd-mac.zip`

(`-mac.zip` should be replaced for another OS)

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/playwright-ruby-client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Playwright project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/playwright-ruby-client/blob/master/CODE_OF_CONDUCT.md).
