---
sidebar_position: 10
---

# Credentials


[Credentials](./credentials) is a virtual WebAuthn authenticator scoped to a [BrowserContext](./browser_context). It lets tests
register passkeys and answer `navigator.credentials.create()` / `navigator.credentials.get()`
ceremonies in the page, without a real authenticator or hardware security key.

There are two common ways to use it:

**Usage: seed a known credential**

```ruby
context = browser.new_context

# A passkey your backend already provisioned for a test user.
context.credentials.create(
  "example.com",
  id: known_credential_id, # base64url
  userHandle: known_user_handle, # base64url
  privateKey: known_private_key, # base64url PKCS#8 (DER)
  publicKey: known_public_key, # base64url SPKI (DER)
)
context.credentials.install

page = context.new_page
page.goto("https://example.com/login")
# The page's navigator.credentials.get() is answered with the seeded passkey.
```

**Usage: capture a passkey, then reuse it**

```ruby
# setup test: let the app register a passkey, then save it.
context = browser.new_context
context.credentials.install

page = context.new_page
page.goto("https://example.com/register")
page.get_by_role("button", name: "Create a passkey").click

# Read back the passkey the page registered - it includes the private key.
credential = context.credentials.get(rpId: "example.com").first
File.write("playwright/.auth/passkey.json", JSON.generate(credential))
```

```ruby
# later test: seed the captured passkey so the app starts already enrolled.
credential = JSON.parse(File.read("playwright/.auth/passkey.json"))
context = browser.new_context
context.credentials.create(
  credential["rpId"],
  id: credential["id"],
  userHandle: credential["userHandle"],
  privateKey: credential["privateKey"],
  publicKey: credential["publicKey"],
)
context.credentials.install

page = context.new_page
page.goto("https://example.com/login")
# navigator.credentials.get() resolves the captured passkey - already signed in.
```

**Defaults**

## install

```
def install
```


Installs the virtual WebAuthn authenticator into the context, overriding
`navigator.credentials.create()` and `navigator.credentials.get()` in all current
and future pages. Call this before the page first touches `navigator.credentials`.

Required: until [Credentials#install](./credentials#install) is called, no interception is in place and the page sees
the platform's native (or absent) WebAuthn behaviour. Seeding credentials with
[Credentials#create](./credentials#create) without installing populates the authenticator, but the
page will never see those credentials.

## create

```
def create(
      rpId,
      id: nil,
      privateKey: nil,
      publicKey: nil,
      userHandle: nil)
```


Seeds a virtual WebAuthn credential and returns it.

With only `rpId`, generates a fresh **ECDSA P-256** keypair, credential id and user handle. The
seeded credential is discoverable (resident), so the page can resolve it from both
username-then-passkey and usernameless passkey flows. The returned object carries the private and public keys, so it can be persisted to disk and re-seeded in a later test.

To **import a known credential**, supply all four of `id`, `userHandle`, `privateKey` and
`publicKey` together.

Call [Credentials#install](./credentials#install) before navigating to a page that uses WebAuthn.

## delete

```
def delete(id)
```


Removes a credential from the authenticator by its id. Works for any credential currently held —
both those seeded with [Credentials#create](./credentials#create) and those the page registered itself by
calling `navigator.credentials.create()`.

## get

```
def get(id: nil, rpId: nil)
```


Returns every credential currently held by the authenticator, optionally filtered by `rpId` or
`id`. This includes both credentials seeded with [Credentials#create](./credentials#create) and credentials
the page registered itself by calling `navigator.credentials.create()`.

Each returned credential includes its private and public keys, so a passkey the app just
registered can be saved and re-seeded into a later test with [Credentials#create](./credentials#create) — see the second example in the class overview.
