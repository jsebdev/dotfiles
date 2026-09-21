---
name: pr-comments
description: Write and post comments on a GitHub pull request. Use when leaving feedback on a PR, putting the findings of a code review onto GitHub, staging review comments for the user to submit themselves, or replying to a reviewer. Covers the tag prefix every comment starts with, the length and plain-language limits, and posting comments as a pending review with gh api.
---

# PR Comments

A pull request comment is one tagged, line-anchored note. Three rules, all of them checkable:

1. It starts with a tag from the list below, followed by a colon.
2. It is **70 words or fewer**.
3. It makes **one** point, in language a reader outside this part of the codebase can follow.

Two points means two comments, or dropping the one that matters less.

## Tags

| Tag | Use it for |
| --- | --- |
| `issue:` | Something is wrong and should change before merge. |
| `suggestion:` | A concrete improvement the author may take or leave. |
| `question:` | You need an answer before you can judge the code. |
| `thought:` | An observation or context, with no action implied. |
| `nitpick:` | Trivial. The author is free to ignore it. |

Nothing outside this list. A comment that fits no tag is a comment that has not decided what it is
asking for, so decide first, then write it.

An `issue:` or a `suggestion:` carries its fix in the same comment. Naming a problem without a way
out makes the author do the work twice.

## Length and language

70 words is a hard ceiling, not a target. The comment is anchored to the line, so it does not
restate the code, quote the diff, or re-explain what the function does.

Lead with the consequence in ordinary words, then the mechanism. Use a technical term only when it
is the actual name of the thing being discussed, never as a shortcut for an explanation. If the
point only lands for someone who already knows the pattern by name, it has not landed.

```
Bad   issue: This violates Liskov substitution: the subtype narrows the precondition, so the
      call site's invariant no longer holds under polymorphic dispatch.

Good  issue: `PartialRefund` rejects amounts that `Refund` accepts, so anything holding a
      `Refund` breaks when it gets this one. Accept the same range, or don't subclass it.
```

```
Bad   suggestion: Consider refactoring this for better maintainability and separation of
      concerns.

Good  suggestion: This parses the date the same way as the due-date helper in
      `billing/api/invoices.py`. Pull both into one helper so a format change only has to be
      made once.
```

### Pointing at other code

Name another place in the code by its **full path in the repository**, then say in words which part
of that file you mean. Never by a line number, and never by a bare filename.

A line number is wrong as soon as the next commit shifts it, and it sends the reader somewhere
unrelated with no hint that it moved. A bare filename does not say where the file lives, and a
repository usually holds several files with the same name.

```
Bad   issue: Same off-by-one as `serializers.py:212`.

Good  issue: The window here ends one day early, the same way the date range in
      `reporting/exports/serializers.py` does, in the serializer that builds the monthly CSV.
      Make the end date inclusive in both.
```

The line the comment is anchored to is the exception: it needs no reference at all, because GitHub
already shows the reader exactly where they are.

## Posting

Post the comments as a **pending review**: a private draft only the author of the review can see.
The user reads it in the GitHub UI, writes their own summary message, and submits it themselves.

Never submit the review, and never post the comments individually. Both take the summary message
and the approve-or-request-changes decision away from the user.

Build the payload as a file, because comment bodies contain characters a shell command line
mangles, then post it in one call:

```
gh api repos/<owner>/<repo>/pulls/<pr>/reviews --input <scratchpad>/review-comments.json
```

```json
{
  "commit_id": "<head sha>",
  "comments": [
    { "path": "api/billing.py", "line": 42, "side": "RIGHT", "body": "issue: ..." }
  ]
}
```

- **Omit `event`.** Including it submits the review immediately and there is no draft left to edit.
- `line` must be a line this PR's diff actually touches. Use `"side": "LEFT"` to comment on a
  deleted line, and `start_line` with `line` for a range.
- A point about the file as a whole is anchored to the nearest line the PR changed in that file.
- A rejected line fails the whole call. Fix the anchor and retry. Never drop the comment instead.
- GitHub allows **one pending review per user per PR**. If the call fails because one exists
  already, fetch it with `gh api repos/<owner>/<repo>/pulls/<pr>/reviews`, tell the user what is in
  it, and ask before deleting it. Never delete a pending review on your own.
- Finish by telling the user how many comments were staged and that they are waiting in the Files
  changed tab of the PR.

## Out of scope

What to look for in a pull request, and how to structure a review in the session, belong to
`my-code-review`. This skill only governs how a comment is written and how it reaches GitHub.
