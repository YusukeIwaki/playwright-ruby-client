---
sidebar_position: 10
---

# FileChooser

[FileChooser](./file_chooser) objects are dispatched by the page in the [`event: Page.fileChooser`] event.
```python sync title=example_b43c3f24b4fb04caf6c90bd75037e31ef5e16331e30b7799192f4cc0ad450778.py
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

Sets the value of the file input this chooser is associated with. If some of the `filePaths` are relative paths, then
they are resolved relative to the current working directory. For empty array, clears the selected files.
