---
name: create-jira-ticket
description: Write and create one or more NEW Jira tickets with a structured user story format, or a bug report format for bugs. Use ONLY when the user wants to CREATE or WRITE new Jira tickets, user stories, bug reports, or requirements. Do NOT use for reading, fetching, viewing, or looking up existing Jira tickets.
---

# Write Jira Tickets

Write and create Jira tickets for $ARGUMENTS.

## Steps

### 1. Gather Session Context

Ask once at the start (unless already clear from the arguments):
- What project and epic should the tickets belong to?

This applies to all tickets in the session. Do not re-ask per ticket unless the user changes it.

### 2. Draft Tickets

For each ticket the user wants to create, draft a title and description. Use exactly this format, unless the ticket is a bug:

**Title**: A short, active-voice summary (e.g. "Allow users to export reports as CSV")

**Description**:
```
As a [user role], I want to [goal] so that [reason].

Acceptance Criteria:
1. [First acceptance criterion]
2. [Second acceptance criterion]
...

Notes:
- [additional note or context]
```

When the ticket reports a bug, use this format instead. It must stay as concise as a user story ticket:

**Title**: A short summary of the broken behavior (e.g. "CSV export drops rows with empty dates")

**Description**:
```
Actual Behavior:
[What happens now]

Expected Behavior:
[What should happen]

Steps to Reproduce:
1. [First step]
2. [Second step]
...

Environment:
- [Where it happens, e.g. production, staging, browser, app version]
```

If the user provides multiple ideas at once, draft all of them before asking for review. Present them numbered so they are easy to reference.

### 3. Iterate

Ask the user if they want to adjust any of the drafts. Reference tickets by number (e.g. "ticket 2"). Do not push any ticket to Jira until the user explicitly approves it.

After approval, ask: "Do you have more tickets to add?" Continue drafting and iterating until the user is done.

### 4. Create in Jira

For each approved ticket, use the Atlassian MCP to create it with:
- The approved title as the summary
- The formatted description
- The correct project and epic
- The Bug issue type for bug tickets

Confirm the created ticket key and URL for each one. If creating multiple, create them in the order they were approved and list all keys at the end.

## Guidelines

See @~/.claude/skills/shared/jira-guidelines.md for shared standards.

- Bug tickets have no user story sentence and no acceptance criteria. Keep each section to the facts needed to reproduce and verify the fix. If the environment is unknown, ask rather than guess.
- The user story sentence must follow "As a / I want / so that" exactly — no variations.
- Notes are optional. Only include them if there is genuinely useful context that does not fit in the acceptance criteria. Avoid adding notes as much as possible, they should be the exception, not the norm.
- If the user's idea is too broad for a single ticket, flag it and suggest splitting before drafting.
- Tickets should be as small as possible while still delivering independent value. If in doubt, suggest splitting.
- When drafting a set of related tickets, each AC must belong strictly to the ticket it lives in. Before finalising, scan every AC and ask: "Is this something that gets done *in this ticket*, or is it a side-effect / prerequisite of another ticket?" If it belongs elsewhere, move it there or convert it to a Note with a reference to the owning ticket (e.g. "Handled in PEB-123"). A common mistake is adding an AC that describes triggering or depending on work in a linked ticket — that is a Note, not an AC.

