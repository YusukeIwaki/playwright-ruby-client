# RSpec Debugging

## Critical execution rule

- Run RSpec via `rbenv exec`.
- Some environments fail with plain `bundle exec rspec`, so always use `rbenv exec bundle exec rspec ...`.

## Debug rule when spec fails

- On failure, rerun with `DEBUG=1`.
- Use `DEBUG=1` output to inspect Playwright protocol logs and isolate the issue.

## Example

```sh
rbenv exec bundle exec rspec spec/integration/page/aria_snapshot_ai_spec.rb
```

```sh
DEBUG=1 rbenv exec bundle exec rspec spec/integration/page/aria_snapshot_ai_spec.rb
```

## Node.js Playwright protocol log

- Node.js Playwright protocol logs can be captured with `DEBUG=pw:*`.
- This is useful when comparing behavior against the Ruby client.

```sh
DEBUG=pw:* node script.mjs 2>&1 | head -200
```
