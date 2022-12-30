---
sidebar_position: 10
---

# APIResponse

[APIResponse](./api_response) class represents responses returned by [APIRequestContext#get](./api_request_context#get) and similar methods.

```py title=example_4f0529be9a259a20e30c3048d99dfc039ddb85955b57f7d4537067cd202e110c.py
import asyncio
from playwright.async_api import async_playwright, Playwright

async def run(playwright: Playwright):
    context = await playwright.request.new_context()
    response = await context.get("https://example.com/user/repos")
    assert response.ok
    assert response.status == 200
    assert response.headers["content-type"] == "application/json; charset=utf-8"
    assert response.json()["name"] == "foobar"
    assert await response.body() == '{"status": "ok"}'


async def main():
    async with async_playwright() as playwright:
        await run(playwright)

asyncio.run(main())

```

```py title=example_d3853ee82c5e37c48d2014a4a0044137503aaeebb1ecad637f435e289ca5314e.py
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    context = playwright.request.new_context()
    response = context.get("https://example.com/user/repos")
    assert response.ok
    assert response.status == 200
    assert response.headers["content-type"] == "application/json; charset=utf-8"
    assert response.json()["name"] == "foobar"
    assert response.body() == '{"status": "ok"}'

```


## body

```
def body
```

Returns the buffer with response body.

## dispose

```
def dispose
```

Disposes the body of this response. If not called then the body will stay in memory until the context closes.

## headers

```
def headers
```

An object with all the response HTTP headers associated with this response.

## headers_array

```
def headers_array
```

An array with all the request HTTP headers associated with this response. Header names are not lower-cased. Headers
with multiple entries, such as `Set-Cookie`, appear in the array multiple times.

## json

```
def json
```

Returns the JSON representation of response body.

This method will throw if the response body is not parsable via `JSON.parse`.

## ok

```
def ok
```

Contains a boolean stating whether the response was successful (status in the range 200-299) or not.

## status

```
def status
```

Contains the status code of the response (e.g., 200 for a success).

## status_text

```
def status_text
```

Contains the status text of the response (e.g. usually an "OK" for a success).

## text

```
def text
```

Returns the text representation of response body.

## url

```
def url
```

Contains the URL of the response.
