# development

## Prerequisites

- Install Ruby dependencies via `bin/setup`:

  ```sh
  bin/setup
  ```

- Install Node.js and `playwright-core`. Use the version defined in [`lib/playwright/version.rb`](../lib/playwright/version.rb):

  ```sh
  VERSION=$(ruby -r "./lib/playwright/version" -e "puts Playwright::COMPATIBLE_PLAYWRIGHT_VERSION")
  npm install "playwright-core@$VERSION"
  ```
  Avoid using an unversioned `npx` command because it can fetch an incompatible version.

- Set the `PLAYWRIGHT_CLI_EXECUTABLE_PATH` environment variable. For example:

  ```sh
  export PLAYWRIGHT_CLI_EXECUTABLE_PATH="$(pwd)/node_modules/.bin/playwright-core"
  ```

## API generation and testing

### Create/Update API definition

```sh
./development/generate_api_json.sh
```

This resolves the upstream commit from the version in `development/CLI_VERSION`, checks out only the required `utils/` and `docs/` directories, and generates `development/api.json` from the upstream source. Set `PW_SRC_DIR` to reuse an existing checkout at the resolved commit.

### Generate API codes

```
rm lib/playwright_api/*.rb
find documentation/docs -name "*.md" | grep -v documentation/docs/article/ | xargs rm
bundle exec ruby development/generate_api.rb
```

### Test it

```
"$PLAYWRIGHT_CLI_EXECUTABLE_PATH" install
rbenv exec bundle exec rspec
```

* Testing with the **latest** version of `playwright-core` might fail because of breaking changes.
* Testing with the **next** version of `playwright-core` must pass.
