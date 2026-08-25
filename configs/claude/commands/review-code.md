---
description: Review a pull request with the code-reviewer agent
argument-hint: "[PR number | branch | --post]"
---

Review a pull request using the `code-reviewer` agent.

Arguments: $ARGUMENTS

## Steps

1. Determine the target PR:
   - If the arguments contain a PR number or a branch name, use it.
   - Otherwise resolve the PR for the current branch with `gh pr view --json number,title,baseRefName`.
   - If no PR is found, ask the user for the PR number and stop.
2. Launch the `code-reviewer` agent with the Task tool, passing the PR number and the base branch.
3. Tell the agent to post its feedback as one single `gh pr comment` only when the arguments include `--post`. Otherwise it must return the feedback in the conversation without touching GitHub.
4. Relay the agent's severity-grouped feedback back to the user.
