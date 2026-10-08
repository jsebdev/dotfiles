---
name: general-testing-guidelines
description: Language-agnostic test naming, structure, and organization guidelines. Triggers when: (1) Writing new test functions or files, (2) Modifying existing tests, (3) Reviewing test code. Apply regardless of programming language.
---

# General Testing Guidelines

These guidelines apply to all test code, regardless of language or framework. Language-specific skills (go-testing, python-testing, etc.) extend these principles — follow both.

## Test Naming

A test name is the primary documentation for the behavior being verified. It must describe the **scenario and expected outcome**, never the testing mechanism.

### The rule

Name tests so that a failure message is self-explanatory without reading the code.

**Wrong — names describe the mechanism, not the behavior:**

```
UseDB
MockDependencies
HappyPath
ErrorCase
Success
Failure
```

**Right — names describe the scenario and what should happen:**

```
patches_raw_conversation_without_overwriting_protected_fields
returns_not_found_when_questionnaire_does_not_exist
rejects_request_when_email_is_missing
sends_welcome_email_after_successful_registration
```

### Naming formula

Use one of these patterns, selecting whichever makes the intent clearest:

- `[action]_[expected_outcome]` — e.g., `create_user_returns_201`
- `[context]_[action]_[expected_outcome]` — e.g., `when_email_missing_returns_400`
- `[subject]_[expected_behavior]` — e.g., `patch_does_not_overwrite_status`

### Red flags to eliminate

| Bad name pattern | Why it fails | Fix |
|---|---|---|
| `UseDB` | Describes how the test runs, not what it verifies | Describe what behavior is exercised against the real store |
| `Success` / `HappyPath` | Vague — success of what? | Name the specific outcome |
| `ErrorCase` / `Failure` | Which error? | Name the error condition and what should happen |
| `Test1` / `Case2` | No information at all | Describe the scenario |
| `Mock*` | Describes the test double, not the behavior | Focus on the behavior under test |

## Integration vs. Unit Tests

When a test uses real infrastructure (database, network, filesystem), mark it clearly so the reader immediately understands the test boundary and cost.

- Prefix integration tests: `integration_*` or suffix with `_integration`
- Keep integration tests in dedicated files or directories where the language/framework allows
- The `UseDB` test above should be named something like `integration_patches_raw_conversation_and_preserves_protected_fields`

## Test Structure: Arrange-Act-Assert

Every test body follows three phases, in order:

```
Arrange  — set up inputs, dependencies, and expected values
Act      — call the code under test, nothing else
Assert   — verify the outcome
```

Never interleave setup and assertions. If you find yourself asserting in the middle of setup, extract a helper or split into separate tests.

## One Behavior Per Test

Each test verifies exactly one behavior. If a test name requires "and" to be accurate, it is testing two things — split it.

**Wrong:**
```
creates_user_and_sends_email_and_logs_event
```

**Right:**
```
creates_user_in_database
sends_welcome_email_after_user_creation
logs_user_creation_event
```

## Test Independence

Tests must not depend on execution order or shared mutable state from other tests. Every test should be able to run in isolation and pass.

- Set up all state within the test or a scoped fixture/helper
- Tear down any side effects (database rows, files, environment variables) in cleanup
- Never rely on a previous test having run first

## Focus on Behavior, Not Implementation

Tests should assert **what** the system does, not **how** it does it internally. Avoid:

- Asserting which private methods were called
- Asserting internal data structures that are not part of the public contract
- Mocking every dependency by default — only mock what must be controlled

Test from the outside: given this input, do I get this output?

## Checklist

- [ ] Test name describes the scenario and expected outcome, not the mechanism
- [ ] No names like `UseDB`, `HappyPath`, `Mock*`, `Success`, `Failure`
- [ ] Integration tests are clearly marked as such
- [ ] Each test follows Arrange-Act-Assert order
- [ ] Each test verifies exactly one behavior
- [ ] Tests are independent and can run in any order
- [ ] Assertions target observable behavior, not internal implementation details
