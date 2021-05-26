---
sidebar_position: 10
---

# Android

Playwright has **experimental** support for Android automation. You can access android namespace via:

An example of the Android automation script would be:

Note that since you don't need Playwright to install web browsers when testing Android, you can omit browser download
via setting the following environment variable when installing Playwright:

```sh js
PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 npm i -D playwright
```


## devices

```
def devices
```

Returns the list of detected Android devices.
