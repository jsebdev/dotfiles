---
name: elaborate
argument-hint: <something Claude stated earlier in this session>
description: Elaborate on a claim Claude made earlier in this session by walking the user through the exact code that backs it, step by step, in reading order. Use when the user invokes /elaborate, or asks to be shown where in the code a previous statement comes from, or asks how an earlier claim was reached. Refuses when the claim was never made in this session.
---

# Elaborate

The user was told something in this session and wants to see it for themselves. The deliverable is a
**reading tour**: the ordered list of places in the code the user should open, and what each one
proves, so they end up able to re-derive the claim without you.

This is not a re-explanation and not a fresh investigation. It is the evidence trail behind a
statement that was already made here.

Run it **inline, in the current session**. The conversation history is the input, so never hand this
to a subagent: a fresh agent has no access to what was stated, and even a fork would be doing new
research rather than showing its sources.

## Arguments

**Arguments received:** $ARGUMENTS

That line is the claim to elaborate on, as the user typed it. It is normally a paraphrase or a
fragment, not a quote, and it may be empty.

## Steps

### 1. Locate the claim in this session

Search the conversation for what you actually asserted. The claim qualifies when it is something
**you** stated in this session, whether in prose, in a code walkthrough, in a plan, or in a summary
of a subagent's report.

These all count:

- A verbatim or near-verbatim match.
- A paraphrase whose meaning is the same as something you said.
- A fragment naming one part of a longer statement, for example `the retry logic` when you had
  explained how retries are wired.
- A pronoun-shaped reference to your most recent statement, for example `that` or `the last part`,
  and an empty argument line. Take the most recent substantive claim you made and say which one you
  picked in the first line of the tour.

These do **not** count, and route to step 2:

- Something the **user** asserted, that you never confirmed. Elaborating on it would mean building a
  justification for a claim you have not checked.
- Something nobody said in this session. A prior session does not count; that context is gone.
- A general question about the codebase that happens to be phrased as a request to elaborate.

When two different statements plausibly match, do not guess. Name both in one line each and ask
which. Do not tour both.

### 2. When the claim was not made here, decline

Say plainly that there is nothing to elaborate on, in two or three sentences:

- State that you did not make that claim in this session.
- Say what you searched, so the answer is checkable, for example "nothing in this session covers the
  cache eviction path."
- When something adjacent **was** said, name it in one clause and ask whether that is the one meant.
- Offer the alternative in one sentence: you can investigate the question fresh, as a normal
  question, if they want that instead.

Then stop. Do not start investigating anyway, and do not assemble a tour of code that supports a
claim you never made. A confident-looking tour behind an unmade claim is worse than the refusal,
because the user cannot tell the difference.

### 3. Recover how the claim was reached

Before touring anything, work out where the claim actually came from, because that determines whether
it can be shown at all:

| Origin | What to do |
| --- | --- |
| Files you read in this session | Tour them. This is the normal case. |
| A subagent's report you relayed | Open the files it named and verify them yourself before touring. Never present a relayed finding as first-hand. |
| Command output, for example a test run or a `git log` | Cite the command and re-run it when it is read-only and cheap, so the user sees current output rather than a stale paste. |
| General knowledge about a language, framework, or library | Say so. Point at the doc or the installed source, and at the call site in this repo where it applies. |
| Inference across several places | Tour each place, then state the step that joins them, which is the part that is not in any single file. |

If you cannot reconstruct a basis for the claim, say that instead of manufacturing one, and mark the
claim as unverified.

### 4. Build the tour

Read the files again now. Do not tour from memory or from a summary; the point of the skill is that
every stop is real and current, and line numbers drift.

Order the stops so understanding compounds:

1. **Entry point** — where the behavior starts, so the user has a place to stand.
2. **The path**, in execution order, one stop per place that changes the answer.
3. **The stop that proves the claim** — the line that makes the statement true. Mark it as the one
   that matters.
4. **The edges**, only when they change how the claim should be read: the guard that makes it
   conditional, the default that makes it usually invisible, the caller that makes it reachable.

Skip anything that does not carry the claim. A tour of nine files where three would do is a worse
answer, because the user has to find the load-bearing part themselves.

### 5. Verify while you read

Elaborating is a re-check, not a defense. When the code does not say what you said it did:

- Correct it in the tour, at the stop where the difference shows up, plainly and without preamble.
- Keep touring the rest.
- Say what the corrected version means for anything already decided or built on the old claim.

A tour that ends "and this is where I had it wrong" is a good outcome. Do not soften the finding to
protect the earlier statement.

## Output Format

Open with one line naming the claim you are elaborating on, so the user can confirm you matched the
right one.

Then the numbered stops. Each stop is:

- **`path/to/file.ext:line-range`** — what to look at there, and what it establishes. One to three
  sentences.
- A short quoted excerpt when a specific line is the evidence. A few lines, not the whole function.

Close with **What this means** — two or three sentences tying the stops back to the original claim,
including any correction, and naming the one thing that would change the conclusion if it were
different.

Rules:

- Always give `file:line`. A stop without a location is not a stop, because the user cannot follow it.
- Cite line ranges from the file as it is now, not from a diff or an earlier read.
- Reading order beats file order. Follow the behavior, not the directory listing.
- Do not write new code, do not propose refactors, and do not fix what you notice along the way.
  Mention a real problem in one clause and move on; the user can ask.
- Mark inferred steps as inferred. "These two facts imply X" is honest; presenting X as if it were on
  a line in a file is not.
- No preamble, no restating the skill, no offering to elaborate further.

## Calibration

Good — locates the claim, walks it in order, marks the load-bearing line, states the catch:

> Elaborating: "the session cache is only written on a cache miss."
>
> 1. **`api/handlers/session.go:42-58`** — `LoadSession` is the only caller; it checks the cache
>    before touching the database.
> 2. **`cache/session_store.go:88-104`** — `Get` returns `(value, found)`, and `found` is false for
>    both a missing key and an expired one.
> 3. **`api/handlers/session.go:61`** — the write. **This is the line the claim rests on**: `Set` is
>    inside the `if !found` branch, so a hit never refreshes the entry.
>
> **What this means:** a hot session still expires on its original TTL, since nothing extends it on
> read. If `Set` moved above the branch, the claim would stop being true.

Correctly refused — the claim was the user's, not mine:

> I did not say the worker pool is unbounded in this session. What I said was that the queue has no
> backpressure, at `queue/dispatch.go:31`, which is a different claim. Want the tour for that one, or
> should I go check the pool size fresh?

Wrong — a tour with no locations, which the user cannot follow:

> The authentication flow works by validating the token, then loading the user, then checking
> permissions in the middleware layer.
