# API Generation

## Source of generated artifacts

- Input: `development/api.json`
- Generator script: `development/generate_api.rb`

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
rm lib/playwright_api/*.rb
find documentation/docs -name "*.md" | grep -v documentation/docs/article/ | xargs rm
bundle exec ruby development/generate_api.rb
```
