---
name: point-me-in-the-right-direction
description: Get a short, fresh-eyes pointer toward a simpler approach, instead of a full solution. Use when the user invokes /point-me-in-the-right-direction, or asks whether there is a simpler or better way to do something they are already deep into. Thinks in a subagent with no conversation history so the answer is not anchored on the approach already under discussion. Language and stack agnostic.
---

# Point Me In The Right Direction

The user is deep in a problem and wants to know whether they are solving it the hard way. They do
not want a solution, a plan, or code. They want a short pointer they can go explore on their own.

The value here comes from breaking anchoring. By the time this is invoked, the conversation has
usually converged on one approach and is iterating inside it, and every further turn deepens the
commitment. So the thinking happens somewhere that has never seen the conversation.

## Steps

### 1. Identify the problem

The invocation arguments (`$ARGUMENTS`) are usually a question ("Is there a better way to do these
filters?"), sometimes a file or an area, sometimes empty. If empty, take the problem from whatever
the conversation has most recently been working on.

If you genuinely cannot tell which problem is meant, ask one short question and stop. Do not guess
between two unrelated problems.

### 2. Write a self-contained brief

The subagent has no conversation history, so the brief is everything it gets. Include:

- **The goal**, in domain terms, not in terms of the current implementation.
- **Hard constraints** — what any answer must satisfy (a security rule, backward compatibility,
  data that already exists in the wild, an interface other code depends on). Give the reason, not
  just the rule; a constraint without a reason cannot be challenged, and challenging it is
  sometimes the answer.
- **The current approach**, stated neutrally as fact, with file paths so the agent reads real code
  instead of your summary of it.
- **Approaches already ruled out**, each with the hard reason it fails. Genuine blockers only.

Leave out your own verdicts, rankings, preferences, and anything you have been arguing for in the
conversation. Those are the anchor this skill exists to escape. State what is true; do not state
what you concluded.

### 3. Run the fresh-eyes agent

Spawn one `general-purpose` agent. Never `fork` — a fork inherits this context and defeats the
whole point. In its prompt:

- It is read-only. It must not edit or write files, or run anything that changes state.
- Its job is the *simplest thing that satisfies the constraints*, not an improvement on the current
  approach. A structurally different answer is a good answer.
- Point it at the four places simple answers hide:
  - **The platform already does it** — a framework feature, standard library call, library option,
    or config flag that replaces the hand-written mechanism. This is the most common real answer.
  - **The codebase already does it** — prior art solving the same shape somewhere else in this repo.
  - **The problem is the wrong shape** — the difficulty comes from a self-imposed constraint, a data
    model that stores one fact two ways, or a boundary drawn in the wrong place. Fix that and the
    hard part stops existing.
  - **It does not need doing** — the requirement is speculative, or the case being handled cannot
    actually occur.
- If the current approach is already the simplest thing that satisfies the constraints, say exactly
  that. Do not manufacture an alternative.
- Verify before asserting. Do not name a feature, flag, or method without checking that it exists
  and does what the pointer claims it does.

Ask it to return, per pointer: the direction in one sentence, the concrete mechanism, what moving
part disappears, and the one thing that would make it wrong.

If nothing comes back that clears the bar, you may run one more agent with a different lens. Not
more than that.

### 4. Filter

Drop anything that violates a stated constraint, restates the current approach in new words, or
names something you can see does not exist. If a pointer contradicts something already established
in this conversation, say so in a clause rather than relaying it as though unopposed.

If nothing survives, report that. "The approach you have is already the simple one, and here is the
part that is actually load-bearing" is a valid and useful answer.

### 5. Report

- **One pointer** when the answer is clear. **Up to three** only when the alternatives genuinely
  compete. Never pad to three.
- Two to four sentences each. The whole response should be readable in one breath.
- Name the mechanism concretely — an API, a lookup, a library option, a layer. "Simplify the
  abstraction" is not a direction.
- Say what it buys: which moving part disappears.
- Say the catch, when there is one, in one clause.
- Inline identifiers are fine. No code blocks, no diffs, no migration steps, no file-by-file plan.
- Stop there. Do not implement, do not write a plan, and do not offer to. The user explores from
  here; that is the point.

## Calibration

Good — names a mechanism, says what disappears, states the catch:

> You are hand-rolling retry and backoff around each call site. Your HTTP client has a retry policy
> built in — configure it once where the client is constructed and every call inherits it, and the
> per-call wrappers go away. Catch: it retries at the transport layer, so an application error
> returned with a 200 will not trigger it.

Too vague to act on — no mechanism, so there is no direction in it:

> Consider refactoring this to be more modular and reduce coupling.

Over-delivered — this is the solution, and it takes the exploring away from the user:

> Here is the full replacement class, the migration, and the four call sites to update.
