#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLAYWRIGHT_VERSION="${1:-$(tr -d '[:space:]' < "$SCRIPT_DIR/CLI_VERSION")}"
API_JSON_PATH="$REPO_ROOT/development/api.json"

if [[ -z "$PLAYWRIGHT_VERSION" ]]; then
  echo "Playwright version is empty." >&2
  exit 1
fi

for command_name in git jq node npm; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Required command is not available: $command_name" >&2
    exit 1
  fi
done

PLAYWRIGHT_GIT_HEAD="$(npm view "playwright-core@$PLAYWRIGHT_VERSION" gitHead)"
if [[ ! "$PLAYWRIGHT_GIT_HEAD" =~ ^[0-9a-f]{40}$ ]]; then
  echo "Failed to resolve gitHead for playwright-core@$PLAYWRIGHT_VERSION." >&2
  exit 1
fi

TEMP_API_JSON="$(mktemp "$API_JSON_PATH.tmp.XXXXXX")"
CLONED_SOURCE_DIR=""

cleanup() {
  rm -f -- "$TEMP_API_JSON"
  if [[ -n "$CLONED_SOURCE_DIR" ]]; then
    rm -rf -- "$CLONED_SOURCE_DIR"
  fi
}
trap cleanup EXIT

if [[ -n "${PW_SRC_DIR:-}" ]]; then
  PLAYWRIGHT_SOURCE_DIR="$PW_SRC_DIR"
  SOURCE_GIT_HEAD="$(git -C "$PLAYWRIGHT_SOURCE_DIR" rev-parse HEAD)"
  if [[ "$SOURCE_GIT_HEAD" != "$PLAYWRIGHT_GIT_HEAD" ]]; then
    echo "PW_SRC_DIR is at $SOURCE_GIT_HEAD, expected $PLAYWRIGHT_GIT_HEAD for playwright-core@$PLAYWRIGHT_VERSION." >&2
    exit 1
  fi
else
  CLONED_SOURCE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/playwright-source.XXXXXX")"
  PLAYWRIGHT_SOURCE_DIR="$CLONED_SOURCE_DIR"

  git -C "$PLAYWRIGHT_SOURCE_DIR" init --quiet
  git -C "$PLAYWRIGHT_SOURCE_DIR" remote add origin https://github.com/microsoft/playwright.git
  git -C "$PLAYWRIGHT_SOURCE_DIR" sparse-checkout init --cone
  git -C "$PLAYWRIGHT_SOURCE_DIR" sparse-checkout set utils docs
  git -C "$PLAYWRIGHT_SOURCE_DIR" fetch --quiet --depth 1 origin "$PLAYWRIGHT_GIT_HEAD"
  git -C "$PLAYWRIGHT_SOURCE_DIR" checkout --quiet --detach FETCH_HEAD
fi

echo "Generating api.json for playwright-core@$PLAYWRIGHT_VERSION ($PLAYWRIGHT_GIT_HEAD)"
API_JSON_MODE=1 node "$PLAYWRIGHT_SOURCE_DIR/utils/doclint/generateApiJson.js" |
  jq . > "$TEMP_API_JSON"

if [[ ! -s "$TEMP_API_JSON" ]]; then
  echo "Generated api.json is empty." >&2
  exit 1
fi

mv "$TEMP_API_JSON" "$API_JSON_PATH"
echo "Updated $API_JSON_PATH"
