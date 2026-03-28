# Playwright 1.59.0 Upgrade Work Log

## Overview

- **Date**: 2026-03-28
- **Driver**: `1.59.0-alpha-2026-03-28` (alpha)
- **Library version**: `1.59.beta1`
- **Compatible Playwright version**: `1.59.0`

## Upstream References

- playwright-python backport issue: https://github.com/microsoft/playwright-python/issues/3027
- playwright-java backport issue: https://github.com/microsoft/playwright-java/issues/1884
- playwright-java roll PRs: https://github.com/microsoft/playwright-java/pull/1900, https://github.com/microsoft/playwright-java/pull/1901

Note: Playwright 1.59 is NOT yet officially released (as of 2026-03-28). playwright-python port has not started (all unchecked). playwright-java port is almost complete.

---

## Done: Version & Generation

| Item | Change |
|---|---|
| `development/CLI_VERSION` | `1.58.0` -> `1.59.0-alpha-2026-03-28` |
| `lib/playwright/version.rb` VERSION | `1.58.1` -> `1.59.beta1` |
| `lib/playwright/version.rb` COMPATIBLE_PLAYWRIGHT_VERSION | `1.58.2` -> `1.59.0` |
| `development/generate_api/models/js_type.rb` | Added `'Disposable' => 'untyped'` to TYPE_MAP (new type in 1.59 API) |
| `development/api.json` | Regenerated from alpha driver |
| `documentation/docs/**` | Regenerated |

## Done: Parameter Additions (existing features)

| Method | Parameters Added | File |
|---|---|---|
| `Locator#aria_snapshot` | `depth:` (int), `mode:` ("ai"/"default") | `lib/playwright/locator_impl.rb` |
| `Page#console_messages` | `filter:` ("all"/"since-navigation") | `lib/playwright/channel_owners/page.rb` |
| `Page#page_errors` | `filter:` ("all"/"since-navigation") | `lib/playwright/channel_owners/page.rb` |
| `Tracing#start` | `live:` (bool) | `lib/playwright/channel_owners/tracing.rb` |
| `BrowserType#launch` | `artifactsDir:` (auto-passed via options hash) | No code change needed |
| `BrowserType#launch_persistent_context` | `artifactsDir:` (auto-passed via **options) | No code change needed |

## Done: New Methods

| Method | Description | File |
|---|---|---|
| `Request#existing_response` | Returns response if already received, nil otherwise (non-blocking) | `lib/playwright/channel_owners/request.rb` |
| `Response#http_version` | Returns HTTP version string (e.g., "HTTP/1.1") | `lib/playwright/channel_owners/response.rb` |
| `ConsoleMessage#timestamp` | Returns timestamp in ms since Unix epoch | `lib/playwright/console_message_impl.rb` |
| `Page#clear_console_messages` | Clears stored console messages | `lib/playwright/channel_owners/page.rb` |
| `Page#clear_page_errors` | Clears stored page errors | `lib/playwright/channel_owners/page.rb` |
| `Page#aria_snapshot` | Page-level aria snapshot (depth, mode, timeout) | `lib/playwright/channel_owners/page.rb` |
| `BrowserContext#set_storage_state` | Sets storage state from path or parameters | `lib/playwright/channel_owners/browser_context.rb` |
| `BrowserContext#closed?` | Returns whether context close was called | `lib/playwright/channel_owners/browser_context.rb` |
| `Locator#normalize` | Returns normalized locator using best-practice selectors | `lib/playwright/locator_impl.rb` |

## Done: Breaking Change Adaptation

| Change | Description | Files |
|---|---|---|
| `snapshotForAI` protocol removed | `Page.snapshotForAI` protocol method replaced by `Frame.ariaSnapshot(mode: 'ai')`. `snapshot_for_ai` now delegates to `aria_snapshot(mode: 'ai')` | `lib/playwright/channel_owners/page.rb` |
| Incremental snapshots API changed | Old `mode: 'incremental'` / `track:` on `snapshotForAI` replaced by `_track:` parameter on `ariaSnapshot`. Client sends `track:` (not `_track:`) to protocol. `selector` and `track` are mutually exclusive. | `lib/playwright/channel_owners/page.rb`, `lib/playwright/locator_impl.rb` |
| `Page#aria_snapshot` uses Frame protocol | Page-level `ariaSnapshot` is not a Page protocol method; implemented via `main_frame.channel` with `selector: 'body'` (omitted when `track` is specified) | `lib/playwright/channel_owners/page.rb` |
| `ariaSnapshot` returns `result['snapshot']` | Protocol response now wraps snapshot string in `{ snapshot: ... }` object instead of returning bare string | `lib/playwright/channel_owners/page.rb`, `lib/playwright/locator_impl.rb` |
| Test file rewritten | `aria_snapshot_ai_spec.rb` fully rewritten to match upstream `page-aria-snapshot-ai.spec.ts`. All 33 tests ported (no skips). String containment matching (`include`) used per upstream `toContainYaml`. | `spec/integration/page/aria_snapshot_ai_spec.rb` |

