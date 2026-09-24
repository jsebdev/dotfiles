---
name: my-code-review
description: Review a pull request against its base branch and return severity-grouped, actionable feedback following my project conventions. Use when the user invokes /my-code-review, asks for a PR review, asks for feedback on changes they just finished, or asks to review only part of a PR such as certain files, directories, or concerns. Covers ticket resolution, target resolution, scoping the review, the review checklist, the output format, and staging the feedback as comments on the PR.
---

# My Code Review

Review a pull request against its base branch and return prioritized, actionable feedback.

Run this review **inline, in the current session** by default. The point of doing it inline is that
every command and every file examined stays visible, so follow-up questions about how the review was
conducted can be answered. Delegate to the `code-reviewer` agent only when the diff is large enough
to crowd out the rest of the session (roughly 40+ changed files or several thousand changed lines).
A scope narrow enough to fit comfortably in the session is reviewed inline even when the full PR is
large.

Inline and delegated are exclusive. When delegating, do not run a second review pass yourself;
verify the agent's findings after its report is complete, and do it silently.

### Delegating

Hand the agent the ticket's acceptance criteria and the decisions recorded in its comments verbatim,
along with the PR threads sorted by step 3. Pass on any scope the user asked for, and require a "Files examined / commands run" section so
procedural questions remain answerable.

Require the agent to write its complete review to `<scratchpad>/review-<pr>.md` and return only that
path and a one-line status. Read the file and publish from it. A subagent result payload is
size-capped and truncates silently mid-item, so it must never carry the review itself.

If a report arrives truncated anyway, do not relay it and do not request it piecemeal. Re-request it
as a file. If that truncates too, abandon delegation and review the remaining scope inline.

## Scope

The user asks for the review in plain language. Read what they asked for and take from it whichever
of these apply:

- **Which PR**, given as a number, a URL, or a branch name.
- **Which ticket**, given as a ticket key, which skips ticket detection.
- **A path scope**, for example "only the migration files" or "just the API directory": review only
  the changed files matching it.
- **A focus scope**, for example "just look at error handling" or "security only": apply only the
  parts of the review checklist that speak to it.

### Scope rules

- With nothing narrowing the review, review every changed file against the whole checklist.
- A path scope narrows which changed files are reviewed. A focus scope narrows which checklist
  sections are applied. They combine, so "the API changes, security only" reviews the files under
  the API path for security alone.
- Resolving and reading the ticket is never skipped, whatever the scope. The ticket is what tells you
  whether the code in scope implements the agreed behavior.
- The ticket context checks still run under a path scope, but assess only the acceptance criteria the
  files in scope are responsible for, and say which criteria you did not assess.
- If a path scope matches no changed file, say so, list the changed files, and stop. Do not silently
  widen the review.
- Findings outside the requested scope are not reported, with one exception: a Critical finding, which
  you report under its normal group with the note that it falls outside the requested scope.
- State the scope you applied at the top of the review, next to the ticket key.

### Planning artifacts are inputs, not review targets

Spec, design, user-story and plan files committed in the PR, such as `specs/<ticket>/design.md`
or `.branch-plans/`, are read for intent and never reviewed. Report no finding on them and stage
no comment on them, even when they have drifted from the code. They record intent at the moment
the work was planned, so drift in them misleads no one who is reading the code. A comment on one
is noise the author has to dismiss.

This covers planning artifacts only. Documentation that describes shipped behavior to its next
reader, such as a README, `docs/` or a CLAUDE.md, is still reviewed.

```
Bad   design.md still passes `open` to the modal, but the prop was removed. Drop it.
Good  (no finding: the spec is only an input, and the code is what gets reviewed)
```

## Steps

1. **Resolve the target PR**
   - A PR number the user named wins.
   - A branch name they named resolves with `gh pr view <branch> --json number,title,baseRefName`.
   - Otherwise resolve the PR for the current branch with `gh pr view --json number,title,baseRefName`.
   - If no PR is found, ask the user for the PR number and stop.
