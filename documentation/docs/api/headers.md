---
sidebar_position: 10
---

# Headers

HTTP request and response all headers collection.

## get

```
def get(name)
```



## get_all

```
def get_all(name)
```

Returns all header values for the given header name.

## header_names

```
def header_names
```

Returns all header names in this headers collection.

## headers

```
def headers
```

Returns all headers as a dictionary. Header names are normalized to lower case, multi-value headers are concatenated
using comma.
