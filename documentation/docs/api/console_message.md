---
sidebar_position: 10
---

# ConsoleMessage

[ConsoleMessage](./console_message) objects are dispatched by page via the [`event: Page.console`] event.

## args

```
def args
```

List of arguments passed to a `console` function call. See also [`event: Page.console`].

## location

```
def location
```



## text

```
def text
```

The text of the console message.

## type

```
def type
```

One of the following values: `'log'`, `'debug'`, `'info'`, `'error'`, `'warning'`, `'dir'`, `'dirxml'`, `'table'`,
`'trace'`, `'clear'`, `'startGroup'`, `'startGroupCollapsed'`, `'endGroup'`, `'assert'`, `'profile'`, `'profileEnd'`,
`'count'`, `'timeEnd'`.
