---
sidebar_position: 10
---

# Request

Whenever the page sends a request for a network resource the following sequence of events are emitted by [Page](./page):
- [`event: Page.request`] emitted when the request is issued by the page.
- [`event: Page.response`] emitted when/if the response status and headers are received for the request.
- [`event: Page.requestFinished`] emitted when the response body is downloaded and the request is complete.

If request fails at some point, then instead of `'requestfinished'` event (and possibly instead of 'response'
event), the  [`event: Page.requestFailed`] event is emitted.

**NOTE** HTTP Error responses, such as 404 or 503, are still successful responses from HTTP standpoint, so request
will complete with `'requestfinished'` event.

If request gets a 'redirect' response, the request is successfully finished with the `requestfinished` event, and a
new request is  issued to a redirected url.

## all_headers

```
def all_headers
```

An object with all the request HTTP headers associated with this request. The header names are lower-cased.

## failure

```
def failure
```

The method returns `null` unless this request has failed, as reported by `requestfailed` event.

**Usage**

Example of logging of all the failed requests:

```ruby
page.on("requestfailed", ->(request) { puts "#{request.url} #{request.failure}" })
```



## frame

```
def frame
```

Returns the [Frame](./frame) that initiated this request.

## headers

```
def headers
```

An object with the request HTTP headers. The header names are lower-cased. Note that this method does not return
security-related headers, including cookie-related ones. You can use [Request#all_headers](./request#all_headers) for complete
list of headers that include `cookie` information.

## headers_array

```
def headers_array
```

An array with all the request HTTP headers associated with this request. Unlike [Request#all_headers](./request#all_headers),
header names are NOT lower-cased. Headers with multiple entries, such as `Set-Cookie`, appear in the array multiple
times.

## header_value

```
def header_value(name)
```

Returns the value of the header matching the name. The name is case insensitive.

## navigation_request?

```
def navigation_request?
```

Whether this request is driving frame's navigation.

## method

```
def method
```

Request's method (GET, POST, etc.)

## post_data

```
def post_data
```

Request's post body, if any.

## post_data_buffer

```
def post_data_buffer
```

Request's post body in a binary form, if any.

## post_data_json

```
def post_data_json
```

Returns parsed request's body for `form-urlencoded` and JSON as a fallback if any.

When the response is `application/x-www-form-urlencoded` then a key/value object of the values will be returned.
Otherwise it will be parsed as JSON.

## redirected_from

```
def redirected_from
```

Request that was redirected by the server to this one, if any.

When the server responds with a redirect, Playwright creates a new [Request](./request) object. The two requests are connected
by [redirected_from](./request#redirected_from) and [redirected_to](./request#redirected_to) methods. When multiple server redirects has happened, it is possible to
construct the whole redirect chain by repeatedly calling [redirected_from](./request#redirected_from).

**Usage**

For example, if the website `http://github.com` redirects to `https://github.com`:

```py title=example_b32fe2f633a7879ff5023d4a2b820d10d225ad5078a2a2034b0781159e7983a0.py
response = await page.goto("http://example.com")
print(response.request.redirected_from.url) # "http://example.com"

```

```py title=example_b33082ad183920ec77a72169c2f1b12b1f70bc70c280e761c1e9d7284a3cdd42.py
response = page.goto("http://example.com")
print(response.request.redirected_from.url) # "http://example.com"

```

If the website `https://google.com` has no redirects:

```py title=example_1a8c712da7e8a552bdda1433b80674421b2e60e5da442efd44614a17b32ce46d.py
response = await page.goto("https://google.com")
print(response.request.redirected_from) # None

```

```py title=example_edaa5af7c2aa595c532ffda589a6b75245acdc06117642455a1784d66f393235.py
response = page.goto("https://google.com")
print(response.request.redirected_from) # None

```



## redirected_to

```
def redirected_to
```

New request issued by the browser if the server responded with redirect.

**Usage**

This method is the opposite of [Request#redirected_from](./request#redirected_from):

```ruby
request.redirected_from.redirected_to # equals to request
```



## resource_type

```
def resource_type
```

Contains the request's resource type as it was perceived by the rendering engine. ResourceType will be one of the
following: `document`, `stylesheet`, `image`, `media`, `font`, `script`, `texttrack`, `xhr`, `fetch`,
`eventsource`, `websocket`, `manifest`, `other`.

## response

```
def response
```

Returns the matching [Response](./response) object, or `null` if the response was not received due to error.

## sizes

```
def sizes
```

Returns resource size information for given request.

## timing

```
def timing
```

Returns resource timing information for given request. Most of the timing values become available upon the
response, `responseEnd` becomes available when request finishes. Find more information at
[Resource Timing API](https://developer.mozilla.org/en-US/docs/Web/API/PerformanceResourceTiming).

**Usage**

```py title=example_76fa4b1944457cd4b7d2334344fefeed5000705b35d7a138cb648a1129a8a159.py
async with page.expect_event("requestfinished") as request_info:
    await page.goto("http://example.com")
request = await request_info.value
print(request.timing)

```

```py title=example_21bc2dce9e8c8b65dc1e8e1a6027ca43ec57cf5ff64deee99077733cebd62253.py
with page.expect_event("requestfinished") as request_info:
    page.goto("http://example.com")
request = request_info.value
print(request.timing)

```



## url

```
def url
```

URL of the request.
