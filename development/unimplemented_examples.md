# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_df65eb1dce081c61ad27e6322e441a7713c18bd842cd9c7d5f9c685ce987a5b6 (Keyboard)

```
page.keyboard.press("ControlOrMeta+A")

```

### example_8abc1c4dd851cb7563f1f6b6489ebdc31d783b4eadbb48b0bfa0cfd2a993f788 (Page#emulate_media)

```
page.emulate_media(color_scheme="dark")
page.evaluate("matchMedia('(prefers-color-scheme: dark)').matches")
# → True
page.evaluate("matchMedia('(prefers-color-scheme: light)').matches")
# → False

```
