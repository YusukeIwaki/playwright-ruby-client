# unimplemented_examples.md

## What it is

- `development/unimplemented_examples.md` is a generated artifact.
- It lists examples from API docs that could not be converted to Ruby examples.

## How examples are converted

- Source: API doc comments
- Conversion rules: `development/generate_api/example_codes.rb`
- Unmapped examples remain in Python in docs and are listed in `development/unimplemented_examples.md`.

## When this file changes

1. Review the diff to identify unmapped examples.
2. Add conversion mappings to `development/generate_api/example_codes.rb` when needed.
3. Re-run `bundle exec ruby development/generate_api.rb`.
