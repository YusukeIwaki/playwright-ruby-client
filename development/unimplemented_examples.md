# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_347531c10d6bf4b1f6e727494b385f224aa59a068df9073b0afaa2ca1b66362d

```
page.route("**/*", lambda route: route.abort())  # Runs last.
page.route("**/*", lambda route: route.fallback())  # Runs second.
page.route("**/*", lambda route: route.fallback())  # Runs first.

```

### example_2b4eca732c7ed8d0d22b23cd55d462cdd20bfc2f94f19640e744e265f53286ca

```
# Handle GET requests.
def handle_post(route):
    if route.request.method != "GET":
        route.fallback()
        return
  # Handling GET only.
  # ...

# Handle POST requests.
def handle_post(route):
    if route.request.method != "POST":
        route.fallback()
        return
  # Handling POST only.
  # ...

page.route("**/*", handle_get)
page.route("**/*", handle_post)

```

### example_457b18e26c0c4a1a8074c8678d0377ba50fe9d0eeb1ef2b520acbb2c68da240a

```
def handle(route, request):
    # override headers
    headers = {
        **request.headers,
        "foo": "foo-value" # set "foo" header
        "bar": None # remove "bar" header
    }
    route.fallback(headers=headers)
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
