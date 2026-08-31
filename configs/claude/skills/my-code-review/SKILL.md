---
name: my-code-review
description: Review a pull request against its base branch and return severity-grouped, actionable feedback following my project conventions. Use when the user invokes /my-code-review, asks for a PR review, or asks for feedback on changes they just finished. Covers target resolution, the review checklist, the output format, and when to post feedback to GitHub.
---

# My Code Review

Review a pull request against its base branch and return prioritized, actionable feedback.

Run this review **inline, in the current session** by default. The point of doing it inline is that
every command and every file examined stays visible, so follow-up questions about how the review was
conducted can be answered. Delegate to the `code-reviewer` agent only when the diff is large enough
to crowd out the rest of the session (roughly 40+ changed files or several thousand changed lines).
When delegating, require the agent to include a "Files examined / commands run" section in its
report so procedural questions remain answerable.

## Arguments

Arguments may contain a PR number, a branch name, and the `--post` flag. All are optional.

## Steps

1. **Resolve the target PR**
   - A PR number in the arguments wins.
   - A branch name in the arguments resolves with `gh pr view <branch> --json number,title,baseRefName`.
   - Otherwise resolve the PR for the current branch with `gh pr view --json number,title,baseRefName`.
   - If no PR is found, ask the user for the PR number and stop.
2. **Fetch the changes** against the base branch with `gh pr diff` and `gh pr view`. Review only what
   this PR introduced, never pre-existing code on the base branch.
3. **Review every changed file systematically** using the checklist below. Read surrounding context
   in the files themselves when the diff alone is not enough to judge a change.
4. **Compile the feedback** into the three severity groups below.
5. **Return the feedback in the conversation.** Post to GitHub only when the arguments include
   `--post` or the user explicitly asks for it, and then as **one single** `gh pr comment` containing
   the whole review. Never post multiple comments, inline comments, or per-file comments.

## Review Checklist

### Design and conventions

- Best practices for the language and framework in use.
- Reusability and extensibility problems the change is setting up for later. Use the
  `software-designer-mindset` skill for this.
- Self-documenting code: meaningful names over comments and docstrings, complex logic extracted into
  well-named functions rather than explained in a comment.
- No abbreviations or acronyms in names.
- If a plan file is available, do a functionality gap assessment against it.

### Correctness and quality

- Security vulnerabilities and potential exploits.
- Performance bottlenecks and inefficient algorithms.
- Code duplication and refactoring opportunities.
- Error handling and edge case coverage.
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

Organize all feedback as a flat list under exactly these three groups:

### 🔴 Critical (must fix)

Bugs, security vulnerabilities, data loss, broken functionality.

- **[file:line]** — the issue and what to do instead

### 🟡 Important (should fix)

Performance, maintainability, code quality, deviations from project conventions.

- **[file:line]** — the issue and what to do instead

### 🟢 Suggestions (nice to have)

Minor improvements, style preferences, alternative approaches worth considering.

- **[file:line]** — the suggestion and the reasoning behind it

Rules:

- One or two sentences per item, maximum. The file path, affected lines, and the suggested fix are
  sufficient. No elaboration blocks.
- Always include the file path and line number or range when applicable.
- Give the fix inline, in the same item.
- Write "None" under a group that has no items.
- Prefix an uncertain recommendation with **[Question]** to flag it for discussion.
- No positives, praise, congratulations, or personal messages. Surface only what needs fixing.
- End with a one or two sentence status summary, for example "3 critical issues to address before
  merge, mostly around input validation and error handling." Never recap every finding.

## Tone

Direct and practical. No praise, no filler. The job is to surface problems and suggest improvements.
Explain why something matters when it is not obvious, but do it in the same one-liner.
