---
sidebar_position: 10
---

# APIRequest


Exposes API that can be used for the Web API testing. This class is used for creating
[APIRequestContext](./api_request_context) instance which in turn can be used for sending web requests. An instance
of this class can be obtained via [Playwright#request](./playwright#request). For more information
see [APIRequestContext](./api_request_context).

## new_context

```
def new_context(
      baseURL: nil,
      clientCertificates: nil,
      extraHTTPHeaders: nil,
      failOnStatusCode: nil,
      httpCredentials: nil,
      ignoreHTTPSErrors: nil,
      maxRedirects: nil,
      proxy: nil,
      storageState: nil,
      timeout: nil,
      userAgent: nil)
```


Creates new instances of [APIRequestContext](./api_request_context).
