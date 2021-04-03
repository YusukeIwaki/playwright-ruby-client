# development

## (opt) Download driver

Edit `development/CLI_VERSION` and then download the specific version of driver.

```
wget https://playwright.azureedge.net/builds/driver/next/playwright-$(cat development/CLI_VERSION)-mac.zip
```

Then, extract the driver zip file, and set `PLAYWRIGHT_CLI_EXECUTABLE_PATH`.


## Create/Update API definition

```
$PLAYWRIGHT_CLI_EXECUTABLE_PATH print-api-json | jq > development/api.json
$PLAYWRIGHT_CLI_EXECUTABLE_PATH --version | cut -d' ' -f2 > development/CLI_VERSION
```

## Generate API codes

```
rm lib/playwright_api/*.rb
bundle exec ruby development/generate_api.rb
```

## Test it

```
$PLAYWRIGHT_CLI_EXECUTABLE_PATH install
bundle exec rspec
```
