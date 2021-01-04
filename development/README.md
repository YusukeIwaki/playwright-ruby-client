# development

## Create/Update API definition

```
playwright-cli print-api-json | jq > development/api.json
playwright-cli --version > development/CLI_VERSION
```

## Generate API codes

```
rm lib/playwright_api/*.rb
bundle exec ruby development/generate_api.rb
```
