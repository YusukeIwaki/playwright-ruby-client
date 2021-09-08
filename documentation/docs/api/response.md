---
sidebar_position: 10
---

# Response

[Response](./response) class represents responses which are received by page.

## body

```
def body
```

Returns the buffer with response body.

## finished

```
def finished
```

Waits for this response to finish, returns failure error if request failed.

## frame

```
def frame
```

Returns the [Frame](./frame) that initiated this response.

## headers

```
def headers
```

**DEPRECATED** Incomplete list of headers as seen by the rendering engine. Use [Response#all_headers](./response#all_headers) instead.

## headers_array

```
def headers_array
```

An array with all the request HTTP headers associated with this response. Unlike [Response#all_headers](./response#all_headers), header
names are not lower-cased. Headers with multiple entries, such as `Set-Cookie`, appear in the array multiple times.

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

## request

```
def request
```

Returns the matching [Request](./request) object.

## security_details

```
def security_details
```

Returns SSL and other security information.

## server_addr

```
def server_addr
```

Returns the IP address and port of the server.

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
