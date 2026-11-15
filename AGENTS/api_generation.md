# API Generation

## Source of generated artifacts

- API definition generator: `development/generate_api_json.sh`
- API definition: `development/api.json`
- Generator script: `development/generate_api.rb`

`generate_api_json.sh` resolves the exact upstream Playwright commit from the version in `development/CLI_VERSION`, then generates the API definition from upstream `utils/` and `docs/`. It does not use the Playwright CLI. Set `PW_SRC_DIR` to reuse an existing checkout at the resolved commit.

## Generated outputs

- `lib/playwright_api/*.rb`
- `documentation/docs/api/**/*.md`
- `documentation/docs/include/api_coverage.md`
- `sig/playwright.rbs`
- `development/unimplemented_examples.md`

## Critical rules

- `lib/playwright_api/` is not tracked by Git (`lib/playwright_api/.gitignore` only).
- Do not manually edit `lib/playwright_api/*.rb`.
- Re-run `development/generate_api.rb` whenever API specs change.

## Typical command set

```sh
./development/generate_api_json.sh
rm lib/playwright_api/*.rb
find documentation/docs -name "*.md" | grep -v documentation/docs/article/ | xargs rm
bundle exec ruby development/generate_api.rb
```
