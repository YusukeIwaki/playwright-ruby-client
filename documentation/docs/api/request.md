---
sidebar_position: 10
---

# Request

Whenever the page sends a request for a network resource the following sequence of events are emitted by [Page](./page):
- [`event: Page.request`] emitted when the request is issued by the page.
- [`event: Page.response`] emitted when/if the response status and headers are received for the request.
- [`event: Page.requestFinished`] emitted when the response body is downloaded and the request is complete.

If request fails at some point, then instead of `'requestfinished'` event (and possibly instead of 'response' event),
the  [`event: Page.requestFailed`] event is emitted.

> NOTE: HTTP Error responses, such as 404 or 503, are still successful responses from HTTP standpoint, so request will
complete with `'requestfinished'` event.

If request gets a 'redirect' response, the request is successfully finished with the 'requestfinished' event, and a new
request is  issued to a redirected url.

## failure

```
def failure
```

The method returns `null` unless this request has failed, as reported by `requestfailed` event.

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

**DEPRECATED** Incomplete list of headers as seen by the rendering engine. Use [Request#all_headers](./request#all_headers) instead.

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

When the server responds with a redirect, Playwright creates a new [Request](./request) object. The two requests are connected by
`redirectedFrom()` and `redirectedTo()` methods. When multiple server redirects has happened, it is possible to
construct the whole redirect chain by repeatedly calling `redirectedFrom()`.

For example, if the website `http://example.com` redirects to `https://example.com`:

```ruby
response = page.goto("http://github.com")
puts response.url # => "https://github.com"
puts response.request.redirected_from&.url # => "http://github.com"
```

If the website `https://google.com` has no redirects:

```ruby
response = page.goto("https://google.com")
puts response.request.redirected_from&.url # => nil
```



## redirected_to

```
def redirected_to
```

New request issued by the browser if the server responded with redirect.

This method is the opposite of [Request#redirected_from](./request#redirected_from):

```ruby
request.redirected_from.redirected_to # equals to request
```



## resource_type

```
def resource_type
```

Contains the request's resource type as it was perceived by the rendering engine. ResourceType will be one of the
following: `document`, `stylesheet`, `image`, `media`, `font`, `script`, `texttrack`, `xhr`, `fetch`, `eventsource`,
`websocket`, `manifest`, `other`.

## response

```
def response
```

Returns the matching [Response](./response) object, or `null` if the response was not received due to error.

## sizes

```
def sizes
```

Returns resource size information for given request. Requires the response to be finished via
[Response#finished](./response#finished) to ensure the info is available.

## timing

```
def timing
```

Returns resource timing information for given request. Most of the timing values become available upon the response,
`responseEnd` becomes available when request finishes. Find more information at
[Resource Timing API](https://developer.mozilla.org/en-US/docs/Web/API/PerformanceResourceTiming).

```ruby
request = page.expect_event("requestfinished") do
  page.goto("https://example.com")
end
puts request.timing
```



## url

```
def url
```

URL of the request.
