---
sidebar_position: 10
---

# FileChooser

[FileChooser](./file_chooser) objects are dispatched by the page in the [`event: Page.fileChooser`] event.

```py title=example_7a1d0490f41c1b1ab1ebd7495fafd769b4f337b4755d19af4785796c8ac3e121.py
async with page.expect_file_chooser() as fc_info:
    await page.get_by_text("Upload file").click()
file_chooser = await fc_info.value
await file_chooser.set_files("myfile.pdf")

```

```py title=example_e33aff4cd491e76d860c1c5498a25a331b0b99cae9c161baeea0f3190552e2d1.py
with page.expect_file_chooser() as fc_info:
    page.get_by_text("Upload file").click()
file_chooser = fc_info.value
file_chooser.set_files("myfile.pdf")

```



## element

```
def element
```

Returns input element associated with this file chooser.

## multiple?

```
def multiple?
```

Returns whether this file chooser accepts multiple files.

## page

```
def page
```

Returns page this file chooser belongs to.

## set_files

```
def set_files(files, noWaitAfter: nil, timeout: nil)
```
alias: `files=`

Sets the value of the file input this chooser is associated with. If some of the `filePaths` are relative paths,
then they are resolved relative to the current working directory. For empty array, clears the selected files.
