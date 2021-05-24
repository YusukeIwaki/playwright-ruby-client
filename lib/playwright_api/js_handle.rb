module Playwright
  # JSHandle represents an in-page JavaScript object. JSHandles can be created with the [`method: Page.evaluateHandle`]
  # method.
  #
  #
  # ```js
  # const windowHandle = await page.evaluateHandle(() => window);
  # // ...
  # ```
  #
  # ```java
  # JSHandle windowHandle = page.evaluateHandle("() => window");
  # // ...
  # ```
  #
  # ```python async
  # window_handle = await page.evaluate_handle("window")
  # # ...
  # ```
  #
  # ```python sync
  # window_handle = page.evaluate_handle("window")
  # # ...
  # ```
  #
  # ```csharp
  # var windowHandle = await page.EvaluateHandleAsync("() => window");
  # ```
  #
  # JSHandle prevents the referenced JavaScript object being garbage collected unless the handle is exposed with
  # [`method: JSHandle.dispose`]. JSHandles are auto-disposed when their origin frame gets navigated or the parent context
  # gets destroyed.
  #
  # JSHandle instances can be used as an argument in [`method: Page.evalOnSelector`], [`method: Page.evaluate`] and
  # [`method: Page.evaluateHandle`] methods.
  class JSHandle < PlaywrightApi

    # Returns either `null` or the object handle itself, if the object handle is an instance of `ElementHandle`.
    def as_element
      wrap_impl(@impl.as_element)
    end

    # The `jsHandle.dispose` method stops referencing the element handle.
    def dispose
      wrap_impl(@impl.dispose)
    end

    # Returns the return value of `expression`.
    #
    # This method passes this handle as the first argument to `expression`.
    #
    # If `expression` returns a [Promise], then `handle.evaluate` would wait for the promise to resolve and return its value.
    #
    # Examples:
    #
    #
    # ```js
    # const tweetHandle = await page.$('.tweet .retweets');
    # expect(await tweetHandle.evaluate(node => node.innerText)).toBe('10 retweets');
    # ```
    #
    # ```java
    # ElementHandle tweetHandle = page.querySelector(".tweet .retweets");
    # assertEquals("10 retweets", tweetHandle.evaluate("node => node.innerText"));
    # ```
    #
    # ```python async
    # tweet_handle = await page.query_selector(".tweet .retweets")
    # assert await tweet_handle.evaluate("node => node.innerText") == "10 retweets"
    # ```
    #
    # ```python sync
    # tweet_handle = page.query_selector(".tweet .retweets")
    # assert tweet_handle.evaluate("node => node.innerText") == "10 retweets"
    # ```
    #
    # ```csharp
    # var tweetHandle = await page.QuerySelectorAsync(".tweet .retweets");
    # Assert.Equals("10 retweets", await tweetHandle.EvaluateAsync("node => node.innerText"));
    # ```
    def evaluate(expression, arg: nil)
      wrap_impl(@impl.evaluate(unwrap_impl(expression), arg: unwrap_impl(arg)))
    end

    # Returns the return value of `expression` as a `JSHandle`.
    #
    # This method passes this handle as the first argument to `expression`.
    #
    # The only difference between `jsHandle.evaluate` and `jsHandle.evaluateHandle` is that `jsHandle.evaluateHandle` returns
    # `JSHandle`.
    #
    # If the function passed to the `jsHandle.evaluateHandle` returns a [Promise], then `jsHandle.evaluateHandle` would wait
    # for the promise to resolve and return its value.
    #
    # See [`method: Page.evaluateHandle`] for more details.
    def evaluate_handle(expression, arg: nil)
      wrap_impl(@impl.evaluate_handle(unwrap_impl(expression), arg: unwrap_impl(arg)))
    end

    # The method returns a map with **own property names** as keys and JSHandle instances for the property values.
    #
    #
    # ```js
    # const handle = await page.evaluateHandle(() => ({window, document}));
    # const properties = await handle.getProperties();
    # const windowHandle = properties.get('window');
    # const documentHandle = properties.get('document');
    # await handle.dispose();
    # ```
    #
    # ```java
    # JSHandle handle = page.evaluateHandle("() => ({window, document}"););
    # Map<String, JSHandle> properties = handle.getProperties();
    # JSHandle windowHandle = properties.get("window");
    # JSHandle documentHandle = properties.get("document");
    # handle.dispose();
    # ```
    #
    # ```python async
    # handle = await page.evaluate_handle("{window, document}")
    # properties = await handle.get_properties()
    # window_handle = properties.get("window")
    # document_handle = properties.get("document")
    # await handle.dispose()
    # ```
    #
    # ```python sync
    # handle = page.evaluate_handle("{window, document}")
    # properties = handle.get_properties()
    # window_handle = properties.get("window")
    # document_handle = properties.get("document")
    # handle.dispose()
    # ```
    #
    # ```csharp
    # var handle = await page.EvaluateHandleAsync("() => ({window, document}");
    # var properties = await handle.GetPropertiesAsync();
    # var windowHandle = properties["window"];
    # var documentHandle = properties["document"];
    # await handle.DisposeAsync();
    # ```
    def get_properties
      wrap_impl(@impl.get_properties)
    end
    alias_method :properties, :get_properties

    # Fetches a single property from the referenced object.
    def get_property(propertyName)
      wrap_impl(@impl.get_property(unwrap_impl(propertyName)))
    end

    # Returns a JSON representation of the object. If the object has a `toJSON` function, it **will not be called**.
    #
    # > NOTE: The method will return an empty JSON object if the referenced object is not stringifiable. It will throw an
    # error if the object has circular references.
    def json_value
      wrap_impl(@impl.json_value)
    end

    # @nodoc
    def to_s
      wrap_impl(@impl.to_s)
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def on(event, callback)
      event_emitter_proxy.on(event, callback)
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def off(event, callback)
      event_emitter_proxy.off(event, callback)
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def once(event, callback)
      event_emitter_proxy.once(event, callback)
    end

    private def event_emitter_proxy
      @event_emitter_proxy ||= EventEmitterProxy.new(self, @impl)
    end
  end
end
