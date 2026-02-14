# Playwright Upgrade Workflow

## Scope

Standard process for `Update Playwright driver to 1.xx.x` tasks.

## Order (Do not reorder)

1. Update versions
- `development/CLI_VERSION`
- `lib/playwright/version.rb` (`VERSION`, `COMPATIBLE_PLAYWRIGHT_VERSION`)

2. Update API definition
- Set `PLAYWRIGHT_CLI_EXECUTABLE_PATH`
- `$PLAYWRIGHT_CLI_EXECUTABLE_PATH print-api-json | jq . > development/api.json`

3. Clean before generation + regenerate
- `rm lib/playwright_api/*.rb`
- `find documentation/docs -name "*.md" | grep -v documentation/docs/article/ | xargs rm`
- `bundle exec ruby development/generate_api.rb`

4. Update tests first
- Add/update `spec/` changes that represent upstream behavior differences.

5. Implement
- Apply minimal implementation changes in `lib/playwright/**`.

6. Run tests
- `bundle exec rspec`
- Run focused specs first while iterating, then run the full suite.

## Notes

- During upgrade work, prefer the steps in `development/README.md`.
- `development/update_playwright_driver.sh` can be used as a helper script.