2. **Resolve and read the ticket, before reading a single line of the diff.**
   - A ticket key the user gave wins. Otherwise extract it from the branch name, the PR title,
     the PR body, or the commits on the branch: `gh pr view <number> --json title,body,headRefName`
     and `git log --oneline <base>..HEAD`.
   - Read the ticket **together with its comments** through the Jira MCP server for this
     repository's site — `getJiraIssue` with `comment` in `fields` and
     `responseContentFormat: "markdown"`, passing the site hostname as `cloudId`. A repository may
     have several Jira servers configured; pick the one whose site matches the ticket link in the
     PR body.
   - Never review from the description alone. The comments are where the team asks the open
     questions and where product answers them, and an answer recorded there **outranks the PR
     description, the commit messages, and any plan or spec file committed in the PR**. Read every
     comment, oldest to newest, and note which question each one answers.
   - **If the ticket cannot be resolved or cannot be read, stop and do not review.** That covers:
     no ticket key found anywhere, no Jira MCP server for the site, permission denied, or a failing
     fetch. Warn the user, say what you tried and how it failed, and ask them for the ticket key or
     for a paste of the ticket with its comments. Resume only once you have it. Reviewing without
     ticket context is how a rejected option ships as if it were the agreed one.
3. **Read the PR's existing discussion, also before the diff.** A PR that has already been reviewed
   carries agreements the diff cannot show you. Fetch all three sources, with `--paginate`:
   - inline review threads: `gh api repos/<owner>/<repo>/pulls/<pr>/comments`
   - review summaries: `gh api repos/<owner>/<repo>/pulls/<pr>/reviews`
   - the conversation tab: `gh api repos/<owner>/<repo>/issues/<pr>/comments`

   Group the inline comments into threads by `in_reply_to_id`. Read every thread oldest to newest
   and sort each one into one of these:
   - **Unanswered.** Still open. Do not stage it again. If it still applies, the review points to
     that thread instead of raising a new finding.
   - **Author says it is done.** Check the claim against the current code. A claim the code does
     not back up is a finding, and the finding quotes the reply.
   - **Author declined or pushed back.** This includes "kept on purpose", "won't do", "out of
     scope", or doing something other than what was asked. It goes in the **Author pushback**
     section of the review, never back in as a new finding. The reviewer decides whether to accept
     it, and they decide that from the ticket.

   Apply the same checks to the author's summary comment on the conversation tab: every claim it
   makes about the code must hold in the current diff. If the discussion cannot be fetched, stop,
   say why, and ask the user how to proceed. A review that ignores the earlier rounds repeats
   settled points and misses the ones the author declined.
4. **Fetch the changes** against the base branch with `gh pr diff` and `gh pr view`. Review only what
   this PR introduced, never pre-existing code on the base branch.
5. **Apply the scope.** List the changed files with `gh pr diff <number> --name-only`, then reduce
   that list to the files a path scope selects. Reduce the checklist to the sections a focus scope
   selects. Confirm both in one line before reviewing, for example "Reviewing 4 of 23 changed files
   under `api/`, security checks only."
6. **Review every file in scope systematically** using the checklist below. Read surrounding context
   in the files themselves when the diff alone is not enough to judge a change.
7. **Compile the feedback** into the three severity groups below, written to
   `<scratchpad>/review-<pr>.md`. That file is the single source the review is published from.
8. **Publish the review exactly once**, as a single message carrying all three groups. Never relay a
   partial review: when findings arrive in pieces, accumulate them silently and publish when
   complete.
9. **Stage the findings on the PR**, following the `pr-comments` skill for how each comment is
   written and posted. Do this on every review, not only when asked. Drop the `[file:line]` prefix
   on the way across: the comment is anchored to that line already, and a line number written into
   a comment body rots on the next commit. A finding that names no file and line stays in the
   session review only, and you say which ones those were. Never stage a finding an existing thread
   already raises, answered or not. Point to that thread in the session review instead.

## Review Checklist

### Ticket context

- Every acceptance criterion, marked covered, partially covered, or missing, naming the file that
  covers it.
- Every decision recorded in the ticket comments, especially the answer to a question the team asked
  there. Code implementing the option that was rejected is a **Critical** finding, and the comment
  that settles it goes in the item, quoted.
