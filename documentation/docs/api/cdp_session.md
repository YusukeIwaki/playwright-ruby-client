---
sidebar_position: 10
---

# CDPSession

- extends: [EventEmitter]

The [CDPSession](./cdp_session) instances are used to talk raw Chrome Devtools Protocol:
- protocol methods can be called with `session.send_message` method.
- protocol events can be subscribed to with `session.on` method.

Useful links:
- Documentation on DevTools Protocol can be found here: [DevTools Protocol Viewer](https://chromedevtools.github.io/devtools-protocol/).
- Getting Started with DevTools Protocol: https://github.com/aslushnikov/getting-started-with-cdp/blob/master/README.md

```python title="example_314a4cc521d931dff12aaf59a90d03d01ed5d1440e3dbddd57e526cb467d0450.py"
client = page.context.new_cdp_session(page)
client.send("Animation.enable")
client.on("Animation.animationCreated", lambda: print("animation created!"))
response = client.send("Animation.getPlaybackRate")
print("playback rate is " + str(response["playbackRate"]))
client.send("Animation.setPlaybackRate", {
    "playbackRate": response["playbackRate"] / 2
})

```

## detach

```
def detach
```


Detaches the CDPSession from the target. Once detached, the CDPSession object won't emit any events and can't be used to
send messages.

## send_message

```
def send_message(method, params: nil)
```


