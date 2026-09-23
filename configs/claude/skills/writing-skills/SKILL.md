---
name: writing-skills
description: How to write or edit a skill that stays useful. Triggers when (1) asked to create, write, edit, or add a skill, (2) asked to fix or generalize an existing skill, (3) about to encode a correction or preference so it is not repeated, or (4) reviewing a skill someone else wrote.
---

# Writing Skills

A skill is a standing instruction loaded into a future session that has none of this
conversation's context. It earns its place only if it changes what that session does.

## Write the rule, not the incident

A skill almost always starts life as a correction: something was done wrong, and the fix should
stick. The trap is writing down **the incident** instead of **the rule the incident violated**. An
incident-shaped skill fires once, on the exact case that has already been fixed, and is silent on
every neighbouring case.

Generalise by asking: *what class of decision was made badly?* Then write the rule for that class,
and use the incident only as the worked example.

```
Bad   (incident):  "Expand depth tests go in project_document_view_set/."
Good  (rule):      "A test for cross-cutting behavior lives under the unit it actually calls."
```

The test: if the rule only ever applies to the file that triggered it, it is a code comment, a
CLAUDE.md line, or a ticket — not a skill.

## Keep it general, but keep it falsifiable

Generalising too far is the opposite failure. "Write clean tests" is unfalsifiable: no future
session can tell whether it complied. A good rule names the decision point, gives the default, and
shows the shape of a violation.

Every rule should let a reader answer *"does what I am about to do break this?"* without judgement
calls.

## Structure

- **Frontmatter.** `name` is the directory name. `description` decides whether the skill loads at
  all, so write it as concrete triggers — the situations, in the words someone would actually use —
  not a summary of the contents.
- **Lead with the rule.** The first screen should carry the load. Rationale comes after the rule,
  in a sentence or two, and only where a reader who disagrees would otherwise ignore it.
- **Short.** No one reads 200 lines. Cut anything the tooling already enforces — a linter, a type
  checker, or a failing test is a better teacher than a paragraph.
- **Examples in pairs.** One wrong, one right, minimal, directly comparable. The pair does more
  work than the prose around it.
- **Say what is out of scope.** Name the sibling skills that own adjacent ground and defer to them
  rather than restating their content, which will drift.

## Make it composable

Skills are loaded together, so they must not contradict each other or duplicate ground. Before
writing, check what already exists: extend the closest skill rather than adding a near-duplicate,
and if a rule belongs to a broader skill, put it there instead.

Layer general to specific — a language-agnostic skill, then a language skill, then a
framework skill — and have each one defer upward rather than repeating.

## Where it goes

Put a skill where its scope is. A rule about one repository belongs in that repository
(`.claude/skills/`); a rule that would hold in any project using the same language or framework
belongs with the user's global skills (`~/.claude/skills/`). When in doubt, ask — a
project-specific rule promoted to global will misfire in every other project.

## What does not belong in a skill

- Anything that will change on its own schedule: version numbers, quotas, worker counts, current
  state of a deployment. It rots silently and is then worse than nothing.
- TODOs, "we should…", or opinions about work someone intends to do. Those belong in a ticket,
  where they can be closed.
- Symbols the code may rename. Describe the behavior; name a symbol only where the reader needs it
  to navigate.
- A restatement of another skill.

## Before you save

1. Does the rule apply to cases beyond the one that prompted it?
2. Can a reader tell whether they are violating it, without asking anyone?
3. Would this change what a future session does — or is it already obvious from the code?
4. Do the triggers in `description` match how someone would actually phrase the request?
5. Is it short enough to be read in full?
