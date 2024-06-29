---
sidebar_position: 10
---

# Clock


Accurately simulating time-dependent behavior is essential for verifying the correctness of applications. Learn more about [clock emulation](https://playwright.dev/python/docs/clock).

Note that clock is installed for the entire [BrowserContext](./browser_context), so the time
in all the pages and iframes is controlled by the same clock.

## fast_forward

```
def fast_forward(ticks)
```


Advance the clock by jumping forward in time. Only fires due timers at most once. This is equivalent to user closing the laptop lid for a while and
reopening it later, after given time.

**Usage**

```python title="example_aa1d7ed6650f37a2ef8a00945f0f328896eae665418b6758a9e24fcc4c7bcd83.py"
page.clock.fast_forward(1000)
page.clock.fast_forward("30:00")

```

## install

```
def install(time: nil)
```


Install fake implementations for the following time-related functions:
- `Date`
- `setTimeout`
- `clearTimeout`
- `setInterval`
- `clearInterval`
- `requestAnimationFrame`
- `cancelAnimationFrame`
- `requestIdleCallback`
- `cancelIdleCallback`
- `performance`

Fake timers are used to manually control the flow of time in tests. They allow you to advance time, fire timers, and control the behavior of time-dependent functions. See [Clock#run_for](./clock#run_for) and [Clock#fast_forward](./clock#fast_forward) for more information.

## run_for

```
def run_for(ticks)
```


Advance the clock, firing all the time-related callbacks.

**Usage**

```python title="example_ce3b9a2e3e9e37774d4176926f5aa8ddf76d8c2b3ef27d8d8f82068dd3720a48.py"
page.clock.run_for(1000);
page.clock.run_for("30:00")

```

## pause_at

```
def pause_at(time)
```


Advance the clock by jumping forward in time and pause the time. Once this method is called, no timers
are fired unless [Clock#run_for](./clock#run_for), [Clock#fast_forward](./clock#fast_forward), [Clock#pause_at](./clock#pause_at) or [Clock#resume](./clock#resume) is called.

Only fires due timers at most once.
This is equivalent to user closing the laptop lid for a while and reopening it at the specified time and
pausing.

**Usage**

```python title="example_e3bfa88ff84efbef1546730c2046e627141c6cd5f09c54dc2cf0e07cbb17c0b5.py"
page.clock.pause_at(datetime.datetime(2020, 2, 2))
page.clock.pause_at("2020-02-02")

```

## resume

```
def resume
```


Resumes timers. Once this method is called, time resumes flowing, timers are fired as usual.

## set_fixed_time

```
def set_fixed_time(time)
```
alias: `fixed_time=`


Makes `Date.now` and `new Date()` return fixed fake time at all times,
keeps all the timers running.

**Usage**

```python title="example_612285ca3970e44df82608ceff6f6b9ae471b0f7860b60916bbaefd327dd2ffd.py"
page.clock.set_fixed_time(datetime.datetime.now())
page.clock.set_fixed_time(datetime.datetime(2020, 2, 2))
page.clock.set_fixed_time("2020-02-02")

```

## set_system_time

```
def set_system_time(time)
```
alias: `system_time=`


Sets current system time but does not trigger any timers.

**Usage**

```python title="example_1f707241c9dfcb70391f40269feeb3e50099815e43b9742bba738b72defae04f.py"
page.clock.set_system_time(datetime.datetime.now())
page.clock.set_system_time(datetime.datetime(2020, 2, 2))
page.clock.set_system_time("2020-02-02")

```
