# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_bbeb6c856287d9a14962cd222891b682b8f1c52dafcf933198e651e634906122

```
def handle(route, request):
    # override headers
    headers = {
        **request.headers,
        "foo": "foo-value" # set "foo" header
        "bar": None # remove "bar" header
    }
    route.continue_(headers=headers)
}
page.route("**/*", handle)

```

### example_e4e1e47809bf39ddce020b8a6bdb0560ffb660f92bd0743107c9c1557f4bbd60

```
row_locator = page.lsocator("tr")
# ...
row_locator
    .filter(has_text="text in column 1")
    .filter(has=page.locator("tr", has_text="column 2 button"))
    .screenshot()

```
