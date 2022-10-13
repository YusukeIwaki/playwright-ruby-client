# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_19c86319c1f40a2cae90cfaf7f6471c50b59319e8b08d6e37d9be9d4697de0b8

```
data = {
    "title": "Book Title",
    "body": "John Doe",
}
api_request_context.fetch("https://example.com/api/createBook", method="post", data=data)

```

### example_c5f1dfbcb296a3bc1e1e9e0216dacb2ee7c2af8685053b9e4bb44c823d82767c

```
api_request_context.fetch(
  "https://example.com/api/uploadScrip'",
  method="post",
  multipart={
    "fileField": {
      "name": "f.js",
      "mimeType": "text/javascript",
      "buffer": b"console.log(2022);",
    },
  })

```

### example_cf0d399f908388d6949e0fd2a750800a486e56e31ddc57b5b8f685b94cccfed8

```
query_params = {
  "isbn": "1234",
  "page": "23"
}
api_request_context.get("https://example.com/api/getText", params=query_params)

```

### example_d42fb8f54175536448ed40ab14732e18bb20140493c96e5d07990ef7c200ac15

```
data = {
    "title": "Book Title",
    "body": "John Doe",
}
api_request_context.post("https://example.com/api/createBook", data=data)

```

### example_858c53bcbc4088deffa2489935a030bb6a485ae8927e43b393b38fd7e4414c17

```
formData = {
    "title": "Book Title",
    "body": "John Doe",
}
api_request_context.post("https://example.com/api/findBook", form=formData)

```

### example_3a940e5f148822e63981b92e0dd21748d81cdebc826935849d9fa08723fbccdc

```
api_request_context.post(
  "https://example.com/api/uploadScrip'",
  multipart={
    "fileField": {
      "name": "f.js",
      "mimeType": "text/javascript",
      "buffer": b"console.log(2022);",
    },
  })

```
