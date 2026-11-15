# unimplemented_examples.md

## What it is

- `development/unimplemented_examples.md` is a generated artifact.
- It lists examples from API docs that could not be converted to Ruby examples.
- During Playwright version upgrades, changes in this file must be resolved before tests and implementation work continue.

## How examples are converted

- Source: API doc comments
- Conversion rules: `development/generate_api/example_codes.rb`
- Unmapped examples remain in Python in docs and are listed in `development/unimplemented_examples.md`.

## Policy

- Do not manually edit `development/unimplemented_examples.md`.
- Do not only append new mappings. First check whether the upstream example is a revised version of an example that was already mapped under an older example ID.
- Prefer updating or replacing the existing mapping when the sample is logically the same.
- Add a new mapping only when no existing Ruby sample covers the same API documentation example.
- Keep `development/generate_api/example_codes.rb` organized by the source comment format `# ClassName#method_name`.

## Required workflow when this file changes

1. Review the diff in `development/unimplemented_examples.md`.
   - Record each example ID.
   - Record the method memo in parentheses, such as `Page#route_web_socket`.
   - Read the Python example body and summarize what behavior it demonstrates.
2. Identify the upstream commit that introduced or revised the example.
   - Search upstream Playwright history for the method name and example text.
   - Confirm whether the change is a new API example or an API review/doc rewrite that changed the example ID.
   - Use this commit information when explaining the upgrade work.
3. Search for an existing Ruby mapping before adding anything.
   - Search `development/generate_api/example_codes.rb` by method memo, old example IDs if known, method names, unique string literals, and nearby API names.
   - Also search `spec/integration/example_spec.rb` for old example IDs that may depend on the mapped method.
4. Decide how to update `development/generate_api/example_codes.rb`.
   - If the old mapping represents the same documentation example, rename the method to the new example ID and update the Ruby body to match the new upstream sample.
   - If there is no existing mapping, add a new method for the new example ID.
   - Add or update the source comment immediately above the method using `# ClassName#method_name`.
   - Insert methods in alphabetical `ClassName#method_name` order, matching nearby comments such as `# BrowserContext#route` and `# Page#pdf`.
5. Update example specs if needed.
   - If `spec/integration/example_spec.rb` calls an old example ID that was renamed, update the call to the new example ID.
   - Keep the spec intent unchanged unless the upstream example behavior changed.
6. Re-run generation.
   - `bundle exec ruby development/generate_api.rb`
7. Verify the result.
   - `development/unimplemented_examples.md` should no longer list examples that now have Ruby mappings.
   - The corresponding `documentation/docs/api/**/*.md` examples should be rendered as Ruby, not Python.
   - Run `git diff --check`.
   - Run focused specs if `spec/integration/example_spec.rb` changed.

## Mapping notes

- The example ID is `example_` plus the SHA256 of the original fenced Python code block, including fence metadata.
- Small upstream edits can therefore create a new example ID even when the example is conceptually the same.
- Ruby mappings should demonstrate the same behavior, but they should use the Ruby client's public API names.
- If the Python API shape does not exist in Ruby, map to the closest equivalent Ruby API and keep the example concise.
