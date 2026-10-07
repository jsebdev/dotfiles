---
name: hypothetical-steps
description: Explain a problem, review comment, bug report, risk or idea as a numbered sequence of concrete steps, from the triggering event to the visible outcome, checked against the real code. Use when the user invokes /hypothetical-steps, asks for "hypothetical steps", "the steps that would break this", "walk me through how this happens", "what is the scenario", "how could this fail", or says they don't understand how a described problem would actually occur.
---

# Hypothetical Steps

The user has a claim they can't picture yet: a reviewer's comment, a risk, a bug, a proposal. Turn
it into the chain of events that makes it true, one step at a time, so they can judge it.
`$ARGUMENTS` is the claim. If it is empty, use the claim most recently discussed in the
conversation.

## Rules

- **Check every step before you write it.** Read the code, configs, workflows and branches each
  step depends on. When the problem involves what is running in production, read the deployed
  branch, not the working tree. If a step can't be checked (prod data, runtime timing), say so
  inside that step. If checking shows the claim is false, say where the chain breaks and stop.
  Never make up a step to fill a gap.
- **One actor, one action, one state change per step, in time order.** Start at the event that
  begins the chain (a deploy, a request, a user action, a scheduled job) and end at what someone
  actually sees or loses.
- **Name the exact thing that changes, and give it concrete values.** "The link is gone" makes the
  reader ask what link. "Settlement 42's `claim_settlement_id` goes from 7 to NULL" does not. Use
  made-up ids and values when they make the step easier to follow.
- **Cite the line that does it**, as `path:line`, on any step where code acts.
- **When two versions of the code run at once, name each one** (old release / new release, web /
  worker) at the top, and say in every step which one acts.

```
Bad:   6. The sync signal breaks the link.
Good:  6. Old `post_save` (`signals/settlement/sync_claim_settlement_signal.py:46`) sees
          type == company_fund and writes `claim_settlement_id = NULL` on settlement 42.
```

## Output

1. One line saying what the actors and versions are, when that is needed.
2. The numbered steps. Usually 5 to 10. Merge steps that change nothing the reader cares about.
3. **What has to line up**: the conditions that must all be true, and how likely that makes it.
   It is often "possible", not "certain".
4. **What stays safe**: the nearby cases that do not break, and why, in one or two lines.
5. One sentence on what this means for the decision the user is facing. No fix plan unless asked.

For an idea or proposal, the steps describe how it plays out from the first action to the outcome,
and step 3 becomes the assumptions it depends on.

Answer in chat. Keep it short enough to read in one go.

## Out of scope

- Suggesting simpler alternatives: `point-me-in-the-right-direction`.
- Reviewing a whole change: `pr-review` or `code-review`.
