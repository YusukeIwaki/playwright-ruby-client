# development

## (opt) Download driver

Edit `development/CLI_VERSION` and then download the specific version of driver. It can be found in https://github.com/microsoft/playwright/actions/workflows/publish_canary.yml

```
wget https://playwright.azureedge.net/builds/driver/next/playwright-$(cat development/CLI_VERSION)-mac.zip
```

Then, extract the driver zip file, and set `PLAYWRIGHT_CLI_EXECUTABLE_PATH`.


## Create/Update API definition

```
$PLAYWRIGHT_CLI_EXECUTABLE_PATH print-api-json | jq > development/api.json
```

## Generate API codes

```
rm lib/playwright_api/*.rb
find documentation/docs -name "*.md" | grep -v documentation/docs/article/ | xargs rm
bundle exec ruby development/generate_api.rb
```

## Test it

```
$PLAYWRIGHT_CLI_EXECUTABLE_PATH install
bundle exec rspec
```

* Testing with **latest** version of playwright driver might fail because of some breaking changes
* Testing with **next** version of playwright **must be passed**
