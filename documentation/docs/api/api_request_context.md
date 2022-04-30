---
sidebar_position: 10
---

# APIRequestContext

This API is used for the Web API testing. You can use it to trigger API endpoints, configure micro-services, prepare
environment or the service to your e2e test.

Each Playwright browser context has associated with it [APIRequestContext](./api_request_context) instance which shares cookie storage with the
browser context and can be accessed via [BrowserContext#request](./browser_context#request) or [Page#request](./page#request). It is also
possible to create a new APIRequestContext instance manually by calling [APIRequest#new_context](./api_request#new_context).

**Cookie management**

[APIRequestContext](./api_request_context) retuned by [BrowserContext#request](./browser_context#request) and [Page#request](./page#request) shares cookie storage
with the corresponding [BrowserContext](./browser_context). Each API request will have `Cookie` header populated with the values from the
browser context. If the API response contains `Set-Cookie` header it will automatically update [BrowserContext](./browser_context) cookies
and requests made from the page will pick them up. This means that if you log in using this API, your e2e test will be
logged in and vice versa.

If you want API requests to not interfere with the browser cookies you shoud create a new [APIRequestContext](./api_request_context) by calling
[APIRequest#new_context](./api_request#new_context). Such [APIRequestContext](./api_request_context) object will have its own isolated cookie storage.

```ruby
playwright.chromium.launch do |browser|
  # This will launch a new browser, create a context and page. When making HTTP
  # requests with the internal APIRequestContext (e.g. `context.request` or `page.request`)
  # it will automatically set the cookies to the browser page and vise versa.
  context = browser.new_context(base_url: 'https://api.github,com')
  api_request_context = context.request


  # Create a repository.
  response = api_request_context.post(
    "/user/repos",
    headers: {
      "Accept": "application/vnd.github.v3+json",
      "Authorization": "Bearer #{API_TOKEN}",
    },
    data: { name: 'test-repo-1' },
  )
  response.ok? # => true
  response.json['name'] # => "test-repo-1"

  # Delete a repository.
  response = api_request_context.delete(
    "/repos/YourName/test-repo-1",
    headers: {
      "Accept": "application/vnd.github.v3+json",
      "Authorization": "Bearer #{API_TOKEN}",
    },
  )
  response.ok? # => true
end
```


## delete

```
def delete(
      url,
      data: nil,
      failOnStatusCode: nil,
      form: nil,
      headers: nil,
      ignoreHTTPSErrors: nil,
      multipart: nil,
      params: nil,
      timeout: nil)
```

Sends HTTP(S) [DELETE](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/DELETE) request and returns its
response. The method will populate request cookies from the context and update context cookies from the response. The
method will automatically follow redirects.

## dispose

```
def dispose
```

All responses returned by [APIRequestContext#get](./api_request_context#get) and similar methods are stored in the memory, so that you
can later call [APIResponse#body](./api_response#body). This method discards all stored responses, and makes
[APIResponse#body](./api_response#body) throw "Response disposed" error.

## fetch

```
def fetch(
      urlOrRequest,
      data: nil,
      failOnStatusCode: nil,
      form: nil,
      headers: nil,
      ignoreHTTPSErrors: nil,
      method: nil,
      multipart: nil,
      params: nil,
      timeout: nil)
```

Sends HTTP(S) request and returns its response. The method will populate request cookies from the context and update
context cookies from the response. The method will automatically follow redirects.

## get

```
def get(
      url,
      failOnStatusCode: nil,
      headers: nil,
      ignoreHTTPSErrors: nil,
      params: nil,
      timeout: nil)
```

Sends HTTP(S) [GET](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/GET) request and returns its response. The
method will populate request cookies from the context and update context cookies from the response. The method will
automatically follow redirects.

## head

```
def head(
      url,
      failOnStatusCode: nil,
      headers: nil,
      ignoreHTTPSErrors: nil,
      params: nil,
      timeout: nil)
```

Sends HTTP(S) [HEAD](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/HEAD) request and returns its response.
The method will populate request cookies from the context and update context cookies from the response. The method will
automatically follow redirects.

## patch

```
def patch(
      url,
      data: nil,
      failOnStatusCode: nil,
      form: nil,
      headers: nil,
      ignoreHTTPSErrors: nil,
      multipart: nil,
      params: nil,
      timeout: nil)
```

Sends HTTP(S) [PATCH](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/PATCH) request and returns its response.
The method will populate request cookies from the context and update context cookies from the response. The method will
automatically follow redirects.

## post

```
def post(
      url,
      data: nil,
      failOnStatusCode: nil,
      form: nil,
      headers: nil,
      ignoreHTTPSErrors: nil,
      multipart: nil,
      params: nil,
      timeout: nil)
```

Sends HTTP(S) [POST](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/POST) request and returns its response.
The method will populate request cookies from the context and update context cookies from the response. The method will
automatically follow redirects.

## put

```
def put(
      url,
      data: nil,
      failOnStatusCode: nil,
      form: nil,
      headers: nil,
      ignoreHTTPSErrors: nil,
      multipart: nil,
      params: nil,
      timeout: nil)
```

Sends HTTP(S) [PUT](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/PUT) request and returns its response. The
method will populate request cookies from the context and update context cookies from the response. The method will
automatically follow redirects.
