# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_62dfcdbf7cb03feca462cfd43ba72022e8c7432f93d9566ad1abde69ec3f7666

```
def handle(route):
    response = route.fetch()
    json = response.json()
    json["message"]["big_red_dog"] = []
    route.fulfill(response=response, json=json)

page.route("https://dog.ceo/api/breeds/list/all", handle)

```

### example_40a7d124045a4f729e0deddcfb511b9232ada7f16e0caa4e07ea083c2bfd3c16

```
page.get_by_alt_text("Playwright logo").click()

```

### example_c19c4ba9cb058cdfedf7fd87eb1634459f0b62d9ee872e61272414b0fb69a01c

```
page.get_by_label("Password").fill("secret")

```

### example_c521b79be0a480325f84dc2c110a9803f0d74b2042da32c84660abe90ab7bb37

```
page.get_by_placeholder("name@example.com").fill("playwright@microsoft.com")

```

### example_d0da510d996da8a4b3e0505412b0b651049ab11b56317300ba3dc52e928500b3

```
expect(page.get_by_role("heading", name="Sign up")).to_be_visible()

page.get_by_role("checkbox", name="Subscribe").check()

page.get_by_role("button", name=re.compile("submit", re.IGNORECASE)).click()

```

### example_291583061a6a67f91ea5f926eac4b5cd6c351d7009ddfef39b52efba03909ca0

```
page.get_by_test_id("directions").click()

```

### example_0aecb761822601bd6adf174c0aeb9db69bf4880a62eb4a1cdeb67c2f57c7149e

```
expect(page.get_by_title("Issues count")).to_have_text("25 issues")

```

### example_40a7d124045a4f729e0deddcfb511b9232ada7f16e0caa4e07ea083c2bfd3c16

```
page.get_by_alt_text("Playwright logo").click()

```

### example_c19c4ba9cb058cdfedf7fd87eb1634459f0b62d9ee872e61272414b0fb69a01c

```
page.get_by_label("Password").fill("secret")

```

### example_c521b79be0a480325f84dc2c110a9803f0d74b2042da32c84660abe90ab7bb37

```
page.get_by_placeholder("name@example.com").fill("playwright@microsoft.com")

```

### example_d0da510d996da8a4b3e0505412b0b651049ab11b56317300ba3dc52e928500b3

```
expect(page.get_by_role("heading", name="Sign up")).to_be_visible()

page.get_by_role("checkbox", name="Subscribe").check()

page.get_by_role("button", name=re.compile("submit", re.IGNORECASE)).click()

```

### example_291583061a6a67f91ea5f926eac4b5cd6c351d7009ddfef39b52efba03909ca0

```
page.get_by_test_id("directions").click()

```

### example_0aecb761822601bd6adf174c0aeb9db69bf4880a62eb4a1cdeb67c2f57c7149e

```
expect(page.get_by_title("Issues count")).to_have_text("25 issues")

```

### example_db3fbc8764290dcac5864a6d11dae6643865e74e0d1bb7e6a00ce777321a0b2f

```
texts = page.get_by_role("link").all_inner_texts()

```

### example_46e7add209e0c75ea54b931e47cefd095d989d034e76ec8918939e0f47b89ca3

```
texts = page.get_by_role("link").all_text_contents()

```

### example_09bf5cd40405b9e5cd84333743b6ef919d0714bb4da78c86404789d26ff196ae

```
box = page.get_by_role("button").bounding_box()
page.mouse.click(box["x"] + box["width"] / 2, box["y"] + box["height"] / 2)

```

### example_17dff0bf6d8bc93d2e17be7fd1c1231ee72555eabb19c063d71ee804928273a8

```
page.get_by_role("checkbox").check()

```

### example_ccddf9c70c0dd2f6eaa85f46cf99155666e5be09f98bacfca21735d25e990707

```
page.get_by_role("textbox").clear()

```

### example_0e93b0bcf462c0151fa70dfb6c3cb691c67ec10cdf0498478427a5c1d2a83521

```
page.get_by_role("button").click()

```

### example_855b70722b9c7795f29b6aa150ba7997d542adf67f9104638ca48fd680ad6d86

```
page.locator("canvas").click(
    button="right", modifiers=["Shift"], position={"x": 23, "y": 32}
)

```

### example_a711e425f2e4fe8cdd4e7ff99d609e607146ddb7b1fb5c5d8978bd0555ac1fcd

```
count = page.get_by_role("listitem").count()

```

### example_72b38530862dccd8b3ad53982f45a24a5ee82fc6e50fccec328d544bf1a78909

```
locator.dispatch_event("click")

```

### example_bf805bb1858c7b8ea50d9c52704fab32064e1c26fb608232e823fe87267a07b3

```
# note you can only create data_transfer in chromium and firefox
data_transfer = page.evaluate_handle("new DataTransfer()")
locator.dispatch_event("#source", "dragstart", {"dataTransfer": data_transfer})

```

### example_877178e12857c7b3ef09f6c50606489c9d9894220622379b72e1e180a2970b96

```
locator = page.locator("div")
more_than_ten = locator.evaluate_all("(divs, min) => divs.length > min", 10)

```

### example_77567051f4c8531c719eb0b94e53a061ffe9a414e3bb131cbc956d1fdcf6eab3

```
page.get_by_role("textbox").fill("example value")

```

### example_40a7d124045a4f729e0deddcfb511b9232ada7f16e0caa4e07ea083c2bfd3c16

```
page.get_by_alt_text("Playwright logo").click()

```

