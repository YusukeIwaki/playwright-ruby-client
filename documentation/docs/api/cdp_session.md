---
sidebar_position: 10
---

# CDPSession

- extends: [EventEmitter]

The [CDPSession](./cdp_session) instances are used to talk raw Chrome Devtools Protocol:
- protocol methods can be called with `session.send_message` method.
- protocol events can be subscribed to with `session.on` method.

Useful links:
- Documentation on DevTools Protocol can be found here:
  [DevTools Protocol Viewer](https://chromedevtools.github.io/devtools-protocol/).
- Getting Started with DevTools Protocol:
  https://github.com/aslushnikov/getting-started-with-cdp/blob/master/README.md

```py title=example_5a71b3279416804f1a19f525b52e755d10f0019943360d0ca6394f03e15f3a59.py
client = await page.context.new_cdp_session(page)
await client.send("Animation.enable")
client.on("Animation.animationCreated", lambda: print("animation created!"))
response = await client.send("Animation.getPlaybackRate")
print("playback rate is " + str(response["playbackRate"]))
await client.send("Animation.setPlaybackRate", {
    playbackRate: response["playbackRate"] / 2
})

```

```py title=example_fc0ffd4be81e3c4dac4dc6965d540a5656d93969a14f864fa722f037252b2848.py
client = page.context.new_cdp_session(page)
client.send("Animation.enable")
client.on("Animation.animationCreated", lambda: print("animation created!"))
response = client.send("Animation.getPlaybackRate")
print("playback rate is " + str(response["playbackRate"]))
client.send("Animation.setPlaybackRate", {
    playbackRate: response["playbackRate"] / 2
})

```


## detach

```
def detach
```

Detaches the CDPSession from the target. Once detached, the CDPSession object won't emit any events and can't be
used to send messages.

## send_message

```
def send_message(method, params: nil)
```


