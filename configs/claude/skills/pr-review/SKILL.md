---
name: pr-review
description: Review a pull request against its base branch and return severity-grouped, actionable feedback following the project's conventions. Use when the user invokes /pr-review, asks for a PR review, asks for feedback on changes they just finished, or asks to review only part of a PR such as certain files, directories, or concerns. Covers ticket resolution, target resolution, scoping the review, the review checklist, the output format, and staging the feedback as comments on the PR.
---

# PR Review

`<scratchpad>` is the session's scratchpad directory when Claude Code lists one, and otherwise a
directory outside the repository created with `mktemp -d`.

Review a pull request against its base branch and return prioritized, actionable feedback.

Run this review **inline, in the current session** by default. The point of doing it inline is that
every command and every file examined stays visible, so follow-up questions about how the review was
conducted can be answered. Delegate to the `code-reviewer` agent only when the diff is large enough
to crowd out the rest of the session (roughly 40+ changed files or several thousand changed lines).
A scope narrow enough to fit comfortably in the session is reviewed inline even when the full PR is
large.

Inline and delegated are exclusive. When delegating, do not run a second review pass yourself;
verify the agent's findings after its report is complete, and do it silently. Read
`delegating.md`, next to this file, before delegating.

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

Spec, design, user-story and plan files committed in the PR, such as
`.branch-plans/<branch-name>.md`, are read for intent and never reviewed. Report no finding on them and stage
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
6. **Load the rules before reading the code.** For the files in scope, load every skill the
   checklist names (for test files, the testing skills and any project test-placement skill), and
   read every `CLAUDE.md` on the path from the repository root to each changed file. A checklist
   item that names a skill counts as not applied until that skill is loaded in this session, and
   the review says so under "Files examined". Reading a rule from memory is how a whole category of
   findings goes missing without anyone noticing.
7. **Review every file in scope systematically** using the checklist below. Read surrounding context
   in the files themselves when the diff alone is not enough to judge a change. Test files are
   reviewed in their own right, one test at a time. Reading them only to see what they cover is not
   a review of them.
8. **Compile the feedback**, opening with the "What the PR does" summary and then the three
   severity groups below, written to `<scratchpad>/review-<pr>.md`. That file is the single source the review is published from. It
   ends with a "Files examined / commands run" section listing the skills loaded and the `CLAUDE.md`
   files read, inline reviews included.
9. **Publish the review exactly once**, as a single message carrying the summary and all three
   groups. Never relay a
   partial review: when findings arrive in pieces, accumulate them silently and publish when
   complete.
10. **Stage the findings on the PR**, following the `pr-comments` skill for how each comment is
   written and posted. Drop the `[file:line]` prefix on the way across: the comment is anchored to
   that line already, and a line number written into a comment body rots on the next commit. A
   finding that names no file and line stays in the session review only, and you say which ones
   those were. Never stage a finding an existing thread already raises, answered or not. Point to
   that thread in the session review instead.

## Review Checklist

Never report what GitHub or CI already shows the author, such as a merge conflict or a failing
check. They have to fix it to merge anyway, so a comment on it only adds noise.

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

- The rules loaded in step 6 and the `software-designer-mindset` skill are this checklist. Hold every
  identifier and every file the PR adds or changes against them, tests included. Skimming the rules
  once and then reading the diff for bugs is how a misleading name gets through.
- If a plan or spec file is available, do a functionality gap assessment against it, and anchor
  any gap it reveals to the code. Where the plan conflicts with the ticket, the ticket wins, and the
  plan itself is still not a finding.

### Correctness and quality

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
  - For every branch, guard, or early return the PR adds, name the test that fails when it is
    deleted. If no test fails, that is an **Important** finding, even when a test with the right
    name exists: its setup may never reach the branch.
  - For every input the PR rejects, check which inputs the tests actually send. An error message
    built from the input is checked against its worst input, such as an empty string.

    ```
    Bad   (no finding) a blank-number test exists, so the `if number:` guard is covered
    Good  the only portfolio in the database is the one being imported, so deleting the guard
          leaves the test green. Add a second portfolio that already has a blank number.
    ```

### Data layer

- Database migrations, query efficiency, indexing strategy, and data model design.
- N+1 queries, with a concrete query optimization suggested.

### Observability

- Useful observability on application code. Use the `logging` skill for this.

## Output Format

Below the ticket key and scope, and above every other section, open with what the PR does.

### 🧭 What the PR does

Two or three short paragraphs on **how** the developer built it, written from the code. The reviewer has
already read the ticket, so never restate what the user sees or what the acceptance criteria ask
for. Every sentence should tell the reader something the ticket could not. Answer these at a high
level, skipping any that do not apply:

- **Flow, before and after.** Which client called which endpoint, and what it calls now.
- **Who decides.** Which layer and module owns each new rule (frontend or backend, and where), and
  how the other layers learn the result: a flag in a response, a template variable, a status.
- **Why the new pieces exist.** For each new file, endpoint or module, why the author added it
  instead of extending the existing one.
- **What stays untouched.** Existing paths the change reuses or leaves as they were.

Do not judge here. Findings and caveats belong in the groups below.

```
Bad   Non-IH vendors now accept a job with one confirmed click, and RMs get a plain "Manually
      Confirm" button on the card. IH vendors keep the scheduling flow.
      (restates the acceptance criteria)
Good  The backend owns the IH/non-IH split. `requires_an_appointment` in
      vendor_assignment_helpers.py sends an `appointment_required` flag to the email template, 
      and to the vendor assignment serializer. The frontend never checks the
      vendor type, it only branches on that flag. Before, every accept went through the one legacy
      `vendor-response/` endpoint, whose PATCH branched on the body to tell decline from booking.
      Now a non-IH accept calls a new `PATCH vendor-response/acceptance/` instead.
```

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

Performance, maintainability, and code quality problems that cost something real if left alone:
duplicated logic that must be kept in sync, a test that can pass without exercising its behavior, a
document that misstates shipped behavior. Readability problems belong here too, never under
Suggestions: a name that misstates what it holds, a name this PR made stale, or code with no clear
place to live.

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
- No positives, praise, congratulations, or personal messages. Surface only what needs fixing. The
  "What the PR does" summary is description, not praise, and is the one section that is not a
  finding.
- End with a one or two sentence status summary, for example "3 critical issues to address before
  merge, mostly around input validation and error handling." Never recap every finding.

## Tone

Direct and practical. No praise, no filler. The job is to surface problems and suggest improvements.
Explain why something matters when it is not obvious, but do it in the same one-liner.

Do not narrate the review in progress. The first thing the user sees about the review should be the
review.
