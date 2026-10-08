---
name: implement
description: Professional feature and bug fix implementation workflow for git repositories. Runs only when the developer types /sc-workflow:implement. Ensures code quality through planning, implementation, testing, and review cycles.
disable-model-invocation: true
---

# Implementation Workflow

Follow this systematic approach to implement features or bug fixes professionally.

## Prerequisites

- The GitHub CLI, authenticated with `gh auth login`
- A Jira MCP server connected for the project's Jira site, and a Jira ticket for the change

## 1. Ticket and Branch

- Take the ticket key from the developer's request, or ask for it
- Read the ticket together with its comments through the Jira MCP server whose site matches the ticket: `getJiraIssue` with `comment` in `fields`
- **Stop** when the ticket cannot be read: say what was tried and how it failed, and ask the developer for the key or a paste of the ticket with its comments
- An answer recorded in a ticket comment outranks the description and the developer's request
- Put the ticket key in the branch name, so the reviews in steps 7 and 9 find the ticket
- Name the branch by the project's branch naming rule if the project has one
- Otherwise create `feature/<descriptive-name>` or `bugfix/<descriptive-name>` in kebab-case (e.g., `feature/add-user-authentication`)
- **Critical**: Never modify code directly on `test`, `stage`, `staging`, `main`, or `master` branches

## 2. Planning Phase

- Invoke the built-in **`Plan` agent** to create an implementation plan, handing it the ticket's acceptance criteria and the decisions recorded in its comments verbatim
- The plan covers every acceptance criterion, and says which criteria it leaves out and why
- Save plan to `.branch-plans/<branch-name>.md`
- Estimate the files the plan touches and apply the size rule in the `sc-workflow:create-pr` skill before implementing
- **Always ask clarifying questions** when multiple valid approaches exist:
  - Architecture decisions
  - Technology choices
  - Trade-offs between approaches
- Wait for user approval if significant architectural decisions are involved

## 3. Implementation

- Invoke the **`sc-workflow:code-writer` agent** with the plan file path
- Ensure implementation follows the approved plan
- Maintain consistency with existing codebase patterns and conventions

## 4. Testing & Validation

- Run the project's **complete test suite**
- Run linters checks
- Run formatters checks
- Verify all tests pass
- Address any failures or errors before proceeding
- If new functionality is added, confirm adequate test coverage exists

## 5. Commit Changes

- Stage **only relevant files** for the implementation
- **Never use** `git add .`
- Explicitly add files: `git add <file1> <file2> ...`
- Write clear, descriptive commit messages following conventional commits format when applicable
- Commit structure: `<type>: <concise description>`

## 6. Pull Request Creation

- Load the `sc-workflow:create-pr` skill first: a PR over 40 changed files is stopped and split
- Create PR using: `gh pr create --draft`
- Use the project branch naming convention for the PR title if the project has one
- Otherwise, use the convention: `<user>/<branch-name>`
- Use the project's PR template if it has one
- Otherwise, use the following template for the PR description:

```
  ## Summary
  [1-2 sentence summary of changes]

  ## Test Plan
  [Concise steps to verify the implementation]
```

- Keep descriptions concise and actionable
- **Strictly forbidden**: `git push` to `test`, `stage`, `staging`, `main`, or `master` branches

## 7. Initial Code Review (Internal)

- Invoke the **`sc-workflow:code-reviewer` agent** for initial feedback
- Tell the agent not to stage its findings on the PR: they stay in the session
- Review suggestions with focus on:
  - Code quality and maintainability
  - Adherence to project conventions
  - Potential bugs or edge cases
  - Performance considerations
- **Wait for review completion** before proceeding

## 8. Address Review Feedback

- Invoke the **`sc-workflow:code-writer` agent** to implement review suggestions
- Commit fixes with clear messages referencing review feedback
- Push changes to the branch
- Ensure all feedback is addressed
- Request a new internal review (step 7) until no more critical feedback is given or up to a maximum of 3 internal reviews. whatever condition is met first continue to the final code review step.

## 9. Final Code Review (GitHub)

- Invoke the **`sc-workflow:code-reviewer` agent** for final review
- **Push review comments to the GitHub PR**
- Comments should be constructive and specific
- **Do not auto-address these comments** - they are for user visibility
- This is the final automated review in the workflow

## 10. User Review & Approval

- Notify user that PR is ready for review
- List every Critical finding still open after the last internal review, with the file and line it points to
- **Wait for user approval** before any merge actions
- Address any additional user feedback as requested

---

## Key Principles

- **Quality over speed**: Each step ensures professional standards
- **Clear communication**: Ask questions early, document decisions
- **Incremental validation**: Test and review at multiple stages
- **Explicit actions**: Never use wildcards or shortcuts that could introduce unintended changes
- **Separation of concerns**: Internal review before external visibility

## Common Pitfalls to Avoid

- ❌ Skipping the planning phase for "simple" changes
- ❌ Using `git add .` (always specify files explicitly)
- ❌ Pushing directly to protected branches
- ❌ Proceeding past step 7 before review completion
- ❌ Auto-addressing final review comments (step 9)
- ❌ Verbose PR descriptions (keep them concise and scannable)
