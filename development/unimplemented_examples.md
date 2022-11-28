# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_b5cbf187e1332705618516d4be127b8091a5d1acfa9a12d382086a2b0e738909

```
handle = page.evaluate_handle("({window, document})")
properties = handle.get_properties()
window_handle = properties.get("window")
document_handle = properties.get("document")
handle.dispose()

```

### example_cbf4890335f3140b7b275bdad85b330140e5fbb21e7f4b89643c73115ee62a17

```
# Matches <span>
page.get_by_text("world")

# Matches first <div>
page.get_by_text("Hello world")

# Matches second <div>
page.get_by_text("Hello", exact=True)

# Matches both <div>s
page.get_by_text(re.compile("Hello"))

# Matches second <div>
page.get_by_text(re.compile("^hello$", re.IGNORECASE))

```

### example_cbf4890335f3140b7b275bdad85b330140e5fbb21e7f4b89643c73115ee62a17

```
# Matches <span>
page.get_by_text("world")

# Matches first <div>
page.get_by_text("Hello world")

# Matches second <div>
page.get_by_text("Hello", exact=True)

# Matches both <div>s
page.get_by_text(re.compile("Hello"))

# Matches second <div>
page.get_by_text(re.compile("^hello$", re.IGNORECASE))

```

### example_cbf4890335f3140b7b275bdad85b330140e5fbb21e7f4b89643c73115ee62a17

```
# Matches <span>
page.get_by_text("world")

# Matches first <div>
page.get_by_text("Hello world")

# Matches second <div>
page.get_by_text("Hello", exact=True)

# Matches both <div>s
page.get_by_text(re.compile("Hello"))

# Matches second <div>
page.get_by_text(re.compile("^hello$", re.IGNORECASE))

```

### example_4b7e4ce2b2fdb7e75c2145e4ba89216e4cbd2892caff1b05189e8729d3aa8dfb

```
locator = page.frame_locator("my-frame").get_by_text("Submit")
locator.click()

```

### example_12733f9ff809e08435510bc818e9a4194f9f89cbf6de5c38bfb3e1dca9e72565

```
frameLocator = locator.frame_locator(":scope")

```

### example_cbf4890335f3140b7b275bdad85b330140e5fbb21e7f4b89643c73115ee62a17

```
# Matches <span>
page.get_by_text("world")

# Matches first <div>
page.get_by_text("Hello world")

# Matches second <div>
page.get_by_text("Hello", exact=True)

# Matches both <div>s
page.get_by_text(re.compile("Hello"))

# Matches second <div>
page.get_by_text(re.compile("^hello$", re.IGNORECASE))

```
