# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_aa1d7ed6650f37a2ef8a00945f0f328896eae665418b6758a9e24fcc4c7bcd83 (Clock#fast_forward)

```
page.clock.fast_forward(1000)
page.clock.fast_forward("30:00")

```

### example_ce3b9a2e3e9e37774d4176926f5aa8ddf76d8c2b3ef27d8d8f82068dd3720a48 (Clock#run_for)

```
page.clock.run_for(1000);
page.clock.run_for("30:00")

```

### example_e3bfa88ff84efbef1546730c2046e627141c6cd5f09c54dc2cf0e07cbb17c0b5 (Clock#pause_at)

```
page.clock.pause_at(datetime.datetime(2020, 2, 2))
page.clock.pause_at("2020-02-02")

```

### example_612285ca3970e44df82608ceff6f6b9ae471b0f7860b60916bbaefd327dd2ffd (Clock#set_fixed_time)

```
page.clock.set_fixed_time(datetime.datetime.now())
page.clock.set_fixed_time(datetime.datetime(2020, 2, 2))
page.clock.set_fixed_time("2020-02-02")

```

### example_1f707241c9dfcb70391f40269feeb3e50099815e43b9742bba738b72defae04f (Clock#set_system_time)

```
page.clock.set_system_time(datetime.datetime.now())
page.clock.set_system_time(datetime.datetime(2020, 2, 2))
page.clock.set_system_time("2020-02-02")

```

### example_13746919ebdd1549604b1a2c4a6cc9321ba9d0728c281be6f1d10d053fc44108 (Page#expect_response)

```
with page.expect_response("https://example.com/resource") as response_info:
    page.get_by_text("trigger response").click()
response = response_info.value
return response.ok

# or with a lambda
with page.expect_response(lambda response: response.url == "https://example.com" and response.status == 200 and response.request.method == "get") as response_info:
    page.get_by_text("trigger response").click()
response = response_info.value
return response.ok

```

### example_923b47ff333a782480c31d60370a4f2d7a0970a65490cb831f51efaf67f9c07e (Browser#contexts)

```
browser = pw.webkit.launch()
print(len(browser.contexts)) # prints `0`
context = browser.new_context()
print(len(browser.contexts)) # prints `1`

```

### example_eef80d0e7a868da02c471a2a562e27511ce74abc91865c1daab36b6f4835bd3c (Locator#set_input_files)

```
# Select one file
page.get_by_label("Upload file").set_input_files('myfile.pdf')

# Select multiple files
page.get_by_label("Upload files").set_input_files(['file1.txt', 'file2.txt'])

# Select a directory
page.get_by_label("Upload directory").set_input_files('mydir')

# Remove all the selected files
page.get_by_label("Upload file").set_input_files([])

# Upload buffer from memory
page.get_by_label("Upload file").set_input_files(
    files=[
        {"name": "test.txt", "mimeType": "text/plain", "buffer": b"this is a test"}
    ],
)

```
