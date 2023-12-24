# Unimplemented examples

Excample codes in API documentation is replaces with the methods defined in development/generate_api/example_codes.rb.

The examples listed below is not yet implemented, and documentation shows Python code.


### example_c05d76146085d8afc519158aef621696f3458b669479d57b4560355c6b0c5ef7 (Tracing#start)

```
context.tracing.start(screenshots=True, snapshots=True)
page = context.new_page()
page.goto("https://playwright.dev")
context.tracing.stop(path = "trace.zip")

```

### example_c74a3f913c302bc9bf81146db28832bdfe33ab7721f1343efb1e207bb070abce (Tracing#start_chunk)

```
context.tracing.start(screenshots=True, snapshots=True)
page = context.new_page()
page.goto("https://playwright.dev")

context.tracing.start_chunk()
page.get_by_text("Get Started").click()
# Everything between start_chunk and stop_chunk will be recorded in the trace.
context.tracing.stop_chunk(path = "trace1.zip")

context.tracing.start_chunk()
page.goto("http://example.com")
# Save a second trace file with different actions.
context.tracing.stop_chunk(path = "trace2.zip")

```