- Behavior the PR description, a ticket comment, or an author reply on the PR claims that the code
  does not actually do.
  Documentation misstating shipped behavior is a finding in its own right, because it is what the
  next reader will trust. Planning artifacts are excluded (see above).
- Scope: work the ticket never asked for, and acceptance criteria deferred without saying so.

### Design and conventions

- Best practices for the language and framework in use.
- Reusability and extensibility problems the change is setting up for later. Use the
  `software-designer-mindset` skill for this.
- Self-documenting code: meaningful names over comments and docstrings, complex logic extracted into
  well-named functions rather than explained in a comment.
- No abbreviations or acronyms in names.
- If a plan or spec file is available, do a functionality gap assessment against it, and anchor
  any gap it reveals to the code. Where the plan conflicts with the ticket, the ticket wins, and the
  plan itself is still not a finding.

### Correctness and quality

- Security vulnerabilities and potential exploits.
- Performance bottlenecks and inefficient algorithms.
- Code duplication and refactoring opportunities.
- Error handling and edge case coverage.
- Reachable states only. Before asking for a new test case, permission combination, or input,
  confirm the code allows that state: check the model's `clean`, its `CheckConstraint`s, and its
  field choices. Never request coverage for a state the model rejects.
- Unjustified optionality. For every optional prop, parameter, or field the PR adds or widens, and
  every `?.`, `??`, `if (!x) return`, or default that covers a missing value, ask what real
  situation produces the missing case. If the answer is only "a caller might not pass it", it is
  **Critical**, not a style note: the type is licensing a wiring bug to render as empty state. Say
  in the finding whether the type should be required or the consumer should throw.
- Test coverage for new functionality. Use `general-testing-guidelines`, plus `python-testing` or
  `go-testing` for the relevant language.
- Type safety and proper type annotations.
- Memory leaks and resource management.
- API design and contract consistency.

### Data layer

- Database migrations, query efficiency, indexing strategy, and data model design.
- N+1 queries, with a concrete query optimization suggested.

### Observability

- Useful observability on application code. Use the `logging` skill for this.

## Output Format

When the author declined or pushed back on any earlier comment, open the review with this section,
above the three groups. Leave it out when nobody pushed back.

### ↩️ Author pushback (your call)

- **[file:line]** — what you asked · the author's reply, quoted briefly · whether the ticket backs
  you or them, citing the criterion or comment. End with **Accept** or **Push back**.

Nothing in this section is staged on the PR. The reply is the reviewer's to write.

Organize the rest of the feedback as a flat list under exactly these three groups:

### 🔴 Critical (must fix)

Bugs, security vulnerabilities, data loss, broken functionality, behavior that contradicts a
decision recorded on the ticket.

- **[file:line]** — the issue and what to do instead

### 🟡 Important (should fix)

Performance, maintainability, code quality, deviations from project conventions.

- **[file:line]** — the issue and what to do instead

### 🟢 Suggestions (nice to have)

Minor improvements, style preferences, alternative approaches worth considering.

- **[file:line]** — the suggestion and the reasoning behind it

Rules:

- Name the ticket key you reviewed against at the top of the review, and the scope you applied when
  the user narrowed it, for example "Scope: `services/billing/` only, tests and correctness."
- Under a narrowed scope, list the acceptance criteria you did not assess, so the gap is visible.
- One or two sentences per item, maximum. The file path, affected lines, and the suggested fix are
  sufficient. No elaboration blocks.
- Always include the file path and line number or range when applicable.
- Give the fix inline, in the same item.
- For a finding that comes from ticket context, cite the acceptance criterion or the comment behind
  it, with its author and date, so the author can check the source.
- Write "None" under a group that has no items.
- Prefix an uncertain recommendation with **[Question]** to flag it for discussion.
- No positives, praise, congratulations, or personal messages. Surface only what needs fixing.
- End with a one or two sentence status summary, for example "3 critical issues to address before
  merge, mostly around input validation and error handling." Never recap every finding.

## Tone

Direct and practical. No praise, no filler. The job is to surface problems and suggest improvements.
Explain why something matters when it is not obvious, but do it in the same one-liner.

Do not narrate the review in progress. The first thing the user sees about the review should be the
review.