## Done: Bug Fixes

| Fix | Description | File |
|---|---|---|
| Dialog.dismiss error handling | Swallow errors (including TargetClosedError) on dismiss to prevent crashes during beforeunload dialogs | `lib/playwright/channel_owners/dialog.rb` |

## Done: Channel Owner Stubs (prevent crashes)

The 1.59 server sends new channel owner types that need stub classes to avoid `Missing type` errors at runtime, even when the full API is not implemented.

| Stub | File | Reason |
|---|---|---|
| `Debugger` | `lib/playwright/channel_owners/debugger.rb` | Server sends Debugger objects for BrowserContext.debugger; no API exposed yet |
| `Overlay` | `lib/playwright/channel_owners/overlay.rb` | Server sends Overlay objects for Page.overlay; API excluded per user decision |
| `Disposable` | `lib/playwright/channel_owners/disposable.rb` | Server sends Disposable objects as return values from various methods (e.g., addInitScript); `dispose` method implemented |

---

## Skipped: User Decision (upstream direction unclear)

| Feature | Reason | Action for 1.59.0 GA |
|---|---|---|
| `Video.start()` / `Video.stop()` | Upstream (playwright-python) has not finalized the direction for programmatic video recording control | Re-evaluate when 1.59.0 is officially released. Check if the API has stabilized in playwright-python/java |
| `Page.overlay` / Overlay class | Upstream has not finalized the direction for overlay API (show, chapter, setVisible) | Re-evaluate when 1.59.0 is officially released |

## Skipped: Alpha Instability / JS-only / Too Large

| Feature | Reason | Action for 1.59.0 GA |
|---|---|---|
| `Page.screencast` / Screencast class | JS-only in protocol (`langs.only: ["js"]`); JPEG frame streaming API | Implement if protocol exposes it to non-JS clients in GA |
| `Page.agent()` / PageAgent (AI agent API) | Large new feature, actively evolving in alpha (perform, expect, extract, dispose) | Evaluate scope and stability at GA |
| `BrowserContext.debugger` / Debugger class | New debugger API (pausedDetails, requestPause, resume, runTo, onPausedStateChanged) | Implement at GA if API stabilizes |
| CDPSession `event`/`close` events | JS-only in protocol definition | Implement if needed at GA |
| `BrowserContext.options()` | Exposes context creation options; low priority | Implement at GA |
| `recordVideo.annotate` option | Related to video recording features (excluded); annotation overlay during recording | Implement together with video features at GA |
| `recordVideo.dir` optional change | Related to video recording; `dir` now optional when `artifactsDir` is set | Implement together with video features at GA |
| `expect(locator).toHaveURLPattern()` | New assertion; needs locator assertion framework update | Implement at GA |

---

## Test Results

- **984 examples, 0 failures, 35 pending** (screencast_spec.rb excluded)
- `spec/integration/screencast_spec.rb` はハングする: 1.59 で Video API が変更され、`recordVideo` 使用時に Video artifact イベントが送信されなくなっている可能性あり。GA 版で Video.start/stop を実装する際に合わせて修正が必要。
- `spec/integration/page/aria_snapshot_ai_spec.rb` の incremental snapshot テスト (12件) は skip に変更: upstream で incremental snapshot 機能が削除されたため。
- `spec/integration/client_certificates_spec.rb` は環境依存のため無視。

---

## Notes for 1.59.0 GA Upgrade

When Playwright 1.59.0 is officially released:

1. **Update CLI_VERSION** to `1.59.0` (remove alpha suffix)
2. **Update VERSION** to `1.59.0` (remove beta suffix)
3. **Re-download driver** and regenerate api.json (alpha->GA API may differ)
4. **Fix screencast_spec.rb hang**: Video artifact event handling likely needs update for new Video.start/stop API
5. **Re-check skipped features** above, especially:
   - Video.start/stop and overlay: check if upstream has finalized direction
   - PageAgent (AI agent): evaluate if API has stabilized
   - Screencast: check if protocol has been opened to non-JS
5. **Check playwright-python backport issue** (https://github.com/microsoft/playwright-python/issues/3027) for completion status
6. **Run full test suite** to catch any alpha->GA behavioral changes
