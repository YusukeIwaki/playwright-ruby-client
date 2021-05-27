---
sidebar_position: 10
---

# JSHandle

JSHandle represents an in-page JavaScript object. JSHandles can be created with the [Page#evaluate_handle](./page#evaluate_handle)
method.

```python sync title=example_c408a96b8ac9c9bd54d915009c8b477eb75b7bf9e879fd76b32f3d4b6340a667.py
window_handle = page.evaluate_handle("window")
# ...

```

JSHandle prevents the referenced JavaScript object being garbage collected unless the handle is exposed with
[JSHandle#dispose](./js_handle#dispose). JSHandles are auto-disposed when their origin frame gets navigated or the parent context
gets destroyed.

JSHandle instances can be used as an argument in [Page#eval_on_selector](./page#eval_on_selector), [Page#evaluate](./page#evaluate) and
[Page#evaluate_handle](./page#evaluate_handle) methods.

## as_element

```
def as_element
```

Returns either `null` or the object handle itself, if the object handle is an instance of [ElementHandle](./element_handle).

## dispose

```
def dispose
```

The `jsHandle.dispose` method stops referencing the element handle.

## evaluate

```
def evaluate(expression, arg: nil)
```

Returns the return value of `expression`.

This method passes this handle as the first argument to `expression`.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then `handle.evaluate` would wait for the promise to resolve and return its value.

Examples:

```python sync title=example_2400f96eaaed3bc6ef6b0a16ba48e83d38a166c7d55a5dba0025472cffc6f2be.py
tweet_handle = page.query_selector(".tweet .retweets")
assert tweet_handle.evaluate("node => node.innerText") == "10 retweets"

```



## evaluate_handle

```
def evaluate_handle(expression, arg: nil)
```

Returns the return value of `expression` as a [JSHandle](./js_handle).

This method passes this handle as the first argument to `expression`.

The only difference between `jsHandle.evaluate` and `jsHandle.evaluateHandle` is that `jsHandle.evaluateHandle` returns
[JSHandle](./js_handle).

If the function passed to the `jsHandle.evaluateHandle` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then `jsHandle.evaluateHandle` would wait
for the promise to resolve and return its value.

See [Page#evaluate_handle](./page#evaluate_handle) for more details.

## get_properties

```
def get_properties
```

The method returns a map with **own property names** as keys and JSHandle instances for the property values.

```python sync title=example_8292f0e8974d97d20be9bb303d55ccd2d50e42f954e0ada4958ddbef2c6c2977.py
handle = page.evaluate_handle("{window, document}")
properties = handle.get_properties()
window_handle = properties.get("window")
document_handle = properties.get("document")
handle.dispose()

```



## get_property

```
def get_property(propertyName)
```

Fetches a single property from the referenced object.

## json_value

```
def json_value
```

Returns a JSON representation of the object. If the object has a `toJSON` function, it **will not be called**.

> NOTE: The method will return an empty JSON object if the referenced object is not stringifiable. It will throw an
error if the object has circular references.
