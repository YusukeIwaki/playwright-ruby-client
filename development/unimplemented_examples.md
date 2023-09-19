# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_c247767083cf193df26a39a61a3a8bc19d63ed5c24db91b88c50b7d37975005d (Download)

```
# Start waiting for the download
with page.expect_download() as download_info:
    # Perform the action that initiates download
    page.get_by_text("Download file").click()
download = download_info.value

# Wait for the download process to complete and save the downloaded file somewhere
download.save_as("/path/to/save/at/" + download.suggested_filename)

```

### example_66ffd4ef7286957e4294d84b8f660ff852c87af27a56b3e4dd9f84562b5ece02 (Download#save_as)

```
download.save_as("/path/to/save/at/" + download.suggested_filename)

```

### example_1b7781d5527574a18d4b9812e3461203d2acc9ba7e09cbfd0ffbc4154e3f5971 (Locator#press_sequentially)

```
locator.press_sequentially("hello") # types instantly
locator.press_sequentially("world", delay=100) # types slower, like a user

```

### example_cc0a6b9aa95b97e5c17c4b114da10a29c7f6f793e99aee1ea2703636af6e24f9 (Locator#press_sequentially)

```
locator = page.get_by_label("Password")
locator.press_sequentially("my password")
locator.press("Enter")

```
