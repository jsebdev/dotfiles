# Delegating a review

Hand the `code-reviewer` agent the ticket's acceptance criteria and the decisions recorded in its
comments verbatim, along with the PR threads sorted by step 3. Pass on any scope the user asked for,
and require a "Files examined / commands run" section so procedural questions remain answerable.

Require the agent to write its complete review to `<scratchpad>/review-<pr>.md` and return only that
path and a one-line status. Read the file and publish from it. A subagent result payload is
size-capped and truncates silently mid-item, so it must never carry the review itself.

If a report arrives truncated anyway, do not relay it and do not request it piecemeal. Re-request it
as a file. If that truncates too, abandon delegation and review the remaining scope inline.
