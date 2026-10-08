---
name: create-pr
description: Open a pull request, and keep every pull request at 40 changed files or fewer. Use when asked to create, open or push a PR, when planning or starting a change, and before any rename, move, reformat or migration that spreads across many files. Covers estimating a change's size before writing it, stopping to propose a split into several PRs, and committing, pushing and opening each PR.
---

# Create PR

**A pull request changes 40 files or fewer.** A change that will cross 40 is stopped before it is
written, and the user is shown a split into several PRs. A reviewer cannot hold 200 files in their
head, so a big PR gets skimmed and approved instead of reviewed, and anything that goes wrong in it
is harder to revert.

## 1. Estimate the size before writing code

Run this check when a change is being planned, not when its PR is opened. Once the files exist, the
only option left is to split code that was never designed to be split.

Count the files the change will touch. A rename is the usual cause of a big change, because one
symbol reaches every caller, test and doc: `grep -rlw <symbol> .` counts them before anything is
edited. Add the files the new logic, the tests and the docs need.

- Bad: renaming a model, its foreign keys, its endpoint and the frontend API layer in the same PR
  as the new behaviour. The renames alone touch 150 files and hide the 30 that matter.
- Good: PR 1 does only the renames. PR 2, based on PR 1, adds the behaviour in 30 files the
  reviewer reads closely.

## 2. Over 40: stop and propose a split

Do not start writing. Tell the user the estimated count and propose one PR per kind of change, in
this order, with the files each one holds:

1. **Renames and moves.** No behaviour changes, so the reviewer only checks that names line up.
2. **Formatting and lint fixes.** No behaviour changes.
3. **New logic** with its tests and docs.
4. **Removing what the new logic replaced**: deprecated fields, columns, endpoints.

Each PR must pass CI and be safe to merge on its own. A PR that needs the previous one is opened
against that one's branch, so its diff shows only its own files. When one kind of change is still
over 40 files by itself, split it by area (backend and frontend, or one module at a time).

The user decides. When they choose to keep one PR anyway, say once that it is over the limit and
continue.

## 3. Before opening: count again

`git diff --name-only <base>...HEAD` plus the files about to be committed. Over 40, stop, show the
count and a proposed split built from the files in that diff, and wait for the user's answer before
pushing.

## 4. Commit, push, open

When the project has its own PR skill or a `.github/pull_request_template.md`, follow it for the
commit message, the branch name and the PR body. This skill only adds the size rule. Otherwise:

- Stage files by path, `git add <path> <path>`. Never `.`, `-A`, `-u` or `commit -a`. Leave out
  files that are not part of this change and list them in the report.
- Never push to `main`, `master` or `staging`. Push the feature branch with
  `git push -u origin <branch>`, and never use `--force`.
- Base the PR on the repo's default branch, or on the previous PR's branch for a stacked split.
- Write a short body: what changed and why in two to four sentences, then how to test it. Write it
  to a temporary file and run `gh pr create --base <base> --title "<title>" --body-file <file>`.

Report the PR URL, its base and its file count.

Leaving review comments on a PR belongs to `sc-workflow:pr-comments`.
