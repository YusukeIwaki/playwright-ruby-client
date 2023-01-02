---
sidebar_position: 10
---

# Android

Playwright has **experimental** support for Android automation. This includes Chrome for Android and Android WebView.
*Requirements*
- Android device or AVD Emulator.
- [ADB daemon](https://developer.android.com/studio/command-line/adb) running and authenticated with your device. Typically running `adb devices` is all you need to do.
- [`Chrome 87`](https://play.google.com/store/apps/details?id=com.android.chrome) or newer installed on the device
- "Enable command line on non-rooted devices" enabled in `chrome://flags`.
*Known limitations*
- Raw USB operation is not yet supported, so you need ADB.
- Device needs to be awake to produce screenshots. Enabling "Stay awake" developer mode will help.
- We didn't run all the tests against the device, so not everything works.
*How to run*
An example of the Android automation script would be:
Note that since you don't need Playwright to install web browsers when testing Android, you can omit browser download via setting the following environment variable when installing Playwright:
```bash js
PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 npm i -D playwright
```

## devices

```
def devices(host: nil, omitDriverInstall: nil, port: nil)
```

Returns the list of detected Android devices.
