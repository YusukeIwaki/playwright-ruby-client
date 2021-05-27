---
sidebar_position: 3
---

# Integration into Ruby on Rails application

`playwright-ruby-client` is a client library just for browser automation. `capybara-playwright-driver` provides the [Capybara](https://github.com/teamcapybara/capybara) driver based on playwright-ruby-client and makes it easy to integrate into Ruby on Rails applications.

## Installation

Add the line below into Gemfile:

```rb
gem 'capybara-playwright-driver'
```

and then `bundle install`.

Note that capybara-playwright-driver does not depend on Selenium. But `selenium-webdriver` is also required [on Rails 5.x, 6.0](https://github.com/rails/rails/pull/39179)

## Register and configure Capybara driver

```rb
Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(app,
    browser_type: :chromium, # :chromium (default) or :firefox, :webkit
    headless: false, # true for headless mode (default), false for headful mode.
  )
end
```

### Update timeout

Capybara sets the default value of timeout to *2 seconds*. Generally it is too short to wait for HTTP responses.

It is recommended to set the timeout to 15-30 seconds for Playwright driver.

```rb
Capybara.default_max_wait_time = 15
```

### (Optional) Update default driver

By default, Capybara driver is set to `:rack_test`, which works only with non-JS contents. If your Rails application has many JavaScript contents, it is recommended to change the default driver to `:playwrite`.

```rb
Capybara.default_driver = :playwright
Capybara.javascript_driver = :playwright
```

It is not mandatry. Without changing the default driver, you can still use Playwright driver by specifying `Capybara.current_driver = :playwrite` (or `driven_by :playwright` in system spec) explicitly.
