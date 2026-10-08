---
name: logging
description: Implements wide events log lines instead of scattered log statements. Use when adding logging, observability, or debugging instrumentation to a codebase. Covers structured event construction, span annotation, high-cardinality field selection, and tail sampling strategies. Use when the user mentions logging, observability, tracing, debugging, or wide events.
---

# Wide Event Logging

## Core principle

**Log what happened to the request, not what the code is doing.**

Instead of emitting many small log lines throughout a request lifecycle, build one rich event per request per service and emit it once at the end.

## Quick reference

- **Wide event**: A single context-rich log event emitted once per request per service, containing multiple structured field attributes
- **Cardinality**: Number of unique values a field can have. High-cardinality fields (userId, sessionId, traceId) are the most useful for debugging
- **Dimensionality**: Number of fields per event. More fields = more questions you can answer

## Implementation pattern

### 1. Create the event at request start

```yaml
event:
  traceId:
  timestamp:
  method:
  path:
  queryParams:
```

### 2. Enrich as the request progresses

Do not emit logs at each step. Attach data to the event:

```typescript
// After auth
event.userId = user.id;
event.subscriptionTier = user.tier;
event.lifetimeValue = user.ltv;

// After business logic
event.orderId = order.id;
event.cartItemCount = cart.items.length;
event.featureFlags = getActiveFlags(user);

// On error
event.errorType = "payment_declined";
event.errorCode = "insufficient_funds";
```

### 3. Emit once at the end

```typescript
finally {
  event.duration = Date.now() - event.timestamp;
  event.statusCode = res.statusCode;
  event.dbQueryCount = queryCounter.count;
  event.cacheHits = cache.hits;
  logger.info(event);
}
```

**Important note** be aware of the used observability framework (sentry, datadog, etc) some fields may already be instrumented by the framework

## Field categories to include

This is just an example for reference each code has its own important fields that should be identified when the feature is implemented, the categories to include are but not limited to:

- Request context
- User context
- Business context
- Infrastructure context
- Error context
- Performance context

## Anti-patterns

| Do not                                | Do instead                                           |
| ------------------------------------- | ---------------------------------------------------- |
| `console.log("payment failed")`       | Add error details to the wide event                  |
| Log userId in inconsistent formats    | Use a single structured field: `event.userId`        |
| Log at every step                     | Build one event, emit once                           |
| Pass a god object for logging context | Use span context or framework-level context          |
| Switch to JSON and call it done       | One comprehensive event per request with all context |

## Validation checklist

When reviewing logging instrumentation, verify:

- [ ] Each request emits **one wide event**, not many small logs
- [ ] High-cardinality fields included (userId, sessionId, traceId)
- [ ] Business context attached (entity IDs, feature flags, subscription tier)
- [ ] Error context includes specific codes, not just messages
- [ ] Performance metrics captured (DB query count/duration, cache hit/miss)
- [ ] Infrastructure context present (deploymentId, gitHash, region)
- [ ] Query params are logged
- [ ] Event emits in a `finally` block so it always fires
- [ ] Trace IDs propagate across service boundaries (client → server → downstream)
- [ ] PII handled appropriately
