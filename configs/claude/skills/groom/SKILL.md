# Groom Story

Groom the Jira story $ARGUMENTS for implementation readiness.  You are helping
an engineer prepare this story, potentially during a conversation with a
stakeholder. Be conversational and focused.

## Steps

### 1. Load Context
- Fetch the story from Jira using Atlassian MCP
- Fetch all stories in the same epic (if any)
- Fetch stories linked via Jira links (blocks, is-blocked-by, relates-to)
- Note the story's current acceptance criteria, description, and any comments

### 2. Analyze
Evaluate the story against these dimensions. Do NOT present all of these as a
checklist. Only raise items that are genuinely problematic or missing. Group
your findings naturally.

**Ambiguity**
- Are there terms used without clear definition?
- Are there conditional behaviors where the condition isn't fully specified?
  ("if the user has access" — what defines access?)
- Are there implicit assumptions about state, ordering, or environment?

**Edge Cases**
- What happens at boundaries? (empty lists, max values, zero quantities,
  concurrent access)
- What are the failure modes? (network failures, partial completion, invalid
  input)
- What about timing? (race conditions, timeouts, retries)
- What about permissions/roles if applicable?

**Contradictions**
- Does this story conflict with any related story in the same epic or linked
  stories?
- Does it contradict acceptance criteria in other stories?
- Are there implicit assumptions that conflict with established patterns?

**Scope**
- Is this story small enough to implement in a single sprint? If not, suggest
  how to split it into smaller stories that each deliver value independently.
- Are there acceptance criteria that belong in a separate story?
- Is there a clear "done" state?

### 3. Present Findings
Present your analysis conversationally. Lead with the most important issues.
For each finding:
- State the issue clearly
- Explain why it matters (what could go wrong)
- Suggest specific language for the fix

Ask the engineer to confirm, modify, or dismiss each finding before moving on.
Do not rush through everything at once. Pause after presenting 2-3 findings and
wait for feedback.

### 4. Draft Updates
Once the engineer has confirmed which changes to make, draft the updated story:
- Updated description (if changed)
- Updated acceptance criteria
- New edge case acceptance criteria
- Any suggested story splits as separate story drafts

Present the full updated text for review. Mark what changed clearly so the
engineer can review diffs mentally.

### 5. Push to Jira
Only after explicit engineer approval:
- Update the story description and acceptance criteria in Jira
- If splitting, create new stories in the same epic with appropriate links
- Add a comment on the original story summarizing what was changed and why

If the engineer wants to make further adjustments,
iterate before pushing.

## Guidelines

See @~/.claude/skills/shared/jira-guidelines.md for shared standards.

- Be opinionated about completeness but defer to the engineer's judgment on scope.
- If the story references domain concepts you don't understand, ask rather than assume.
- When suggesting acceptance criteria, use the format already established in the story. Match the team's style.
