---
sidebar_position: 10
---

# CDPSession

- extends: [EventEmitter]

The [CDPSession](./cdp_session) instances are used to talk raw Chrome Devtools Protocol:
- protocol methods can be called with `session.send` method.
- protocol events can be subscribed to with `session.on` method.

Useful links:
- Documentation on DevTools Protocol can be found here:
  [DevTools Protocol Viewer](https://chromedevtools.github.io/devtools-protocol/).
- Getting Started with DevTools Protocol:
  https://github.com/aslushnikov/getting-started-with-cdp/blob/master/README.md

```python sync title=example_bed004cd0b9cde7e172522563fa7a2be13934496c0789c7f9067c3c4e1ee9ded.py
client = page.context().new_cdp_session(page)
client.send("animation.enable")
client.on("animation.animation_created", lambda: print("animation created!"))
response = client.send("animation.get_playback_rate")
print("playback rate is " + response["playback_rate"])
client.send("animation.set_playback_rate", {
    playback_rate: response["playback_rate"] / 2
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


