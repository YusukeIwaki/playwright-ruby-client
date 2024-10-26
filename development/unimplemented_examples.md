# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_388f0632ba64c07369bdd5e8fe0bfaf07d94a1b576444d4045d9787b2672e7d8 (FrameLocator)

```
locator = page.locator("my-frame").content_frame.get_by_text("Submit")
locator.click()

```

### example_32979c158691d02e6365a178a0ac9443ee6ef2b870815f0930199e8f39c43a5f (FrameLocator)

```
# Throws if there are several frames in DOM:
page.locator('.result-frame').content_frame.get_by_role('button').click()

# Works because we explicitly tell locator to pick the first frame:
page.locator('.result-frame').first.content_frame.get_by_role('button').click()

```

### example_a9d648fee9c328e08fc365f5f04a073d479a0b068248ac49cd10e4a0a2ce561b (FrameLocator#owner)

```
frame_locator = page.locator("iframe[name=\"embedded\"]").content_frame
# ...
locator = frame_locator.owner
expect(locator).to_be_visible()

```
