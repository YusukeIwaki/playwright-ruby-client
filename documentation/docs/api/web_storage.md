---
sidebar_position: 10
---

# WebStorage


WebStorage exposes the page's `localStorage` or `sessionStorage` for the current origin via an async,
[browser-consistent](https://developer.mozilla.org/en-US/docs/Web/API/Storage) API.

Instances are accessed through [Page#local_storage](./page#local_storage) and [Page#session_storage](./page#session_storage).

```ruby
page.goto("https://example.com")
page.local_storage.set_item("token", "abc")
token = page.local_storage.get_item("token")
all = page.local_storage.items
page.local_storage.remove_item("token")
page.local_storage.clear
```

## items

```
def items
```


Returns all items in the storage as name/value pairs.

## get_item

```
def get_item(name)
```


Returns the value for the given `name` if present.

## set_item

```
def set_item(name, value)
```


Sets the value for the given `name`. Overwrites any existing value for that name.

## remove_item

```
def remove_item(name)
```


Removes the item with the given `name`. No-op if the item is absent.

## clear

```
def clear
```


Removes all items from the storage.
