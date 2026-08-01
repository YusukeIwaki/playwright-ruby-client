# CI Expectations

## Main guardrails

`/.github/workflows/check.yml` detects stale generated artifacts.

Checked paths:

- `development/api.json`
- `documentation/docs/**`
- `development/unimplemented_examples.md`

## Practical implication

- If the Playwright version changes, run `development/generate_api_json.sh` before regenerating artifacts.
- If API-related code changes, regenerate artifacts before finishing.
- If you open a PR without regeneration, `check.yml` will likely fail.

## Related workflows

- `/.github/workflows/rspec.yml`
- `/.github/workflows/deploy.yml`

These workflows also depend on `bundle exec ruby development/generate_api.rb`.
