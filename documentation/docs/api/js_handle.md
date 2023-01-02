---
sidebar_position: 10
---

# JSHandle

JSHandle represents an in-page JavaScript object. JSHandles can be created with the [Page#evaluate_handle](./page#evaluate_handle)
method.

```py title=example_17146524853cd5b870cf5c993385a7126575cf88028e7d90169004a05aa04837.py
window_handle = await page.evaluate_handle("window")
# ...

```

```py title=example_3c7d10533f6a8963517e3163c66a67a91d9a8949f5ec46eff99a34c00f0d7b44.py
window_handle = page.evaluate_handle("window")
# ...

```

JSHandle prevents the referenced JavaScript object being garbage collected unless the handle is exposed with
[JSHandle#dispose](./js_handle#dispose). JSHandles are auto-disposed when their origin frame gets navigated or the parent
context gets destroyed.

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

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then `handle.evaluate` would wait for the promise to resolve and return its
value.

**Usage**

```py title=example_74096f4c9d345dfdae2af95915fa304cfa139510c2609f4922da0f226438c1a7.py
tweet_handle = await page.query_selector(".tweet .retweets")
assert await tweet_handle.evaluate("node => node.innerText") == "10 retweets"

```

```py title=example_ce17e3fa4ba162c686f91326e6eb216dc476d2193eb618d4755bd0bb5d6e8ca9.py
tweet_handle = page.query_selector(".tweet .retweets")
assert tweet_handle.evaluate("node => node.innerText") == "10 retweets"

```



## evaluate_handle

```
def evaluate_handle(expression, arg: nil)
```

Returns the return value of `expression` as a [JSHandle](./js_handle).

This method passes this handle as the first argument to `expression`.

The only difference between [JSHandle#evaluate](./js_handle#evaluate) and [JSHandle#evaluate_handle](./js_handle#evaluate_handle) is that [JSHandle#evaluate_handle](./js_handle#evaluate_handle)
returns [JSHandle](./js_handle).

If the function passed to the [JSHandle#evaluate_handle](./js_handle#evaluate_handle) returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [JSHandle#evaluate_handle](./js_handle#evaluate_handle) would
wait for the promise to resolve and return its value.

See [Page#evaluate_handle](./page#evaluate_handle) for more details.

## get_properties

```
def get_properties
```
alias: `properties`

The method returns a map with **own property names** as keys and JSHandle instances for the property values.

**Usage**

```py title=example_bcf32c51c8d6ea2c9147accc061ad381155e791596499a2fc217c37ac35d06ca.py
handle = await page.evaluate_handle("({window, document})")
properties = await handle.get_properties()
window_handle = properties.get("window")
document_handle = properties.get("document")
await handle.dispose()

```

```py title=example_cb9a1c6393e8de14b45b2797c873237d62c714015fb69c5b8cd32a6cfc7159f2.py
handle = page.evaluate_handle("({window, document})")
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

**NOTE** The method will return an empty JSON object if the referenced object is not stringifiable. It will throw
an error if the object has circular references.
