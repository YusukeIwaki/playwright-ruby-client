---
sidebar_position: 10
---

# Download

[Download](./download) objects are dispatched by page via the [`event: Page.download`] event.

All the downloaded files belonging to the browser context are deleted when the browser context is closed.

Download event is emitted once the download starts. Download path becomes available once download completes:

```python sync title=example_26c9f5a18a58f9976e24d83a3ae807479df5e28de9028f085615d99be2cea5a1.py
with page.expect_download() as download_info:
    page.get_by_text("Download file").click()
download = download_info.value
# wait for download to complete
path = download.path()

```



## cancel

```
def cancel
```

Cancels a download. Will not fail if the download is already finished or canceled. Upon successful cancellations,
`download.failure()` would resolve to `'canceled'`.

## delete

```
def delete
```

Deletes the downloaded file. Will wait for the download to finish if necessary.

## failure

```
def failure
```

Returns download error if any. Will wait for the download to finish if necessary.

## page

```
def page
```

Get the page that the download belongs to.

## path

```
def path
```

Returns path to the downloaded file in case of successful download. The method will wait for the download to finish if
necessary. The method throws when connected remotely.

Note that the download's file name is a random GUID, use [Download#suggested_filename](./download#suggested_filename) to get suggested file
name.

## save_as

```
def save_as(path)
```

Copy the download to a user-specified path. It is safe to call this method while the download is still in progress. Will
wait for the download to finish if necessary.

## suggested_filename

```
def suggested_filename
```

Returns suggested filename for this download. It is typically computed by the browser from the
[`Content-Disposition`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Disposition) response header
or the `download` attribute. See the spec on [whatwg](https://html.spec.whatwg.org/#downloading-resources). Different
browsers can use different logic for computing it.

## url

```
def url
```

Returns downloaded url.
