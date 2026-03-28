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

4. Research upstream changes
- Search `https://github.com/microsoft/playwright-python/issues` for an issue titled "Backport client side changes for 1.xx" (e.g. https://github.com/microsoft/playwright-python/issues/3027). This is the primary source of what needs to be ported.
- Also check `https://github.com/microsoft/playwright-java/issues` for a similar backport issue.
- Check `https://github.com/microsoft/playwright-python/pulls` for version upgrade PRs to use as implementation reference.

5. Plan and confirm scope with user
- Enter plan mode (`EnterPlanMode`) before writing any code.
- Bug fixes: include by default — no confirmation needed.
- Features already implemented in the Ruby client: include improvements without confirmation.
- New features not yet implemented in the Ruby client: explain each one and get explicit user approval before proceeding.
- Exit plan mode only after the user agrees on the scope.

6. Update tests first
- Add/update `spec/` changes that represent upstream behavior differences, scoped to the agreed plan.

7. Implement
- Apply minimal implementation changes in `lib/playwright/**`.

8. Run tests
- `bundle exec rspec`
- Run focused specs first while iterating, then run the full suite.

## Notes

- During upgrade work, prefer the steps in `development/README.md`.
- `development/update_playwright_driver.sh` can be used as a helper script.
