# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_314a4cc521d931dff12aaf59a90d03d01ed5d1440e3dbddd57e526cb467d0450 (CDPSession)

```
client = page.context.new_cdp_session(page)
client.send("Animation.enable")
client.on("Animation.animationCreated", lambda: print("animation created!"))
response = client.send("Animation.getPlaybackRate")
print("playback rate is " + str(response["playbackRate"]))
client.send("Animation.setPlaybackRate", {
    "playbackRate": response["playbackRate"] / 2
})

```

### example_a583bf0ade385126b3b7e024ef012ccfc140e67d6b7fdf710ee1ba065ec6a80d (APIRequestContext#fetch)

```
api_request_context.fetch(
  "https://example.com/api/uploadScript",  method="post",
  multipart={
    "fileField": {
      "name": "f.js",
      "mimeType": "text/javascript",
      "buffer": b"console.log(2022);",
    },
  })

```

### example_1e1af87a9320d43292d33275903ecf758c730b518de1ef8149d6b47e6160b0c8 (APIRequestContext#post)

```
api_request_context.post(
  "https://example.com/api/uploadScript'",
  multipart={
    "fileField": {
      "name": "f.js",
      "mimeType": "text/javascript",
      "buffer": b"console.log(2022);",
    },
  })

```
