# Upstream PR Review

## Scope

This review is mandatory for every `Update Playwright driver to 1.xx.x` task.
The goal is to decide what must be ported from Node.js Playwright into this Ruby client before editing tests or implementation code.

## Required output

For each upstream Playwright PR, summarize:

- Behavior change summary.
- Whether this Ruby library needs a port, a generated API/docs check, or no action.
- Whether `packages/playwright-core/src/client/**` changed, and what changed if it did.
- Whether tests were added or changed, and what behavior they cover.

Keep the upstream PR order from the source list. When a feature PR is later reverted in the same target release, mark both the feature PR and the revert PR as canceled in summaries, for example with Markdown strikethrough.

## Source list

Prefer an upstream language-port tracking issue when available, especially `microsoft/playwright-python` issues titled like client-side backports. These issues usually list the relevant `microsoft/playwright` PRs in the correct order.

If no tracking issue is available:

- Compare the target Playwright release with the previous release in `microsoft/playwright`.
- Focus on merged PRs that affect protocol, generated API, client behavior, assertions, selectors, tracing, network routing, browser/context/page events, or tests under `tests/`.
- Do not rely only on release notes; small client behavior changes often do not appear there.

## Suggested commands

Extract a PR list from a tracking issue:

```sh
gh issue view <issue-number> --repo microsoft/playwright-python --json body --jq '.body' \
  | rg -o 'pull/[0-9]+' \
  | cut -d/ -f2
```

Collect metadata for each PR:

```sh
gh pr view <pr-number> --repo microsoft/playwright \
  --json number,title,url,body,files,additions,deletions,changedFiles,mergedAt,mergeCommit
```

For large diffs, use a local upstream clone and compare the merge commit with its first parent:

```sh
git clone --filter=blob:none --no-checkout https://github.com/microsoft/playwright.git /tmp/playwright-upstream
cd /tmp/playwright-upstream
git diff --name-only <parent-sha> <merge-commit-sha>
git diff --stat <parent-sha> <merge-commit-sha> -- packages/playwright-core/src/client tests docs/src/api packages/protocol
```

## Classification rules

- `packages/playwright-core/src/client/**` changes are strong porting candidates, but absence of client changes does not prove no Ruby action is needed.
- `packages/protocol/**`, `docs/src/api/**`, and `packages/*/types*.d.ts` changes usually require API generation and generated diff review.
- `packages/injected/**`, `packages/playwright/src/matchers/**`, selectors, assertions, and trace/HAR changes can require Ruby implementation or RSpec changes even when `src/client` is untouched.
- Test-only PRs are usually no-action for Ruby unless they document a behavior change that Ruby should now cover.
- Build, bundle, TypeScript, import-path, MCP-only, trace-viewer-only, and test-runner-only PRs are usually no-action for this Ruby client.
- Reverted features should not be ported. Record both the adding PR and reverting PR as canceled so the final target-release behavior is clear.

## Review checklist

1. Read the PR title, changed file list, and relevant diff hunks.
2. Identify protocol/API/docs changes and generated artifact implications.
3. Inspect `packages/playwright-core/src/client/**` changes and translate them into Ruby client concepts.
4. Inspect added or modified upstream tests and decide which RSpec files should be updated.
5. Search this repository for existing equivalent implementation before deciding the work is already covered.
6. Produce the required output table and use it to drive test-first porting.

## PR description

For upgrade PRs, include the review table in the PR description or link to an equivalent committed note. The table must be clear enough for the next upgrade to audit which upstream PRs were ported, skipped, generated-only, or canceled by a revert.
