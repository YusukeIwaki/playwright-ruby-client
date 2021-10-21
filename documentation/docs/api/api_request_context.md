---
sidebar_position: 10
---

# APIRequestContext

This API is used for the Web API testing. You can use it to trigger API endpoints, configure micro-services, prepare
environment or the service to your e2e test. When used on [Page](./page) or a [BrowserContext](./browser_context), this API will automatically use
the cookies from the corresponding [BrowserContext](./browser_context). This means that if you log in using this API, your e2e test will be
logged in and vice versa.
