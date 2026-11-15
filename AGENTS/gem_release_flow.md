# Gem Release Flow

## Overview

Pushing a Git tag triggers `.github/workflows/deploy.yml`, which builds and publishes the gem to RubyGems.

## Tag format

The deploy workflow triggers on tags matching these patterns:

- `X.Y.Z` — stable release (e.g. `1.58.0`)
- `X.Y.betaN` — beta release (e.g. `1.58.beta1`)
- `X.Y.Z.alphaN` — alpha release (e.g. `1.58.1.alpha1`)

## Steps to release

1. Update `lib/playwright/version.rb`:
   - Set `Playwright::VERSION` to the target version string.
   - `COMPATIBLE_PLAYWRIGHT_VERSION` stays at the base Playwright version.

2. Commit the version change.

3. Create and push a Git tag matching the version exactly:
   ```sh
   git tag 1.58.1.alpha1
   git push origin 1.58.1.alpha1
   ```

4. The deploy workflow will:
   - Check out the tagged commit.
   - Verify `Playwright::VERSION == RELEASE_TAG` (must match exactly).
   - Run `bundle exec ruby development/generate_api.rb` to generate API code.
   - Run `rake build` to build the gem.
   - Push the gem to RubyGems using the `RUBYGEMS_API_KEY` secret.

## Important notes

- The `Playwright::VERSION` in `lib/playwright/version.rb` **must exactly match** the Git tag name. If they differ, the deploy job fails at the version check step.
- Alpha/beta tags do NOT require a separate branch — they can be tagged on any commit.
