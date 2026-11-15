# Past Upgrade PR Patterns

Common patterns observed from `Update Playwright driver to 1.xx.x` PRs reviewed with `gh`.

## PR sample

- `#366` (1.58.0)
- `#360` (1.57.0)
- `#354` (1.56.1)
- `#348` (1.55.0)
- `#341` (1.54.1)
- `#336` (1.53.0)
- `#331` (1.52.0)
- `#327` (1.51.0)

## Frequently changed files

Almost every time:

- `development/CLI_VERSION`
- `development/api.json`
- `lib/playwright/version.rb`

High frequency:

- `documentation/docs/api/*.md`
- `documentation/docs/include/api_coverage.md`
- `development/generate_api/example_codes.rb`
- `spec/integration/example_spec.rb`
- `lib/playwright/channel_owners/page.rb`
- `lib/playwright/locator_impl.rb`

Sometimes:

- `development/generate_api.rb`
- `development/unimplemented_examples.md`

## Work style trend

- The first commit often updates version files and generated API artifacts.
- Follow-up commits often add/update specs and then implement `lib/playwright/**` changes.
- Broader upstream changes usually increase docs/example/assets updates.
