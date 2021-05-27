---
sidebar_position: 10
---

# FileChooser

[FileChooser](./file_chooser) objects are dispatched by the page in the [`event: Page.fileChooser`] event.

```python sync title=example_371975841dd417527a865b1501e3a8ba40f905b895cf3317ca90d9890e980843.py
with page.expect_file_chooser() as fc_info:
    page.click("upload")
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

Sets the value of the file input this chooser is associated with. If some of the `filePaths` are relative paths, then
they are resolved relative to the the current working directory. For empty array, clears the selected files.
