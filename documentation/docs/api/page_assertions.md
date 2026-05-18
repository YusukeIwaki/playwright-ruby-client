---
sidebar_position: 10
---

# PageAssertions


The [PageAssertions](./page_assertions) class provides assertion methods that can be used to make assertions about the [Page](./page) state in the tests.

```ruby
page.content = <<~HTML
<a href="https://example.com/user/login">Sign in</a>
HTML

page.get_by_text("Sign in").click
expect(page).to have_url(/.*\/login/)
```

## not_to_have_title

```
def not_to_have_title(titleOrRegExp, timeout: nil)
```


The opposite of [PageAssertions#to_have_title](./page_assertions#to_have_title).

## not_to_have_url

```
def not_to_have_url(urlOrRegExp, ignoreCase: nil, timeout: nil)
```


The opposite of [PageAssertions#to_have_url](./page_assertions#to_have_url).

## to_match_aria_snapshot

```
def to_match_aria_snapshot(expected, timeout: nil)
```


Asserts that the page body matches the given [accessibility snapshot](https://playwright.dev/python/docs/aria-snapshots).

**Usage**

```ruby
page.goto("https://demo.playwright.dev/todomvc/")
expect(page).to match_aria_snapshot(<<~YAML)
  - heading "todos"
  - textbox "What needs to be done?"
YAML
```

## not_to_match_aria_snapshot

```
def not_to_match_aria_snapshot(expected, timeout: nil)
```


The opposite of [PageAssertions#to_match_aria_snapshot](./page_assertions#to_match_aria_snapshot).

## to_have_title

```
def to_have_title(titleOrRegExp, timeout: nil)
```


Ensures the page has the given title.

**Usage**

```ruby
expect(page).to have_title(/.*checkout/)
```

## to_have_url

```
def to_have_url(urlOrRegExp, ignoreCase: nil, timeout: nil)
```


Ensures the page is navigated to the given URL.

**Usage**

```ruby
expect(page).to have_url(/.*checkout/)
```
