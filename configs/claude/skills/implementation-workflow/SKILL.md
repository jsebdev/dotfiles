---
name: implementation-workflow
description: Professional feature and bug fix implementation workflow for git repositories. Use when user requests to implement features, fix bugs, or explicitly requests this workflow. Ensures code quality through planning, implementation, testing, and review cycles.
---

# Implementation Workflow

Follow this systematic approach to implement features or bug fixes professionally:

## 1. Branch Creation

- Create a new branch: `feature/<descriptive-name>` or `bugfix/<descriptive-name>`
- **Critical**: Never modify code directly on `staging`, `main`, or `master` branches
- Use kebab-case for branch names (e.g., `feature/add-user-authentication`)

## 2. Planning Phase

- Invoke the **plan agent** to create an implementation plan
- Save plan to `.branch-plans/<branch-name>.md`
- **Always ask clarifying questions** when multiple valid approaches exist:
  - Architecture decisions
  - Technology choices
  - Trade-offs between approaches
- Commit the plan file before proceeding
- Wait for user approval if significant architectural decisions are involved

## 3. Implementation

- Invoke the **code-writer agent** with the plan file path
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

- Create PR using: `gh pr create`
- **Naming convention**: `Andres/feature/<descriptive-name>` or `Andres/bugfix/<descriptive-name>`
- **PR Description format**:

```
  ## Summary
  [1-2 sentence summary of changes]

  ## Test Plan
  [Concise steps to verify the implementation]
```

- Keep descriptions concise and actionable
- **Strictly forbidden**: `git push` to `staging`, `main`, or `master` branches

## 7. Initial Code Review (Internal)

- Invoke the **code-reviewer agent** for initial feedback
- **Do not push comments to GitHub yet**
- Review suggestions with focus on:
  - Code quality and maintainability
  - Adherence to project conventions
  - Potential bugs or edge cases
  - Performance considerations
- **Wait for review completion** before proceeding

## 8. Address Review Feedback

- Invoke the **code-writer agent** to implement review suggestions
- Commit fixes with clear messages referencing review feedback
- Push changes to the branch
- Ensure all feedback is addressed
- Request a new internal review (step 7) until no more critical feedback is given or up to a maximum of 3 internal reviews. whatever condition is met first continue to the final code review step.

## 9. Final Code Review (GitHub)

- Invoke the **code-reviewer agent** for final review
- **Push review comments to the GitHub PR**
- Comments should be constructive and specific
- **Do not auto-address these comments** - they are for user visibility
- This is the final automated review in the workflow

## 10. User Review & Approval

- Notify user that PR is ready for review
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
