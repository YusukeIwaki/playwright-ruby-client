# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_1a49593581cd5207e8a467122ebd57b2918fb8724f8814426852556924e4c597 (Request#frame)

```
frame_url = request.frame.url

```

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
