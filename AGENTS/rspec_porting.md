# RSpec Porting Rules

## Principle

Tests must be faithful Ruby translations of upstream Node.js Playwright tests.
Do NOT write isolated unit tests with doubles, mocks, or instance_double.

## Source of tests

- Upstream tests live in `microsoft/playwright` under `tests/`.
- Use the release branch matching the target version (e.g., `release-1.59`).
- Example: `tests/library/inspector/recorder-api.spec.ts`

## File naming

- Match the upstream file name converted to snake_case.
- Place under `spec/integration/` following the existing directory conventions of this project. Do not blindly mirror the upstream directory structure.
- Examples:
  - `tests/library/inspector/recorder-api.spec.ts` → `spec/integration/recorder_api_spec.rb`
  - `tests/library/browsercontext-storage-state.spec.ts` → `spec/integration/browser_context/storage_state_spec.rb`
  - `tests/library/browsercontext-har.spec.ts` → `spec/integration/browser_context/har_spec.rb`

## Porting procedure

1. Fetch the upstream test file from the correct release branch.
2. Identify all test cases relevant to the feature being ported.
3. Translate each test case to RSpec, preserving:
   - The test name (in the `it` description).
   - The test logic and assertions.
   - The upstream file URL as a comment at the top of the file or describe block.
4. Use integration test helpers (`with_page`, `with_context`, `sinatra`, `server_prefix`, etc.) from `spec/spec_helper.rb`.
5. Use `Playwright::Test::Matchers` (via `include Playwright::Test::Matchers`) when assertions like `have_text` are needed.

## What NOT to do

- Do not use `instance_double`, `double`, `allow`, `receive`, or other mocking constructs.
- Do not invent tests that have no upstream counterpart.
- Do not place tests under `spec/playwright/` (that path is not used in this project).
