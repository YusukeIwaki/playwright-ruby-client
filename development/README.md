# development

## Prerequisites

- Install Ruby dependencies via `bin/setup`:

  ```sh
  bin/setup
  ```

- Install Node.js and the Playwright driver. Use the version defined in [`lib/playwright/version.rb`](../lib/playwright/version.rb):

  ```sh
  VERSION=$(ruby -r "./lib/playwright/version" -e "puts Playwright::COMPATIBLE_PLAYWRIGHT_VERSION")
  npm install "playwright@$VERSION"
  ```
  Avoid using `npx` to install Playwright because it always fetches the latest version.

- Set the `PLAYWRIGHT_CLI_EXECUTABLE_PATH` environment variable. For example:

  ```sh
  export PLAYWRIGHT_CLI_EXECUTABLE_PATH="$(pwd)/node_modules/.bin/playwright"
  ```

## API generation and testing

### (opt) Download driver

Edit `development/CLI_VERSION` and then download the specific version of driver. It can be found in https://github.com/microsoft/playwright/actions/workflows/publish_canary.yml

```
wget https://playwright.azureedge.net/builds/driver/next/playwright-$(cat development/CLI_VERSION)-mac.zip
```

Then, extract the driver zip file, and set `PLAYWRIGHT_CLI_EXECUTABLE_PATH`.

Note that Playwright >= 1.43 doesn't include playwright.sh, and we have to set `$DRIVER_DOWNLOAD_PATH/node $DRIVER_DOWNLOAD_PATH/package/cli.js` into PLAYWRIGHT_CLI_EXECUTABLE_PATH or manually put https://github.com/microsoft/playwright/blob/v1.42.1/utils/build/run-driver-posix.sh into the root of the downloaded driver's dir.

### Create/Update API definition

```
$PLAYWRIGHT_CLI_EXECUTABLE_PATH print-api-json | jq > development/api.json
```

### Generate API codes

```
rm lib/playwright_api/*.rb
find documentation/docs -name "*.md" | grep -v documentation/docs/article/ | xargs rm
bundle exec ruby development/generate_api.rb
```

### Test it

```
$PLAYWRIGHT_CLI_EXECUTABLE_PATH install
bundle exec rspec
```

* Testing with **latest** version of playwright driver might fail because of some breaking changes
* Testing with **next** version of playwright **must be passed**
