---
sidebar_position: 10
---

# APIRequestContext

This API is used for the Web API testing. You can use it to trigger API endpoints, configure micro-services, prepare
environment or the service to your e2e test. When used on [Page](./page) or a [BrowserContext](./browser_context), this API will automatically use
the cookies from the corresponding [BrowserContext](./browser_context). This means that if you log in using this API, your e2e test will be
logged in and vice versa.

```python sync title=example_6db210740dd2dcb4551c2207b3204fde7127b24c7850226b273d15c0d6624ba5.py
import os
from playwright.sync_api import sync_playwright

REPO = "test-repo-1"
USER = "github-username"
API_TOKEN = os.getenv("GITHUB_API_TOKEN")

with sync_playwright() as p:
    # This will launch a new browser, create a context and page. When making HTTP
    # requests with the internal APIRequestContext (e.g. `context.request` or `page.request`)
    # it will automatically set the cookies to the browser page and vise versa.
    browser = playwright.chromium.launch()
    context = browser.new_context(base_url="https://api.github.com")
    api_request_context = context.request
    page = context.new_page()

    # Alternatively you can create a APIRequestContext manually without having a browser context attached:
    # api_request_context = playwright.request.new_context(base_url="https://api.github.com")


    # Create a repository.
    response = api_request_context.post(
        "/user/repos",
        headers={
            "Accept": "application/vnd.github.v3+json",
            # Add GitHub personal access token.
            "Authorization": f"token {API_TOKEN}",
        },
        data={"name": REPO},
    )
    assert response.ok
    assert response.json()["name"] == REPO

    # Delete a repository.
    response = api_request_context.delete(
        f"/repos/{USER}/{REPO}",
        headers={
            "Accept": "application/vnd.github.v3+json",
            # Add GitHub personal access token.
            "Authorization": f"token {API_TOKEN}",
        },
    )
    assert response.ok
    assert await response.body() == '{"status": "ok"}'

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