### example_c19c4ba9cb058cdfedf7fd87eb1634459f0b62d9ee872e61272414b0fb69a01c

```
page.get_by_label("Password").fill("secret")

```

### example_c521b79be0a480325f84dc2c110a9803f0d74b2042da32c84660abe90ab7bb37

```
page.get_by_placeholder("name@example.com").fill("playwright@microsoft.com")

```

### example_d0da510d996da8a4b3e0505412b0b651049ab11b56317300ba3dc52e928500b3

```
expect(page.get_by_role("heading", name="Sign up")).to_be_visible()

page.get_by_role("checkbox", name="Subscribe").check()

page.get_by_role("button", name=re.compile("submit", re.IGNORECASE)).click()

```

### example_291583061a6a67f91ea5f926eac4b5cd6c351d7009ddfef39b52efba03909ca0

```
page.get_by_test_id("directions").click()

```

### example_0aecb761822601bd6adf174c0aeb9db69bf4880a62eb4a1cdeb67c2f57c7149e

```
expect(page.get_by_title("Issues count")).to_have_text("25 issues")

```

### example_0a9e085f6c2ab04459adc2bf6ec73a06ff3cde201943ff8f4965552528b73f89

```
page.get_by_role("link").hover()

```

### example_bb8cec73e5210f884833e04e6d71f7c035451bafd39500e057e6d6325c990474

```
value = page.get_by_role("textbox").input_value()

```

### example_f617df59758f06107dd5c79e986aabbfde5861fbda6ccc5d8b91a508ebdc48f7

```
checked = page.get_by_role("checkbox").is_checked()

```

### example_5c008cd1a3ece779fe8c29092643a482cd0215d5c09001cd9ef08c444ea6cdd1

```
disabled = page.get_by_role("button").is_disabled()

```

### example_10e437a8b21b128feda412f1e3cf85615fe260be2ad08758a3c5e5216b46187b

```
editable = page.get_by_role("textbox").is_editable()

```

### example_69710ffa4599909a9ae6cd570a2b88f6981c064c577b1e255fe5cc21b07d033c

```
enabled = page.get_by_role("button").is_enabled()

```

### example_f25a3bde8e8a1d091d01321314daa6059cb8aa026a3c2c4be50b1611bbdb3c19

```
hidden = page.get_by_role("button").is_hidden()

```

### example_b54ab20fe81143e0242d5d001ce2b1af4a272a2cc7c9d6925551de10f46a68c4

```
visible = page.get_by_role("button").is_visible()

```

### example_37f239c3646f77e0658c12f139a5883eb99d9952f7761ad58ffb629fa385c7bb

```
banana = page.get_by_role("listitem").last()

```

### example_d6cc7c4a653d7139137c582ad853bebd92e3b97893fb6d5f88919553404c57e4

```
banana = page.get_by_role("listitem").nth(2)

```

### example_29eed7b713b928678523c677c788808779cf13dda2bb117aab2562cef3b08647

```
page.get_by_role("textbox").press("Backspace")

```

### example_43381950beaa21258e3f378d4b6aff54b83fa3eba52f36c65f4ca2d3d6df248d

```
page.get_by_role("link").screenshot()

```

### example_d787f101e95d45bbcf3184b241bab4925e68d8e5c117299d0a95bf66f19bbdaa

```
page.get_by_role("link").screenshot(animations="disabled", path="link.png")

```

### example_bab309d5b9f84c3b57a3057462dbddf7436cba6181457788c8e302d8e20aa108

```
page.get_by_role("checkbox").set_checked(True)

```

### example_f1bf5c6c31c8405ce60cee9138c6d6dc6923be52e61ff8c2a3c3d28186b72282

```
# Select one file
page.get_by_label("Upload file").set_input_files('myfile.pdf')

# Select multiple files
page.get_by_label("Upload files").set_input_files(['file1.txt', 'file2.txt'])

# Remove all the selected files
page.get_by_label("Upload file").set_input_files([])

# Upload buffer from memory
page.get_by_label("Upload file").set_input_files(
    files=[
        {"name": "test.txt", "mimeType": "text/plain", "buffer": b"this is a test"}
    ],
)

```

### example_ead0dc91ccaf4d3de1e28cccdadfacb0e75c79ffcfb8fc5a2b55afa736870fa6

```
page.get_by_role("checkbox").uncheck()

```

### example_40a7d124045a4f729e0deddcfb511b9232ada7f16e0caa4e07ea083c2bfd3c16

```
page.get_by_alt_text("Playwright logo").click()

```

### example_c19c4ba9cb058cdfedf7fd87eb1634459f0b62d9ee872e61272414b0fb69a01c

```
page.get_by_label("Password").fill("secret")

```

### example_c521b79be0a480325f84dc2c110a9803f0d74b2042da32c84660abe90ab7bb37

```
page.get_by_placeholder("name@example.com").fill("playwright@microsoft.com")

```

### example_d0da510d996da8a4b3e0505412b0b651049ab11b56317300ba3dc52e928500b3

```
expect(page.get_by_role("heading", name="Sign up")).to_be_visible()

page.get_by_role("checkbox", name="Subscribe").check()

page.get_by_role("button", name=re.compile("submit", re.IGNORECASE)).click()

```

### example_291583061a6a67f91ea5f926eac4b5cd6c351d7009ddfef39b52efba03909ca0

```
page.get_by_test_id("directions").click()

```

### example_0aecb761822601bd6adf174c0aeb9db69bf4880a62eb4a1cdeb67c2f57c7149e

```
expect(page.get_by_title("Issues count")).to_have_text("25 issues")

```
